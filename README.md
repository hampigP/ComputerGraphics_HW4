# ComputerGraphics_HW4
[DEMO Video](https://youtu.be/c4PfvD8k2qo)


## Perspective-Correct Barycentric Coordinates

在 renderer pipeline 中，發現在插值某些屬性 (例如 position、normal、顏色)時，如果只做一般的 barycentric 插值 (affine interpolation) 會出現透視錯誤，例如亮度不平均或是貼圖變形。原因是透視投影破壞了線性插值的特質，必須做透視校正才能正確插值。

我在 `util` 的 `barycentric()` 函式中實作：

1. 先計算螢幕空間的 barycentric weights （α/β/γ）
2. 分別除以頂點的 clip-space sw
3. 再正規化

這樣可以確保 barycentric weights 在透視投影下能被正確插值，避免 shading 顏色錯誤。

以下是主要實作片段：

```
float[] barycentric(Vector3 P, Vector4[] verts) {
    Vector3 A = verts[0].homogenized();
    Vector3 B = verts[1].homogenized();
    Vector3 C = verts[2].homogenized();

    Vector4 AW = verts[0];
    Vector4 BW = verts[1];
    Vector4 CW = verts[2];

    float denom = (B.y - C.y)*(A.x - C.x) + (C.x - B.x)*(A.y - C.y);
    float alpha = ((B.y - C.y)*(P.x - C.x) + (C.x - B.x)*(P.y - C.y)) / denom;
    float beta  = ((C.y - A.y)*(P.x - C.x) + (A.x - C.x)*(P.y - C.y)) / denom;
    float gamma = 1 - alpha - beta;

    float alpha_p = alpha / AW.w;
    float beta_p  = beta  / BW.w;
    float gamma_p = gamma / CW.w;

    float sum = alpha_p + beta_p + gamma_p;
    alpha_p /= sum; beta_p /= sum; gamma_p /= sum;

    return new float[]{alpha_p, beta_p, gamma_p};
}
```

## Phong Shading (Fragment Shader)

在 Phong shading 中，將光照放在 fragment shader 計算，以達到更精細的光照效果。

Phong 模型由三部分組成：

1. Ambient
2. Diffuse
3. Specular

光源以點光源為主，因此光照方向是透過「光源位置 - fragment 世界座標」來計算，而不是使用不存在的 `direction`

在實作中我遇到的情況：

1. `Vector3.normalize()` 回傳 `void` ，因此必須先複製再 normalize
2. `Vector3.mult()` 只支援 float multiplication，因此環境光使用分量相乘

以下是 shading 程式碼：

```
Vector3 N = w_normal.copy(); N.normalize();
Vector3 L = Vector3.sub(light.transform.position, w_position); L.normalize();
Vector3 V = Vector3.sub(cam.transform.position, w_position); V.normalize();

Vector3 Ia = new Vector3(
    albedo.x * AMBIENT_LIGHT.x,
    albedo.y * AMBIENT_LIGHT.y,
    albedo.z * AMBIENT_LIGHT.z
);

float ndotl = max(0.0, Vector3.dot(N, L));
Vector3 Id = albedo.mult(Kd * ndotl);

Vector3 R = N.mult(2.0 * Vector3.dot(N, L)).sub(L);
R.normalize();
float rdotv = max(0.0, Vector3.dot(R, V));
Vector3 Is = light.light_color.mult(light.intensity * Ks * pow(rdotv, m));

Vector3 finalcolor = Ia.add(Id).add(Is);
return new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
```

## Flat Shading (Fragment Shader)

Flat shading 的目標是讓一個三角形整面呈現單一光照顏色，因此我簡化法向量，並在 fragment 階段計算：

- 法向量使用固定值
- 光照方向由光源位置到 fragment 位置方向計算

以下 Flat shading 實作：

```
Vector3 N = new Vector3(0, 1, 0);
N.normalize();
Vector3 L = Vector3.sub(basic_light.transform.position, position);
L.normalize();
float diff = max(0.0, Vector3.dot(N, L));
Vector3 finalcolor = new Vector3(diff, diff, diff);
return new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
```

## Gouraud Shading（Vertex Shader）

Gouraud shading 的特點是將光照計算放在 vertex shader，並將顏色插值到 fragment：

1. 於 vertex 計算每個頂點的 diffuse color
2. 為每個頂點指定 v_color
3. Fragment shader 只回傳插值後的色值

以下範例：

```
for (int i = 0; i < 3; i++) {
    gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
    Vector3 N = new Vector3(0,1,0);
    Vector3 L = Vector3.sub(basic_light.transform.position, aVertexPosition[i]);
    L.normalize();
    float diff = max(0.0, Vector3.dot(N, L));
    v_color[i] = new Vector4(diff, diff, diff, 1.0);
}
return new Vector4[][] { gl_Position, v_color };
```
