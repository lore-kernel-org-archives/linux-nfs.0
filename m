Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:37667 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751707Ab3KDUvY (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Nov 2013 15:51:24 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linux NFS <linux-nfs@vger.kernel.org>
CC: J Bruce Fields <bfields@fieldses.org>, Steve Dickson <steved@redhat.com>,
        Jeff Layton <jlayton@redhat.com>,
        David Quigley <dpquigl@davequigley.com>
Subject: [PATCH 5/5] NFSv4.2: Remove redundant checks in nfs_setsecurity+nfs4_label_init_security
Date: Mon, 4 Nov 2013 15:51:12 -0500
Message-ID: <1383598272-17737-5-git-send-email-Trond.Myklebust@netapp.com>
In-Reply-To: <1383598272-17737-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1383598272-17737-1-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-2-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-3-git-send-email-Trond.Myklebust@netapp.com>
 <1383598272-17737-4-git-send-email-Trond.Myklebust@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We already check for nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL)
in nfs4_label_alloc()
We check the minor version in _nfs4_server_capabilities before setting
NFS_CAP_SECURITY_LABEL.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/inode.c    | 6 ------
 fs/nfs/nfs4proc.c | 3 ---
 2 files changed, 9 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 09d4df5f588a..4ae41a26844f 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -274,12 +274,6 @@ void nfs_setsecurity(struct inode *inode, struct nfs_fattr *fattr,
 	if (label == NULL)
 		return;
 
-	if (nfs_server_capable(inode, NFS_CAP_SECURITY_LABEL) == 0)
-		return;
-
-	if (NFS_SERVER(inode)->nfs_client->cl_minorversion < 2)
-		return;
-
 	if ((fattr->valid & NFS_ATTR_FATTR_V4_SECURITY_LABEL) && inode->i_security) {
 		error = security_inode_notifysecctx(inode, label->label,
 				label->len);
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index ed2a0e6b9aed..5ab33c0792df 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -105,9 +105,6 @@ nfs4_label_init_security(struct inode *dir, struct dentry *dentry,
 	if (nfs_server_capable(dir, NFS_CAP_SECURITY_LABEL) == 0)
 		return NULL;
 
-	if (NFS_SERVER(dir)->nfs_client->cl_minorversion < 2)
-		return NULL;
-
 	err = security_dentry_init_security(dentry, sattr->ia_mode,
 				&dentry->d_name, (void **)&label->label, &label->len);
 	if (err == 0)
-- 
1.8.3.1

