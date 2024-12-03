

export class MGestureModifier implements GestureModifier{

  handlers: GestureHandler<TapGestureHandler | LongPressGestureHandler | PanGestureHandler | SwipeGestureHandler | PinchGestureHandler | RotationGestureHandler | GestureGroupHandler>[];

  constructor(...handlers: GestureHandler<TapGestureHandler | LongPressGestureHandler | PanGestureHandler | SwipeGestureHandler | PinchGestureHandler | RotationGestureHandler | GestureGroupHandler>[]) {
    this.handlers = handlers;
  }

  applyGesture(event: UIGestureEvent): void {
    this.handlers?.forEach((item) => {
      event.addGesture(item);
    })
  }
}