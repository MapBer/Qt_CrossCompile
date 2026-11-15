cmake_minimum_required(VERSION 3.16)

project(QtHelloWorld VERSION 1.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt6 6.2 REQUIRED COMPONENTS Quick)

qt_add_executable(hello_world main.cpp)
qt_add_resources(hello_world "qml_resources"
    PREFIX "/"
    FILES Main.qml
)
target_link_libraries(hello_world PRIVATE Qt6::Quick)

install(TARGETS hello_world RUNTIME DESTINATION bin)
