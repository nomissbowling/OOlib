import
  std/macros,
  oolib / [sub, util, classes, protocols],
  oolib / state / [states, context]

export
  optBase,
  pClass,
  pProtocol,
  ignored


macro class*(
    head: untyped{nkIdent | nkCommand | nkInfix | nkCall | nkPragmaExpr},
    body: untyped{nkStmtList}
): untyped =
  let
    info = parseClassHead(head)
    context = newContext(newState(info))
    theClass = context.defClass(info)
    members = parseClassBody(body, info)
  theClass.add members.body.copy()
  context.defConstructor(theClass, info, members)
  for c in members.constsList:
    theClass.insertIn1st genConstant(info.name.strVal, c)
  context.defMemberVars(theClass, members)
  context.defMemberFuncs(theClass, info, members)
  result = theClass


proc isClass*(T: typedesc): bool =
  ## Returns whether `T` is class or not.
  T.hasCustomPragma(pClass)


proc isClass*[T](instance: T): bool =
  ## Is an alias for `isClass(T)`.
  T.isClass()


macro protocol*(head: untyped, body: untyped): untyped =
  let
    info = parseProtocolHead(head)
    members = parseProtocolBody(body)
  result = defProtocol(info, members)


proc isProtocol*(T: typedesc): bool =
  ## Returns whether `T` is protocol or not.
  T.hasCustomPragma(pProtocol)


proc isProtocol*[T](instance: T): bool =
  ## Is an alias for `isProtocol(T)`.
  T.isProtocol()
