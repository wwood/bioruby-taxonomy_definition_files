require 'csv'

module Bio
  class Lineage
    attr_accessor :taxon_id, :domain, :kingdom, :phylum, :class_name, :order, :family, :genus, :species
    
    def genus_species
      @genus+' '+@species
    end
  end
end

module Bio  
  module IMG
    class Lineage < Bio::Lineage
      attr_accessor :definition_line
    end
    
    # Acts like an array of Bio::IMG::Lineage objects
    #
    # Use TaxonomyDefinitionFile#read to read in a file downloaded through the IMG export system
    class TaxonomyDefinitionFile < Array
      FIELD_NAMES_TO_CLASSIFICATIONS = {
        'taxon_oid' => :taxon_id,
        'Domain' => :domain,
        'Phylum' => :phylum,
        'Class' => :class_name,
        'Order' => :order,
        'Family' => :family,
        'Genus' => :genus,
        'Species' => :species,
      }
      
      # Reads an img_taxonomy_file into a new TaxonomyDefinitionFile object. 
      # This object is then an array of Bio::IMG::Lineage objects from that file
      def self.read(img_taxonomy_filename_path)
        all_lineages = TaxonomyDefinitionFile.new
        
        # taxon_oid       Domain  Status  Genome Name     Phylum  Class   Order   Family  Genus   Species Strain  Release Date    IMG Release
        # 650716001       Archaea Finished        Acidianus hospitalis W1 Crenarchaeota   Thermoprotei    Sulfolobales    Sulfolobaceae   Acidianus       hospitalis      W1      2011-12-01      IMG/W 3.5
        # 648028003       Archaea Finished        Acidilobus saccharovorans 345-15        Crenarchaeota   Thermoprotei    Acidilobales    Acidilobaceae   Acidilobus      saccharovorans  345-15  2011-01-01      IMG/W 3.3
        # 646564501       Archaea Finished        Aciduliprofundum boonei T469    Euryarchaeota   Thermoplasmata  Thermoplasmatales       Aciduloprofundaceae     Aciduliprofundum        boonei  T469    2010-08-01      IMG/
        CSV.foreach(img_taxonomy_filename_path, :col_sep => "\t", :headers => true) do |row|
          lineage = Bio::IMG::Lineage.new
          lineage.definition_line = row.to_s(:col_sep => "\t")
          
          # 0# 650716001
          # 1# Archaea
          # 2# Finished
          # 3# Acidianus hospitalis W1
          # 4# Crenarchaeota
          # 5# Thermoprotei
          # 6# Sulfolobales
          # 7# Sulfolobaceae
          # 8# Acidianus
          # 9# hospitalis
          # 10# W1
          # 11# 2011-12-01
          # 12# IMG/W 3.5
          
          FIELD_NAMES_TO_CLASSIFICATIONS.each do |header, attribute|
            value = row[header]
            value = value.to_i if attribute == :taxon_id
            lineage.send "#{attribute}=".to_sym, value
          end
          
          all_lineages.push lineage
        end
        
        return all_lineages
      end
    end
  end
end
