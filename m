Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:19151 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965631AbcHBM5s (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:48 -0400
From: Baole Ni <baolex.ni@intel.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, kadlec@blackhole.kfki.hu,
        m.szyprowski@samsung.com, kyungmin.park@samsung.com,
        k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
        baolex.ni@intel.com, arnd@arndb.de, aryabinin@virtuozzo.com
Subject: [PATCH 1138/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:42 +0800
Message-Id: <20160802121942.25983-1-baolex.ni@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 net/sunrpc/svc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
index cc98528..5f0c605 100644
--- a/net/sunrpc/svc.c
+++ b/net/sunrpc/svc.c
@@ -100,7 +100,7 @@ param_get_pool_mode(char *buf, struct kernel_param *kp)
 }
 
 module_param_call(pool_mode, param_set_pool_mode, param_get_pool_mode,
-		 &svc_pool_map.mode, 0644);
+		 &svc_pool_map.mode, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 /*
  * Detect best pool mapping mode heuristically,
-- 
2.9.2

