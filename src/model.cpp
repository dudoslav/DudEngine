#include "model.h"

model::model()
{
    //ctor
}

model::point4D model::getPoint4DAt(unsigned int n){
    return points.at(n);
}

void model::addPoint(float x, float y, float z, float w){
    points.push_back(point4D{x,y,z,w});
}

model::point3D model::getPoint3DAt(unsigned int n){
    point3D nowPoint;
    nowPoint.x = 640* points.at(n).x /
        points.at(n).w;
    nowPoint.y = 640 * (points.at(n).y /
        points.at(n).w);
    nowPoint.z = 640 * points.at(n).z /
        points.at(n).w;
    return nowPoint;
}


void model::loadModel(string path){
    ifstream file;
    string s;
    point4D nowPoint;

    file.open(path.c_str());
    if (!file.is_open()){
        perror('Failed to open file: ' + path.c_str());
    } else {
        while(!file.eof()){
            file >> s;
            if (s == "v"){
                file >> nowPoint.x >> nowPoint.y >> nowPoint.z >> nowPoint.w;
                cout << nowPoint.x;
                cout << nowPoint.y;
                cout << nowPoint.z;
                points.push_back(nowPoint);
            } else {
                getline(file, s);
            }
        }
    }
}

void model::render(){
    point3D nowPoint;
    for (unsigned int i = 0; i < 15; i++){
			glBegin(GL_LINE);
			glColor3f(1.f, 1.f, 1.f);
			nowPoint = getPoint3DAt(i);
			glVertex3f(nowPoint.x,nowPoint.y,nowPoint.z-2);
			nowPoint = getPoint3DAt(i+1);
			glVertex3f(nowPoint.x,nowPoint.y,nowPoint.z-2);
			glEnd();
		}
}

model::~model()
{
    //dtor
}
