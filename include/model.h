#ifndef MODEL_H
#define MODEL_H
#include <vector>
#include <fstream>
#include <GL/gl.h>
#include <GL/glu.h>
#include <string>
#include <iostream>

using namespace std;

class model
{
    private:
    struct point4D{
        float x,y,z,w;
    };
    struct point3D{
        float x,y,z;
    };
    std::vector<point4D> points;
    public:
        model();
        point4D getPoint4DAt(unsigned int n);
        point3D getPoint3DAt(unsigned int n);
        void addPoint(float x, float y, float z, float w);
        void loadModel(string path);
        void render();
        virtual ~model();
    protected:
};

#endif // MODEL_H
