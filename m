From: andros@netapp.com
Subject: [PATCH 06/14] SQUASHME pnfs_submit: remove unused nfs4_pnfs_device_put
Date: Thu,  8 Apr 2010 15:54:02 -0400
Message-ID: <1270756450-5570-7-git-send-email-andros@netapp.com>
References: <1270756450-5570-1-git-send-email-andros@netapp.com>
 <1270756450-5570-2-git-send-email-andros@netapp.com>
 <1270756450-5570-3-git-send-email-andros@netapp.com>
 <1270756450-5570-4-git-send-email-andros@netapp.com>
 <1270756450-5570-5-git-send-email-andros@netapp.com>
 <1270756450-5570-6-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: pnfs@linux-nfs.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:47475 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933300Ab0DHTy5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 8 Apr 2010 15:54:57 -0400
In-Reply-To: <1270756450-5570-6-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayoutdev.c |   21 ---------------------
 1 files changed, 0 insertions(+), 21 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 99a7ceb..db6817d 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -795,24 +795,3 @@ nfs4_pnfs_dserver_get(struct pnfs_layout_segment *lseg,
 
 	return 0;
 }
-
-/* Currently not used.
- * I have disabled checking the device count until we can think of a good way
- * to call nfs4_pnfs_device_put in a generic way from the pNFS client.
- * The only way I think think of is to put the nfs4_file_layout_dsaddr directly
- * in the nfs4_write/read_data structure, which breaks the clear line between
- * the pNFS client and layout drivers.  If I did do this, then I could call
- * an ioctl on the NFSv4 file layout driver to decrement the device count.
- */
-#if 0
-static void
-nfs4_pnfs_device_put(struct nfs_server *server,
-		     struct nfs4_pnfs_dev_hlist *hlist,
-		     struct nfs4_file_layout_dsaddr *dsaddr)
-{
-	dprintk("nfs4_pnfs_device_put: dev_id=%u\n", dsaddr->dev_id);
-	/* XXX Do we need to invoke this put_client? */
-	/* server->rpc_ops->put_client(dsaddr->clp); */
-	atomic_dec(&dsaddr->count);
-}
-#endif
-- 
1.6.6

