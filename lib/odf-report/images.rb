module ODFReport
	module Images
#		IMAGE_DIR_NAME = "Pictures"
		def find_image_name_matches(content)
			@images.each_pair do |image_name, path|
				if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
					placeholder_path = node.attribute('href').value
					@image_names_replacements[path] = placeholder_path[0...(-1 * old_extension.length)] + new_extension
#					@image_names_replacements[placeholder_path] = ::File.join(IMAGE_DIR_NAME, ::File.basename(placeholder_path))
				end
			end
		end
		def replace_images(file)
			return if @images.empty?
			@image_names_replacements.each_pair do |path, template_image|
			p template_image
			old_extension = ::File.extname template_image
			new_extension = ::File.extname path
			FileUtils.mkdir(::File.join(file.tmp_dir, ::File.dirname(template_image)) ) unless ::File.exists? ::File.join(file.tmp_dir, ::File.dirname(template_image))
				file.update(template_image) do |content|
p content
					content.replace ::File.read(path)
					if old_extension != new_extension
						content.rename template_image, template_image[0...(-1 * old_extension.length)] + new_extension
					end
				end
			end
		end # replace_images
		# newer versions of LibreOffice can't open files with duplicates image names
		def avoid_duplicate_image_names(content)
			nodes = content.xpath("//draw:frame[@draw:name]")
			nodes.each_with_index do |node, i|
				node.attribute('name').value = "pic_#{i}"
			end
		end
	end
end