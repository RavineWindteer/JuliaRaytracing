cd(@__DIR__)
using Pkg
Pkg.activate("./JuliaRaytracing/")

include("sphere.jl")
include("camera.jl")


function main()

    ground_material = Lambertian(Color(0.5, 0.5, 0.5))
    world = [
        Sphere(Point3(0.0, -1000.0, 0.0), 1000.0, ground_material)
        ]
    
    for a in -11:10
        for b in -11:10
            choose_mat = random_float()
            center = Point3(a + 0.9*random_float(), 0.2, b + 0.9*random_float())
    
            if length(center - Point3(4.0, 0.2, 0.0)) > 0.9
                if choose_mat < 0.8
                    # diffuse
                    albedo = random() * random()
                    sphere_material = Lambertian(albedo)
                    push!(world, Sphere(center, 0.2, sphere_material))
                elseif choose_mat < 0.95
                    # metal
                    albedo = random(0.5, 1.0)
                    fuzz = random_float(0.0, 0.5)
                    sphere_material = Metal(albedo, fuzz)
                    push!(world, Sphere(center, 0.2, sphere_material))
                else
                    # glass
                    sphere_material = Dielectric(1.5)
                    push!(world, Sphere(center, 0.2, sphere_material))
                end
            end
        end
    end

    material1 = Dielectric(1.5)
    push!(world, Sphere(Point3(0.0, 1.0, 0.0), 1.0, material1))

    material2 = Lambertian(Color(0.4, 0.2, 0.1))
    push!(world, Sphere(Point3(-4.0, 1.0, 0.0), 1.0, material2))

    material3 = Metal(Color(0.7, 0.6, 0.5), 0.0)
    push!(world, Sphere(Point3(4.0, 1.0, 0.0), 1.0, material3))
    
    cam = Camera(
        aspect_ratio = 16.0 / 9.0,
        image_width = 1200,
        samples_per_pixel = 100,
        max_depth = 50,
        vfov = 20,
        lookfrom = Point3(13.0, 2.0, 3.0),
        lookat = Point3(0.0, 0.0, 0.0),
        vup = Vec3(0.0, 1.0, 0.0),
        defocus_angle = 0.6,
        focus_dist = 10.0)

    render(cam, "./renders/image.png", world)
end

main()
