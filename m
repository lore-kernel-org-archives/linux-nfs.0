Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:11958 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965723AbcHBM54 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:56 -0400
From: Baole Ni <baolex.ni@intel.com>
To: bfields@fieldses.org, jlayton@poochiereds.net,
        trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, mhalcrow@google.com,
        kirill.shutemov@linux.intel.com, oneukum@suse.com
Subject: [PATCH 1046/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:11:29 +0800
Message-Id: <20160802121129.19843-1-baolex.ni@intel.com>
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
 fs/lockd/svc.c | 12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
index 154a107..8f1f2d5 100644
--- a/fs/lockd/svc.c
+++ b/fs/lockd/svc.c
@@ -644,15 +644,15 @@ MODULE_DESCRIPTION("NFS file locking service version " LOCKD_VERSION ".");
 MODULE_LICENSE("GPL");
 
 module_param_call(nlm_grace_period, param_set_grace_period, param_get_ulong,
-		  &nlm_grace_period, 0644);
+		  &nlm_grace_period, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_call(nlm_timeout, param_set_timeout, param_get_ulong,
-		  &nlm_timeout, 0644);
+		  &nlm_timeout, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_call(nlm_udpport, param_set_port, param_get_int,
-		  &nlm_udpport, 0644);
+		  &nlm_udpport, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 module_param_call(nlm_tcpport, param_set_port, param_get_int,
-		  &nlm_tcpport, 0644);
-module_param(nsm_use_hostnames, bool, 0644);
-module_param(nlm_max_connections, uint, 0644);
+		  &nlm_tcpport, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(nsm_use_hostnames, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
+module_param(nlm_max_connections, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 static int lockd_init_net(struct net *net)
 {
-- 
2.9.2

