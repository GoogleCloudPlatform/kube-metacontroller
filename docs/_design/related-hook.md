### CompositeController changes

The composite controller `sync` and `finalize` hooks will contain a new field, `related`.

This field is in the same format as `children` / `ChildMap`.

### Related Hook

If the `related` hook is defined, Metacontroller will ask for which related
objects, or classes of objects that your `sync` and `finalize` hooks need to
know about.

This is useful for mapping across many objects. One example would be a
controller that lets you specify ConfigMaps to be placed in every Namespace.

Another use-case is being able to reference other objects, e.g. the `env`
section from a core `Pod` object.

If you don't define a `related` hook, then the related section of the hooks will
be empty.

The `related` hook will not provide any information about the current state of
the cluster. Thus, the set of related objects may only depend on the state of
the parent object.

#### Related Hook Request

A separate request will be sent for each parent object,
so your hook only needs to think about one parent at a time.

The body of the request (a POST in the case of a [webhook][])
will be a JSON object with the following fields:

| Field | Description |
| ----- | ----------- |
| `controller` | The whole CompositeController object, like what you might get from `kubectl get compositecontroller <name> -o json`. |
| `parent` | The parent object, like what you might get from `kubectl get <parent-resource> <parent-name> -o json`. |

#### Related Hook Response

The body of your response should be a JSON object with the following fields:

| Field | Description |
| ----- | ----------- |
| `labelSelectors` | A list of JSON objects representing all the desired label selectors for this parent object. |

The `labelSelectors` field should contain a flat list of objects,
not an associative array.

Each labelSelector object should be a JSON object with the following fields:
| Field | Description |
| ----- | ----------- |
| `apiVersion` | The API Version |
| `kind` | The API Kind |
| `labelSelector` | A `v1.LabelSelector` object. |
| `namespace` | Optional. The Namespace to select in |

If the parent resource is cluster scoped and the related resource is namespaced,
the namespace may be used to restrict which objects to look at. If the parent
resource is namespaced, the related resources must come from the same namespace.
Specifying the namespace is optional, but if specified must match.

Note that your webhook handler must return a response with a status code of `200`
to be considered successful. Metacontroller will wait for a response for up to the
amount defined in the [Webhook spec](/api/hook/#webhook).
