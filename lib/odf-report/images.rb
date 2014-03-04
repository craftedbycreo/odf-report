module ODFReport
	module Images
		def find_image_name_matches(content)
			@images.each_pair do |image_name, path|
				if node = content.xpath("//draw:frame[@draw:name='#{image_name}']/draw:image").first
					placeholder_path = node.attribute('href').value
					node.attribute('href').value = ::File.join(::File.dirname(placeholder_path), ::File.basename(path))
					@image_names_replacements[path] = placeholder_path
				end
			end
		end
		def find_and_update_image_name_matches!(content)
			find_image_name_matches(content)
		end
		def replace_images(file)
			return if @images.empty?
			@image_names_replacements.each_pair do |path, template_image|
				FileUtils.mkdir(::File.join(file.tmp_dir, ::File.dirname(template_image)) ) unless ::File.exists? ::File.join(file.tmp_dir, ::File.dirname(template_image))
				file.update(template_image) do |content|
					content.replace ::File.read(path)
				end
				file.rename_content template_image, ::File.join(::File.dirname(template_image), ::File.basename(path))
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