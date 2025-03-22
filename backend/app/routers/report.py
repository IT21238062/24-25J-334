import base64
import io
import os
from datetime import datetime

from fastapi import APIRouter, HTTPException
from fastapi.responses import FileResponse, JSONResponse
from reportlab.lib import colors
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import ParagraphStyle, getSampleStyleSheet
from reportlab.lib.units import inch
from reportlab.pdfgen import canvas
from reportlab.platypus import Paragraph, SimpleDocTemplate, Spacer, Table, TableStyle

from app.controllers.prediction_controller import predict_crop_controller
from app.models.api_models.predict_crop import PredictCrop
from app.services.db_services import get_sensor_data

router = APIRouter()


@router.get("/crop-prediction/download-report")
def get_report():
    """
    Generate and return a PDF report for crop prediction.
    The report can be returned in two formats:
    1. As a direct file download
    2. As a base64 encoded string in the response JSON
    """
    try:
        # Create a directory for reports if it doesn't exist
        os.makedirs("reports", exist_ok=True)

        # Generate a unique filename with timestamp
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        filename = f"crop_report_{timestamp}.pdf"
        filepath = os.path.join("data", filename)

        # Get sensor data
        sensor_data = get_sensor_data()

        # Generate the PDF report
        generate_crop_report(filepath, sensor_data)

        # Return the file for download
        return FileResponse(
            path=filepath,
            filename=filename,
            media_type="application/pdf",
            headers={"Content-Disposition": f"attachment; filename={filename}"},
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error generating report: {str(e)}"
        )


@router.get("/crop-prediction/download-report-base64")
def get_report_base64():
    """
    Generate and return a PDF report for crop prediction as base64 encoded string.
    This endpoint is useful for mobile apps that need to handle the PDF data directly.
    """
    try:
        # Create a buffer to store the PDF
        buffer = io.BytesIO()

        # Get sensor data
        sensor_data = get_sensor_data()

        # Generate the PDF report in memory
        generate_crop_report(buffer, sensor_data)

        # Get the PDF data as base64
        buffer.seek(0)
        pdf_data = buffer.getvalue()
        base64_pdf = base64.b64encode(pdf_data).decode("utf-8")

        # Return the base64 encoded PDF
        return JSONResponse(
            content={
                "status": "success",
                "message": "Report generated successfully",
                "data": {"report": f"data:application/pdf;base64,{base64_pdf}"},
            }
        )
    except Exception as e:
        raise HTTPException(
            status_code=500, detail=f"Error generating report: {str(e)}"
        )


def generate_crop_report(output, sensor_data):
    """
    Generate a PDF report with crop prediction and sensor data.

    Args:
        output: Can be a file path string or a file-like object (BytesIO)
        sensor_data: Dictionary containing sensor data
    """
    # Create the PDF document
    doc = SimpleDocTemplate(output, pagesize=letter)
    styles = getSampleStyleSheet()

    # Create custom styles
    title_style = ParagraphStyle(
        "Title",
        parent=styles["Heading1"],
        fontSize=18,
        alignment=1,  # Center alignment
        spaceAfter=12,
    )

    subtitle_style = ParagraphStyle(
        "Subtitle", parent=styles["Heading2"], fontSize=14, spaceAfter=10
    )

    # Create the content elements
    elements = []

    # Add title
    elements.append(Paragraph("Crop Prediction Report", title_style))
    elements.append(Spacer(1, 0.25 * inch))

    # Add date
    date_str = datetime.now().strftime("%B %d, %Y %H:%M:%S")
    elements.append(Paragraph(f"Generated on: {date_str}", styles["Normal"]))
    elements.append(Spacer(1, 0.25 * inch))

    # Add historical predictions section from CSV
    elements.append(Paragraph("Historical Crop Predictions", subtitle_style))
    elements.append(Spacer(1, 0.1 * inch))

    # Read the CSV file with historical predictions
    csv_path = os.path.join("data/predictions", "crop_predictions.csv")
    if os.path.exists(csv_path):
        import csv

        # Read the CSV file
        with open(csv_path, "r") as csvfile:
            reader = csv.reader(csvfile)
            headers = next(reader)  # Get the headers

            # Create table data with headers
            history_table_data = [headers]

            # Add up to 10 most recent entries (in reverse order)
            rows = list(reader)
            for row in rows[-10:]:  # Get last 10 rows
                history_table_data.append(row)

            # Calculate column widths based on content
            col_widths = [1.2 * inch]  # Timestamp column
            col_widths.extend([0.6 * inch] * 7)  # N, P, K, Temp, Humidity, pH, Rainfall
            col_widths.append(1.2 * inch)  # Predicted Crop

            # Create the table
            history_table = Table(history_table_data, colWidths=col_widths)
            history_table.setStyle(
                TableStyle(
                    [
                        ("BACKGROUND", (0, 0), (-1, 0), colors.lightblue),
                        ("TEXTCOLOR", (0, 0), (-1, 0), colors.black),
                        ("ALIGN", (0, 0), (-1, 0), "CENTER"),
                        ("FONTNAME", (0, 0), (-1, 0), "Helvetica-Bold"),
                        ("FONTSIZE", (0, 0), (-1, -1), 8),  # Smaller font for the table
                        ("BOTTOMPADDING", (0, 0), (-1, 0), 8),
                        ("BACKGROUND", (0, 1), (-1, -1), colors.white),
                        ("GRID", (0, 0), (-1, -1), 1, colors.black),
                        ("VALIGN", (0, 0), (-1, -1), "MIDDLE"),
                        ("ALIGN", (0, 0), (-1, -1), "CENTER"),
                    ]
                )
            )

            elements.append(history_table)
    else:
        elements.append(
            Paragraph("No historical prediction data available.", styles["Normal"])
        )

    elements.append(Spacer(1, 0.25 * inch))

    # # Add recommendations section
    # elements.append(Paragraph("Recommendations", subtitle_style))
    # elements.append(
    #     Paragraph(
    #         "Based on the sensor data and crop prediction, here are some recommendations:",
    #         styles["Normal"],
    #     )
    # )
    # elements.append(Spacer(1, 0.1 * inch))

    # # Add some generic recommendations
    # recommendations = [
    #     "Ensure proper irrigation based on soil moisture levels.",
    #     "Monitor soil temperature for optimal growth conditions.",
    #     "Adjust fertilization based on NPK levels in the soil.",
    #     "Consider weather conditions for planting and harvesting decisions.",
    # ]

    # for rec in recommendations:
    #     elements.append(Paragraph(f"• {rec}", styles["Normal"]))
    #     elements.append(Spacer(1, 0.05 * inch))

    # Build the PDF
    doc.build(elements)
