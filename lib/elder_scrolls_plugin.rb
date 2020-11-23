require 'riffola'
require 'base64'
require 'bindata'

class ElderScrollsPlugin

  # Set the current esp being read (useful for BinData decoding types that depend on the esp)
  #
  # Parameters::
  # * *esp* (ElderScrollsPlugin): The current esp
  def self.current_esp=(esp)
    @esp = esp
  end

  # Get the current esp being read (useful for BinData decoding types that depend on the esp)
  #
  # Result::
  # * ElderScrollsPlugin: The current esp
  def self.current_esp
    @esp
  end

  # Hash< Chunk or nil, Array<Chunk> >: The chunks tree, with nil being the root node
  attr_reader :chunks_tree

  # Array<String>: Ordered list of masters
  attr_reader :masters

  # Array<Riffola::Chunk>: Unknown chunks encountered
  attr_reader :unknown_chunks

  KNOWN_GRUP_RECORDS_WITHOUT_FIELDS = %w(
    NAVM
    CELL
    LAND
    NPC_
  )

  KNOWN_GRUP_RECORDS_WITH_FIELDS = %w(
    AACT
    ACHR
    ACTI
    ADDN
    ALCH
    AMMO
    ANIO
    APPA
    ARMA
    ARMO
    ARTO
    ASPC
    ASTP
    AVIF
    BOOK
    BPTD
    CAMS
    CLAS
    CLDC
    CLFM
    CLMT
    COBJ
    COLL
    CONT
    CPTH
    CSTY
    DEBR
    DIAL
    DLBR
    DLVW
    DOBJ
    DOOR
    DUAL
    ECZN
    EFSH
    ENCH
    EQUP
    EXPL
    EYES
    FACT
    FLOR
    FLST
    FSTP
    FSTS
    FURN
    GLOB
    GMST
    GRAS
    HAIR
    HAZD
    HDPT
    IDLE
    IDLM
    IMAD
    IMGS
    INFO
    INGR
    IPCT
    IPDS
    KEYM
    KYWD
    LCRT
    LCTN
    LGTM
    LIGH
    LSCR
    LTEX
    LVLI
    LVLN
    LVSP
    MATO
    MATT
    MESG
    MGEF
    MISC
    MOVT
    MSTT
    MUSC
    MUST
    NAVI
    OTFT
    PACK
    PERK
    PROJ
    PWAT
    QUST
    RACE
    REFR
    REGN
    RELA
    REVB
    RFCT
    RGDL
    SCEN
    SCOL
    SCPT
    SCRL
    SHOU
    SLGM
    SMBN
    SMEN
    SMQN
    SNCT
    SNDR
    SOPM
    SOUN
    SPEL
    SPGD
    STAT
    TACT
    TREE
    TXST
    VTYP
    WATR
    WEAP
    WOOP
    WRLD
    WTHR
  )

  KNOWN_FIELDS = %w(
    00TX
    10TX
    20TX
    30TX
    40TX
    50TX
    60TX
    70TX
    80TX
    90TX
    :0TX
    ;0TX
    <0TX
    =0TX
    >0TX
    ?0TX
    @0TX
    A0TX
    ACEC
    ACEP
    ACID
    ACPR
    ACSR
    ACUN
    AHCF
    AHCM
    ALCA
    ALCL
    ALCO
    ALDN
    ALEA
    ALED
    ALEQ
    ALFA
    ALFC
    ALFD
    ALFE
    ALFI
    ALFL
    ALFR
    ALID
    ALLS
    ALNA
    ALNT
    ALPC
    ALRT
    ALSP
    ALST
    ALUA
    ANAM
    ATKD
    ATKE
    AVSK
    B0TX
    BAMT
    BIDS
    BNAM
    BOD2
    BPND
    BPNI
    BPNN
    BPNT
    BPTN
    C0TX
    CIS1
    CIS2
    CITC
    CNAM
    CNTO
    COCT
    COED
    CRDT
    CRVA
    CTDA
    D0TX
    DALC
    DATA
    DEMO
    DESC
    DEST
    DEVA
    DFTF
    DFTM
    DMAX
    DMDL
    DMDS
    DMDT
    DMIN
    DNAM
    DODT
    DSTD
    DSTF
    E0TX
    EAMT
    ECOR
    EDID
    EFID
    EFIT
    EITM
    ENAM
    ENIT
    EPF2
    EPF3
    EPFD
    EPFT
    ETYP
    F0TX
    FLMV
    FLTR
    FLTV
    FNAM
    FNPR
    FTSF
    FTSM
    FULL
    G0TX
    GNAM
    H0TX
    HCLF
    HEAD
    HEDR
    HNAM
    HTID
    ICO2
    ICON
    IDLA
    IDLC
    IDLF
    IDLT
    IMSP
    INAM
    INCC
    INDX
    INTV
    ITXT
    JNAM
    K0TX
    KNAM
    KSIZ
    KWDA
    L0TX
    LLCT
    LNAM
    LTMP
    LVLD
    LVLF
    LVLG
    LVLI
    LVLO
    MDOB
    MHDT
    MNAM
    MO2S
    MO2T
    MO3S
    MO3T
    MO4S
    MO4T
    MO5T
    MOD2
    MOD3
    MOD4
    MOD5
    MODL
    MODS
    MODT
    MPAI
    MPAV
    MTNM
    NAM0
    NAM1
    NAM2
    NAM3
    NAM4
    NAM5
    NAM7
    NAM8
    NAM9
    LCEC
    LCEP
    LCID
    LCPR
    LCSR
    LCUN
    NAMA
    NAME
    NEXT
    NNAM
    NVER
    NVMI
    NVPP
    OBND
    OCOR
    ONAM
    PDTO
    PFIG
    PFPC
    PHTN
    PHWT
    PKC2
    PKCU
    PKDT
    PLDT
    PLVD
    PNAM
    POBA
    POCA
    POEA
    PRCB
    PRKC
    PRKE
    PRKF
    PSDT
    PTDA
    QNAM
    QOBJ
    QSDT
    QSTA
    QTGL
    RCEC
    RCLR
    RCPR
    RCSR
    RCUN
    RDAT
    RDMO
    RDSA
    RDWT
    RNAM
    RNMV
    RPLD
    RPLI
    RPRF
    RPRM
    SDSC
    SLCP
    SNAM
    SNDD
    SNMV
    SOUL
    SPCT
    SPIT
    SPLO
    SPMV
    SWMV
    TCLT
    TIFC
    TINC
    TIND
    TINI
    TINL
    TINP
    TINT
    TINV
    TIRS
    TNAM
    TPIC
    TRDT
    TWAT
    TX00
    TX01
    TX02
    TX03
    TX04
    TX05
    TX07
    UNAM
    UNES
    VENC
    VEND
    VENV
    VMAD
    VNAM
    VTCK
    WBDT
    WCTR
    WKMV
    WNAM
    XACT
    XALP
    XAPD
    XAPR
    XCNT
    XEMI
    XESP
    XEZN
    XIS2
    XLCM
    XLCN
    XLIB
    XLIG
    XLKR
    XLOC
    XLRL
    XLRM
    XLRT
    XLTW
    XMBO
    XMBR
    XMRK
    XNAM
    XNDP
    XOCP
    XOWN
    XPOD
    XPPA
    XPRD
    XPRM
    XRDS
    XRGB
    XRGD
    XRMR
    XSCL
    XTEL
    XTNM
    XTRI
    XWCN
    XWCU
    XWEM
    XXXX
    YNAM
    ZNAM
  )

  class FormId < BinData::Primitive
    uint32le :form_id

    def get
      "#{ElderScrollsPlugin.current_esp.absolute_form_id(sprintf('%08X', self.form_id))} - #{sprintf('%08X', self.form_id)}"
    end
  end

  class Label < BinData::Primitive
    string :label, read_length: 4

    def get
      self.label.ascii_only? ? self.label : "<#{Base64.encode64(self.label)}>"
    end
  end

  class RoundedFloat < BinData::Primitive
    float_le :float
    def get
      self.float.round(4)
    end
  end

  class Door < BinData::Record
    uint32le :unknown
    form_id :door_ref
  end

  class Vertex < BinData::Record
    rounded_float :x
    rounded_float :y
    rounded_float :z
  end

  class Triangle < BinData::Record
    uint16le :vertex_index_0
    uint16le :vertex_index_1
    uint16le :vertex_index_2
  end

  class IslandNavMesh < BinData::Record
    rounded_float :x_min
    rounded_float :y_min
    rounded_float :z_min
    rounded_float :x_max
    rounded_float :y_max
    rounded_float :z_max
    uint32le :triangles_count
    array :triangles, type: :triangle, initial_length: :triangles_count
    uint32le :vertices_count
    array :vertices, type: :vertex, initial_length: :vertices_count
  end

  module Headers
    class GRUP < BinData::Record
      label :label
      int32le :grup_type
      uint16le :date
      uint16le :unknown_1
      uint16le :version
      uint16le :unknown_2
    end
    class TES4 < BinData::Record
      uint32le :flags
      uint32le :id
      uint32le :revision
      uint16le :version
      uint16le :unknown
    end
    class All < BinData::Record
      uint32le :flags
      form_id :id
      uint32le :revision
      uint16le :version
      uint16le :unknown
    end
  end

  module Data
    module ACHR
      class ACHR_DATA < BinData::Record
        rounded_float :x_pos
        rounded_float :y_pos
        rounded_float :z_pos
        rounded_float :x_rot
        rounded_float :y_rot
        rounded_float :z_rot
      end
      class ACHR_NAME < BinData::Record
        form_id :base_npc
      end
    end
    module NVMI
      class NVMI_NAVI < BinData::Record
        form_id :nav_mesh
        uint32le :unknown
        rounded_float :x
        rounded_float :y
        rounded_float :z
        uint32le :preferred_merges_flag
        uint32le :merged_to_count
        array :merged_to, type: :form_id, initial_length: :merged_to_count
        uint32le :preferred_merges_count
        array :preferred_merges, type: :form_id, initial_length: :preferred_merges_count
        uint32le :doors_count
        array :doors, type: :door, initial_length: :doors_count
        uint8 :is_island_mesh_flag
        island_nav_mesh :island_nav_mesh, onlyif: :has_island_nav_mesh?
        uint32le :location_marker
        form_id :world_space
        form_id :cell, onlyif: :world_space_is_skyrim?
        form_id :grid_x, onlyif: :world_space_is_not_skyrim?
        form_id :grid_y, onlyif: :world_space_is_not_skyrim?

        def world_space_is_skyrim?
          world_space.downcase == 'skyrim.esm/00003C'
        end
        def world_space_is_not_skyrim?
          !world_space_is_skyrim?
        end
        def has_island_nav_mesh?
          is_island_mesh_flag.nonzero?
        end
      end
    end
    module REFR
      class REFR_DATA < BinData::Record
        rounded_float :x_pos
        rounded_float :y_pos
        rounded_float :z_pos
        rounded_float :x_rot
        rounded_float :y_rot
        rounded_float :z_rot
      end
      class REFR_NAME < BinData::Record
        form_id :form_id
      end
      class REFR_XLIG < BinData::Record
        rounded_float :fov
        rounded_float :fade
        rounded_float :end_distance
        rounded_float :shadow_depth
        int32le :unknown
      end
      class REFR_XLKR < BinData::Record
        form_id :form_id_1
        form_id :form_id_2
      end
      class REFR_XLRL < BinData::Record
        form_id :form_id
      end
      class REFR_XNDP < BinData::Record
        form_id :form_id
        int32le :unknown
      end
      class REFR_XPRM < BinData::Record
        rounded_float :x_bound
        rounded_float :y_bound
        rounded_float :z_bound
        rounded_float :r
        rounded_float :g
        rounded_float :b
        rounded_float :unknown_1
        int32le :unknown_2
      end
      class REFR_XTEL < BinData::Record
        form_id :door_form_id
        rounded_float :x_pos
        rounded_float :y_pos
        rounded_float :z_pos
        rounded_float :x_rot
        rounded_float :y_rot
        rounded_float :z_rot
        int32le :alarm
      end
    end
  end

  # Constructor
  #
  # Parameters::
  # * *file_name* (String): ESP file name
  # * *decode_only_tes4* (Boolean): Do we decode only the TES4 header? [default: false]
  # * *ignore_unknown_chunks* (Boolean): Do we ignore unknown chunks? [default: false]
  # * *decode_fields* (Boolean): Do we decode fields content? [default: true]
  # * *warnings* (Boolean): Do we activate warnings? [default: true]
  # * *debug* (Boolean): Do we activate debugging logs? [default: false]
  def initialize(file_name, decode_only_tes4: false, ignore_unknown_chunks: false, decode_fields: true, warnings: true, debug: false)
    @file_name = file_name
    @decode_only_tes4 = decode_only_tes4
    @ignore_unknown_chunks = ignore_unknown_chunks
    @decode_fields = decode_fields
    @warnings = warnings
    @debug = debug
    # Get the list of masters
    @masters = []
    # Internal mapping of first 2 digits of a FormID to the corresponding master name
    @master_ids = {}
    # List of form ids being defined
    @form_ids = []
    # Unknown chunks encountered during decoding
    @unknown_chunks = []
    # Configure the current parser
    ElderScrollsPlugin.current_esp = self
    # Tree of chunks (nil for root)
    # Hash< Chunk or nil, Array<Chunk> >
    @chunks_tree = {}
    chunks = Riffola.read(@file_name, chunks_format: {
      '*' => { header_size: 8 },
      'TES4' => { header_size: 16 },
      'GRUP' => { data_size_correction: -24, header_size: 16 }
    }, debug: @debug, warnings: @warnings) do |chunk|
      # Decode the TES4 to get the masters
      read_chunk(chunk) if chunk.name == 'TES4'
      !decode_only_tes4 || chunk.name != 'TES4'
    end
    # We just finished parsing TES4, update the masters index
    @master_ids.merge!(sprintf('%.2x', @master_ids.size) => File.basename(@file_name))
    p @master_ids
    @chunks_tree[nil] = chunks
    unless decode_only_tes4
      chunks.each do |chunk|
        # Don't read TES4 twice, especially because we already have our master IDs parsed
        read_chunk(chunk) unless chunk.name == 'TES4'
      end
    end
  end

  # Output a node of the chunks tree
  #
  # Parameters::
  # * *chunk* (Riffola::Chunk or nil): The node to be dumped, or nil for root [default = nil]
  # * *output_prefix* (String): Output prefix [default = '']
  def dump(chunk = nil, output_prefix = '')
    esp_info = chunk.nil? ? nil : chunk.instance_variable_get(:@esp_info)
    sub_chunks = @chunks_tree[chunk]
    puts "#{output_prefix}+- #{chunk.nil? ? 'ROOT' : "#{chunk.name}#{esp_info[:description].nil? ? '' : " - #{esp_info[:description]}"}"}#{sub_chunks.empty? ? '' : " (#{sub_chunks.size} sub-chunks)"}"
    sub_chunks.each.with_index do |sub_chunk, idx_sub_chunk|
      dump(sub_chunk, "#{output_prefix}#{idx_sub_chunk == sub_chunks.size - 1 ? ' ' : '|'}  ")
    end
  end

  # Dump masters
  def dump_masters
    @masters.each.with_index do |master, idx|
      puts "* [#{sprintf('%.2x', idx)}] - #{master}"
    end
  end

  # Dump absolute Form IDs
  def dump_absolute_form_ids
    @form_ids.sort.each do |form_id|
      puts "* [#{form_id}] - #{absolute_form_id(form_id)}"
    end
  end

  # Return the esp content as JSON
  #
  # Parameters::
  # * *chunk* (Riffola::Chunk or nil): The node to be dumped, or nil for root [default = nil]
  # Result::
  # * Hash: JSON object
  def to_json(chunk = nil)
    esp_info = chunk.nil? ? { type: :root, description: 'root' } : chunk.instance_variable_get(:@esp_info)
    json = {
      name: chunk.nil? ? 'ROOT' : chunk.name
    }
    json[:type] = esp_info[:type] unless esp_info[:type].nil?
    json[:description] = esp_info[:description] unless esp_info[:description].nil?
    json[:decoded_data] = esp_info[:decoded_data] unless esp_info[:decoded_data].nil?
    json[:decoded_header] = esp_info[:decoded_header] unless esp_info[:decoded_header].nil?
    unless chunk.nil?
      if esp_info[:decoded_header].nil?
        header = chunk.header
        json[:header] = (header.ascii_only? ? header : Base64.encode64(header)) unless header.empty?
      end
      if esp_info[:type] == :field && esp_info[:decoded_data].nil?
        data = chunk.data
        json[:data] = (data.ascii_only? ? data : Base64.encode64(data))
      end
    end
    json[:sub_chunks] = @chunks_tree[chunk].
      map { |sub_chunk| to_json(sub_chunk) }.
      sort_by { |chunk_json| [chunk_json[:name], chunk_json[:description], chunk_json[:data]] } if @chunks_tree[chunk].size > 0
    json
  end

  # Convert a Form ID into its absolute form.
  # An absolute form ID is not dependent on the order of the masters and includes the master name.
  #
  # Parameters::
  # * *form_id* (String): The original form ID
  # Result::
  # * String: The absolute Form ID
  def absolute_form_id(form_id)
    "#{@master_ids.key?(form_id[0..1]) ? @master_ids[form_id[0..1]] : "!!!#{form_id[0..1]}"}/#{form_id[2..7]}"
  end

  private

  # Read a given chunk info
  #
  # Parameters::
  # * *chunk* (Riffola::Chunk): Chunk to be read
  def read_chunk(chunk)
    puts "[ESP DEBUG] - Read chunk #{chunk.name}..." if @debug
    description = nil
    decoded_data = nil
    subchunks = []
    header = chunk.header
    case chunk.name
    when 'TES4'
      # Always read fields of TES4 as they define the masters, which are needed for others
      puts "[ESP DEBUG] - Read children chunks of #{chunk}" if @debug
      subchunks = chunk.sub_chunks(sub_chunks_format: {
        '*' => { header_size: 0, size_length: 2 },
        'ONAM' => {
          data_size_correction: proc do |file|
            # Size of ONAM field is sometimes badly computed. Correct it.
            file.seek(4, IO::SEEK_CUR)
            stored_size = file.read(2).unpack('S').first
            file.read(chunk.size).index('INTV') - stored_size
          end
        }
      })
      chunk_type = :record
    when 'MAST'
      description = chunk.data[0..-2].downcase
      @masters << description
      @master_ids[sprintf('%.2x', @master_ids.size)] = description
      chunk_type = :field
    when 'GRUP'
      puts "[ESP DEBUG] - Read children chunks of #{chunk}" if @debug
      subchunks = chunk.sub_chunks(sub_chunks_format: Hash[(['GRUP'] + KNOWN_GRUP_RECORDS_WITHOUT_FIELDS + KNOWN_GRUP_RECORDS_WITH_FIELDS).map do |known_sub_record_name|
        [
          known_sub_record_name,
          {
            header_size: 16,
            data_size_correction: known_sub_record_name == 'GRUP' ? -24 : 0
          }
        ]
      end])
      chunk_type = :group
    when *KNOWN_GRUP_RECORDS_WITHOUT_FIELDS
      # GRUP record having no fields
      form_id_str = sprintf('%.8x', header[4..7].unpack('L').first)
      @form_ids << form_id_str
      description = "FormID: #{form_id_str}"
      puts "[WARNING] - #{chunk} seems to have fields: #{chunk.data.inspect}" if @warnings && chunk.data[0..3] =~ /^\w{4}$/
      chunk_type = :record
    when *KNOWN_GRUP_RECORDS_WITH_FIELDS
      # GRUP record having fields
      form_id_str = sprintf('%.8x', header[4..7].unpack('L').first)
      @form_ids << form_id_str
      description = "FormID: #{form_id_str}"
      if @decode_fields
        puts "[ESP DEBUG] - Read children chunks of #{chunk}" if @debug
        subchunks = chunk.sub_chunks(sub_chunks_format: { '*' => { header_size: 0, size_length: 2 } })
      end
      chunk_type = :record
    when *KNOWN_FIELDS
      # Field
      record_module_name =
        if Data.const_defined?(chunk.parent_chunk.name.to_sym)
          chunk.parent_chunk.name.to_sym
        elsif Data.const_defined?(:All)
          :All
        else
          nil
        end
      unless record_module_name.nil?
        record_module = Data.const_get(record_module_name)
        data_class_name =
          if record_module.const_defined?("#{record_module_name}_#{chunk.name}".to_sym)
            "#{record_module_name}_#{chunk.name}".to_sym
          elsif record_module.const_defined?("#{record_module_name}_All".to_sym)
            "#{record_module_name}_All".to_sym
          else
            nil
          end
        unless data_class_name.nil?
          data_info = record_module.const_get(data_class_name)
          decoded_data = {}
          data_info.read(chunk.data).each_pair do |property, value|
            decoded_data[property] = value
          end
        end
      end
      chunk_type = :field
    else
      warning_desc = "Unknown chunk: #{chunk}. Data: #{chunk.data.inspect}"
      if @ignore_unknown_chunks
        puts "[WARNING] - #{warning_desc}" if @warnings
        @unknown_chunks << chunk
        chunk_type = :unknown
      else
        raise warning_desc
      end
    end
    # Decorate the chunk with our info
    esp_info = {
      description: description,
      type: chunk_type
    }
    esp_info[:decoded_data] = decoded_data unless decoded_data.nil?
    unless header.empty?
      header_class_name =
        if Headers.const_defined?(chunk.name.to_sym)
          chunk.name.to_sym
        elsif Headers.const_defined?(:All)
          :All
        else
          nil
        end
      unless header_class_name.nil?
        header_info = Headers.const_get(header_class_name)
        esp_info[:decoded_header] = {}
        header_info.read(header).each_pair do |property, value|
          esp_info[:decoded_header][property] = value
        end
      end
    end
    chunk.instance_variable_set(:@esp_info, esp_info)
    @chunks_tree[chunk] = subchunks
    subchunks.each.with_index do |subchunk, idx_subchunk|
      read_chunk(subchunk)
    end
  end

end
