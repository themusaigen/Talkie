-- For Signal`s types.
local Signal = require(script.Parent.Shared.Signal)

export type ClientCallback = (...any) -> ...any
export type ClientHandler = (...any) -> ()
export type ClientObserver = (value: any) -> ()
export type ClientMiddlewareFun = (...any) -> (boolean, table?)
export type ClientMiddlewareList = { ClientMiddlewareFun }
export type ClientMiddleware = { [string]: ClientMiddlewareList }
export type ClientParseResult = { ClientFunction | ClientEvent | ClientProperty }

export type ClientFunction = {
	Listen: (self: ClientFunction, callback: ClientCallback) -> (),
	Invoke: (self: ClientFunction, ...any) -> ...any,
	SetMiddleware: (self: ClientFunction, middleware: ClientMiddleware) -> (),
}

export type ClientEvent = {
	Connect: (self: ClientEvent, handler: ClientHandler) -> Signal.Connection,
	Once: (self: ClientEvent, handler: ClientHandler) -> Signal.Connection,
	Wait: (self: ClientEvent) -> ...any,
	Fire: (self: ClientEvent, ...any) -> (),
	SetMiddleware: (self: ClientEvent, middleware: ClientMiddleware) -> (),
	Destroy: (self: ClientEvent) -> (),
}

export type ClientProperty = {
	Get: (self: ClientProperty) -> any,
	RequestToSync: (self: ClientProperty) -> (),
	Observe: (self: ClientProperty, observer: ClientObserver) -> (),
	SetMiddleware: (self: ClientFunction, middleware: ClientMiddleware) -> (),
	IsReady: (self: ClientProperty) -> boolean,
}

export type Client = {
	Function: (self: Client, name: string, handler: ClientHandler?, middleware: ClientMiddleware?) -> ClientFunction,
	Event: (self: Client, name: string, middleware: ClientMiddleware?) -> ClientEvent,
	Property: (self: Client, name: string, middleware: ClientMiddleware?) -> ClientProperty,
	Parse: (self: Client) -> ClientParseResult,
	Inbound: (...ClientMiddlewareFun) -> ClientMiddleware,
	Outbound: (...ClientMiddlewareFun) -> ClientMiddleware,
}

export type ServerCallback = (player: Player, ...any) -> ...any
export type ServerHandler = (player: Player, ...any) -> ()
export type ServerMiddlewareFun = (player: Player?, ...any) -> (boolean, table?) -- Player is optional.
export type ServerMiddlewareList = { ServerMiddlewareFun }
export type ServerMiddleware = { [string]: ServerMiddlewareList }
export type ServerFilter = (player: Player) -> boolean
export type ServerSetFilter = (player: Player, value: any) -> boolean

export type ServerFunction = {
	Listen: (self: ServerFunction, callback: ServerCallback) -> (),
	Invoke: (self: ServerFunction, player: Player, ...any) -> ...any,
	SetMiddleware: (self: ServerFunction, middleware: ServerMiddleware) -> (),
	Destroy: (self: ServerFunction) -> (),
}

export type ServerEvent = {
	Connect: (self: ServerEvent, handler: ServerHandler) -> Signal.Connection,
	Once: (self: ServerEvent, handler: ServerHandler) -> Signal.Connection,
	Wait: (self: ServerEvent) -> ...any,
	Fire: (self: ServerEvent, player: Player | { Players }, ...any) -> (),
	FireAll: (self: ServerEvent, ...any) -> (),
	FireByFilter: (self: ServerEvent, filter: ServerFilter, ...any) -> (),
	FireExcept: (self: ServerEvent, players: Player | { Player }, ...any) -> (),
	SetMiddleware: (self: ServerEvent, middleware: ServerMiddleware) -> (),
	Destroy: (self: ServerEvent) -> (),
}

export type ServerProperty = {
	Set: (self: ServerProperty, value: any) -> (),
	GetFor: (self: ServerProperty, player: Player) -> (),
	SetFor: (self: ServerProperty, player: Player | { Player }, value: any) -> (),
	SetTop: (self: ServerProperty, value: any) -> (),
	SetByFilter: (self: ServerProperty, filter: ServerSetFilter, value: any) -> (),
	ClearFor: (self: ServerProperty, player: Player | { Player }) -> (),
	ClearAll: (self: ServerProperty) -> (),
	ClearByFilter: (self: ServerProperty, filter: ServerFilter) -> (),
	Destroy: (self: ServerProperty) -> (),
	SetMiddleware: (self: ServerProperty, middleware: ServerMiddleware) -> (),
}

export type Server = {
	Function: (self: Server, name: string, handler: ServerHandler?, middleware: ServerMiddleware?) -> ServerFunction,
	Event: (self: Server, name: string, unreliable: boolean?, middleware: ServerMiddleware?) -> ServerEvent,
	Property: (self: Server, name: string, value: any, middleware: ServerMiddleware?) -> ServerProperty,
	Inbound: (...ServerMiddlewareFun) -> ServerMiddleware,
	Outbound: (...ServerMiddlewareFun) -> ServerMiddleware,
}

export type SharedEntityList = {
	[string]: ServerEvent | ServerProperty | ServerFunction | ClientFunction | ClientEvent | ClientProperty,
}

export type Storage<T> = {
	new: (parent: Instance, name: string, ...any) -> T,
}

export type Buffer = {
	Resize: (self: Buffer, size: number) -> (),
	Serialize: (self: Buffer) -> string,
	GetData: (self: Buffer) -> buffer,
	SetData: (self: Buffer, data: Buffer | string | buffer) -> (),
	Reset: (self: Buffer) -> (),
	ResetReadOffset: (self: Buffer) -> (),
	ResetWriteOffset: (self: Buffer) -> (),
	ResetOffsets: (self: Buffer) -> (),
	SetWriteOffset: (self: Buffer, offset: number) -> (),
	SetReadOffset: (self: Buffer, offset: number) -> (),
	GetSize: (self: Buffer) -> number,
	IgnoreBytes: (self: Buffer, count: number) -> (),
	GetNumberOfBytesUsed: (self: Buffer) -> number,
	GetNumberOfUnreadBytes: (self: Buffer) -> number,
	ReadBoolean: (self: Buffer) -> boolean,
	WriteBoolean: (self: Buffer, state: boolean) -> (),
	ReadBuffer: (self: Buffer, size: number) -> Buffer,
	WriteBuffer: (self: Buffer, input: Buffer | buffer | string) -> (),
	ReadString: (self: Buffer, len: number) -> string,
	WriteString: (self: Buffer, str: string) -> (),
	ReadUInt8: (self: Buffer) -> number,
	ReadUInt16: (self: Buffer) -> number,
	ReadUInt32: (self: Buffer) -> number,
	ReadInt8: (self: Buffer) -> number,
	ReadInt16: (self: Buffer) -> number,
	ReadInt32: (self: Buffer) -> number,
	ReadFloat: (self: Buffer) -> number,
	ReadFloat32: (self: Buffer) -> number,
	ReadFloat64: (self: Buffer) -> number,
	WriteUInt8: (self: Buffer, input: number) -> (),
	WriteUInt16: (self: Buffer, input: number) -> (),
	WriteUInt32: (self: Buffer, input: number) -> (),
	WriteInt8: (self: Buffer, input: number) -> (),
	WriteInt16: (self: Buffer, input: number) -> (),
	WriteInt32: (self: Buffer, input: number) -> (),
	WriteFloat: (self: Buffer, input: number) -> (),
	WriteFloat32: (self: Buffer, input: number) -> (),
	WriteFloat64: (self: Buffer, input: number) -> (),
}

export type TrivialType<T> = {
	read: (buf: Buffer) -> T,
	write: (buf: Buffer, value: T) -> ()
}
export type TypePair<T> = {[string]: TrivialType<T>}
export type TypeList<T> = {TypePair<T>}

export type BufferIO = {
	Int8: TrivialType<number>,
	Int16: TrivialType<number>,
	Int32: TrivialType<number>,
	UInt8: TrivialType<number>,
	UInt16: TrivialType<number>,
	UInt32: TrivialType<number>,
	Float: TrivialType<number>,
	Float32: TrivialType<number>,
	Float64: TrivialType<number>,
	Boolean: TrivialType<boolean>,
	String8: TrivialType<string>,
	String16: TrivialType<string>,
	String32: TrivialType<string>,
	Vector2: TrivialType<Vector2>,
	Vector2int16: TrivialType<Vector2int16>,
	Vector3: TrivialType<Vector3>,
	Vector3int16: TrivialType<Vector3int16>,
	Color3: TrivialType<Color3>,
	CFrame: TrivialType<CFrame>,
	Array8: <T>(valueType: TrivialType<T>) -> TrivialType<{T}>,
	Array16: <T>(valueType: TrivialType<T>) -> TrivialType<{T}>,
	Array32: <T>(valueType: TrivialType<T>) -> TrivialType<{T}>,
	Optional: <Args...>(...TrivialType<Args...>) -> TrivialType<{[string]: any}>,
	Struct: (...{[string]: TrivialType<any>}) -> TrivialType<{[string]: any}>,
	Default: <T>(valueType: TrivialType<T>, default: T) -> TrivialType<T>,
	Map8: <K, V>(keyType: TrivialType<K>, valueType: TrivialType<V>) -> TrivialType<{[K]: V}>,
	Map16: <K, V>(keyType: TrivialType<K>, valueType: TrivialType<V>) -> TrivialType<{[K]: V}>,
	Map32: <K, V>(keyType: TrivialType<K>, valueType: TrivialType<V>) -> TrivialType<{[K]: V}>
}

export type Packet = {
	Serialize: (self: Packet, data: table) -> Buffer,
	Deserialize: (self: Packet, data: Buffer | buffer | string) -> {[string]: any},
}

export type ChannelConfiguration = {
	Tickrate: number,
	UseReliable: boolean,
	UseUnreliable: boolean,
}

return nil
