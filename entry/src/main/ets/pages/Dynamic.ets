
@Component
export struct Dynamic {


  build() {
    GridRow({
      columns: { sm: 4, md: 8, lg: 12 },
      gutter: { x: 12 }
    })
  }
}