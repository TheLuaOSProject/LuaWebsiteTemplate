--[[
Based off
```ts
type EffectFn = () => void;

interface Subscription {
    execute: EffectFn;
    dependencies: Set<Set<Subscription>>; // Now correctly typed to store sets of subscriptions
}

const context: Subscription[] = [];

function subscribe(running: Subscription, subscriptions: Set<Subscription>) {
    subscriptions.add(running);
    running.dependencies.add(subscriptions); // Correctly add the set of subscriptions to the dependencies
}

export function createSignal<T>(value: T): [() => T, (nextValue: T) => void] {
    const subscriptions: Set<Subscription> = new Set();

    const read = (): T => {
        const running = context[context.length - 1];
        if (running) {
            subscribe(running, subscriptions);
        }
        return value;
    };

    const write = (nextValue: T): void => {
        value = nextValue;
        for (const sub of subscriptions) {
            sub.execute();
        }
    };
    return [read, write];
}

function cleanup(running: Subscription): void {
    for (const dep of running.dependencies) {
        dep.delete(running); // This should now work as 'dep' is correctly identified as a Set<Subscription>
    }
    running.dependencies.clear();
}

export function createEffect(fn: EffectFn): void {
    const effect: Subscription = {
        execute: () => {
            cleanup(effect);
            context.push(effect);
            try {
                fn();
            } finally {
                context.pop();
            }
        },
        dependencies: new Set()
    };

    effect.execute();
}

export function createMemo<T>(fn: () => T): () => T {
    let [s, set] = createSignal<T>(undefined as unknown as T);
    createEffect(() => set(fn()));
    return s;
}
```
]]
---@class reactive.base
local reactive = {}

---@class reactive.base.Subscription
---@field execute fun(): nil
---@field dependencies reactive.base.Subscription[][]

---@type reactive.base.Subscription[]
local context = {}

---@param running reactive.base.Subscription
---@param subscriptions reactive.base.Subscription[]
local function subscribe(running, subscriptions)
    table.insert(subscriptions, running)
    table.insert(running.dependencies, subscriptions)
end

---@generic T
---@param value T
---@return (fun(): T) get, (fun(nextValue: T): nil) set
function reactive.create_signal(value)
    local subscriptions = {}
    local function read()
        local running = context[#context]
        if running then
            subscribe(running, subscriptions)
        end
        return value
    end
    local function write(next_value)
        value = next_value
        for _, sub in ipairs(subscriptions) do
            sub:execute()
        end
    end
    return read, write
end

---@param running reactive.base.Subscription
local function cleanup(running)
    for _, dep in ipairs(running.dependencies) do
        for i, v in ipairs(dep) do
            if v == running then
                table.remove(dep, i)
                break
            end
        end
    end
    running.dependencies = {}
end

---@param fn fun(): nil
function reactive.create_effect(fn)
    local effect = {
        execute = function(effect)
            cleanup(effect)
            table.insert(context, effect)
            fn()
            table.remove(context)
        end,
        dependencies = {}
    }
    effect:execute()
end

---@generic T
---@param fn fun(): T
---@return fun(): T
function reactive.create_memo(fn)
    local get, set = reactive.create_signal(nil)
    reactive.create_effect(function()
        set(fn())
    end)
    return get
end

return reactive
