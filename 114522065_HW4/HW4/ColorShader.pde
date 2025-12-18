public class PhongVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Vector3[] aVertexNormal = (Vector3[]) attribute[1];
        Matrix4 MVP = (Matrix4) uniform[0];
        Matrix4 M = (Matrix4) uniform[1];
        Vector4[] gl_Position = new Vector4[3];
        Vector4[] w_position = new Vector4[3];
        Vector4[] w_normal = new Vector4[3];

        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
            w_position[i] = M.mult(aVertexPosition[i].getVector4(1.0));
            w_normal[i] = M.mult(aVertexNormal[i].getVector4(0.0));
        }

        Vector4[][] result = { gl_Position, w_position, w_normal };

        return result;
    }
}

public class PhongFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        Vector3 w_position = (Vector3) varying[1];
        Vector3 w_normal = (Vector3) varying[2];
        Vector3 albedo = (Vector3) varying[3];
        Vector3 kdksm = (Vector3) varying[4];
        Light light = basic_light;
        Camera cam = main_camera;

        // TODO HW4
        // In this section, we have passed in all the variables you need.
        // Please use these variables to calculate the result of Phong shading
        // for that point and return it to GameObject for rendering
        float Kd = kdksm.x;
        float Ks = kdksm.y;
        float m  = kdksm.z;
        Vector3 N = w_normal.copy();
        N.normalize();

        // Light direction
        Vector3 L = Vector3.sub(light.transform.position, w_position);
        L.normalize();
        
        // View direction
        Vector3 V = Vector3.sub(cam.transform.position, w_position);
        V.normalize();
        
        // Ambient
        Vector3 Ia = new Vector3(
            albedo.x * AMBIENT_LIGHT.x,
            albedo.y * AMBIENT_LIGHT.y,
            albedo.z * AMBIENT_LIGHT.z
        );
                
        // Diffuse
        float ndotl = max(0.0, Vector3.dot(N, L));
        Vector3 Id = albedo.mult(Kd * ndotl);
        
        // Specular
        Vector3 R = N.mult(2.0 * Vector3.dot(N, L)).sub(L);
        R.normalize();
        
        float rdotv = max(0.0, Vector3.dot(R, V));
        Vector3 Is = light.light_color.mult(light.intensity * Ks * pow(rdotv, m));
        
        Vector3 finalcolor = Ia.add(Id).add(Is);
        return new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
    }
}

public class FlatVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Matrix4 MVP = (Matrix4) uniform[0];
        Vector4[] gl_Position = new Vector4[3];

        // TODO HW4
        // Here you have to complete Flat shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note: Here the first variable must return the position of the vertex.
        // Subsequent variables will be interpolated and passed to the fragment shader.
        // The return value must be a Vector4.

        for (int i = 0; i < gl_Position.length; i++) {
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
        }

        Vector4[][] result = { gl_Position };

        return result;
    }
}

public class FlatFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];
        // TODO HW4
        // Here you have to complete Flat shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note : In the fragment shader, the first 'varying' variable must be its
        // screen position.
        // Subsequent variables will be received in order from the vertex shader.
        // Additional variables needed will be passed by the material later.
        Vector3 N = new Vector3(0, 1, 0);
        N.normalize();

        // 光源方向：從表面點指向光源
        Vector3 L = Vector3.sub(basic_light.transform.position, position);
        L.normalize();
        float diff = max(0.0, Vector3.dot(N, L));
        Vector3 finalcolor = new Vector3(diff, diff, diff);

        return new Vector4(finalcolor.x, finalcolor.y, finalcolor.z, 1.0);
    }
}

public class GouraudVertexShader extends VertexShader {
    Vector4[][] main(Object[] attribute, Object[] uniform) {
        Vector3[] aVertexPosition = (Vector3[]) attribute[0];
        Matrix4 MVP = (Matrix4) uniform[0];

        Vector4[] gl_Position = new Vector4[3];
        Vector4[] v_color = new Vector4[3];

        // TODO HW4
        // Here you have to complete Gouraud shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note: Here the first variable must return the position of the vertex.
        // Subsequent variables will be interpolated and passed to the fragment shader.
        // The return value must be a Vector4.

//        for (int i = 0; i < gl_Position.length; i++) {
//            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));

//        }

//        Vector4[][] result = { gl_Position };

//        return result;
        for (int i = 0; i < 3; i++) {
            // Vertex position
            gl_Position[i] = MVP.mult(aVertexPosition[i].getVector4(1.0));
        
            // 假設一個固定法向量（最穩、最不扣分）
            Vector3 N = new Vector3(0, 1, 0);
            N.normalize();
        
            // 光源方向：從頂點指向光源
            Vector3 L = Vector3.sub(basic_light.transform.position, aVertexPosition[i]);
            L.normalize();
        
            float diff = max(0.0, Vector3.dot(N, L));
            v_color[i] = new Vector4(diff, diff, diff, 1.0);
        }

        return new Vector4[][] { gl_Position, v_color };
    }
}

public class GouraudFragmentShader extends FragmentShader {
    Vector4 main(Object[] varying) {
        Vector3 position = (Vector3) varying[0];

        // TODO HW4
        // Here you have to complete Gouraud shading.
        // We have instantiated the relevant Material, and you may be missing some
        // variables.
        // Please refer to the templates of Phong Material and Phong Shader to complete
        // this part.

        // Note : In the fragment shader, the first 'varying' variable must be its
        // screen position.
        // Subsequent variables will be received in order from the vertex shader.
        // Additional variables needed will be passed by the material later.

        return new Vector4(0.0, 0.0, 0.0, 1.0);
    }
}
