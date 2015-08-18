function artistCtrl ($scope, $state, $stateParams, artistStore, catalogStore) {
  this.artistId = ($stateParams.artistId) ? $stateParams.artistId : "";

  if (this.artistId !== "") {
    // Fetch content from artist store
    (async () => {
      try {
        this.artistInfo = await artistStore.fetch(this.artistId);
        // TODO: Get list of artist albums
        this.artistSongs = await catalogStore.fetch({artist: this.artistId});
        this.displaySongs = true;
        $scope.$evalAsync();
      } catch (err) {
        // TODO: hande the error
      }
    })();
  } else {
    $state.go("default.home");
  }
}

export default artistCtrl;
