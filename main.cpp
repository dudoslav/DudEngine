#include <iostream>
#include "SDL2/SDL.h"
#undef main

using namespace std;

bool running = true;
SDL_Window *window;

void init(){
    SDL_Init(SDL_INIT_VIDEO);

    window = SDL_CreateWindow(
        "An SDL2 window",
        SDL_WINDOWPOS_UNDEFINED,
        SDL_WINDOWPOS_UNDEFINED,
        640,
        480,
        SDL_WINDOW_OPENGL
    );
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
