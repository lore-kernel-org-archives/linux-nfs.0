Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:2688 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1763488AbdLSOf2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 19 Dec 2017 09:35:28 -0500
From: Benjamin Coddington <bcodding@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: permit layoutget of executable-only files
Date: Tue, 19 Dec 2017 09:35:25 -0500
Message-Id: <2f621da7f3633e5a127ac89d886738c35ea02880.1513693981.git.bcodding@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clients must be able to read a file in order to execute it, and for pNFS
that means the client needs to be able to perform a LAYOUTGET on the file.

This behavior for executable-only files was added for OPEN in commit
a043226bc140 "nfsd4: permit read opens of executable-only files".

This fixes up xfstests generic/126 on block/scsi layouts.

Signed-off-by: Benjamin Coddington <bcodding@redhat.com>
---
 fs/nfsd/nfs4proc.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 8487486ec496..8ce60986fb75 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1372,14 +1372,14 @@ nfsd4_layoutget(struct svc_rqst *rqstp,
 	const struct nfsd4_layout_ops *ops;
 	struct nfs4_layout_stateid *ls;
 	__be32 nfserr;
-	int accmode;
+	int accmode = NFSD_MAY_READ_IF_EXEC;
 
 	switch (lgp->lg_seg.iomode) {
 	case IOMODE_READ:
-		accmode = NFSD_MAY_READ;
+		accmode |= NFSD_MAY_READ;
 		break;
 	case IOMODE_RW:
-		accmode = NFSD_MAY_READ | NFSD_MAY_WRITE;
+		accmode |= NFSD_MAY_READ | NFSD_MAY_WRITE;
 		break;
 	default:
 		dprintk("%s: invalid iomode %d\n",
-- 
2.9.3

