Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:61494 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754758Ab2DXSuw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 24 Apr 2012 14:50:52 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/1] NFS: Prevent garbage cinfo->ds from leaking out
Date: Tue, 24 Apr 2012 14:50:34 -0400
Message-Id: <1335293434-12957-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a bugfix that applies on top of the previous directio patches,
that fixes a bug introduced in "NFS: create struct nfs_commit_info".

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 806a55f..80a63f6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -1184,7 +1184,12 @@ filelayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
 static struct pnfs_ds_commit_info *
 filelayout_get_ds_info(struct inode *inode)
 {
-	return &FILELAYOUT_FROM_HDR(NFS_I(inode)->layout)->commit_info;
+	struct pnfs_layout_hdr *layout = NFS_I(inode)->layout;
+
+	if (layout == NULL)
+		return NULL;
+	else
+		return &FILELAYOUT_FROM_HDR(layout)->commit_info;
 }
 
 static struct pnfs_layoutdriver_type filelayout_type = {
-- 
1.7.2.1

