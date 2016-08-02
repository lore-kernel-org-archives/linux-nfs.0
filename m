Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:30211 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965744AbcHBM5h (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:37 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, mhalcrow@google.com,
        kirill.shutemov@linux.intel.com, oneukum@suse.com
Subject: [PATCH 1048/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:11:39 +0800
Message-Id: <20160802121139.19975-1-baolex.ni@intel.com>
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
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index aaf7bd0..d3f4311 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2079,7 +2079,7 @@ static LIST_HEAD(nfs_access_lru_list);
 static atomic_long_t nfs_access_nr_entries;
 
 static unsigned long nfs_access_max_cachesize = ULONG_MAX;
-module_param(nfs_access_max_cachesize, ulong, 0644);
+module_param(nfs_access_max_cachesize, ulong, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(nfs_access_max_cachesize, "NFS access maximum total cache length");
 
 static void nfs_access_free_entry(struct nfs_access_entry *entry)
-- 
2.9.2

