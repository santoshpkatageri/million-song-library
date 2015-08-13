import SongListEntity from "../entities/SongListEntity";

function myLibraryStore (request, entityMapper) {
  "ngInject";

  const API_REQUEST_PATH = "/api/accountedge/users/mylibrary";
  return {
    /**
     * @return {SongListEntity}
     */
    async fetch() {
      return entityMapper(await request.get(API_REQUEST_PATH), SongListEntity);
    }
  };
}

export default myLibraryStore;
