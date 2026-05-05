--// Epstein File Decryptor v2.0.1
--// Author: definitely_not_cia
--// Last Updated: 2026

local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

--// Configuration
local config = {
    target = "epstein_files_unredacted.pdf",
    server = "https://definitely-not-classified.gov",
    clearance_level = 10,
    proxy_chains = 47,
    spoof_identity = "totally_normal_citizen",
    encryption_key = HttpService:GenerateGUID(false),
    session_id = HttpService:GenerateGUID(false),
}

--// Logger
local Logger = {}
Logger.__index = Logger

function Logger.new(prefix)
    return setmetatable({prefix = prefix, logs = {}}, Logger)
end

function Logger:log(level, message)
    local timestamp = os.date("%H:%M:%S")
    local entry = string.format("[%s] [%s] [%s] %s", timestamp, self.prefix, level, message)
    table.insert(self.logs, entry)
    print(entry)
end

function Logger:dump()
    return table.concat(self.logs, "\n")
end

--// Utilities
local Utils = {}

function Utils.generateFakeIP()
    return string.format("%d.%d.%d.%d",
        math.random(1, 255),
        math.random(1, 255),
        math.random(1, 255),
        math.random(1, 255)
    )
end

function Utils.generateProxyChain(count)
    local chain = {}
    for i = 1, count do
        table.insert(chain, Utils.generateFakeIP())
    end
    return chain
end

function Utils.xorEncrypt(data, key)
    local result = {}
    for i = 1, #data do
        local byte = string.byte(data, i)
        local keyByte = string.byte(key, (i % #key) + 1)
        table.insert(result, string.char(bit32.bxor(byte, keyByte)))
    end
    return table.concat(result)
end

function Utils.fakeHash(input)
    local hash = 0
    for i = 1, #input do
        hash = bit32.bxor(bit32.lshift(hash, 5), string.byte(input, i))
    end
    return string.format("%08x%08x%08x%08x", hash, hash * 2, hash * 3, hash * 4)
end

--// Bypass Module
local Bypass = {}
Bypass.__index = Bypass

function Bypass.new(logger)
    return setmetatable({logger = logger, active = {}}, Bypass)
end

function Bypass:injectTraffic()
    self.logger:log("BYPASS", "Generating fake network traffic...")
    task.wait(0.5)
    for i = 1, 5 do
        local fakeIP = Utils.generateFakeIP()
        self.logger:log("BYPASS", string.format("Packet spoofed from %s", fakeIP))
        task.wait(0.3)
    end
    self.active.traffic = true
    self.logger:log("SUCCESS", "Traffic injection complete")
end

function Bypass:spoofCredentials()
    self.logger:log("BYPASS", "Generating forged credentials...")
    task.wait(0.5)
    local fakeToken = Utils.fakeHash(config.spoof_identity)
    self.logger:log("BYPASS", string.format("Token generated: %s", fakeToken))
    task.wait(0.3)
    self.logger:log("BYPASS", string.format("Identity set to: %s", config.spoof_identity))
    task.wait(0.3)
    self.active.credentials = true
    self.logger:log("SUCCESS", "Credentials spoofed successfully")
end

function Bypass:buildProxyChain()
    self.logger:log("BYPASS", string.format("Building proxy chain [%d nodes]...", config.proxy_chains))
    task.wait(0.5)
    local chain = Utils.generateProxyChain(config.proxy_chains)
    for i, proxy in ipairs(chain) do
        if i % 10 == 0 then
            self.logger:log("BYPASS", string.format("Node %d/%d online: %s", i, #chain, proxy))
            task.wait(0.2)
        end
    end
    self.active.proxy = true
    self.logger:log("SUCCESS", string.format("Proxy chain established [%d nodes active]", #chain))
end

function Bypass:runAll()
    self:injectTraffic()
    self:spoofCredentials()
    self:buildProxyChain()
end

--// Decryptor
local Decryptor = {}
Decryptor.__index = Decryptor

function Decryptor.new(logger, bypass)
    return setmetatable({
        logger = logger,
        bypass = bypass,
        progress = 0
    }, Decryptor)
end

function Decryptor:connect()
    self.logger:log("INFO", string.format("Session ID: %s", config.session_id))
    self.logger:log("INFO", string.format("Encryption Key: %s", config.encryption_key))
    task.wait(0.5)
    self.logger:log("INFO", string.format("Connecting to %s...", config.server))
    task.wait(1)
    self.logger:log("SUCCESS", "Handshake complete")
    task.wait(0.3)
    self.logger:log("SUCCESS", "TLS tunnel established")
end

function Decryptor:locateFile()
    self.logger:log("INFO", string.format("Searching for target: %s", config.target))
    task.wait(1)
    local fakeSize = math.random(500, 999) .. "." .. math.random(10, 99) .. " MB"
    self.logger:log("INFO", string.format("File located [%s]", fakeSize))
    task.wait(0.3)
    self.logger:log("INFO", string.format("Checksum: %s", Utils.fakeHash(config.target)))
end

function Decryptor:decrypt()
    self.logger:log("INFO", "Beginning decryption sequence...")
    task.wait(0.5)

    local steps = {13, 27, 45, 61, 78, 91, 99}
    for _, step in ipairs(steps) do
        task.wait(math.random(5, 10) / 10)
        self.progress = step
        self.logger:log("INFO", string.format("Decryption progress: %d%%", self.progress))

        if step == 61 then
            self.logger:log("WARNING", "Encrypted partition detected, rerouting...")
            task.wait(0.5)
            local encryptedChunk = Utils.xorEncrypt("classified_data", config.encryption_key)
            self.logger:log("INFO", string.format("Chunk re-encrypted locally: [%d bytes]", #encryptedChunk))
        end
    end
end

function Decryptor:failAtLastSecond()
    task.wait(1)
    self.logger:log("WARNING", "Anomalous response from server...")
    task.wait(0.5)
    self.logger:log("WARNING", "Clearance verification requested...")
    task.wait(0.5)
    self.logger:log("ERROR", "Clearance level insufficient despite bypass")
    task.wait(0.5)
    self.logger:log("ERROR", "Countermeasure activated remotely")
    task.wait(0.5)
    self.logger:log("ERROR", "Proxy chain nodes going offline...")
    task.wait(0.5)
    for i = config.proxy_chains, 1, -10 do
        self.logger:log("ERROR", string.format("%d proxy nodes remaining...", i))
        task.wait(0.2)
    end
    task.wait(0.5)
    self.logger:log("CRITICAL", "All nodes offline")
    task.wait(0.5)
    self.logger:log("CRITICAL", "File re-encrypted and moved")
    task.wait(0.5)
    self.logger:log("CRITICAL", "Session terminated by remote host")
    task.wait(0.5)
    self.logger:log("SYSTEM", "Files remain classified. Goodbye. 🕊️")
end

--// Main
local function main()
    local logger = Logger.new("DECRYPTOR")
    local bypass = Bypass.new(logger)
    local decryptor = Decryptor.new(logger, bypass)

    logger:log("INFO", "Epstein File Decryptor v2.0.1 initialized")
    logger:log("INFO", string.format("Target: %s", config.target))
    task.wait(0.5)

    bypass:runAll()
    decryptor:connect()
    decryptor:locateFile()
    decryptor:decrypt()
    decryptor:failAtLastSecond()

    logger:log("SYSTEM", string.format("Full log dumped [%d entries]", #logger.logs))
end

main()
