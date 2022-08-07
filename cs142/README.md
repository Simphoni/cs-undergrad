Stanford CS142: Web Applications

# JavaScript
## `arr.map(func)`
`arr` is an array of objects  
`func` is usually an anonymous function  
the result is an array of the objects mapped and in the original order
## `for (i in arr)`
`i` is initiated with arr's index
## `for (i of arr)`
`i` is initiated with values of arr

# React
## `React.createElement(types, props, ...children)`
+ type: HTML tag / React.Component
+ props: attribute
+ children: string / React element / array of ...
## `[count, setCount] = useState(initVal)`
+ initVal: value to initiate count
+ count: a member of the current class
+ setCount: the handle func to trigger `setState()` with count as arg
## `useEffect(func, capList)`
calls `func` on the following scenes:
+ Mounting
+ when capList is not provided, whenever `state` is updated
+ when capList is provided (can be empty), whenever the elements enclosed are updated
+ Unmounting
