/**
 * Wrapper object that provides access to the CVE ID Services API
 *  Note that the location of the CVE Services API, username, password, tokens, etc., is
 *    set in the project's .env file.
 */
import { ApiBaseService } from '../../net/ApiBaseService.js';
export interface CveIdResponse {
    cve_ids: CveIdData[];
    totalCount: number;
    itemsPerPage: number;
    pageCount: number;
    currentPage: number;
    prevPage: number | null;
    nextPage: number | null;
}
export interface CveIdData {
    "requested_by": {
        "user": string;
        "cna": string;
    };
    "time": {
        "created": string;
        "modified": string;
    };
    "cve_id": string;
    "cve_year": string;
    "state": "RESERVED" | "PUBLISHED" | "REJECTED";
    "reserved": string;
    "owning_cna": string;
}
export interface CveIdApiOptions {
    cve_id_year?: string;
    page?: number;
    state?: "RESERVED" | "PUBLISHED" | "REJECTED";
    time_reserved_lt?: string;
    time_reserved_gt?: string;
    time_modified_lt?: string;
    time_modified_gt?: string;
}
export declare class CveIdService extends ApiBaseService {
    constructor();
    getAllCveIdsPages(options: CveIdApiOptions): Promise<CveIdResponse>;
    /** returns the CVE IDs from a specified year
     *
     */
    getCveIdsUsingYear(year: string): Promise<CveIdResponse>;
    /** wrapper for /cve-id */
    cveIds(option: CveIdApiOptions): Promise<CveIdResponse>;
}
