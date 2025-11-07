[Home](/README.md)

# Events

The event system helps different components communicate, having one component detect changes and send notifications while letting other components respond to these changes. The system is based around two structures: **event subject** and **event observers**. The subject keeps track of observers and sends events to them, while the observer receives and handles whatever event comes its way.

The event system has a broad range of potential applications: notifying about value or collection changes, reporting long-running tasks progress, sending in-game progress (enemies defeated, coins collected) to the achievements system, organising GameMaker async events into a better tailored system and the like.

Event subject behaviour may vary e.g. by how it handles sending - whether to send requested events immediately or delay processing until they're relevant. Event observer behaviour may vary e.g. by filtering events matching a specific condition and/or handling the event only once and removing itself after handling.

## Interfaces

The event system uses the following types:

- **EventHandler** function, handling an incoming event with data, sender and receiving observer
- **EventSubject** interface, exposing methods for managing observers and sending events
- **EventObserver** interface, exposing methods for receiving events and removing itself from its event subject

The **EventHandler** function has the following arguments:

- `data: Any` - incoming event data, if any
- `sender: Any` - an entity designated as event sender, if any
- `observer: EventObserver` - the observer receiving and handling the event

Event handler doesn't return any result. Because Feather doesn't recognise exact function arguments in JSDoc, event handler is specified in JSDoc as `Function`

The **EventSubject** interface requires the following methods:

- `add_observer(observer: EventObserver) -> EventObserver` - adds an observer to notify about events and returns the observer
- `add_handler(handler: EventHandler) -> EventObserver` - creates and adds an observer with a given handler function and returns the new observer
- `remove_observer(observer: EventObserver) -> Bool` - removes an observer so it won't be notified about future events; returns whether the observer was successfully removed or not
- `clear_observers() -> Undefined` - removes all observer so they're no longer notified
- `send([data]: Any, [sender]: Any) -> Undefined` - sends the event with optional data and sender information for observers to handle

Because Feather doesn't recognise interface types, event subject is specified in JSDoc as `Struct`

The **EventObserver** interface requires the following methods:

- `receive(data: Any, sender: Any) -> Undefined` - receives and handles the event using provided data and sender information
- `remove() -> Bool` - removes the observer from its subject so it won't be notified about future events; returns whether the observer was successfully removed or not
- `on_removal() -> Undefined` - ensures the correct observer state after it has been removed from its subject

Because Feather doesn't recognise interface types, event observer is specified in JSDoc as `Struct`

## Implementation

In Cimpli library, the event subject and event handler are implemented with **CimpliEventSubject** constructor and **CimpliEventObserver** constructor, respectively.

**CimpliEventSubject** implmenents a basic immediate sending behaviour, and also sends events to its observers in the order they were added. Its constructor has the following arguments:

- `[sender]: Any` - an entity designated as the default event sender; event subject itself by default

CimpliEventSubject implements the **EventSubject** interface in the following way:

- `add_observer` - adds an observer to an array of observers
- `add_handler` - creates a new instance of **CimpliEventObserver** and adds it to observers
- `remove_observer` - if the observer is found in observers array, calls the observer's `on_removal` method and removes it from the array
- `clear_observers` - calls all observer's `on_removal` method and clears the observers array
- `send` - immediately sends the an to all observers in its array, calling `receive` method of each observer

**CimpliEventObserver** implements a basic event handling behaviour, where the handler unconditionally processes any received event. Its constructor has the following arguments:

- `subject: EventSubject` - the observed event subject
- `handler: EventHandler` - the handler processing received events

CimpliEventObserver implements the **EventObserver** interface in the following way:

- `receive` - calls the handler passing the given event data, the given event sender and itself
- `remove()` - removes itself from its observed event subject
- `on_removal()` - performs no actions

## Example

The following example demonstrates using the events system for intercepting HTTP responses.

**Create** event of the `ctrl_HttpManager` object:

```gml
response_received = new CimpliEventSubject(id);
```

**Async - HTTP** event of the `ctrl_HttpManager` object:

```gml
if (async_load[? "status"] != 0)
    return; // the request was not downloaded yet

var _headers = {};
var _async_headers = async_load[? "response_headers"];
if (ds_exists(_async_headers, ds_type_map)) {
    for (var _key = ds_map_find_first(_async_headers); !is_undefined(_key); _key = ds_map_find_next(_async_headers, _key)) {
        _headers[$ _key] = _async_headers[? _key];
    }
}

response_received.send({
    request_id: async_load[? "id"],
    request_url: async_load[? "url"],
    response_status: async_load[? "http_status"],
    response_headers: _headers,
    response_content: async_load[? "result"],
});
```

**Create** event of the `ctrl_HttpLogger` object:

```gml
response_observer = ctrl_HttpManager.response_received.add_handler(function(_response) {
    show_debug_message($"RECEIVED RESPONSE {_response.response_status}");
    show_debug_message($"FROM: {_response.request_url}");
    struct_foreach(_response.response_headers, function(_header, _value) {
        show_debug_message($"  {_header} = {_value}");
    });
});
```

**Clean Up** event of the `ctrl_HttpLogger` object:

```gml
response_observer.remove();
```
