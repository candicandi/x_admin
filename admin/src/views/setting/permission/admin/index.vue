<template>
    <div class="admin">
        <el-card class="!border-none" shadow="never">
            <el-form class="mb-[-16px]" :model="formData" inline>
                <el-form-item label="管理员账号" class="w-[280px]">
                    <el-input v-model="formData.username" clearable @keyup.enter="resetPage" />
                </el-form-item>
                <el-form-item label="管理员名称" class="w-[280px]">
                    <el-input v-model="formData.nickname" clearable @keyup.enter="resetPage" />
                </el-form-item>
                <el-form-item label="管理员角色" class="w-[280px]">
                    <el-select v-model="formData.role">
                        <el-option label="全部" value="" />
                        <el-option
                            v-for="(item, index) in optionsData.role"
                            :key="index"
                            :label="item.name"
                            :value="item.id"
                        />
                    </el-select>
                </el-form-item>
                <el-form-item>
                    <el-button type="primary" @click="resetPage">查询</el-button>
                    <el-button @click="resetParams">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>
        <el-card v-loading="pager.loading" class="mt-4 !border-none" shadow="never">
            <el-button v-perms="['admin:system:admin:add']" type="primary" @click="handleAdd">
                <template #icon>
                    <icon name="el-icon-Plus" />
                </template>
                新增
            </el-button>

            <upload
                class="ml-3 mr-3"
                :url="adminImportFile"
                :data="{ cid: 0 }"
                type="file"
                :show-progress="true"
                @change="resetPage"
            >
                <el-button type="primary">
                    <template #icon>
                        <icon name="el-icon-Upload" />
                    </template>
                    导入
                </el-button>
            </upload>

            <el-button type="primary" @click="exportFile">
                <template #icon>
                    <icon name="el-icon-Download" />
                </template>
                导出
            </el-button>

            <div class="mt-4">
                <el-table :data="pager.lists" size="large">
                    <el-table-column label="ID" prop="id" min-width="60" />
                    <el-table-column label="头像" min-width="100">
                        <template #default="{ row }">
                            <el-avatar :size="50" :src="row.avatar"></el-avatar>
                        </template>
                    </el-table-column>
                    <el-table-column label="账号" prop="username" min-width="100" />
                    <el-table-column label="名称" prop="nickname" min-width="100" />
                    <el-table-column label="角色" prop="role" min-width="100" />
                    <el-table-column label="部门" prop="dept" min-width="100" />
                    <el-table-column label="创建时间" prop="createTime" min-width="180" />
                    <el-table-column label="最近登录时间" prop="lastLoginTime" min-width="180" />
                    <el-table-column label="最近登录IP" prop="lastLoginIp" min-width="120" />
                    <el-table-column label="状态" min-width="100">
                        <template #default="{ row }">
                            <el-switch
                                v-perms="['admin:system:admin:disable']"
                                v-if="row.id != 1"
                                :model-value="row.isDisable"
                                :active-value="0"
                                :inactive-value="1"
                                @change="changeStatus($event, row.id)"
                            />
                        </template>
                    </el-table-column>
                    <el-table-column label="操作" width="120" fixed="right">
                        <template #default="{ row }">
                            <el-button
                                v-perms="['admin:system:admin:edit']"
                                type="primary"
                                link
                                @click="handleEdit(row)"
                            >
                                编辑
                            </el-button>
                            <el-button
                                v-if="row.id != 1"
                                v-perms="['admin:system:admin:del']"
                                type="danger"
                                link
                                @click="handleDelete(row.id)"
                            >
                                删除
                            </el-button>
                        </template>
                    </el-table-column>
                </el-table>
            </div>
            <div class="flex mt-4 justify-end">
                <pagination v-model="pager" @change="getLists" />
            </div>
        </el-card>
        <edit-popup v-if="showEdit" ref="editRef" @success="getLists" @close="showEdit = false" />
    </div>
</template>

<script lang="ts" setup>
import {
    adminLists,
    adminDelete,
    adminStatus,
    adminExportFile,
    adminImportFile
} from '@/api/perms/admin'
import { roleAll } from '@/api/perms/role'
import { useDictOptions } from '@/hooks/useDictOptions'
import { usePaging } from '@/hooks/usePaging'
import feedback from '@/utils/feedback'
import EditPopup from './edit.vue'
defineOptions({
    name: 'admin'
})
const editRef = shallowRef<InstanceType<typeof EditPopup>>()
// 表单数据
const formData = reactive<any>({
    //   username: "",
    //   nickname: "",
    //   role: "",
})
const showEdit = ref(false)
const { pager, getLists, resetParams, resetPage } = usePaging({
    fetchFun: adminLists,
    params: formData
})

const changeStatus = async (active: any, id: number) => {
    try {
        await feedback.confirm(`确定${active ? '停用' : '开启'}当前管理员？`)
        await adminStatus({ id })
        feedback.msgSuccess('修改成功')
        getLists()
    } catch (error) {
        getLists()
    }
}
const handleAdd = async () => {
    showEdit.value = true
    await nextTick()
    editRef.value?.open('add')
}

const exportFile = async () => {
    await feedback.confirm('确定要导出？')
    await adminExportFile(formData)
}
const handleEdit = async (data: any) => {
    showEdit.value = true
    await nextTick()
    editRef.value?.open('edit')
    editRef.value?.setFormData(data)
}

const handleDelete = async (id: number) => {
    try {
        await feedback.confirm('确定要删除？')
        await adminDelete({ id })
        feedback.msgSuccess('删除成功')
        getLists()
    } catch (error) {}
}
const { optionsData } = useDictOptions<{
    role: any[]
}>({
    role: {
        api: roleAll
    }
})

onMounted(() => {
    getLists()
})
</script>
