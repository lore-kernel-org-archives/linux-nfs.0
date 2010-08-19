Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37833 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754064Ab0HSP3H (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:29:07 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 4/5] SQUASHME pnfs-submit: rename layoutget 3
Date: Thu, 19 Aug 2010 11:27:56 -0400
Message-Id: <1282231677-4412-5-git-send-email-andros@netpp.com>
In-Reply-To: <1282231677-4412-4-git-send-email-andros@netpp.com>
References: <1282231677-4412-1-git-send-email-andros@netpp.com>
 <1282231677-4412-2-git-send-email-andros@netpp.com>
 <1282231677-4412-3-git-send-email-andros@netpp.com>
 <1282231677-4412-4-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit-layout-helper-functions

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index f838f2d..f094925 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -530,7 +530,7 @@ send_layoutget(struct inode *ino,
 {
 	int status;
 	struct nfs_server *server = NFS_SERVER(ino);
-	struct nfs4_pnfs_layoutget *lgp;
+	struct nfs4_layoutget *lgp;
 
 	dprintk("--> %s\n", __func__);
 
@@ -564,7 +564,7 @@ send_layoutget(struct inode *ino,
 	}
 
 	/* Retrieve layout information from server */
-	status = pnfs4_proc_layoutget(lgp);
+	status = nfs4_proc_layoutget(lgp);
 
 	dprintk("<-- %s status %d\n", __func__, status);
 	return status;
@@ -1121,7 +1121,7 @@ int
 pnfs_layout_process(struct nfs4_layoutget *lgp)
 {
 	struct pnfs_layout_hdr *lo = NFS_I(lgp->args.inode)->layout;
-	struct nfs4_pnfs_layoutget_res *res = &lgp->res;
+	struct nfs4_layoutget_res *res = &lgp->res;
 	struct pnfs_layout_segment *lseg;
 	struct inode *ino = PNFS_INODE(lo);
 	int status = 0;
-- 
1.6.2.5

