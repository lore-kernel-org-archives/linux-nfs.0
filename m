Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36678 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757211AbcCDKQY (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Mar 2016 05:16:24 -0500
Received: by mail-wm0-f65.google.com with SMTP id l68so3370027wml.3
        for <linux-nfs@vger.kernel.org>; Fri, 04 Mar 2016 02:16:23 -0800 (PST)
Date: Fri, 4 Mar 2016 11:17:22 +0100
From: Miklos Szeredi <miklos@szeredi.hu>
To: Goldwyn Rodrigues <rgoldwyn@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        "linux-unionfs@vger.kernel.org" <linux-unionfs@vger.kernel.org>,
        Linux FS-devel Mailing List <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 3/3] nfs: Store and use inode in nfs_open_context
Message-ID: <20160304101722.GA8655@tucsk>
References: <1456855928-29913-1-git-send-email-rgoldwyn@suse.de>
 <1456855928-29913-4-git-send-email-rgoldwyn@suse.de>
 <CAHQdGtRu2nd54+tKQLPp2tvf1MpKw4-X8ESqx-8W4_zAov7hFA@mail.gmail.com>
 <56D6F84B.5040301@suse.de>
 <CAHQdGtSd8Sg-X7vGOJoVZZZZQFxfsdeOsHUcS5z09BOVwQ1pUw@mail.gmail.com>
 <CAHQdGtR1Ywp9JnO7mD5-tOy5wngsgp2OZBJyQx1hyaXpTNc54g@mail.gmail.com>
 <CAJfpegvm_E_K6_wwvuWnnm-D=tBEY=dq_frp8UObUysS4_Pixg@mail.gmail.com>
 <56D70D64.9010705@suse.de>
 <CAJfpegtwDD4Qaect-5qzvG80vnn44iKawYCeTqQKneSK-FU3Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAJfpegtwDD4Qaect-5qzvG80vnn44iKawYCeTqQKneSK-FU3Lg@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Mar 03, 2016 at 09:16:33AM +0100, Miklos Szeredi wrote:
> My plan was to introduce a file_dentry() helper that MUST be used by
> filesystems to get the dentry from the file and that makes sure it's
> the right one (check against file_inode()).   If not, then we could
> call into overlayfs to return the right one, similar to
> ->d_select_inode(), except we want to have a dentry and we want to
> have *a particular dentry* matching file_inode() (the file could have
> been copied up in the mean time).

Something like the following (untested, against overlayfs-next.git)

Thanks,
Miklos

---
 fs/nfs/dir.c           |    6 +++---
 fs/nfs/inode.c         |    2 +-
 fs/nfs/nfs4file.c      |    4 ++--
 fs/open.c              |   11 +++++++++++
 fs/overlayfs/super.c   |   16 ++++++++++++++++
 include/linux/dcache.h |    1 +
 include/linux/fs.h     |    2 ++
 7 files changed, 36 insertions(+), 6 deletions(-)

--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -377,7 +377,7 @@ int nfs_readdir_xdr_filler(struct page *
  again:
 	timestamp = jiffies;
 	gencount = nfs_inc_attr_generation_counter();
-	error = NFS_PROTO(inode)->readdir(file->f_path.dentry, cred, entry->cookie, pages,
+	error = NFS_PROTO(inode)->readdir(file_dentry(file), cred, entry->cookie, pages,
 					  NFS_SERVER(inode)->dtsize, desc->plus);
 	if (error < 0) {
 		/* We requested READDIRPLUS, but the server doesn't grok it */
@@ -560,7 +560,7 @@ int nfs_readdir_page_filler(nfs_readdir_
 		count++;
 
 		if (desc->plus != 0)
-			nfs_prime_dcache(desc->file->f_path.dentry, entry);
+			nfs_prime_dcache(file_dentry(desc->file), entry);
 
 		status = nfs_readdir_add_to_array(entry, page);
 		if (status != 0)
@@ -864,7 +864,7 @@ static bool nfs_dir_mapping_need_revalid
  */
 static int nfs_readdir(struct file *file, struct dir_context *ctx)
 {
-	struct dentry	*dentry = file->f_path.dentry;
+	struct dentry	*dentry = file_dentry(file);
 	struct inode	*inode = d_inode(dentry);
 	nfs_readdir_descriptor_t my_desc,
 			*desc = &my_desc;
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -940,7 +940,7 @@ int nfs_open(struct inode *inode, struct
 {
 	struct nfs_open_context *ctx;
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
 	if (IS_ERR(ctx))
 		return PTR_ERR(ctx);
 	nfs_file_set_open_context(filp, ctx);
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -26,7 +26,7 @@ static int
 nfs4_file_open(struct inode *inode, struct file *filp)
 {
 	struct nfs_open_context *ctx;
-	struct dentry *dentry = filp->f_path.dentry;
+	struct dentry *dentry = file_dentry(filp);
 	struct dentry *parent = NULL;
 	struct inode *dir;
 	unsigned openflags = filp->f_flags;
@@ -57,7 +57,7 @@ nfs4_file_open(struct inode *inode, stru
 	parent = dget_parent(dentry);
 	dir = d_inode(parent);
 
-	ctx = alloc_nfs_open_context(filp->f_path.dentry, filp->f_mode);
+	ctx = alloc_nfs_open_context(file_dentry(filp), filp->f_mode);
 	err = PTR_ERR(ctx);
 	if (IS_ERR(ctx))
 		goto out;
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1234,6 +1234,8 @@ static inline struct inode *file_inode(c
 	return f->f_inode;
 }
 
+extern struct dentry *file_dentry(const struct file *file);
+
 static inline int locks_lock_file_wait(struct file *filp, struct file_lock *fl)
 {
 	return locks_lock_inode_wait(file_inode(filp), fl);
--- a/fs/open.c
+++ b/fs/open.c
@@ -831,6 +831,17 @@ char *file_path(struct file *filp, char
 }
 EXPORT_SYMBOL(file_path);
 
+struct dentry *file_dentry(const struct file *file)
+{
+	struct dentry *dentry = file->f_path.dentry;
+
+	if (d_inode(dentry) == file_inode(file))
+		return dentry;
+	else
+		return dentry->d_op->d_select_dentry(dentry, file_inode(file));
+}
+EXPORT_SYMBOL(file_dentry);
+
 /**
  * vfs_open - open the file at the given path
  * @path: path to open
--- a/fs/overlayfs/super.c
+++ b/fs/overlayfs/super.c
@@ -336,14 +336,30 @@ static int ovl_dentry_weak_revalidate(st
 	return ret;
 }
 
+static struct dentry *ovl_d_select_dentry(struct dentry *dentry,
+					 struct inode *inode)
+{
+	struct ovl_entry *oe = dentry->d_fsdata;
+	struct dentry *realentry = ovl_upperdentry_dereference(oe);
+
+	if (realentry && inode == d_inode(realentry))
+		return realentry;
+	realentry = __ovl_dentry_lower(oe);
+	if (realentry && inode == d_inode(realentry))
+		return realentry;
+	BUG();
+}
+
 static const struct dentry_operations ovl_dentry_operations = {
 	.d_release = ovl_dentry_release,
 	.d_select_inode = ovl_d_select_inode,
+	.d_select_dentry = ovl_d_select_dentry,
 };
 
 static const struct dentry_operations ovl_reval_dentry_operations = {
 	.d_release = ovl_dentry_release,
 	.d_select_inode = ovl_d_select_inode,
+	.d_select_dentry = ovl_d_select_dentry,
 	.d_revalidate = ovl_dentry_revalidate,
 	.d_weak_revalidate = ovl_dentry_weak_revalidate,
 };
--- a/include/linux/dcache.h
+++ b/include/linux/dcache.h
@@ -161,6 +161,7 @@ struct dentry_operations {
 	struct vfsmount *(*d_automount)(struct path *);
 	int (*d_manage)(struct dentry *, bool);
 	struct inode *(*d_select_inode)(struct dentry *, unsigned);
+	struct dentry *(*d_select_dentry)(struct dentry *, struct inode *);
 } ____cacheline_aligned;
 
 /*
