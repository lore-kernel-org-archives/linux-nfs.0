Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:42818 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965832AbcHBM5T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:19 -0400
From: Baole Ni <baolex.ni@intel.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        davem@davemloft.net, kadlec@blackhole.kfki.hu,
        m.szyprowski@samsung.com, kyungmin.park@samsung.com,
        k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, smayhew@redhat.com,
        kirill.shutemov@linux.intel.com, arnd@arndb.de,
        chuansheng.liu@intel.com, baolex.ni@intel.com, aryabinin@virtuozzo.com
Subject: [PATCH 1137/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:19:37 +0800
Message-Id: <20160802121937.25917-1-baolex.ni@intel.com>
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
 net/sunrpc/auth_gss/auth_gss.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/auth_gss/auth_gss.c b/net/sunrpc/auth_gss/auth_gss.c
index e64ae93..a581a9d 100644
--- a/net/sunrpc/auth_gss/auth_gss.c
+++ b/net/sunrpc/auth_gss/auth_gss.c
@@ -2081,13 +2081,13 @@ MODULE_ALIAS("rpc-auth-6");
 MODULE_LICENSE("GPL");
 module_param_named(expired_cred_retry_delay,
 		   gss_expired_cred_retry_delay,
-		   uint, 0644);
+		   uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(expired_cred_retry_delay, "Timeout (in seconds) until "
 		"the RPC engine retries an expired credential");
 
 module_param_named(key_expire_timeo,
 		   gss_key_expire_timeo,
-		   uint, 0644);
+		   uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(key_expire_timeo, "Time (in seconds) at the end of a "
 		"credential keys lifetime where the NFS layer cleans up "
 		"prior to key expiration");
-- 
2.9.2

