#include "olcConsoleGameEngine.h"

struct vec3d
{
	float x, y, z;
};

struct triangle
{
	vec3d p[3];

	wchar_t sym;
	short col;
};

struct mesh
{
	std::vector<triangle> tris;
};

struct mat4x4
{
	float m[4][4] = { 0 };
};

class olcEngine3D : public olcConsoleGameEngine
{
public:
	olcEngine3D() {
		m_sAppName = L"3D Demo";
	}

private:
	mesh meshCude;
	mat4x4 matProj;

	vec3d vCamera = {0.0f};

	float fTheta = 0.0f;

	void MultiplyMatrixVector(vec3d &in, vec3d &out, mat4x4 &m)
	{
		out.x = in.x * m.m[0][0] + in.y * m.m[1][0] + in.z * m.m[2][0] + m.m[3][0];
		out.y = in.x * m.m[0][1] + in.y * m.m[1][1] + in.z * m.m[2][1] + m.m[3][1];
		out.z = in.x * m.m[0][2] + in.y * m.m[1][2] + in.z * m.m[2][2] + m.m[3][2];

		float w = in.x * m.m[0][3] + in.y * m.m[1][3] + in.z * m.m[2][3] + m.m[3][3];

		if (w != 0.0f)
		{
			out.x = out.x / w;
			out.y = out.y / w;
			out.z = out.z / w;
		}
	}

	CHAR_INFO GetColour(float lum)
	{
		short bg_col, fg_col;
		wchar_t sym;
		int pixel_bw = (int)(13.0f * lum);
		switch (pixel_bw)
		{
		case 0: bg_col = BG_BLACK; fg_col = FG_BLACK; sym = PIXEL_SOLID; break;

		case 1: bg_col = BG_BLACK; fg_col = FG_DARK_GREY; sym = PIXEL_QUARTER; break;
		case 2: bg_col = BG_BLACK; fg_col = FG_DARK_GREY; sym = PIXEL_HALF; break;
		case 3: bg_col = BG_BLACK; fg_col = FG_DARK_GREY; sym = PIXEL_THREEQUARTERS; break;
		case 4: bg_col = BG_BLACK; fg_col = FG_DARK_GREY; sym = PIXEL_SOLID; break;

		case 5: bg_col = BG_DARK_GREY; fg_col = FG_GREY; sym = PIXEL_QUARTER; break;
		case 6: bg_col = BG_DARK_GREY; fg_col = FG_GREY; sym = PIXEL_HALF; break;
		case 7: bg_col = BG_DARK_GREY; fg_col = FG_GREY; sym = PIXEL_THREEQUARTERS; break;
		case 8: bg_col = BG_DARK_GREY; fg_col = FG_GREY; sym = PIXEL_SOLID; break;

		case 9:  bg_col = BG_GREY; fg_col = FG_WHITE; sym = PIXEL_QUARTER; break;
		case 10: bg_col = BG_GREY; fg_col = FG_WHITE; sym = PIXEL_HALF; break;
		case 11: bg_col = BG_GREY; fg_col = FG_WHITE; sym = PIXEL_THREEQUARTERS; break;
		case 12: bg_col = BG_GREY; fg_col = FG_WHITE; sym = PIXEL_SOLID; break;
		default:
			bg_col = BG_BLACK; fg_col = FG_BLACK; sym = PIXEL_SOLID;
		}

		CHAR_INFO c;
		c.Attributes = bg_col | fg_col;
		c.Char.UnicodeChar = sym;
		return c;
	}

public:

	bool OnUserCreate() override
	{
		meshCude.tris = {
			// SOUTH
			{ 0.0f, 0.0f, 0.0f,    0.0f, 1.0f, 0.0f,    1.0f, 1.0f, 0.0f },
			{ 0.0f, 0.0f, 0.0f,    1.0f, 1.0f, 0.0f,    1.0f, 0.0f, 0.0f },

			// EAST                                                      
			{ 1.0f, 0.0f, 0.0f,    1.0f, 1.0f, 0.0f,    1.0f, 1.0f, 1.0f },
			{ 1.0f, 0.0f, 0.0f,    1.0f, 1.0f, 1.0f,    1.0f, 0.0f, 1.0f },

			// NORTH                                                     
			{ 1.0f, 0.0f, 1.0f,    1.0f, 1.0f, 1.0f,    0.0f, 1.0f, 1.0f },
			{ 1.0f, 0.0f, 1.0f,    0.0f, 1.0f, 1.0f,    0.0f, 0.0f, 1.0f },

			// WEST                                                      
			{ 0.0f, 0.0f, 1.0f,    0.0f, 1.0f, 1.0f,    0.0f, 1.0f, 0.0f },
			{ 0.0f, 0.0f, 1.0f,    0.0f, 1.0f, 0.0f,    0.0f, 0.0f, 0.0f },

			// TOP                                                       
			{ 0.0f, 1.0f, 0.0f,    0.0f, 1.0f, 1.0f,    1.0f, 1.0f, 1.0f },
			{ 0.0f, 1.0f, 0.0f,    1.0f, 1.0f, 1.0f,    1.0f, 1.0f, 0.0f },

			// BOTTOM                                                    
			{ 1.0f, 0.0f, 1.0f,    0.0f, 0.0f, 1.0f,    0.0f, 0.0f, 0.0f },
			{ 1.0f, 0.0f, 1.0f,    0.0f, 0.0f, 0.0f,    1.0f, 0.0f, 0.0f },

		};

		// Projection Matrix
		float fNear = 0.1f;
		float fFar = 1000.0f;
		float fFov = 90.f;
		float fAspectRatio = (float)ScreenWidth() / (float)ScreenHeight();
		float fFovRad = 1.0f / tanf(fFov * 0.5f / 180.0f * 3.14159f);

		matProj.m[0][0] = fAspectRatio * fFovRad;
		matProj.m[1][1] = fFovRad;
		matProj.m[2][2] = fFar / (fFar - fNear);
		matProj.m[2][3] = 1.f;
		matProj.m[3][2] = (-fFar * fNear) / (fFar - fNear);
		matProj.m[3][3] = 0.0f;

		return true;
	}

	bool OnUserUpdate(float fElapsedTime) override
	{
		Fill(0, 0, ScreenWidth(), ScreenHeight(), PIXEL_SOLID, BG_BLACK);

		mat4x4 matRotX, matRotZ;
		fTheta += 1.0f * fElapsedTime;

		matRotX.m[0][0] = 1;
		matRotX.m[1][1] = cosf(fTheta * 0.5f);
		matRotX.m[1][2] = -sinf(fTheta * 0.5f);
		matRotX.m[2][1] = sinf(fTheta * 0.5f);
		matRotX.m[2][2] = cosf(fTheta * 0.5f);
		matRotX.m[3][3] = 1;

		/*matRotY.m[0][0] = cosf(fTheta * 0.5f);
		matRotY.m[0][2] = sinf(fTheta * 0.5f);
		matRotY.m[1][1] = 1.f;
		matRotY.m[2][0] = -sinf(fTheta * 0.5f);
		matRotY.m[2][2] = cosf(fTheta * 0.5f);
		matRotY.m[3][3] = 1.f;*/

		matRotZ.m[0][0] = cosf(fTheta);
		matRotZ.m[0][1] = -sinf(fTheta);
		matRotZ.m[1][0] = sinf(fTheta);
		matRotZ.m[1][1] = cosf(fTheta);
		matRotZ.m[2][2] = 1;
		matRotZ.m[3][3] = 1;

		for (auto tri : meshCude.tris)
		{
			triangle triProjected, triTranslated, triRotatedZ, triRotatedZY, triRotatedZYX;

			// Rotation X
			MultiplyMatrixVector(tri.p[0], triRotatedZ.p[0], matRotZ);
			MultiplyMatrixVector(tri.p[1], triRotatedZ.p[1], matRotZ);
			MultiplyMatrixVector(tri.p[2], triRotatedZ.p[2], matRotZ);

			// Rotation Y
			/*MultiplyMatrixVector(triRotatedZ.p[0], triRotatedZY.p[0], matRotY);
			MultiplyMatrixVector(triRotatedZ.p[1], triRotatedZY.p[1], matRotY);
			MultiplyMatrixVector(triRotatedZ.p[2], triRotatedZY.p[2], matRotY);*/

			// Rotation Z
			MultiplyMatrixVector(triRotatedZ.p[0], triRotatedZYX.p[0], matRotX);
			MultiplyMatrixVector(triRotatedZ.p[1], triRotatedZYX.p[1], matRotX);
			MultiplyMatrixVector(triRotatedZ.p[2], triRotatedZYX.p[2], matRotX);

			// Translation
			triTranslated = triRotatedZYX;
			triTranslated.p[0].z += triRotatedZYX.p[0].z + 8.0f;
			triTranslated.p[1].z += triRotatedZYX.p[1].z + 8.0f;
			triTranslated.p[2].z += triRotatedZYX.p[2].z + 8.0f;

			// Culling
			vec3d normal, line1, line2;
			line1.x = triTranslated.p[1].x - triTranslated.p[0].x;
			line1.y = triTranslated.p[1].y - triTranslated.p[0].y;
			line1.z = triTranslated.p[1].z - triTranslated.p[0].z;

			line2.x = triTranslated.p[2].x - triTranslated.p[0].x;
			line2.y = triTranslated.p[2].y - triTranslated.p[0].y;
			line2.z = triTranslated.p[2].z - triTranslated.p[0].z;

			normal.x = line1.y * line2.z - line1.z * line2.y;
			normal.y = line1.z * line2.x - line1.x * line2.z;
			normal.z = line1.x * line2.y - line1.y * line2.x;

			// Normalize the normal vector
			float normLen = sqrtf(normal.x*normal.x + normal.y*normal.y + normal.z*normal.z);
			normal.x /= normLen; normal.y /= normLen; normal.z /= normLen;

			if (normal.x * (triTranslated.p[0].x - vCamera.x) +
				normal.y * (triTranslated.p[0].y - vCamera.y) +
				normal.z * (triTranslated.p[0].z - vCamera.z) < 0.0f)
			{

				// Illumination
				vec3d light_direction = { 0.0f, 0.0f, -1.0f };
				float l = sqrtf(light_direction.x*light_direction.x + light_direction.y*light_direction.y + light_direction.z*light_direction.z);
				light_direction.x /= l; light_direction.y /= l; light_direction.z /= l;

				float dp = normal.x * light_direction.x + normal.y * light_direction.y + normal.z * light_direction.z;

				CHAR_INFO c = GetColour(dp);
				triTranslated.col = c.Attributes;
				triTranslated.sym = c.Char.UnicodeChar;

				// Projection
				MultiplyMatrixVector(triTranslated.p[0], triProjected.p[0], matProj);
				MultiplyMatrixVector(triTranslated.p[1], triProjected.p[1], matProj);
				MultiplyMatrixVector(triTranslated.p[2], triProjected.p[2], matProj);
				triProjected.col = triTranslated.col;
				triProjected.sym = triTranslated.sym;

				// Scale
				triProjected.p[0].x += 1.0f; triProjected.p[0].y += 1.0f;
				triProjected.p[1].x += 1.0f; triProjected.p[1].y += 1.0f;
				triProjected.p[2].x += 1.0f; triProjected.p[2].y += 1.0f;
				triProjected.p[0].x *= 0.5f * (float)ScreenWidth();
				triProjected.p[0].y *= 0.5f * (float)ScreenHeight();
				triProjected.p[1].x *= 0.5f * (float)ScreenWidth();
				triProjected.p[1].y *= 0.5f * (float)ScreenHeight();
				triProjected.p[2].x *= 0.5f * (float)ScreenWidth();
				triProjected.p[2].y *= 0.5f * (float)ScreenHeight();



				//std::this_thread::sleep_for(std::chrono::microseconds(5));

				// Rasterize triangle
				FillTriangle((int)triProjected.p[0].x, (int)triProjected.p[0].y,
					(int)triProjected.p[1].x, (int)triProjected.p[1].y,
					(int)triProjected.p[2].x, (int)triProjected.p[2].y,
					triProjected.sym, triProjected.col);

				/*DrawTriangle((int)triProjected.p[0].x, (int)triProjected.p[0].y,
					(int)triProjected.p[1].x, (int)triProjected.p[1].y,
					(int)triProjected.p[2].x, (int)triProjected.p[2].y,
					PIXEL_SOLID, FG_WHITE);*/
			}
		}

		return true;
	}
};

int main() {
	olcEngine3D demo;
	if (demo.ConstructConsole(256, 240, 4, 4))
	{
		demo.Start();
	}

	return 0;
}