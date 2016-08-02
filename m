Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:57203 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965668AbcHBM5t (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:49 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, mhalcrow@google.com,
        kirill.shutemov@linux.intel.com, oneukum@suse.com
Subject: [PATCH 1047/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:11:34 +0800
Message-Id: <20160802121134.19909-1-baolex.ni@intel.com>
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
 fs/nfs/cache_lib.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/cache_lib.c b/fs/nfs/cache_lib.c
index 5f7b053..72422cd 100644
--- a/fs/nfs/cache_lib.c
+++ b/fs/nfs/cache_lib.c
@@ -25,9 +25,9 @@ static char nfs_cache_getent_prog[NFS_CACHE_UPCALL_PATHLEN] =
 static unsigned long nfs_cache_getent_timeout = NFS_CACHE_UPCALL_TIMEOUT;
 
 module_param_string(cache_getent, nfs_cache_getent_prog,
-		sizeof(nfs_cache_getent_prog), 0600);
+		sizeof(nfs_cache_getent_prog), S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(cache_getent, "Path to the client cache upcall program");
-module_param_named(cache_getent_timeout, nfs_cache_getent_timeout, ulong, 0600);
+module_param_named(cache_getent_timeout, nfs_cache_getent_timeout, ulong, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(cache_getent_timeout, "Timeout (in seconds) after which "
 		"the cache upcall is assumed to have failed");
 
-- 
2.9.2

