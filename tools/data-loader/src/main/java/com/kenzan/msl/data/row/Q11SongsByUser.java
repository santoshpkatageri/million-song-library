package com.kenzan.msl.data.row;

import java.util.ArrayList;
import java.util.Date;
import java.util.List;
import java.util.UUID;

import com.kenzan.msl.data.ContentType;
import com.kenzan.msl.data.NormalizedRow;

public class Q11SongsByUser {

    private final UUID userId;
    private final ContentType contentType = ContentType.SONG;
    private final Date favoritesTimestamp;
    private final UUID songId;
    private final UUID albumId;
    private final String albumName;
    private final int albumYear;
    private final UUID aritstId;
    private final UUID artistMbid;
    private final String artistName;
    private final int songDuration;
    private final String songName;
    
    public Q11SongsByUser(final NormalizedRow normalizedRow, final UUID userId,  final Date favoritesTimestamp) {

        this.userId = userId;
        this.favoritesTimestamp = favoritesTimestamp;
        this.songId = normalizedRow.getSong().getId();
        this.albumId = normalizedRow.getAlbum().getId();
        this.albumName = normalizedRow.getAlbum().getName();
        this.albumYear = normalizedRow.getAlbum().getYear();
        this.aritstId = normalizedRow.getArtist().getId();
        this.artistMbid = normalizedRow.getArtist().getMbid();
        this.artistName = normalizedRow.getArtist().getName();
        this.songDuration = normalizedRow.getSong().getDuration();
        this.songName = normalizedRow.getSong().getName();
    }
    
    public String toString() {
        
        final List<String> row = new ArrayList<String>();
        row.add(userId.toString());
        row.add(contentType.toString());
        row.add(RowUtil.formatTimestamp(favoritesTimestamp));
        row.add(songId.toString());
        row.add(albumId.toString());
        row.add(RowUtil.formatText(albumName));
        row.add(RowUtil.formatYear(albumYear));
        row.add(aritstId.toString());
        row.add(artistMbid.toString());
        row.add(RowUtil.formatText(artistName));
        row.add(Integer.toString(songDuration));
        row.add(RowUtil.formatText(songName));
        return String.join(",", row);
    }
}
