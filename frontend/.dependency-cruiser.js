/** @type {import('dependency-cruiser').IConfiguration} */
export default {
  forbidden: [
    {
      name: 'no-circular',
      severity: 'error',
      comment: '禁止循环依赖',
      from: {},
      to: { circular: true },
    },
    {
      name: 'components-no-business',
      severity: 'error',
      comment: 'components/ 不得依赖 services/、store/、pages/ —— 展示组件必须保持纯粹',
      from: { path: '^src/components/' },
      to: { path: '^src/(services|store|pages)/' },
    },
    {
      name: 'no-orphans',
      severity: 'warn',
      comment: '不应有无人引用的孤儿模块（入口文件除外）',
      from: {
        orphan: true,
        pathNot: '^(src/main|src/App|src/test-setup)\\.(t|j)sx?$',
      },
      to: {},
    },
  ],
  options: {
    doNotFollow: { path: 'node_modules' },
    tsPreCompilationDeps: true,
    enhancedResolveOptions: { extensions: ['.ts', '.tsx', '.js', '.jsx'] },
  },
}
