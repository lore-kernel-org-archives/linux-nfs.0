Return-Path: linux-nfs-owner@vger.kernel.org
Received: from smtp.mail.umich.edu ([141.211.14.81]:59743 "EHLO
	hackers.mr.itd.umich.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751642Ab2DJCdm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 Apr 2012 22:33:42 -0400
From: Jim Rees <rees@umich.edu>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2] fix page number calculation bug for block layout decode buffer
Date: Mon,  9 Apr 2012 22:33:39 -0400
Message-Id: <1334025219-11816-1-git-send-email-rees@umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jim Rees <rees@umich.edu>
Suggested-by: Andy Adamson <andros@netapp.com>
Suggested-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/blocklayout/blocklayout.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
index 48cfac3..0418252 100644
--- a/fs/nfs/blocklayout/blocklayout.c
+++ b/fs/nfs/blocklayout/blocklayout.c
@@ -38,6 +38,8 @@
 #include <linux/buffer_head.h>	/* various write calls */
 #include <linux/prefetch.h>
 
+#include "../pnfs.h"
+#include "../internal.h"
 #include "blocklayout.h"
 
 #define NFSDBG_FACILITY	NFSDBG_PNFS_LD
@@ -872,7 +874,7 @@ nfs4_blk_get_deviceinfo(struct nfs_server *server, const struct nfs_fh *fh,
 	 * GETDEVICEINFO's maxcount
 	 */
 	max_resp_sz = server->nfs_client->cl_session->fc_attrs.max_resp_sz;
-	max_pages = max_resp_sz >> PAGE_SHIFT;
+	max_pages = nfs_page_array_len(0, max_resp_sz);
 	dprintk("%s max_resp_sz %u max_pages %d\n",
 		__func__, max_resp_sz, max_pages);
 
-- 
1.7.5.4

