import { Command } from 'commander';
import { GenericCommand } from '../../commands/GenericCommand.js';
export declare class GithubActionCommand extends GenericCommand {
    constructor(program: Command);
    static shouldCollect(element: any, options: any): boolean;
    static collectRuns(options: any): Promise<any[]>;
    run(options: any): Promise<void>;
}
