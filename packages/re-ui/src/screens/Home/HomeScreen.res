@module external styles: {..} = "./HomeScreen.module.css"

let styles = styles["default"]

@react.component
let make = () => {
  let (isCreateFormVisible, setIsCreateFormVisible) = React.useState(() => false)
  let (isJoinFormVisible, setIsJoinFormVisible) = React.useState(() => false)
  let (createFormValue, setCreateFormValue) = React.useState(() => CreateForm.defaultValue)
  let (joinFormValue, setJoinFormValue) = React.useState(() => JoinForm.defaultValue)
  let (_, setRoomState) = RoomContext.useRoomState()

  let showCreateForm = _ => {
    setIsCreateFormVisible(_ => true)
    setIsJoinFormVisible(_ => false)
  }

  let showJoinForm = _ => {
    setIsCreateFormVisible(_ => false)
    setIsJoinFormVisible(_ => true)
  }

  let joinRoom = (~roomId, ~userName) => {
    let _ =
      RoomApi.join(~roomId, ~userName, ~onUpdate=state => setRoomState(_ => state))
      ->Phoenix.Push.receive(~status="ok", ~callback=msg => {
        setRoomState(_ => msg)
        RescriptReactRouter.push("play")
      })
      ->Phoenix.Push.receive(~status="error", ~callback=msg => Js.log(msg))
      ->Phoenix.Push.receive(~status="timeout", ~callback=msg => Js.log(msg))
  }

  let handleCreateForm = _ => {
    let _ = LobbyApi.createRoom(
      ~host={id: SocketApi.userId, name: createFormValue.name},
      ~roomInfo={
        "rounds_per_player": createFormValue.rounds_per_player,
        "round_duration": createFormValue.round_duration,
      },
      ~onRecieve=s => {
        Js.log(s)
        joinRoom(~roomId=s, ~userName=createFormValue.name)
      },
    )
  }

  <Frame>
    <div className={styles["home-screen"]}>
      <div className={styles["title"]}>
        <h1> {React.string(`Злобные карты`)} </h1>
        <h3> {React.string(`Хорошая игра для плохих людей`)} </h3>
      </div>
      <div className={styles["buttons"]}>
        <Button label=`Создать игру` onClick={showCreateForm} />
        <Button label=`Подключится к игре` onClick={showJoinForm} />
      </div>
      <BottomModal visible={isCreateFormVisible} onClose={_ => setIsCreateFormVisible(_ => false)}>
        <CreateForm
          value={createFormValue}
          onChange={v => setCreateFormValue(_ => v)}
          onSubmit={handleCreateForm}
        />
      </BottomModal>
      <BottomModal visible={isJoinFormVisible} onClose={_ => setIsJoinFormVisible(_ => false)}>
        <JoinForm
          onChange={v => setJoinFormValue(_ => v)}
          onSubmit={_ => {
            Js.log("submit")
            let _ = LobbyApi.getRoomByCode(~code=joinFormValue.room_code, ~onRecieve=id => {
              Js.log(id)
              joinRoom(~roomId=id, ~userName=joinFormValue.name)
            })
          }}
          value={joinFormValue}
        />
      </BottomModal>
    </div>
  </Frame>
}
