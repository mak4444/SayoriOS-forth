#ifndef SAYORI_ISO9660_H
#define SAYORI_ISO9660_H

#include <common.h>
#include <io/ports.h>
#include <fs/fsm.h>

typedef struct {
    uint8_t  Zero;                          ///< [0+1] Указывает на загрузочную запись?
    char     ID[5];				            ///< [1+5] ОЕМ-идентификатор (Всегда CD001)
    uint8_t  Version;                       ///< [6+1] Версия файловой системы
    uint8_t  UnUsed00;                      ///< [7+1] [!] Все нули
    char     SystemName[32];                ///< [8+32] Имя системы, которая может работать с секторами 0x00–0x0F тома.
    char     Label[32];                     ///< [40+32] Метка диска
    char     UnUsed01[8];                   ///< [72] [!] Все нули
    int32_t  VolumeSpaceSize[2];            ///< [80] Количество логических блоков, в которых записан том.
    char     UnUsed02[32];                  ///< [88] [!] Все нули
    int32_t  VolumeSetSize;                 ///< [120] Количество логических блоков, в которых записан том.
    int32_t  VolumeSequenceNumber;          ///< [124] Номер этого диска в наборе томов.
    int32_t  LogicalBlockSize;              ///< [128] Размер логического блока в байтах. NB: Это означает, что логический блок на компакт-диске может иметь размер, отличный от 2 КиБ!
    int32_t  PathTableSize[2];              ///< [132] Размер таблицы путей в байтах.
    int32_t  LocOfType_L_PathTable;         ///< [140] Расположение LBA таблицы путей. Таблица путей, на которую указывает, содержит только значения с прямым порядком байтов.
    int32_t  LocOfOpti_L_PathTable;         ///< [144] Местоположение LBA дополнительной таблицы путей. Таблица путей, на которую указывает, содержит только значения с прямым порядком байтов. Ноль означает, что дополнительная таблица путей не существует.
    int32_t  LocOfType_M_PathTable;         ///< [148] Расположение LBA таблицы путей. Таблица путей, на которую указывает, содержит только значения с прямым порядком байтов.
    int32_t  LocOfOpti_M_PathTable;         ///< [152] Местоположение LBA дополнительной таблицы путей. Таблица путей, на которую указывает, содержит только значения с прямым порядком байтов. Ноль означает, что дополнительная таблица путей не существует.
    char     DirectoryEntry[34];            ///< [156] Обратите внимание, что это не адрес LBA, а фактическая запись каталога, которая содержит однобайтовый идентификатор каталога (0x00), отсюда и фиксированный размер в 34 байта.
    char     VolumeSetID[128];              ///< [190] Идентификатор набора томов, членом которого является этот том.
    char     PublisherID[128];              ///< [318] Издательство тома. Для расширенной информации об издателе первый байт должен быть 0x5F, за которым следует имя файла в корневом каталоге. Если не указано, все байты должны быть 0x20.
    char     DataPreparerID[128];           ///< [446] Идентификатор лица(ов), подготовившего данные для этого тома. Для расширенной информации о подготовке первый байт должен быть 0x5F, за которым следует имя файла в корневом каталоге. Если не указано, все байты должны быть 0x20.
    char     ApplicationID[128];            ///< [574] Определяет, как данные записываются на этот том. Для расширенной информации первый байт должен быть 0x5F, за которым следует имя файла в корневом каталоге. Если не указано, все байты должны быть 0x20.
    char     CopyrightFileID[37];           ///< [702] Имя файла в корневом каталоге, который содержит информацию об авторских правах для этого набора томов. Если не указано, все байты должны быть 0x20
    char     AbstractFileID[37];            ///< [739] Имя файла в корневом каталоге, который содержит абстрактную информацию для этого набора томов. Если не указано, все байты должны быть 0x20.
    char     BibliographicFileID[37];       ///< [776] Имя файла в корневом каталоге, содержащего библиографическую информацию для этого набора томов. Если не указано, все байты должны быть 0x20.
    char     VolumeCreationDate[17];        ///< [813] Дата и время создания тома.
    char     VolumeModificationDate[17];    ///< [830] Дата и время изменения тома.
    char     VolumeExpirationDate[17];      ///< [847] Дата и время, после которых этот том считается устаревшим. Если не указано, том никогда не считается устаревшим.
    char     VolumeEffectiveDate[17];       ///< [864] Дата и время, после которых том можно будет использовать. Если не указано иное, том можно использовать немедленно.
    int8_t   FileStructureVersion;          ///< [881] Записи каталога и версия таблицы путей (всегда 0x01).
    int8_t   UnUsed03;                      ///< [882] [!] Всегда 0x00.
    char     ApplicationUsed[512];          ///< [883] Содержание не определено ISO 9660.
    char     Reserved[653];                 ///< [1395] Зарезервировано ISO.
} ISO9660_PVD;  ///< Primary Volume Descriptor || Дескриптор основного тома

typedef struct {
    int8_t   LengthDirectoryRecord;         ///< [0] Длина записи каталога.
    int8_t   ExtendedAttributeRecord;       ///< [1] Длина расширенной записи атрибутов.
    uint32_t LBA[2];                        ///< [2] Местоположение экстента (LBA) в формате с прямым порядком байтов.
    uint32_t Lenght[2];                     ///< [10] Длина данных (размер экстента) в формате с прямым порядком байтов.
    char     Date[7];                       ///< [18] Дата и время записи.
    int8_t   Flags;                         ///< [25] Флаги файлов.
    int8_t   Mode;                          ///< [26] Размер файловой единицы для файлов, записанных в чередующемся режиме, в противном случае — ноль.
    int8_t   Interval;                      ///< [27] Размер интервала чередования для файлов, записанных в режиме чередования, в противном случае — ноль.
    uint32_t VolumeSequenceNumber;          ///< [28] Порядковый номер тома — том, на котором записан этот экстент, в 16-битном формате с прямым порядком байтов.
    int8_t   ID;                            ///< [32] Длина идентификатора файла (имя файла). Это заканчивается знаком ';' символ, за которым следует идентификационный номер файла в десятичном формате ASCII («1»).
    char*    FileID;                        ///< [33] Идентификатор файла.

} ISO9660_Entity;  ///< Сущность файла или папки

size_t fs_iso9660_read(char Disk,const char* Path, size_t Offset, size_t Size,void* Buffer);
size_t fs_iso9660_write(char Disk,const char* Path,size_t Offset,size_t Size,void* Buffer);
FSM_FILE fs_iso9660_info(char Disk,const char* Path);
FSM_DIR* fs_iso9660_dir(char Disk,const char* Path);
int fs_iso9660_create(char Disk,const char* Path,int Mode);
int fs_iso9660_delete(char Disk,const char* Path,int Mode);
void fs_iso9660_label(char Disk, char* Label);
int fs_iso9660_detect(char Disk);
#endif //SAYORI_ISO9660_H
