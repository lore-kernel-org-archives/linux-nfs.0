Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:64915 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965365AbcHBMwK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:52:10 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        chuansheng.liu@intel.com, baolex.ni@intel.com, oneukum@suse.com
Subject: [PATCH 1051/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:11:56 +0800
Message-Id: <20160802121156.20178-1-baolex.ni@intel.com>
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
 fs/nfs/inode.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 52e7d68..571f654 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -2129,7 +2129,7 @@ static void __exit exit_nfs_fs(void)
 /* Not quite true; I just maintain it */
 MODULE_AUTHOR("Olaf Kirch <okir@monad.swb.de>");
 MODULE_LICENSE("GPL");
-module_param(enable_ino64, bool, 0644);
+module_param(enable_ino64, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 module_init(init_nfs_fs)
 module_exit(exit_nfs_fs)
-- 
2.9.2

