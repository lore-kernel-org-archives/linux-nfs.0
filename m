Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57203 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965851AbcHBM5a (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:30 -0400
From: Baole Ni <baolex.ni@intel.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, kadlec@blackhole.kfki.hu,
        m.szyprowski@samsung.com, kyungmin.park@samsung.com,
        k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, chuansheng.liu@intel.com,
        baolex.ni@intel.com, aryabinin@virtuozzo.com
Subject: [PATCH 1136/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:31 +0800
Message-Id: <20160802121931.25849-1-baolex.ni@intel.com>
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
 net/sunrpc/auth.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
index 040ff62..1cd99fc 100644
--- a/net/sunrpc/auth.c
+++ b/net/sunrpc/auth.c
@@ -77,11 +77,11 @@ static const struct kernel_param_ops param_ops_hashtbl_sz = {
 	.get = param_get_hashtbl_sz,
 };
 
-module_param_named(auth_hashtable_size, auth_hashbits, hashtbl_sz, 0644);
+module_param_named(auth_hashtable_size, auth_hashbits, hashtbl_sz, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(auth_hashtable_size, "RPC credential cache hashtable size");
 
 static unsigned long auth_max_cred_cachesize = ULONG_MAX;
-module_param(auth_max_cred_cachesize, ulong, 0644);
+module_param(auth_max_cred_cachesize, ulong, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(auth_max_cred_cachesize, "RPC credential maximum total cache size");
 
 static u32
-- 
2.9.2

