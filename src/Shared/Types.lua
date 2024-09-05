-- For Signal`s types.
local Signal = require(script.Parent.Parent.Packages.Signal)

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

return nil
