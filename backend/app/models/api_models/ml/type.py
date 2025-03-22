import torch
import torch.nn as nn

input = 16 * 3 * 3
output = 5


class Type(nn.Module):
    def __init__(self, input, output):
        super(Type, self).__init__()
        self.cnn1 = nn.Conv2d(
            in_channels=3, out_channels=8, kernel_size=2, padding=1, stride=2
        )
        self.cnn2 = nn.Conv2d(
            in_channels=8, out_channels=16, kernel_size=2, padding=1, stride=2
        )
        self.pooling = nn.MaxPool2d(kernel_size=2, padding=1, stride=2)
        self.flat = lambda x: x.view(-1, 16 * 3 * 3)
        self.lay1 = nn.Linear(input, input * 2)
        self.lay2 = nn.Linear(input * 2, input * 2)
        self.out = nn.Linear(input * 2, output)

    def forward(self, x):
        x = torch.relu(self.pooling(self.cnn1(x)))
        x = torch.relu(self.pooling(self.cnn2(x)))
        x = self.flat(x=x)
        x = torch.relu(self.lay1(x))
        x = torch.relu(self.lay2(x))
        x = self.out(x)
        return x
