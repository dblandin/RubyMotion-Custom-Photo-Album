class ViewController < UIViewController
  attr_accessor :image_view, :take_photo_button, :image_picker

  def viewDidLoad
    super

    view.backgroundColor = UIColor.whiteColor

    self.image_view = UIImageView.alloc.initWithFrame(view.bounds).tap do |image_view|
      image_view.contentMode = UIViewContentModeScaleAspectFill
    end

    self.take_photo_button = UIButton.buttonWithType(UIButtonTypeRoundedRect).tap do |button|
      button.size = CGSizeMake(100, 40)
      button.center = CGPointMake(view.size.width / 2, view.size.height / 2)
      button.setTitle('Take Photo', forState: UIControlStateNormal)
      button.addTarget(self, action: 'take_photo:', forControlEvents: UIControlEventTouchUpInside)
    end

    [image_view, take_photo_button].each { |v| view.addSubview(v) }
  end

  def take_photo(sender)
    if camera_available?
      pick_image_from_camera
    else
      pick_image_from_library
    end
  end

  def camera_available?
    UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceTypeCamera)
  end

  def pick_image_from_camera
    self.image_picker = UIImagePickerController.alloc.init.tap do |picker|
      picker.delegate = self
      picker.sourceType = UIImagePickerControllerSourceTypeCamera
    end

    presentViewController(image_picker, animated: true, completion: nil)
  end

  def pick_image_from_library
    self.image_picker = UIImagePickerController.alloc.init.tap do |picker|
      picker.delegate = self
      picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum
    end

    presentViewController(image_picker, animated: true, completion: nil)
  end

  def imagePickerController(picker, didFinishPickingMediaWithInfo: info)
    dismissViewControllerAnimated(true, completion: lambda {
      image = info[UIImagePickerControllerOriginalImage]

      failure_block = lambda { |error| NSLog("An error occured: #{error.localizedDescription}") }

      save_image(image, to_album: 'Custom Album', failure_block: failure_block)

      image_view.image = image
    })
  end

  def assets_library
    @_assets_library ||= ALAssetsLibrary.alloc.init
  end

  def save_image(image, to_album: album_name, failure_block: failure_block, &completion_block)
    assets_library.writeImageToSavedPhotosAlbum(image.CGImage,
      orientation: image.imageOrientation,
      completionBlock: lambda { |asset_url, error|
        failure_block.call if error

        add_asset_url(asset_url, to_album: album_name, failure_block: failure_block, &completion_block)
    })
  end

  def add_asset_url(asset_url, to_album: album_name, failure_block: failure_block, &completion_block)
    album_found = false

    assets_library.enumerateGroupsWithTypes(ALAssetsGroupAlbum, usingBlock: lambda { |group, stop|
      if group && album_name === group.valueForProperty(ALAssetsGroupPropertyName)
        album_found = stop = true

        assets_library.assetForURL(asset_url, resultBlock: lambda { |asset|
          group.addAsset(asset)

          completion_block.call(nil) if block_given?
        }, failureBlock: failure_block)
      end

      if album_found == false
        assets_library.addAssetsGroupAlbumWithName(album_name, resultBlock: lambda { |group|
          assets_library.assetForURL(asset_url, resultBlock: lambda { |asset|
            group.addAsset(asset)

            completion_block.call(nil) if block_given?
          }, failureBlock: failure_block)
        }, failureBlock: failure_block)
      end
    }, failureBlock: failure_block)
  end
end
