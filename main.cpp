#include <iostream>
#include "SDL2/SDL.h"
#include <GL/gl.h>
#include <GL/glu.h>
#include "include/model.h"
#undef main

using namespace std;

bool running = true;
SDL_Window *window;
SDL_GLContext maincontext;
model dube;

void init(){
    SDL_Init(SDL_INIT_EVERYTHING);

    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
    SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);

    SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);

    window = SDL_CreateWindow("4DudEngine", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED,
        512, 512, SDL_WINDOW_OPENGL | SDL_WINDOW_SHOWN);

    maincontext = SDL_GL_CreateContext(window);
    SDL_GL_SetSwapInterval(1);
    glClearColor ( 0.0, 0.0, 0.0, 0.0 );
    glClear ( GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    SDL_GL_SwapWindow(window);

    glMatrixMode(GL_PROJECTION);
	gluPerspective(75, 75, 0.3, 1000);

	glMatrixMode(GL_MODELVIEW);
	glEnable(GL_DEPTH_TEST);

    dube.loadModel("dube.txt");
}

void update(){
SDL_Event event;
    if (SDL_PollEvent(&event)){
        if (event.type == SDL_QUIT){
            running = false;
        }
        if (event.key.keysym.sym == SDLK_ESCAPE){
            running = false;
        }
    }
}

void render(){
    dube.render();
    //SDL_GL_S
}

void cleanUp(){
SDL_DestroyWindow(window);
SDL_Quit;
}

int main()
{
    init();
    while (running) {
        update();
        render();
    }
    cleanUp();
    return 0;
}
