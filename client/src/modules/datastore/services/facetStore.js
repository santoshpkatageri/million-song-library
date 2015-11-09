/**
 * Facet store
 * @param {request} request
 * @param {entityMapper} entityMapper
 * @param {FacetListEntity} FacetListEntity
 * @returns {*}
 */
export default function facetStore(request, entityMapper, FacetListEntity) {
  'ngInject';

  const API_REQUEST_PATH = '/msl/v1/catalogedge/facet/';

  return {
    /**
     * fetch facets from catalogedge's facet endpoint
     * @param {string} facetId
     */
    async fetch(facetId = '~') {
      const response = await request.get(`${ API_REQUEST_PATH }${ facetId }`);
      return entityMapper(response.data, FacetListEntity);
    },
  };
}