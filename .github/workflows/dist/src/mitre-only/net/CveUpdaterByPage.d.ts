/**
 * Updates repository's CVEs using CveService
 */
import { ActivityStep } from '../../core/Activity.js';
import { ActivityLogOptions } from '../../core/ActivityLog.js';
import { CveUpdater } from '../../net/CveUpdater.js';
export declare const kActivity_UpdateByModificationDateWindow = "UPDATE_BY_MODIFICATION_DATE_WINDOW";
export declare const kActivity_UpdateByPage = "UPDATE_BY_PAGE";
export declare class CveUpdaterByPage extends CveUpdater {
    constructor(activity: string, logOptions: ActivityLogOptions);
    /** retrieves all CVEs by page
     *  @param page requested page number
     *  @returns an Activity with data and properties OR
     *           null if params are detected to be a no-op
    */
    getCvesByPage(page: number, writeDir?: string | undefined): Promise<ActivityStep>;
}
