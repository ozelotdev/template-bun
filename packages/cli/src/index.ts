import { green } from "kolorist";
import minimist from "minimist";
import prompts from "prompts";

const args = minimist<{
	word: string;
}>(
	process.argv.slice(2),
	{
		string: ['word'],
	}
);

const answer = await prompts([
	{
		type: 'text',
		name: 'word',
		message: 'What is your name?',
		initial: args.word,
	},
])

const message = green(`Hello ${answer.word}`);

console.log(message);

process.exit(0);
