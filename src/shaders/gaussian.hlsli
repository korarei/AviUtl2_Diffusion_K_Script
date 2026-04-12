// 後で合計値除算をするため係数は省略
// f は -1 / (2 * sigma * sigma)
inline float
gaussian(float x, float f) {
    return exp(x * x * f);
}
