cmake_minimum_required(VERSION 3.16)
project(dashboard VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

# Host: select Qt with CMAKE_PREFIX_PATH.
# Raspberry Pi: also pass CMAKE_TOOLCHAIN_FILE, RPI_SYSROOT and QT_HOST_PATH.
find_package(Qt6 6.2 REQUIRED COMPONENTS Quick QuickControls2)

set(DASHBOARD_SOURCES
    model/dashboardmodel.h
    model/dashboardmodel.cpp
    controller/dashboardcontroller.h
    controller/dashboardcontroller.cpp
    qml.qrc
)

qt_add_executable(dashboard app.cpp ${DASHBOARD_SOURCES})
target_include_directories(dashboard PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
target_link_libraries(dashboard PRIVATE Qt6::Quick Qt6::QuickControls2)

install(TARGETS dashboard RUNTIME DESTINATION bin)

# Enable explicitly for local validation or for tests run on the Pi.
option(BUILD_TESTING "Build dashboard tests" OFF)
if(BUILD_TESTING)
    enable_testing()
    qt_add_executable(dashboard_tests
        tests/dashboard_tests.cpp
        ${DASHBOARD_SOURCES}
    )
    target_include_directories(dashboard_tests PRIVATE "${CMAKE_CURRENT_SOURCE_DIR}")
    target_link_libraries(dashboard_tests PRIVATE Qt6::Quick Qt6::QuickControls2)
    add_test(NAME dashboard_mvc COMMAND dashboard_tests)
    set_tests_properties(dashboard_mvc PROPERTIES
        ENVIRONMENT "QT_QPA_PLATFORM=offscreen;QT_QUICK_BACKEND=software"
    )
endif()
