discordia = require('discordia')
client = discordia.Client()
local timer = require("timer")
local help = require("help")
base64 = require('base64')
http1 = require('coro-http')
command = require("commands")

local WeekbotVersion = "0.0.1"
coroutine.wrap(function()
	local head, body = http1.request("GET", "http://mrjuicylemon.es/Discordia/WeekBotVersion.txt")
	if body ~= WeekbotVersion then
		print("Your version: "..WeekbotVersion.."\nLatest version: "..body)
		print("Please run\n\nluvit init.lua\n\nto download the latest bot version.")
		timer.sleep(1000)
		print("Do you want to run the bot even if it's not up to date? Y/N")
		local answer = io.read()
		if answer == "N" then
			print("Exiting.")
			os.exit()
		end
	end
end)()

local currentStatus = ""

local function RandomFact(table)
	assert(type(table) == "table", "RandomFact: table expected.")
	if table then
		local randomed = math.random(1, #table)
		return randomed, table[randomed]
	end
end

local function read_file(path)
	local file = io.open(path, "rb")
	if not file then return nil end
	local content = file:read "*a"
	file:close()
	return content
end

function WriteFile(path, file, text)
	local file = io.open(path.."/"..file..".txt", "w")
	file:write(text)
	file:close()
end

local function UpdateBot(avatar, status)
	coroutine.wrap(function()
		local success, result = pcall(function()
			local _, av = Http.request("GET", avatar)
			client:setAvatar("data:image/png;base64,"..base64.encode(av))
			client:setGameName(status)
			currentStatus = status
		end)
		if success then
			WriteFile("WeekBotModules","WeekBotAvatar", date[WhichDay].avatar)
			print("Successfully changed the avatar.")
			print("Successfully changed the status.")
			currentStatus = status
		else
			print(result)
		end
	end)()
end

client:on("ready", function()
	for guild in client.guilds do
		p(func.ts(guild))
	end
	if read_file("WeekBotModules/WeekBotAvatar.txt") ~= date[WhichDay].avatar then
		UpdateBot(date[WhichDay].avatar, date[WhichDay].status)
	else
		print("Bot was not updated as it was already.")
		currentStatus = date[WhichDay].status
	end
end)

client:on("messageCreate", function(message)
	if currentStatus ~= date[WhichDay].status then
		UpdateBot(date[WhichDay].avatar, date[WhichDay].status)
	end
	if not message or message.author == client.user then return end

	local cmd, arg = string.match(message.content, '(%S+) (.*)')
	cmd = cmd or message.content

	if cmd == "!fact" then
		local number, fact = RandomFact(date[WhichDay].facts)
		command[cmd](message, number, fact)
	end

	if cmd == "!help" then
		message.channel:sendMessage(" ", help[arg] or help["empty"])
	end

	if command[cmd] then -- !restart, !guilds
		command[cmd](message, client)
	end

	if cmd == "!update" then
		func.Requesting(message, "Updating myself...")
		UpdateBot(date[WhichDay].avatar, date[WhichDay].status)
		func.Success(message, "Updated. It took **"..math.random(10, 70).."** ms to change my avatar and Game Name.")
	end
end)


client:run(read_file("WeekBotModules/token.txt"))
