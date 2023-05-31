/** object that encapsulates all tested and MITRE-only commands
 *  MITRE-only commands are commands that either are useful to MITRE only
 *  (e.g., commands that cannot run without Secretariat or BulkDownload roles)
 *  or
 *  commands that are not fully implemented/tested and so should be kept internal
 *  for now.
 *
*/
import { MainCommands } from '../../commands/MainCommands.js';
export declare class MitreOnlyCommands extends MainCommands {
    constructor(version: string);
    run(): Promise<void>;
}
