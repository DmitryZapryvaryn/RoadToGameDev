#include <iostream>
#include <string>

#include "olcConsoleGameEngine.h"
using namespace std;

class Tetris : public olcConsoleGameEngine {
public:
	Tetris() {
		m_sAppName = L"Tetris";
	}
private:
	float fPlayerPosX = 60;
	float fPlayerPosY = 60;
	float fPlayerVelX = 60.0f;
	float fPlayerVelY = 60.0f;

	int nCurrentTetr = 0;
	int nCurrentRotation = 0;

	wstring tetromino[5];

	vector<string> tetrisModels;

protected:
	bool OnUserCreate() override {
		/*
		__X_
		__X_
		__X_
		__X_
		*/
		tetromino[0].append(L"..X...X...X...X.");
		/*
		____
		__X_
		__X_
		_XX_
		*/
		tetromino[1].append(L"......X...X..XX.");
		tetromino[2].append(L".....X...X...XX.");
		tetromino[3].append(L".....X...XX...X.");
		/*
		....
		..X.
		.XX.
		.X..
		*/
		tetromino[4].append(L"......X..XX..X..");
		ConstructConsole(150, 80, 12, 12);

		return true;
	}

	bool OnUserUpdate(float fElapsedTime) override {

		Fill(0, 0, ScreenWidth(), ScreenHeight(), L' ');
			// Handle Input
		if (IsFocused())
		{
				if (GetKey(VK_UP).bHeld && fPlayerPosY > 0)
				{
					fPlayerPosY -= fPlayerVelY * fElapsedTime;
				}

				if (GetKey(VK_DOWN).bHeld && fPlayerPosY < ScreenHeight()-1.0f)
				{
					fPlayerPosY += fPlayerVelY * fElapsedTime;
				}

				if (GetKey(VK_LEFT).bHeld && fPlayerPosX > 0)
				{
					fPlayerPosX -= fPlayerVelX * fElapsedTime;
				}

				if (GetKey(VK_RIGHT).bHeld  && fPlayerPosX < ScreenWidth()-1.0f)
				{
					fPlayerPosX += fPlayerVelX * fElapsedTime;
				}

				if (GetKey(VK_CONTROL).bPressed)
				{
					nCurrentRotation += 1;
				}

				if (GetKey(VK_SHIFT).bPressed)
				{
					nCurrentTetr += 1;
					nCurrentTetr %= 5;
				}
		}
		
		if (fPlayerVelX > 0.0f || fPlayerVelY > 0.0f)
		{
			for (int px = 0; px < 4; px++) {
				for (int py = 0; py < 4; py++) {
					if (tetromino[nCurrentTetr][Rotate(px, py, nCurrentRotation)] != L'.')
						Draw(fPlayerPosX + px, fPlayerPosY + py, PIXEL_SOLID, FG_BLUE);
				}
			}
		}
		
		return true;
	}

	void MoveTetromino(int x, int y, int nTetrNumber) {
		
	}

	int Rotate(int px, int py, int r)
	{
		int pi = 0;
		switch (r % 4)
		{
		case 0: // 0 degrees			// 0  1  2  3
			pi = py * 4 + px;			// 4  5  6  7
			break;						// 8  9 10 11
										//12 13 14 15

		case 1: // 90 degrees			//12  8  4  0
			pi = 12 + py - (px * 4);	//13  9  5  1
			break;						//14 10  6  2
										//15 11  7  3

		case 2: // 180 degrees			//15 14 13 12
			pi = 15 - (py * 4) - px;	//11 10  9  8
			break;						// 7  6  5  4
										// 3  2  1  0

		case 3: // 270 degrees			// 3  7 11 15
			pi = 3 - py + (px * 4);		// 2  6 10 14
			break;						// 1  5  9 13
		}								// 0  4  8 12

		return pi;
	}
};

int main() {
	Tetris game;
	game.Start();

	return 0;
}