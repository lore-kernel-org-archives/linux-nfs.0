Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:43180 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757288Ab2D0Slu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 14:41:50 -0400
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Fred Isaman <iisaman@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: Fix a use-before-initialised warning in fs/nfs/write.c and fs/nfs/pnfs.c
Date: Fri, 27 Apr 2012 14:41:45 -0400
Message-Id: <1335552105-27597-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If the allocation of nfs_write_header fails, the list of nfs_pages that
needs to be cleaned up is still on desc->pg_list...

Reported-by: Bryan Schumaker <bjschuma@netapp.com>
Cc: Fred Isaman <iisaman@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/pnfs.c  |    2 +-
 fs/nfs/write.c |    2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4da05e4..39cbac5 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1308,7 +1308,7 @@ pnfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 
 	whdr = nfs_writehdr_alloc();
 	if (!whdr) {
-		desc->pg_completion_ops->error_cleanup(&hdr->pages);
+		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		put_lseg(desc->pg_lseg);
 		desc->pg_lseg = NULL;
 		return -ENOMEM;
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index fec214b..3636191 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1164,7 +1164,7 @@ static int nfs_generic_pg_writepages(struct nfs_pageio_descriptor *desc)
 
 	whdr = nfs_writehdr_alloc();
 	if (!whdr) {
-		desc->pg_completion_ops->error_cleanup(&hdr->pages);
+		desc->pg_completion_ops->error_cleanup(&desc->pg_list);
 		return -ENOMEM;
 	}
 	hdr = &whdr->header;
-- 
1.7.7.6

