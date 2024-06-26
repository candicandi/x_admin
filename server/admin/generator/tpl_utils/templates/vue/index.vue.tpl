<template>
    <div class="index-lists">
        <el-card class="!border-none" shadow="never">
            <el-form ref="formRef" class="mb-[-16px]" :model="queryParams" :inline="true">
            {{{- range .Columns }}}
            {{{- if eq .IsQuery 1 }}}
                {{{- if eq .HtmlType "datetime" }}}
                <el-form-item label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}" class="w-[280px]">
                    <daterange-picker
                        v-model:startTime="queryParams.{{{ (toCamelCase .GoField) }}}Start"
                        v-model:endTime="queryParams.{{{ (toCamelCase .GoField) }}}End"
                    />
                </el-form-item>
                {{{- else if or (eq .HtmlType "select") (eq .HtmlType "radio") }}}
                <el-form-item label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}"  class="w-[280px]">
                    <el-select
                        v-model="queryParams.{{{ (toCamelCase .GoField) }}}"
                        clearable
                    >
                        {{{- if eq .DictType "" }}}
                        <el-option label="请选择字典生成" value="" />
                        {{{- else }}}
                        <el-option label="全部" value="" />
                        <el-option
                            v-for="(item, index) in dictData.{{{ .DictType }}}"
                            :key="index"
                            :label="item.name"
                            :value="item.value"
                        />
                        {{{- end }}}
                    </el-select>
                </el-form-item>
                {{{- else if eq .HtmlType "input" }}}
                <el-form-item label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}" class="w-[280px]">
                    <el-input  v-model="queryParams.{{{ (toCamelCase .GoField) }}}" />
                </el-form-item>
                {{{- end }}}
            {{{- end }}}
            {{{- end }}}
                <el-form-item>
                    <el-button type="primary" @click="resetPage">查询</el-button>
                    <el-button @click="resetParams">重置</el-button>
                </el-form-item>
            </el-form>
        </el-card>
        <el-card class="!border-none mt-4" shadow="never">
            <div>
                <el-button v-perms="['admin:{{{ .ModuleName }}}:add']" type="primary" @click="handleAdd()">
                    <template #icon>
                        <icon name="el-icon-Plus" />
                    </template>
                    新增
                </el-button>
                    <upload
                    class="ml-3 mr-3"
                    :url="{{{.ModuleName}}}_export_file"
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
            </div>
            <el-table
                class="mt-4"
                size="large"
                v-loading="pager.loading"
                :data="pager.lists"
            >
            {{{- range .Columns }}}
            {{{- if .IsList }}}
                {{{- if and (ne .DictType "") (or (eq .HtmlType "select") (eq .HtmlType "radio") (eq .HtmlType "checkbox")) }}}
                <el-table-column label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}" min-width="100">
                    <template #default="{ row }">
                        <dict-value :options="dictData.{{{ .DictType }}}" :value="row.{{{ (toCamelCase .GoField) }}}" />
                    </template>
                </el-table-column>
                {{{- else if eq .HtmlType "imageUpload" }}}
                <el-table-column label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}" min-width="100">
                    <template #default="{ row }">
                        <image-contain
                            :width="40"
                            :height="40"
                            :src="row.{{{ (toCamelCase .GoField) }}}"
                            :preview-src-list="[row.{{{ (toCamelCase .GoField) }}}]"
                            preview-teleported
                            hide-on-click-modal
                        />
                    </template>
                </el-table-column>
                {{{- else }}}
                <el-table-column label="{{{ .ColumnComment }}}" prop="{{{ (toCamelCase .GoField) }}}" min-width="130" />
                {{{- end }}}
            {{{- end }}}
            {{{- end }}}
                <el-table-column label="操作" width="120" fixed="right">
                    <template #default="{ row }">
                        <el-button
                            v-perms="['admin:{{{ .ModuleName }}}:edit']"
                            type="primary"
                            link
                            @click="handleEdit(row)"
                        >
                            编辑
                        </el-button>
                        <el-button
                            v-perms="['admin:{{{ .ModuleName }}}:del']"
                            type="danger"
                            link
                            @click="handleDelete(row.{{{ .PrimaryKey }}})"
                        >
                            删除
                        </el-button>
                    </template>
                </el-table-column>
            </el-table>
            <div class="flex justify-end mt-4">
                <pagination v-model="pager" @change="getLists" />
            </div>
        </el-card>
        <edit-popup
            v-if="showEdit"
            ref="editRef"
            {{{- if ge (len .DictFields) 1 }}}
            :dict-data="dictData"
            {{{- end }}}
            @success="getLists"
            @close="showEdit = false"
        />
    </div>
</template>
<script lang="ts" setup>
import { {{{ .ModuleName }}}_delete, {{{ .ModuleName }}}_list,{{{.ModuleName}}}_import_file, {{{.ModuleName}}}_export_file } from '@/api/{{{ .ModuleName }}}'
{{{- if ge (len .DictFields) 1 }}}
import { useDictData } from '@/hooks/useDictOptions'
{{{- end }}}
import { usePaging } from '@/hooks/usePaging'
import feedback from '@/utils/feedback'
import EditPopup from './edit.vue'
defineOptions({
    name:"{{{ .ModuleName }}}"
})
const editRef = shallowRef<InstanceType<typeof EditPopup>>()
const showEdit = ref(false)
const queryParams = reactive({
{{{- range .Columns }}}
{{{- if .IsQuery }}}
    {{{- if eq .HtmlType "datetime" }}}
    {{{ (toCamelCase .GoField) }}}Start: '',
    {{{ (toCamelCase .GoField) }}}End: '',
    {{{- else }}}
    {{{ (toCamelCase .GoField) }}}: '',
    {{{- end }}}
{{{- end }}}
{{{- end }}}
})

const { pager, getLists, resetPage, resetParams } = usePaging({
    fetchFun: {{{ .ModuleName }}}_list,
    params: queryParams
})

{{{- if ge (len .DictFields) 1 }}}
{{{- $dictSize := sub (len .DictFields) 1 }}}
const { dictData } = useDictData<{
    {{{- range .DictFields }}}
    {{{ . }}}: any[]
    {{{- end }}}
}>([{{{- range .DictFields }}}'{{{ . }}}'{{{- if ne (index $.DictFields $dictSize) . }}},{{{- end }}}{{{- end }}}])
{{{- end }}}


const handleAdd = async () => {
    showEdit.value = true
    await nextTick()
    editRef.value?.open('add')
}

const handleEdit = async (data: any) => {
    try {
        showEdit.value = true
        await nextTick()
        editRef.value?.open('edit')
        editRef.value?.getDetail(data)
    } catch (error) {}
}

const handleDelete = async ({{{ .PrimaryKey }}}: number) => {
    try {
        await feedback.confirm('确定要删除？')
        await {{{ .ModuleName }}}_delete({ {{{ .PrimaryKey }}} })
        feedback.msgSuccess('删除成功')
        getLists()
    } catch (error) {}
}
const exportFile = async () => {
    try {
        await feedback.confirm('确定要导出？')
        await {{{.ModuleName}}}_export_file(queryParams)
    } catch (error) {}
}
getLists()
</script>
