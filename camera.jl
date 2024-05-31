using PNGFiles

include("color.jl")
include("hittable.jl")
include("interval.jl")
include("material.jl")
include("material_scatter.jl")
include("hittable_list.jl")
include("ray.jl")
include("sphere.jl")
include("utils.jl")
include("vec3.jl")


struct Camera
    image_width::Int32
    image_height::Int32
    samples_per_pixel::Int32
    max_depth::Int32
    aspect_ratio::FloatT
    pixel_samples_scale::FloatT
    defocus_angle::FloatT
    focus_dist::FloatT
    vfov::FloatT
    lookfrom::Point3
    lookat::Point3
    vup::Vec3
    center::Point3
    pixel00_loc::Point3
    pixel_delta_u::Vec3
    pixel_delta_v::Vec3
    u::Vec3
    v::Vec3
    w::Vec3
    defocus_disk_u::Vec3
    defocus_disk_v::Vec3

    function Camera(;
        aspect_ratio::Real = 1.0,
        image_width::Real = 100,
        samples_per_pixel::Real = 10,
        max_depth::Real = 10,
        vfov::Real = 90.0,
        lookfrom::Point3 = Point3(0.0, 0.0, 0.0),
        lookat::Point3 = Point3(0.0, 0.0, -1.0),
        vup::Vec3 = Vec3(0.0, 1.0, 0.0),
        defocus_angle::Real = 0.0,
        focus_dist::Real = 10.0)

        # Convert input values to the correct types.
        aspect_ratio = FloatT(aspect_ratio)
        image_width = trunc(Int32, image_width)
        samples_per_pixel = trunc(Int32, samples_per_pixel)
        max_depth = trunc(Int32, max_depth)
        vfov = FloatT(vfov)
        defocus_angle = FloatT(defocus_angle)
        focus_dist = FloatT(focus_dist)

        image_height = Int32(trunc(Int32, image_width / aspect_ratio))
        image_height = Int32((image_height < 1) ? 1 : image_height)

        pixel_samples_scale = FloatT(1.0 / samples_per_pixel)

        center = lookfrom

        # Determine viewport dimensions.
        theta = degrees_to_radians(vfov)
        h = tan(theta / 2.0)
        viewport_height = FloatT(2.0 * h * focus_dist)
        viewport_width = FloatT(viewport_height
            * (FloatT(image_width) / image_height))
        
        # Calculate the u,v,w basis vectors for the camera coordinate frame.
        w = unit_vector(lookfrom - lookat)
        u = unit_vector(cross(vup, w))
        v = cross(w, u)

        # Calculate the vectors across the horizontal and down the vertical 
        # viewport edges.
        viewport_u = viewport_width * u # Vector across viewport horizontal edge
        viewport_v = viewport_height * -v # Vector down viewport vertical edge

        # Calculate the horizontal and vertical delta vectors from pixel to 
        # pixel.
        pixel_delta_u = viewport_u / image_width
        pixel_delta_v = viewport_v / image_height

        # Calculate the location of the upper left pixel.
        viewport_upper_left = (center - (focus_dist * w)
            - (viewport_u / 2) - (viewport_v / 2))
        pixel00_loc = (viewport_upper_left + 0.5 * (pixel_delta_u
            + pixel_delta_v))
        
        # Calculate the camera defocus disk basis vectors.
        defocus_radius = focus_dist * tan(degrees_to_radians(defocus_angle / 2))
        defocus_disk_u = u * defocus_radius
        defocus_disk_v = v * defocus_radius
        
        new(image_width,
            image_height,
            samples_per_pixel,
            max_depth,
            aspect_ratio,
            pixel_samples_scale,
            defocus_angle,
            focus_dist,
            vfov,
            lookfrom,
            lookat,
            vup,
            center,
            pixel00_loc,
            pixel_delta_u,
            pixel_delta_v,
            u,
            v,
            w,
            defocus_disk_u,
            defocus_disk_v)
    end
end

function render(cam::Camera, path::String, world)
    image = zeros(cam.image_height, cam.image_width, 3)

    @inbounds for j in 0:cam.image_height-1
        print("\rScanlines remaining: $(cam.image_height - j - 1) ")
        @inbounds for i in 0:cam.image_width-1
            pixel_color = Color(0.0, 0.0, 0.0)
            @inbounds for s in 1:cam.samples_per_pixel
                r = get_ray(cam, i, j)
                pixel_color += ray_color(r, cam.max_depth, world)
            end

            pixel_color = cam.pixel_samples_scale * pixel_color
            image[j+1, i+1, 1] = pixel_color.x
            image[j+1, i+1, 2] = pixel_color.y
            image[j+1, i+1, 3] = pixel_color.z
        end
    end

    PNGFiles.save(path, image)

    print("\rDone.                 ")
end

function get_ray(cam::Camera, i::Int32, j::Int32)
    # Construct a camera ray originating from the defocus disk and directed at a
    # randomly sampled point around the pixel location i, j.

    offset = sample_square()
    pixel_sample = (cam.pixel00_loc 
        + ((i + offset.x) * cam.pixel_delta_u)
        + ((j + offset.y) * cam.pixel_delta_v))
    
    ray_origin = (cam.defocus_angle <= 0.0) ? cam.center :
        defocus_disk_sample(cam)
    ray_direction = pixel_sample - ray_origin

    Ray(ray_origin, ray_direction)
end

get_ray(cam::Camera, i::Real, j::Real) =
    get_ray(cam, trunc(Int32, i), trunc(Int32, j))

sample_square() = Vec3(random_float()-0.5, random_float()-0.5, 0.0)

function defocus_disk_sample(cam::Camera)
    p = random_in_unit_disk()
    cam.center + (p.x * cam.defocus_disk_u) + (p.y * cam.defocus_disk_v)
end

function ray_color(r::Ray, depth::Int32, world)
    if depth <= 0
        return Color(0.0, 0.0, 0.0)
    end

    rec = HitRecord()

    if hit!(rec, world, r, Interval(0.001, infinity))
        attenuation = Color()
        scattered = Ray()
        if scatter!(attenuation, scattered, rec.mat, r, rec)
            return attenuation * ray_color(scattered, depth - 1, world)
        end
        return Color(0.0, 0.0, 0.0)
    end

    unit_direction = unit_vector(r.direction)
    a = 0.5 * (unit_direction.y + 1.0)
    (1.0 - a) * Color(1.0, 1.0, 1.0) + a * Color(0.5, 0.7, 1.0)
end

ray_color(r::Ray, depth::Real, world) = ray_color(r, trunc(Int32, depth), world)
