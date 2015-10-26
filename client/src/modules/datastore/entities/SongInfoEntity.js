/**
 * @name SongInfoEntity
 * @property {String} songId
 * @property {String} songName
 * @property {String} imageLink
 * @property {String} artistId
 * @property {String} artistName
 * @property {String} albumId
 * @property {String} albumName
 * @property {Number} duration
 * @property {String} genre
 * @property {Number} danceability
 * @property {Number} averageRating
 * @property {Number} personalRating
 * @property {Number} songHotttnesss
 * @property {Number} year
 */
class SongInfoEntity {
  constructor() {
    this.songId = String;
    this.songName = String;
    this.imageLink = String;
    this.artistId = String;
    this.artistName = String;
    this.albumId = String;
    this.albumName = String;
    this.duration = Number;
    this.genre = String;
    this.danceability = Number;
    this.averageRating = Number;
    this.personalRating = Number;
    this.songHotttnesss = Number;
    this.year = Number;
  }
}

export default SongInfoEntity;