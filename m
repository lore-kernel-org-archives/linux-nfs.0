Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga14.intel.com ([192.55.52.115]:3010 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965618AbcHBMw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:52:56 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, oneukum@suse.com
Subject: [PATCH 1054/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:12:11 +0800
Message-Id: <20160802121211.20378-1-baolex.ni@intel.com>
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
 fs/nfs/super.c | 14 +++++++-------
 1 file changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 2137e02..786efd6 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2863,22 +2863,22 @@ static const struct kernel_param_ops param_ops_portnr = {
 };
 #define param_check_portnr(name, p) __param_check(name, p, unsigned int);
 
-module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, 0644);
-module_param(nfs_idmap_cache_timeout, int, 0644);
-module_param(nfs4_disable_idmapping, bool, 0644);
+module_param_named(callback_tcpport, nfs_callback_set_tcpport, portnr, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(nfs_idmap_cache_timeout, int, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(nfs4_disable_idmapping, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_string(nfs4_unique_id, nfs4_client_id_uniquifier,
-			NFS4_CLIENT_ID_UNIQ_LEN, 0600);
+			NFS4_CLIENT_ID_UNIQ_LEN, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(nfs4_disable_idmapping,
 		"Turn off NFSv4 idmapping when using 'sec=sys'");
-module_param(max_session_slots, ushort, 0644);
+module_param(max_session_slots, ushort, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(max_session_slots, "Maximum number of outstanding NFSv4.1 "
 		"requests the client will negotiate");
-module_param(send_implementation_id, ushort, 0644);
+module_param(send_implementation_id, ushort, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(send_implementation_id,
 		"Send implementation ID with NFSv4.1 exchange_id");
 MODULE_PARM_DESC(nfs4_unique_id, "nfs_client_id4 uniquifier string");
 
-module_param(recover_lost_locks, bool, 0644);
+module_param(recover_lost_locks, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(recover_lost_locks,
 		 "If the server reports that a lock might be lost, "
 		 "try to recover it risking data corruption.");
-- 
2.9.2

