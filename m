Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:53391 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753427Ab1FOTPz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2011 15:15:55 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] nfs4.1: check for whole file layouts is comparing against uninitialized values
Date: Wed, 15 Jun 2011 15:15:35 -0400
Message-Id: <1308165335-29609-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 88aa8a0..7fe8e19 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -428,8 +428,8 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 
 	/* FIXME: remove this check when layout segment support is added */
-	if (fl->generic_hdr.pls_range.offset != 0 ||
-	    fl->generic_hdr.pls_range.length != NFS4_MAX_UINT64) {
+	if (lgr->range.offset != 0 ||
+	    lgr->range.length != NFS4_MAX_UINT64) {
 		dprintk("%s Only whole file layouts supported. Use MDS i/o\n",
 			__func__);
 		goto out;
-- 
1.7.2.1

