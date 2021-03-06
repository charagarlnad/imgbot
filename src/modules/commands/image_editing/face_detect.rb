module Bot::DiscordCommands
  module ImageEditing
    extend Discordrb::Commands::CommandContainer
    command(:face_detect, type: :'Image Editing') do |event|
      upload = Tempfile.new(['hBot', '.png'])
      IO.copy_stream(StringIO.new(event.image_source), upload.path)

      detector = OpenCV::CvHaarClassifierCascade.load('data/command_data/ipmask/haarcascade_frontalface_alt.xml')
      image = OpenCV::CvMat.load(upload.path)

      detector.detect_objects(image).each do |region|
        color = OpenCV::CvColor::Blue
        image.rectangle! region.top_left, region.bottom_right, color: color
      end

      image.save_image(upload.path)
      event.channel.send_file upload

      upload.close!

      nil
    end
  end
end
