def add(x,y):
    print("ADDING %d + %d" % (x,y))
    print(x + y)

def subtract(x, y):
    print("SUBTRACTING %d - %d" % (x, y))
    return x - y

def multiply(x, y):
    print("MULTIPLYING %d * %d" % (x, y))
    return x * y

def divide(x, y):
    print("DIVIDING %d / %d" % (x, y))
    return x / y
print("1= ADDITION")
print("2= SUBTRACTION")
print("3= MULTIPLICATION")
print("4= DIVISION")
print("5= EXIT")
Option=input("Choose what operation you want to do")
print("Enter two numbers for processing:")
a, b = int(input()), int(input())
if Option=='1':
    add(a,b)
elif Option=='2':
    subtract(a,b)
elif Option=='3':
    multiply(a,b)
elif Option=='4':
    divide(a,b)
elif Option=='5':
    exit;
