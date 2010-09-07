Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:58313 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932481Ab0IGUDu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 7 Sep 2010 16:03:50 -0400
Received: from [10.58.61.36] (panchal1-lxp.hq.netapp.com [10.58.61.36] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o87K3nYM027358
	for <linux-nfs@vger.kernel.org>; Tue, 7 Sep 2010 13:03:49 -0700 (PDT)
Message-ID: <4C869AA5.60909@netapp.com>
Date: Tue, 07 Sep 2010 16:03:49 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
To: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: [PATCH 4/6] NFS: re-add readdir plus
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

NFS: re-add readdir plus

This patch adds readdir plus support to the cache array.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 87f74bb..6971946 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -321,6 +321,70 @@ int xdr_decode(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry, __be32 *
 	return 0;
 }
 
+static inline
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
+	struct qstr filename = nfs_readdir_make_qstr(entry->name, entry->len);
+	struct dentry *dentry = NULL;
+	struct dentry *alias = NULL;
+	struct inode *dir = parent->d_inode;
+	struct inode *inode;
+
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
 static inline
 void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *entry,
@@ -330,6 +394,8 @@ void nfs_readdir_page_filler(nfs_readdir_descriptor_t *desc, struct nfs_entry *e
 	while (xdr_decode(desc, entry, &ptr) == 0) {
 		if (nfs_readdir_add_to_array(entry, page) == -1)
 			break;
+		if (desc->plus == 1)
+			nfs_prime_dcache(desc->file->f_path.dentry, entry);
 	}
 	kunmap(xdr_page);
 }
