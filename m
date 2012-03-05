Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e1.ny.us.ibm.com ([32.97.182.141]:56406 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932332Ab2CEU1v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:27:51 -0500
Received: from /spool/local
	by e1.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:27:48 -0500
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id B668F38C8065
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:26:57 -0500 (EST)
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KQv4a299520
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:57 -0500
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQvmI000456
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:57 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 05/10] Add nfs4_vfh_getdentry() for getattr recovery.
Date: Mon,  5 Mar 2012 15:26:46 -0500
Message-Id: <1330979211-894-6-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Added nfs4_vfh_getdentry() that traverses all the dcache
entries for the nfs mount and looks for a matching file handle.

The dentry with a matching file handle can then be used for
recovering from a FHEXPIRED error.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4proc.c |   47 +++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 47 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 3706c44..ee62c1e 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2547,6 +2547,53 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 	return err;
 }
 
+/* In the case of gettattr only a fh is given, and we need a VFS object to do
+ * vfh recovery. This function traverses the dcache to find the dentry with
+ * a matching fh
+ */
+struct dentry *nfs4_vfh_getdentry(struct nfs_server *server, struct nfs_fh *fhandle)
+{
+	struct dentry *this_parent;
+	struct list_head *next;
+	struct dentry *d_root = server->rootdentry;
+
+	this_parent = d_root;
+repeat:
+	next = this_parent->d_subdirs.next;
+resume:
+	while (next != &this_parent->d_subdirs) {
+		struct list_head *tmp = next;
+		struct dentry *dentry = list_entry(tmp, struct dentry,
+						d_u.d_child);
+		next = tmp->next;
+		/* Compare dentry's fh with one provided */
+		if (dentry && dentry->d_inode && &dentry->d_name)
+			if (!nfs_compare_fh(NFS_FH(dentry->d_inode), fhandle))
+				return dget(dentry);
+
+		if (!list_empty(&dentry->d_subdirs)) {
+			this_parent = dentry;
+			goto repeat;
+		}
+	}
+	if (this_parent != d_root) {
+		struct dentry *child = this_parent;
+		struct dentry *new = this_parent->d_parent;
+		/*
+		* might go back up the wrong parent if we have had a rename
+		* or deletion return ESTALE if it is renamed or deleted
+		*/
+		if (new != this_parent->d_parent ||
+				(this_parent->d_flags & DCACHE_DISCONNECTED)) {
+			return ERR_PTR(-ESTALE);
+		}
+		this_parent = new;
+		next = child->d_u.d_child.next;
+		goto resume;
+	}
+	return ERR_PTR(-ENOENT);
+}
+
 static int _nfs4_proc_access(struct inode *inode, struct nfs_access_entry *entry)
 {
 	struct nfs_server *server = NFS_SERVER(inode);
-- 
1.7.4.4

