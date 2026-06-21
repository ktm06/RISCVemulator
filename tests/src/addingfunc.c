int add(int i, int j) {
    return i + j;
}

int main() {
    int k = 3;
    int a = add(k, 5);
    int b = add(a, a);
    return b;
}