Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e9.ny.us.ibm.com ([32.97.182.139]:58733 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757496Ab2CEU1E (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Mar 2012 15:27:04 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <treinish@linux.vnet.ibm.com>;
	Mon, 5 Mar 2012 15:27:04 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id F191338C8065
	for <linux-nfs@vger.kernel.org>; Mon,  5 Mar 2012 15:27:00 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q25KQwE62527358
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:58 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q25KQvYs010574
	for <linux-nfs@vger.kernel.org>; Mon, 5 Mar 2012 15:26:58 -0500
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: treinish@linux.vnet.ibm.com
Subject: [PATCH/RFC v3 09/10] VFH recovery from a replication/migration event.
Date: Mon,  5 Mar 2012 15:26:50 -0500
Message-Id: <1330979211-894-10-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1330979211-894-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Implements a refreshing file handles after a successful migration
or replication event. After the client changes to using a different
server if FH4_VOL_MIGRATION is set by the server it is assumed
that the file handles have all expired during migration or
replication.

nfs4_vfh_replication uses the dcache to find each file handle that
is currently cached and refreshes it using an nfs4 lookup.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 fs/nfs/nfs4_fs.h  |    1 +
 fs/nfs/nfs4proc.c |   73 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 74 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4_fs.h b/fs/nfs/nfs4_fs.h
index 52d7f94..b4ca67f 100644
--- a/fs/nfs/nfs4_fs.h
+++ b/fs/nfs/nfs4_fs.h
@@ -218,6 +218,7 @@ extern int nfs4_do_close(struct nfs4_state *state, gfp_t gfp_mask, int wait, boo
 extern int nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *fhandle);
 extern int nfs4_proc_fs_locations(struct inode *dir, const struct qstr *name,
 		struct nfs4_fs_locations *fs_locations, struct page *page);
+extern int nfs4_vfh_replication(struct dentry *d_root);
 extern void nfs4_release_lockowner(const struct nfs4_lock_state *);
 extern const struct xattr_handler *nfs4_xattr_handlers[];
 
diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 78ed5c5..f9484c3 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -2558,6 +2558,79 @@ static int nfs4_proc_lookup(struct rpc_clnt *clnt, struct inode *dir, struct qst
 	return err;
 }
 
+int nfs4_vfh_replication(struct dentry *d_root)
+{
+	struct nfs_fsinfo info;
+	int err = 0;
+	struct nfs_fattr *fattr = NULL;
+	struct dentry *this_parent;
+	struct list_head *next;
+	struct nfs_server *server = NFS_SB(d_root->d_sb);
+	fattr = nfs_alloc_fattr();
+	if (fattr == NULL)
+		return -ENOMEM;
+	info.fattr = fattr;
+	/* Check if we need to refresh filehandles */
+	if ((server->fhexpiretype & NFS4_FH_VOL_MIGRATION
+		|| server->fhexpiretype & NFS4_FH_VOLATILE_ANY)
+		&& server->flags & NFS_MOUNT_VFHRETRY) {
+		/* Update root dentry */
+		err = nfs4_proc_get_root(server, NFS_FH(d_root->d_inode),
+					&info);
+		if (!err) {
+			if (NFS_FILEID(d_root->d_inode) != info.fattr->fileid)
+				set_nfs_fileid(d_root->d_inode,
+							info.fattr->fileid);
+			nfs_copy_fh(server->rootfh, NFS_FH(d_root->d_inode));
+			/* Only needed if fsid changes on server */
+			memcpy(&server->fsid, &info.fattr->fsid,
+				sizeof(server->fsid));
+		} else
+			return err;
+		/* Loop over dcache entries */
+		this_parent = d_root;
+repeat:
+		next = this_parent->d_subdirs.next;
+resume:
+		while (next != &this_parent->d_subdirs) {
+			struct list_head *tmp = next;
+			struct dentry *dentry = list_entry(tmp, struct dentry,
+								d_u.d_child);
+			next = tmp->next;
+			/* Perform NFS lookup on dentry */
+			if (dentry->d_parent->d_inode && dentry->d_inode &&
+								&dentry->d_name)
+				nfs4_proc_lookup(server->client,
+					dentry->d_parent->d_inode,
+					&dentry->d_name,
+					NFS_FH(dentry->d_inode),
+					fattr);
+			if (!list_empty(&dentry->d_subdirs)) {
+				this_parent = dentry;
+				goto repeat;
+			}
+		}
+		if (this_parent != d_root) {
+			struct dentry *child = this_parent;
+			struct dentry *new = this_parent->d_parent;
+		/*
+		* might go back up the wrong parent if we have had a rename
+		* or deletion return ESTALE if it is renamed or deleted
+		*/
+			if (new != this_parent->d_parent ||
+			(this_parent->d_flags & DCACHE_DISCONNECTED)) {
+				return -ESTALE;
+			}
+			this_parent = new;
+			next = child->d_u.d_child.next;
+			goto resume;
+		}
+		return 0;
+
+	} else
+		return 0;
+}
+
 /* In the case of gettattr only a fh is given, and we need a VFS object to do
  * vfh recovery. This function traverses the dcache to find the dentry with
  * a matching fh
-- 
1.7.4.4

