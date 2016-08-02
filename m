Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:28881 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965768AbcHBM5W (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Aug 2016 08:57:22 -0400
From: Baole Ni <baolex.ni@intel.com>
To: trond.myklebust@primarydata.com, anna.schumaker@netapp.com,
        tomi.valkeinen@ti.com, m.chehab@samsung.com,
        gregkh@linuxfoundation.org, m.szyprowski@samsung.com,
        kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        jlayton@poochiereds.net, thomas.haynes@primarydata.com,
        chuansheng.liu@intel.com, baolex.ni@intel.com, oneukum@suse.com
Subject: [PATCH 1050/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:11:51 +0800
Message-Id: <20160802121151.20112-1-baolex.ni@intel.com>
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
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 0aa36be..e76c3a7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -563,11 +563,11 @@ bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg)
 	       ff_layout_no_read_on_rw(lseg);
 }
 
-module_param(dataserver_retrans, uint, 0644);
+module_param(dataserver_retrans, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dataserver_retrans, "The  number of times the NFSv4.1 client "
 			"retries a request before it attempts further "
 			" recovery  action.");
-module_param(dataserver_timeo, uint, 0644);
+module_param(dataserver_timeo, uint, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 MODULE_PARM_DESC(dataserver_timeo, "The time (in tenths of a second) the "
 			"NFSv4.1  client  waits for a response from a "
 			" data server before it retries an NFS request.");
-- 
2.9.2

