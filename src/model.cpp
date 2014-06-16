#include "model.h"

model::model()
{
    //ctor
}

model::point4D model::getPointAt(unsigned int n){
    return points.at(n);
}

void model::addPoint(float x, float y, float z, float w){
    points.push_back(point4D{x,y,z,w});
}

void model::loadModel(string path){
    ifstream file;
    file.open(path.c_str());
    if (!file.is_open()){
        perror('Failed to open file: ' + path.c_str());
    } else {
        while(!file.eof()){

        }
    }
}

model::~model()
{
    //dtor
}
