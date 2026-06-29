import { Layout, Typography } from 'antd'

const { Header, Content } = Layout
const { Title, Paragraph } = Typography

export default function App() {
  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Header>
        <Title level={3} style={{ color: '#fff', margin: 0, lineHeight: '64px' }}>
          herness 通用智能体驾驭系统
        </Title>
      </Header>
      <Content style={{ padding: 24 }}>
        <Title level={4}>驾驭层骨架已就位</Title>
        <Paragraph>
          前端 React + Ant Design 骨架。业务模块（pages / components / services 等）将在
          分层约束下由智能体逐步生成。
        </Paragraph>
      </Content>
    </Layout>
  )
}
