import { TrendChartCard } from './TrendChartCard'

/**
 * 数据 Tab 主页：承载「数据」导航目标页，内含可滚动内容区（后续可替换为图表、卡片等）。
 */
@Component
export struct DataHomePage {
  /** 当前舒适指数，用于仪表数值展示 */
  private readonly comfortScore: number = 45

  build() {
    // 导航子页：与 Navigation + NavPathStack 配合，负责标题与返回栈
    NavDestination() {
      // 页面根布局：占满导航内容区
      Column() {
        // 自定义顶栏：隐藏系统标题栏后自行绘制标题，避免出现返回键
        Row() {
          Text($r('app.string.page_data_title'))
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(Color.White)
        }
        .width('100%')
        .height(56)
        .justifyContent(FlexAlign.Center)
        .backgroundColor('#081F37')

        // 数据页主体滚动区：舒适指数、趋势图、指标卡片等均建议放在此区域内
        Scroll() {
          // 滚动内容容器：居中展示舒适指数仪表卡片
          Column() {
            Column() {
              Stack({ alignContent: Alignment.Center }) {
                // 底层深色圆环
                Progress({
                  value: 100,
                  total: 100,
                  type: ProgressType.Ring
                })
                  .backgroundColor('#214F77')
                  .style({ strokeWidth: 26 })
                  .width(228)
                  .height(228)
                  .rotate({ angle: 0 })

               


                // 中心遮罩，形成圆环效果并承载文字
                Column({ space: 10 }) {
                  Text(`${this.comfortScore}`)
                    .fontSize(72)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#DDF8FF')
                    .lineHeight(72)

                  Text('舒适指数')
                    .fontSize(36 / 2)
                    .fontColor('#86B8CF')
                }
                .width(168)
                .height(168)
                .borderRadius(84)
                .justifyContent(FlexAlign.Center)
                .alignItems(HorizontalAlign.Center)
                .backgroundColor('#0D223C')

              }
              .width(300)
              .height(300)
            }
            .width('100%')
            .height(340)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .borderRadius(22)

            // 趋势图卡片：位于圆环模块下方
            TrendChartCard()
          }
          .width('100%')
          .padding({ left: 16, right: 16, top: 16, bottom: 32 })
          .backgroundColor('#0F1626')
        }
        .layoutWeight(1)
        .width('100%')
        .scrollBar(BarState.Auto)
        .edgeEffect(EdgeEffect.Spring)
        .backgroundColor('#0B1220')
      }
      .width('100%')
      .height('100%')
      // 与顶栏、底栏同色，expandSafeArea 向状态栏/手势条延伸时不会出现异色条带
      .backgroundColor('#081F37')
      // 向系统状态栏、底部手势条方向扩展绘制区域，顶栏与页底背景可铺满屏幕
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .hideTitleBar(true)
  }
}
