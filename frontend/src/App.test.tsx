import { describe, it, expect } from 'vitest'
import { render, screen } from '@testing-library/react'
import App from './App'

describe('App', () => {
  it('渲染主标题', () => {
    render(<App />)
    expect(screen.getByText(/herness 通用智能体驾驭系统/)).toBeInTheDocument()
  })

  it('渲染驾驭层骨架提示', () => {
    render(<App />)
    expect(screen.getByText(/驾驭层骨架已就位/)).toBeInTheDocument()
  })
})
