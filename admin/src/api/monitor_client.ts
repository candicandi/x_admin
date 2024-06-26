import request from '@/utils/request'

// 客户端信息列表
export function monitor_client_list(params?: Record<string, any>) {
    return request.get({ url: '/monitor_client/list', params })
}
// 客户端信息列表-所有
export function monitor_client_list_all(params?: Record<string, any>) {
    return request.get({ url: '/monitor_client/listAll', params })
}

// 客户端信息详情
export function monitor_client_detail(params: Record<string, any>) {
    return request.get({ url: '/monitor_client/detail', params })
}

// 客户端信息新增
export function monitor_client_add(params: Record<string, any>) {
    return request.post({ url: '/monitor_client/add', params })
}

// 客户端信息编辑
export function monitor_client_edit(params: Record<string, any>) {
    return request.post({ url: '/monitor_client/edit', params })
}

// 客户端信息删除
export function monitor_client_delete(params: Record<string, any>) {
    return request.post({ url: '/monitor_client/del', params })
}
