Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:12732 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754968Ab0JVOQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:16:32 -0400
Message-ID: <4CC19CBF.1030306@netapp.com>
Date: Fri, 22 Oct 2010 10:16:31 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/2] NFS: nfs_readdir_filler catch all errors
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Check for all errors, not a specific one.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 879308e..628eca7 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -556,7 +556,7 @@ int nfs_readdir_filler(nfs_readdir_descriptor_t *desc, struct page* page)
 {
 	struct inode	*inode = desc->file->f_path.dentry->d_inode;
 
-	if (nfs_readdir_xdr_to_array(desc, page, inode) == -1)
+	if (nfs_readdir_xdr_to_array(desc, page, inode) < 0)
 		goto error;
 	SetPageUptodate(page);
 
