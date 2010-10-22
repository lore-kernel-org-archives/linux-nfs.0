Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:6970 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757166Ab0JVOOk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 22 Oct 2010 10:14:40 -0400
Message-ID: <4CC19C42.6040302@netapp.com>
Date: Fri, 22 Oct 2010 10:14:26 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
Subject: [PATCH 03/10] NFS: re-add readdir plus
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This patch adds readdir plus support to the cache array.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/dir.c |   67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 67 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 4b07f0a..cd45bf0 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -370,6 +370,71 @@ int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, __be32 *
 	return 0;
 }
 
+static
+int nfs_same_file(struct dentry *dentry, struct nfs_entry *entry)
+{
+	struct nfs_inode *node;
+	if (dentry->d_inode == NULL)
+		goto different;
+	node = NFS_I(dentry->d_inode);
+	if (node->fh.size != entry->fh->size)
+		goto different;
+	if (strncmp(node->fh.data, entry->fh->data, node->fh.size) != 0)
+		goto different;
+	return 1;
+different:
+	return 0;
+}
+
+static
+void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
+{
+	struct qstr filename;
+	struct dentry *dentry = NULL;
+	struct dentry *alias = NULL;
+	struct inode *dir = parent->d_inode;
+	struct inode *inode;
+
+	nfs_readdir_make_qstr(&filename, entry->name, entry->len);
+	if (filename.len == 1 && filename.name[0] == '.')
+		dentry = dget(parent);
+	else if (filename.len == 2 && filename.name[0] == '.'
+				   && filename.name[1] == '.')
+		dentry = dget_parent(parent);
+	else
+		dentry = d_lookup(parent, &filename);
+
+	if (dentry != NULL) {
+		if (nfs_same_file(dentry, entry)) {
+			nfs_refresh_inode(dentry->d_inode, entry->fattr);
+			goto out;
+		} else {
+			d_drop(dentry);
+			dput(dentry);
+		}
+	}
+
+	dentry = d_alloc(parent, &filename);
+	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
+	inode = nfs_fhget(dentry->d_sb, entry->fh, entry->fattr);
+	if (IS_ERR(inode))
+		goto out;
+
+	alias = d_materialise_unique(dentry, inode);
+	if (IS_ERR(alias))
+		goto out;
+	else if (alias) {
+		nfs_set_verifier(alias, nfs_save_change_attribute(dir));
+		dput(alias);
+	} else
+		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
+
+out:
+	dput(dentry);
+	kfree(filename.name);
+	return;
+}
+
 /* Perform conversion from xdr to cache array */
 static
 void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
@@ -379,6 +444,8 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 	while (xdr_decode(desc, entry, &ptr) == 0) {
 		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
+		if (desc->plus == 1)
+			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 	}
 	kunmap(xdr_page);
 }
