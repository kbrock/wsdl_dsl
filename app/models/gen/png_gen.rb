module Gen
  class PngGen
    def dot_to_png(file_name,dot)
      tmp_dotfile="#{RAILS_ROOT}/tmp/#{file_name}.dot"
      tmp_pngfile="#{RAILS_ROOT}/tmp/#{file_name}.png"

      File.delete(tmp_dotfile) if File.file?(tmp_dotfile)
      File.delete(tmp_pngfile) if File.file?(tmp_pngfile)

      File.open(tmp_dotfile,"w") { |f|
        f.write dot
      }

      errors=system("\"#{DOT_CMD}\" -Tpng #{tmp_dotfile} -o #{tmp_pngfile}")
#      RAILS_DEFAULT_LOGGER.info("ran dot cmd \"#{DOT_CMD}\" -Tpng #{tmp_dotfile} -o #{tmp_pngfile}")
#      RAILS_DEFAULT_LOGGER.info(errors)
      File.delete(tmp_dotfile) if File.file?(tmp_dotfile)
    
      tmp_pngfile
    end
  end
end