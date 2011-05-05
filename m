Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:44261 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753619Ab1EEPf7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 5 May 2011 11:35:59 -0400
From: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, ecryptfs-devel@lists.launchpad.net,
        ecryptfs@vger.kernel.org
Subject: [PATCH] NFS: Allow NULL nameidata in d_revalidate and create
Date: Thu,  5 May 2011 10:35:41 -0500
Message-Id: <1304609741-12541-1-git-send-email-tyhicks@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

To add support for eCryptfs mounts on top of NFS client mounts, the NFS
client must properly handle NULL nameidata pointers in its d_revalidate
functions.

NFS clients should also handle NULL nameidata in its create functions,
although this is not currently required for eCryptfs support.

Signed-off-by: Tyler Hicks <tyhicks@linux.vnet.ibm.com>
---
 fs/nfs/dir.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 7237672..03c6ab2 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1095,7 +1095,7 @@ static int nfs_lookup_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct nfs_fattr *fattr = NULL;
 	int error;
 
-	if (nd->flags & LOOKUP_RCU)
+	if (nd && nd->flags & LOOKUP_RCU)
 		return -ECHILD;
 
 	parent = dget_parent(dentry);
@@ -1493,7 +1493,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	struct nfs_open_context *ctx;
 	int openflags, ret = 0;
 
-	if (nd->flags & LOOKUP_RCU)
+	if (nd && nd->flags & LOOKUP_RCU)
 		return -ECHILD;
 
 	inode = dentry->d_inode;
@@ -1583,7 +1583,7 @@ static int nfs_open_create(struct inode *dir, struct dentry *dentry, int mode,
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	if ((nd->flags & LOOKUP_CREATE) != 0) {
+	if (nd && (nd->flags & LOOKUP_CREATE) != 0) {
 		open_flags = nd->intent.open.flags;
 
 		ctx = nameidata_to_nfs_open_context(dentry, nd);
@@ -1673,7 +1673,7 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 	attr.ia_mode = mode;
 	attr.ia_valid = ATTR_MODE;
 
-	if ((nd->flags & LOOKUP_CREATE) != 0)
+	if (nd && (nd->flags & LOOKUP_CREATE) != 0)
 		open_flags = nd->intent.open.flags;
 
 	error = NFS_PROTO(dir)->create(dir, dentry, &attr, open_flags, NULL);
-- 
1.7.4.4

