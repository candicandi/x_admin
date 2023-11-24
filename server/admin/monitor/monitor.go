package monitor

import (
	"strings"
	"x_admin/core/response"
	"x_admin/middleware"
	"x_admin/util"

	"github.com/gin-gonic/gin"
)

func MonitorRoute(rg *gin.RouterGroup) {
	handle := monitorHandler{}

	rg = rg.Group("/monitor", middleware.TokenAuth())
	rg.GET("/cache", middleware.RecordLog("缓存监控"), handle.cache)
	rg.GET("/server", middleware.RecordLog("服务监控"), handle.server)
}

type monitorHandler struct{}

// cache 缓存监控
func (mh monitorHandler) cache(c *gin.Context) {
	cmdStatsMap := util.RedisUtil.Info("commandstats")
	var stats []map[string]string
	for k, v := range cmdStatsMap {
		stats = append(stats, map[string]string{
			"name":  strings.Split(k, "_")[1],
			"value": v[strings.Index(v, "=")+1 : strings.Index(v, ",")],
		})
	}
	response.OkWithData(c, map[string]interface{}{
		"info":         util.RedisUtil.Info(),
		"commandStats": stats,
		"dbSize":       util.RedisUtil.DBSize(),
	})
}

// server 服务监控
func (mh monitorHandler) server(c *gin.Context) {
	response.OkWithData(c, map[string]interface{}{
		"cpu":  util.ServerUtil.GetCpuInfo(),
		"mem":  util.ServerUtil.GetMemInfo(),
		"sys":  util.ServerUtil.GetSysInfo(),
		"disk": util.ServerUtil.GetDiskInfo(),
		"go":   util.ServerUtil.GetGoInfo(),
	})
}
