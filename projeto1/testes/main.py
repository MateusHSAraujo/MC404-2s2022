with open("usar","w") as f:
    for i in range(50):
        f.write("csrrw a0, "+str(i)+", a1\n")
