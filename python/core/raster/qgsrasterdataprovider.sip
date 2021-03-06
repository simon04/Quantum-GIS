
/** Base class for raster data providers
 *
 *  \note  This class has been copied and pasted from
 *         QgsVectorDataProvider, and does not yet make
 *         sense for Raster layers.
 */

class QgsRasterDataProvider : QgsDataProvider, QgsRasterInterface
{
%TypeHeaderCode
#include <qgsrasterdataprovider.h>
#include <qgsrasterinterface.h>
%End

  public:

    //! If you add to this, please also add to capabilitiesString()
    enum Capability
    {
      NoCapabilities,
      Identify,
      ExactMinimumMaximum,
      ExactResolution,
      EstimatedMinimumMaximum,
      BuildPyramids,
      Histogram,
      Size,
      Create,
      Remove,
      IdentifyValue,
      IdentifyText,
      IdentifyHtml,
      IdentifyFeature
    };

    // This is modified copy of GDALColorInterp
    enum ColorInterpretation
    {
      UndefinedColorInterpretation = 0,
      /*! Greyscale */                                      GrayIndex = 1,
      /*! Paletted (see associated color table) */          PaletteIndex = 2, // indexed color table
      /*! Red band of RGBA image */                         RedBand = 3,
      /*! Green band of RGBA image */                       GreenBand = 4,
      /*! Blue band of RGBA image */                        BlueBand = 5,
      /*! Alpha (0=transparent, 255=opaque) */              AlphaBand = 6,
      /*! Hue band of HLS image */                          HueBand = 7,
      /*! Saturation band of HLS image */                   SaturationBand = 8,
      /*! Lightness band of HLS image */                    LightnessBand = 9,
      /*! Cyan band of CMYK image */                        CyanBand = 10,
      /*! Magenta band of CMYK image */                     MagentaBand = 11,
      /*! Yellow band of CMYK image */                      YellowBand = 12,
      /*! Black band of CMLY image */                       BlackBand = 13,
      /*! Y Luminance */                                    YCbCr_YBand = 14,
      /*! Cb Chroma */                                      YCbCr_CbBand = 15,
      /*! Cr Chroma */                                      YCbCr_CrBand = 16,
      /*! Continuous palette, QGIS addition, GRASS */       ContinuousPalette = 17,
      /*! Max current value */                              ColorInterpretationMax = 17
    };

    enum IdentifyFormat
    {
      IdentifyFormatValue,
      IdentifyFormatText,
      IdentifyFormatHtml,
      IdentifyFormatFeature
    };

    // Progress types
    enum RasterProgressType
    {
      ProgressHistogram = 0,
      ProgressPyramids  = 1,
      ProgressStatistics = 2
    };

    enum RasterBuildPyramids
    {
      PyramidsFlagNo = 0,
      PyramidsFlagYes = 1,
      CopyExisting = 2
    };

    enum RasterPyramidsFormat
    {
      PyramidsGTiff = 0,
      PyramidsInternal = 1,
      PyramidsErdas = 2
    };

    QgsRasterDataProvider();

    QgsRasterDataProvider( const QString & uri );

    virtual ~QgsRasterDataProvider();

    virtual QgsRasterInterface * clone() const = 0;

    /* It makes no sense to set input on provider */
    bool setInput( QgsRasterInterface* input );

    // TODO: Document this better.
    /** \brief   Renders the layer as an image
     */
    virtual QImage* draw( const QgsRectangle & viewExtent, int pixelWidth, int pixelHeight ) = 0;

    /** Returns a bitmask containing the supported capabilities
        Note, some capabilities may change depending on whether
        a spatial filter is active on this provider, so it may
        be prudent to check this value per intended operation.
      */
    virtual int capabilities() const;

    /**
     *  Returns the above in friendly format.
     */
    QString capabilitiesString() const;


    // TODO: Get the supported formats by this provider

    // TODO: Get the file masks supported by this provider, suitable for feeding into the file open dialog box

    /** Returns data type for the band specified by number */
    virtual QgsRasterBlock::DataType dataType( int bandNo ) const = 0;

    /** Returns source data type for the band specified by number,
     *  source data type may be shorter than dataType
     */
    virtual QgsRasterBlock::DataType srcDataType( int bandNo ) const = 0;

    /** Returns data type for the band specified by number */
    virtual int colorInterpretation( int theBandNo ) const;

    QString colorName( int colorInterpretation ) const;

    /** Reload data (data could change) */
    virtual bool reload();

    virtual QString colorInterpretationName( int theBandNo ) const;

    /** Get block size */
    virtual int xBlockSize() const;
    virtual int yBlockSize() const;

    /** Get raster size */
    virtual int xSize() const;
    virtual int ySize() const;

    /** read block of data  */
    // TODO clarify what happens on the last block (the part outside raster)
    // virtual void readBlock( int bandNo, int xBlock, int yBlock, void *data );

    /** read block of data using give extent and size */
    // virtual void readBlock( int bandNo, QgsRectangle  const & viewExtent, int width, int height, void *data );

    /** read block of data using give extent and size */
    // virtual void *readBlock( int bandNo, QgsRectangle  const & viewExtent, int width, int height, QgsCoordinateReferenceSystem theSrcCRS, QgsCoordinateReferenceSystem theDestCRS, void *data );

    /** Read block of data using given extent and size. */
    // virtual void *readBlock( int bandNo, QgsRectangle  const & extent, int width, int height );
    virtual QgsRasterBlock *block( int bandNo, const QgsRectangle &extent, int width, int height ) / Factory /;

    /* Read a value from a data block at a given index. */
    virtual double readValue( void *data, int type, int index );

    /* Return true if source band has no data value */
    virtual bool srcHasNoDataValue( int bandNo ) const;

    /** \brief Get source nodata value usage */
    virtual bool useSrcNoDataValue( int bandNo ) const;

    /** \brief Set source nodata value usage */
    virtual void setUseSrcNoDataValue( int bandNo, bool use );

    /** value representing null data */
    //virtual double noDataValue() const;

    /** Value representing currentno data.
     *  WARNING: this value returned by this method is not constant. It may change
     *  for example if user disable use of source no data value. */
    virtual double noDataValue( int bandNo ) const;

    /** Value representing no data value. */
    virtual double srcNoDataValue( int bandNo ) const;

    virtual void setUserNoDataValue( int bandNo, QList<QgsRasterBlock::Range> noData );

    /** Get list of user no data value ranges */
    virtual  QList<QgsRasterBlock::Range> userNoDataValue( int bandNo ) const;

    virtual double minimumValue( int bandNo ) const;
    virtual double maximumValue( int bandNo ) const;

    virtual QList<QgsColorRampShader::ColorRampItem> colorTable( int bandNo ) const;

    // Defined in parent
    /** \brief Returns the sublayers of this layer - Useful for providers that manage their own layers, such as WMS */
    virtual QStringList subLayers() const;

    /** \brief Get histogram. Histograms are cached in providers.
     * @param theBandNo The band (number).
     * @param theBinCount Number of bins (intervals,buckets). If 0, the number of bins is decided automaticaly according to data type, raster size etc.
     * @param theMinimum Minimum value, if NaN, raster minimum value will be used.
     * @param theMaximum Maximum value, if NaN, raster minimum value will be used.
     * @param theExtent Extent used to calc histogram, if empty, whole raster extent is used.
     * @param theSampleSize Approximate number of cells in sample. If 0, all cells (whole raster will be used). If raster does not have exact size (WCS without exact size for example), provider decides size of sample.
     * @param theIncludeOutOfRange include out of range values
     * @return Vector of non NULL cell counts for each bin.
     */
    virtual QgsRasterHistogram histogram( int theBandNo,
                                          int theBinCount,
                                          double theMinimum,
                                          double theMaximum,
                                          const QgsRectangle & theExtent = QgsRectangle(),
                                          int theSampleSize = 0,
                                          bool theIncludeOutOfRange = false );

    /** \brief Returns true if histogram is available (cached, already calculated), the parameters are the same as in histogram() */
    virtual bool hasHistogram( int theBandNo,
                               int theBinCount,
                               double theMinimum,
                               double theMaximum,
                               const QgsRectangle & theExtent = QgsRectangle(),
                               int theSampleSize = 0,
                               bool theIncludeOutOfRange = false );

    /** \brief Find values for cumulative pixel count cut.
     * @param theBandNo The band (number).
     * @param theLowerCount The lower count as fraction of 1, e.g. 0.02 = 2%
     * @param theUpperCount The upper count as fraction of 1, e.g. 0.98 = 98%
     * @param theLowerValue Location into which the lower value will be set.
     * @param theUpperValue  Location into which the upper value will be set.
     * @param theExtent Extent used to calc histogram, if empty, whole raster extent is used.
     * @param theSampleSize Approximate number of cells in sample. If 0, all cells (whole raster will be used). If raster does not have exact size (WCS without exact size for example), provider decides size of sample.
     */
    virtual void cumulativeCut( int theBandNo,
                                double theLowerCount,
                                double theUpperCount,
                                double &theLowerValue,
                                double &theUpperValue,
                                const QgsRectangle & theExtent = QgsRectangle(),
                                int theSampleSize = 0 );

    /** \brief Create pyramid overviews */
    virtual QString buildPyramids( const QList<QgsRasterPyramid>  & thePyramidList,
                                   const QString &  theResamplingMethod = "NEAREST",
                                   RasterPyramidsFormat theFormat = PyramidsGTiff );

    /** \brief Accessor for ths raster layers pyramid list.
     * @param overviewList used to construct the pyramid list (optional), when empty the list is defined by the provider.
     * A pyramid list defines the
     * POTENTIAL pyramids that can be in a raster. To know which of the pyramid layers
     * ACTUALLY exists you need to look at the existsFlag member in each struct stored in the
     * list.
     */
    virtual QList<QgsRasterPyramid> buildPyramidList( QList<int> overviewList = QList<int>() );

    /** \brief Returns true if raster has at least one populated histogram. */
    bool hasPyramids();

    /** If the provider supports it, return band stats for the
        given band. Default behaviour is to blockwise read the data
        and generate the stats unless the provider overloads this function. */
    //virtual QgsRasterBandStats bandStatistics( int theBandNo );

    /** \brief Get band statistics.
     * @param theBandNo The band (number).
     * @param theStats Requested statistics
     * @param theExtent Extent used to calc histogram, if empty, whole raster extent is used.
     * @param theSampleSize Approximate number of cells in sample. If 0, all cells (whole raster will be used). If raster does not have exact size (WCS without exact size for example), provider decides size of sample.
     * @return Band statistics.
     */
    virtual QgsRasterBandStats bandStatistics( int theBandNo,
        int theStats = QgsRasterBandStats::All,
        const QgsRectangle & theExtent = QgsRectangle(),
        int theSampleSize = 0 );

    /** \brief Returns true if histogram is available (cached, already calculated), the parameters are the same as in histogram() */
    virtual bool hasStatistics( int theBandNo,
                                int theStats = QgsRasterBandStats::All,
                                const QgsRectangle & theExtent = QgsRectangle(),
                                int theSampleSize = 0 );

    /** \brief helper function to create zero padded band names */
    QString  generateBandName( int theBandNumber ) const;

    /**
     * Get metadata in a format suitable for feeding directly
     * into a subset of the GUI raster properties "Metadata" tab.
     */
    virtual QString metadata() = 0;

    virtual QMap<int, QVariant> identify( const QgsPoint & thePoint, IdentifyFormat theFormat, const QgsRectangle &theExtent = QgsRectangle(), int theWidth = 0, int theHeight = 0 );

    QMap<QString, QString> identify( const QgsPoint & thePoint, const QgsRectangle &theExtent = QgsRectangle(), int theWidth = 0, int theHeight = 0 );

    /**
     * \brief   Returns the caption error text for the last error in this provider
     *
     * If an operation returns 0 (e.g. draw()), this function
     * returns the text of the error associated with the failure.
     * Interactive users of this provider can then, for example,
     * call a QMessageBox to display the contents.
     *
     */
    virtual QString lastErrorTitle() = 0;

    /**
     * \brief   Returns the verbose error text for the last error in this provider
     *
     * If an operation returns 0 (e.g. draw()), this function
     * returns the text of the error associated with the failure.
     * Interactive users of this provider can then, for example,
     * call a QMessageBox to display the contents.
     *
     */
    virtual QString lastError() = 0;

    /**
     * \brief   Returns the format of the error text for the last error in this provider
     *
     * \note added in 1.6
     */
    virtual QString lastErrorFormat();

    /**Returns the dpi of the output device.
      @note: this method was added in version 1.2*/
    int dpi() const;

    /**Sets the output device resolution.
      @note: this method was added in version 1.2*/
    void setDpi( int dpi );

    static QStringList cStringList2Q_( char ** stringList );

    static QString makeTableCell( const QString & value );
    static QString makeTableCells( const QStringList & values );

    /** Time stamp of data source in the moment when data/metadata were loaded by provider */
    virtual QDateTime timestamp() const;

    /** Current time stamp of data source */
    virtual QDateTime dataTimestamp() const;

    /**Writes into the provider datasource*/
    // TODO: add data type (may be defferent from band type)
    virtual bool write( void* data, int band, int width, int height, int xOffset, int yOffset );

    /** Creates a new dataset with mDataSourceURI
        @return true in case of success*/
    virtual bool create( const QString& format, int nBands,
                         QgsRasterBlock::DataType type,
                         int width, int height, double* geoTransform,
                         const QgsCoordinateReferenceSystem& crs,
                         QStringList createOptions = QStringList() /*e.v. color table*/ );

    /** Set no data value on created dataset
     *  @param bandNo band number
     *  @param noDataValue no data value
     */
    virtual bool setNoDataValue( int bandNo, double noDataValue );

    /**Returns the formats supported by create()*/
    virtual QStringList createFormats() const;

    /** Remove dataset*/
    virtual bool remove();

    static QStringList pyramidResamplingMethods( QString providerKey );

    /** Validates creation options for a specific dataset and destination format - used by GDAL provider only.
     * See also validateCreationOptionsFormat() in gdal provider for validating options based on format only. */
    virtual QString validateCreationOptions( const QStringList& createOptions, QString format );

  signals:
    /** Emit a signal to notify of the progress event.
      * Emited theProgress is in percents (0.0-100.0) */
    void progress( int theType, double theProgress, QString theMessage );
    void progressUpdate( int theProgress );

  protected:

    /** Fill in histogram defaults if not specified */
    void initHistogram( QgsRasterHistogram &theHistogram, int theBandNo,
                        int theBinCount,
                        double theMinimum,
                        double theMaximum,
                        const QgsRectangle & theExtent = QgsRectangle(),
                        int theSampleSize = 0,
                        bool theIncludeOutOfRange = false );

    /** Fill in statistics defaults if not specified */
    void initStatistics( QgsRasterBandStats &theStatistics, int theBandNo,
                         int theStats = QgsRasterBandStats::All,
                         const QgsRectangle & theExtent = QgsRectangle(),
                         int theBinCount = 0 );

};
