#ifndef MODEL_H
#define MODEL_H
#include <vector>
#include <fstream>
//#include <unistd.h>
#include <string>

using namespace std;

class model
{
    private:
    struct point4D{
        float x,y,z,w;
    };
    std::vector<point4D> points;
    public:
        model();
        point4D getPointAt(unsigned int n);
        void addPoint(float x, float y, float z, float w);
        void loadModel(string path);
        virtual ~model();
    protected:
};

#endif // MODEL_H
