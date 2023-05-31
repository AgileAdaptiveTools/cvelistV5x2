import { Command } from 'commander';
import { GenericCommand } from '../../commands/GenericCommand.js';
/**
 * Command to rebuild the the CVEs local directory (defined in .env, but usually ./cves)
 *
 * Note this is a very expensive operation, and requires a special account with privileges on CVE Servies.
 * It usually takes about 30-45 minutes to complete.
 *
 * This is currently only used once a day to verify that all CVEs in CVE Services is cached
 * to the local directory.
 *
 * Note that while it does download all CVEs, it requires a manual update to the CVEProject/cvelistV5 repository.
 *
 */
export declare class RebuildCommand extends GenericCommand {
    constructor(program: Command);
    run(options: any): Promise<void>;
}
