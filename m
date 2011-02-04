Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13672 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753090Ab1BDVet (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Feb 2011 16:34:49 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>,
        Andy Adamson <andros@netapp.com>
Subject: [PATCH 30/40] pnfs-submit: wave3 let LAYOUTGET distinguish between read and write calls
Date: Fri,  4 Feb 2011 16:33:52 -0500
Message-Id: <1296855242-2592-31-git-send-email-andros@netapp.com>
In-Reply-To: <1296855242-2592-30-git-send-email-andros@netapp.com>
References: <1296855242-2592-1-git-send-email-andros@netapp.com>
 <1296855242-2592-2-git-send-email-andros@netapp.com>
 <1296855242-2592-3-git-send-email-andros@netapp.com>
 <1296855242-2592-4-git-send-email-andros@netapp.com>
 <1296855242-2592-5-git-send-email-andros@netapp.com>
 <1296855242-2592-6-git-send-email-andros@netapp.com>
 <1296855242-2592-7-git-send-email-andros@netapp.com>
 <1296855242-2592-8-git-send-email-andros@netapp.com>
 <1296855242-2592-9-git-send-email-andros@netapp.com>
 <1296855242-2592-10-git-send-email-andros@netapp.com>
 <1296855242-2592-11-git-send-email-andros@netapp.com>
 <1296855242-2592-12-git-send-email-andros@netapp.com>
 <1296855242-2592-13-git-send-email-andros@netapp.com>
 <1296855242-2592-14-git-send-email-andros@netapp.com>
 <1296855242-2592-15-git-send-email-andros@netapp.com>
 <1296855242-2592-16-git-send-email-andros@netapp.com>
 <1296855242-2592-17-git-send-email-andros@netapp.com>
 <1296855242-2592-18-git-send-email-andros@netapp.com>
 <1296855242-2592-19-git-send-email-andros@netapp.com>
 <1296855242-2592-20-git-send-email-andros@netapp.com>
 <1296855242-2592-21-git-send-email-andros@netapp.com>
 <1296855242-2592-22-git-send-email-andros@netapp.com>
 <1296855242-2592-23-git-send-email-andros@netapp.com>
 <1296855242-2592-24-git-send-email-andros@netapp.com>
 <1296855242-2592-25-git-send-email-andros@netapp.com>
 <1296855242-2592-26-git-send-email-andros@netapp.com>
 <1296855242-2592-27-git-send-email-andros@netapp.com>
 <1296855242-2592-28-git-send-email-andros@netapp.com>
 <1296855242-2592-29-git-send-email-andros@netapp.com>
 <1296855242-2592-30-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

This is done by introducing pgio->pg_iswrite.

For wave3 do not send layoutget on write
pnfs-submit wave 3 remove pg_iswrite add back for wave4
Remove CONFIG_NFS_V4_1 from struct nfs_page

Signed-off-by: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pagelist.c        |    9 ++++-----
 fs/nfs/write.c           |    3 +++
 include/linux/nfs_page.h |    2 --
 3 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index ea3b7f8..cf09cb7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -259,10 +259,8 @@ static int nfs_can_coalesce_requests(struct nfs_page *prev,
 	/* For non-whole file layouts, need to check that req is inside of
 	 * pgio->pg_test.
 	 */
-#ifdef CONFIG_NFS_V4_1
 	if (pgio->pg_test && !pgio->pg_test(pgio, prev, req))
 		return 0;
-#endif /* CONFIG_NFS_V4_1 */
 	return 1;
 }
 
@@ -300,9 +298,10 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 	} else {
 		put_lseg(desc->pg_lseg);
 		desc->pg_base = req->wb_pgbase;
-		desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
-						   req->wb_context,
-						   IOMODE_READ);
+		if (desc->pg_test)
+			desc->pg_lseg = pnfs_update_layout(desc->pg_inode,
+							   req->wb_context,
+							   IOMODE_READ);
 	}
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &desc->pg_list);
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index 004c28b..aca0268 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -28,6 +28,7 @@
 #include "iostat.h"
 #include "nfs4_fs.h"
 #include "fscache.h"
+#include "pnfs.h"
 
 #define NFSDBG_FACILITY		NFSDBG_PAGECACHE
 
@@ -982,6 +983,8 @@ static void nfs_pageio_init_write(struct nfs_pageio_descriptor *pgio,
 {
 	size_t wsize = NFS_SERVER(inode)->wsize;
 
+	pgio->pg_test = NULL;
+
 	if (wsize < PAGE_CACHE_SIZE)
 		nfs_pageio_init(pgio, inode, nfs_flush_multi, wsize, ioflags);
 	else
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index 488f27b..ba88ff4 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -63,9 +63,7 @@ struct nfs_pageio_descriptor {
 	int 			pg_ioflags;
 	int			pg_error;
 	struct pnfs_layout_segment *pg_lseg;
-#ifdef CONFIG_NFS_V4_1
 	int			(*pg_test)(struct nfs_pageio_descriptor *, struct nfs_page *, struct nfs_page *);
-#endif /* CONFIG_NFS_V4_1 */
 };
 
 #define NFS_WBACK_BUSY(req)	(test_bit(PG_BUSY,&(req)->wb_flags))
-- 
1.6.6

