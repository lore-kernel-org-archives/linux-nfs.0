Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f181.google.com ([209.85.213.181]:41430 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751651AbaBGWIm (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 7 Feb 2014 17:08:42 -0500
Received: by mail-ig0-f181.google.com with SMTP id j1so2860718iga.2
        for <linux-nfs@vger.kernel.org>; Fri, 07 Feb 2014 14:08:41 -0800 (PST)
Message-ID: <1391810919.2865.2.camel@leira.trondhjem.org>
Subject: Re: readdir vs. getattr
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Brown Neil <neilb@suse.de>
Cc: Jeff Layton <jlayton@poochiereds.net>,
        "Mkrtchyan, Tigran" <tigran.mkrtchyan@desy.de>,
        Jim Rees <rees@umich.edu>, linux-nfs <linux-nfs@vger.kernel.org>
Date: Fri, 07 Feb 2014 17:08:39 -0500
In-Reply-To: <6F6E3499-4C95-44B4-BBD0-CFFBFC4F48DA@primarydata.com>
References: <CAGue13pe_ZH_Eto-jL3mLjTNGFK26izTarnZdjs3eL82A2Z37w@mail.gmail.com>
	 <20130404151507.GA8484@umich.edu>
	 <CAGue13o6X5S3ppTX_fmMCTCX=7Mq_57YQEsb_hkOKwN9iOHwEQ@mail.gmail.com>
	 <1365090480.10726.22.camel@leira.trondhjem.org>
	 <20140129182532.7479eeda@notabene.brown>
	 <1342984553.746756.1390987303295.JavaMail.zimbra@desy.de>
	 <20140129071841.1979a48c@tlielax.poochiereds.net>
	 <20140206134539.53d09434@notabene.brown>
	 <20140206135101.1cc83442@notabene.brown>
	 <1391724779.6399.2.camel@leira.trondhjem.org>
	 <20140207153028.7df0d209@notabene.brown>
	 <6F6E3499-4C95-44B4-BBD0-CFFBFC4F48DA@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2014-02-07 at 14:47 -0500, Trond Myklebust wrote:
> On Feb 6, 2014, at 23:30, NeilBrown <neilb@suse.de> wrote:
> > In my test case there is a large directory on the server which doesn't change.
> > The client sends lots of requests to see if it has changed, but it hasn't.
> > (Tested with the labeled-NFS-regression fix applied)
> > 
> > Your patch only changes behaviour if nfs_force_lookup_revalidate is called,
> > and that is only called when NFS_ATTR_FATTR_CHANGE is set, or when an NFSv4
> > client modifies the directory.  Neither of those are happening.
> 
> Right, but I really do not know how to fix that case.
> 
> I read your patch as saying: "If we're revalidating a dentry and we find that the directory has not changed but that the dentry’s inode needs revalidation, then invalidate that directory's attribute, acl and readdir cached data. Then drop the dentry”. I have a hard time seeing how that can be beneficial.
> 
> If we were to modify it, to only invalidate the readdir cached data, then that might improve matters, but it is still hard for me to see how a single inode needing revalidation can justify a full re-read of the parent directory in the general case. You may end up rereading thousands of readdir entries from the server just because someone did a path lookup.

OK. How about something like the following then? The heuristic
specifically looks for the 'ls -l' fingerprint, and uses that to clear
the readdir cache if and when the server supports readdirplus.

8<--------------------------------------------------------------------
>From e2fdc035d223b6a5bffa55583818ac0aa22b996c Mon Sep 17 00:00:00 2001
From: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Fri, 7 Feb 2014 17:02:08 -0500
Subject: [PATCH] NFS: Be more aggressive in using readdirplus for 'ls -l'
 situations

Try to detect 'ls -l' by having nfs_getattr() look at whether or not
there is an opendir() file descriptor for the parent directory.
If so, then assume that we want to force use of readdirplus in order
to avoid the multiple GETATTR calls over the wire.

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/dir.c           | 42 ++++++++++++++++++++++++++++++++++++++----
 fs/nfs/inode.c         | 34 +++++++++++++++++++++++++++-------
 fs/nfs/internal.h      |  1 +
 include/linux/nfs_fs.h |  1 +
 4 files changed, 67 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index be38b573495a..c8e48c26418b 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -69,21 +69,28 @@ const struct address_space_operations nfs_dir_aops = {
 
 static struct nfs_open_dir_context *alloc_nfs_open_dir_context(struct inode *dir, struct rpc_cred *cred)
 {
+	struct nfs_inode *nfsi = NFS_I(dir);
 	struct nfs_open_dir_context *ctx;
 	ctx = kmalloc(sizeof(*ctx), GFP_KERNEL);
 	if (ctx != NULL) {
 		ctx->duped = 0;
-		ctx->attr_gencount = NFS_I(dir)->attr_gencount;
+		ctx->attr_gencount = nfsi->attr_gencount;
 		ctx->dir_cookie = 0;
 		ctx->dup_cookie = 0;
 		ctx->cred = get_rpccred(cred);
+		spin_lock(&dir->i_lock);
+		list_add(&ctx->list, &nfsi->open_files);
+		spin_unlock(&dir->i_lock);
 		return ctx;
 	}
 	return  ERR_PTR(-ENOMEM);
 }
 
-static void put_nfs_open_dir_context(struct nfs_open_dir_context *ctx)
+static void put_nfs_open_dir_context(struct inode *dir, struct nfs_open_dir_context *ctx)
 {
+	spin_lock(&dir->i_lock);
+	list_del(&ctx->list);
+	spin_unlock(&dir->i_lock);
 	put_rpccred(ctx->cred);
 	kfree(ctx);
 }
@@ -126,7 +133,7 @@ out:
 static int
 nfs_closedir(struct inode *inode, struct file *filp)
 {
-	put_nfs_open_dir_context(filp->private_data);
+	put_nfs_open_dir_context(filp->f_path.dentry->d_inode, filp->private_data);
 	return 0;
 }
 
@@ -437,6 +444,22 @@ void nfs_advise_use_readdirplus(struct inode *dir)
 	set_bit(NFS_INO_ADVISE_RDPLUS, &NFS_I(dir)->flags);
 }
 
+/*
+ * This function is mainly for use by nfs_getattr().
+ *
+ * If this is an 'ls -l', we want to force use of readdirplus.
+ * Do this by checking if there is an active file descriptor
+ * and calling nfs_advise_use_readdirplus, then forcing a
+ * cache flush.
+ */
+void nfs_force_use_readdirplus(struct inode *dir)
+{
+	if (!list_empty(&NFS_I(dir)->open_files)) {
+		nfs_advise_use_readdirplus(dir);
+		nfs_zap_mapping(dir, dir->i_mapping);
+	}
+}
+
 static
 void nfs_prime_dcache(struct dentry *parent, struct nfs_entry *entry)
 {
@@ -815,6 +838,17 @@ int uncached_readdir(nfs_readdir_descriptor_t *desc)
 	goto out;
 }
 
+static bool nfs_dir_mapping_need_revalidate(struct inode *dir)
+{
+	struct nfs_inode *nfsi = NFS_I(dir);
+
+	if (nfs_attribute_cache_expired(dir))
+		return true;
+	if (nfsi->cache_validity & NFS_INO_INVALID_DATA)
+		return true;
+	return false;
+}
+
 /* The file offset position represents the dirent entry number.  A
    last cookie cache takes care of the common case of reading the
    whole directory.
@@ -847,7 +881,7 @@ static int nfs_readdir(struct file *file, struct dir_context *ctx)
 	desc->plus = nfs_use_readdirplus(inode, ctx) ? 1 : 0;
 
 	nfs_block_sillyrename(dentry);
-	if (ctx->pos == 0 || nfs_attribute_cache_expired(inode))
+	if (ctx->pos == 0 || nfs_dir_mapping_need_revalidate(inode))
 		res = nfs_revalidate_mapping(inode, file->f_mapping);
 	if (res < 0)
 		goto out;
diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 4636b828e957..d1407380338a 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -594,6 +594,25 @@ void nfs_setattr_update_inode(struct inode *inode, struct iattr *attr)
 }
 EXPORT_SYMBOL_GPL(nfs_setattr_update_inode);
 
+static void nfs_request_parent_use_readdirplus(struct dentry *dentry)
+{
+	struct dentry *parent;
+
+	parent = dget_parent(dentry);
+	nfs_force_use_readdirplus(parent->d_inode);
+	dput(parent);
+}
+
+static bool nfs_need_revalidate_inode(struct inode *inode)
+{
+	if (NFS_I(inode)->cache_validity &
+			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
+		return true;
+	if (nfs_attribute_cache_expired(inode))
+		return true;
+	return false;
+}
+
 int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
 {
 	struct inode *inode = dentry->d_inode;
@@ -622,10 +641,13 @@ int nfs_getattr(struct vfsmount *mnt, struct dentry *dentry, struct kstat *stat)
  	    ((mnt->mnt_flags & MNT_NODIRATIME) && S_ISDIR(inode->i_mode)))
 		need_atime = 0;
 
-	if (need_atime)
-		err = __nfs_revalidate_inode(NFS_SERVER(inode), inode);
-	else
-		err = nfs_revalidate_inode(NFS_SERVER(inode), inode);
+	if (need_atime || nfs_need_revalidate_inode(inode)) {
+		struct nfs_server *server = NFS_SERVER(inode);
+
+		if (server->caps & NFS_CAP_READDIRPLUS)
+			nfs_request_parent_use_readdirplus(dentry);
+		err = __nfs_revalidate_inode(server, inode);
+	}
 	if (!err) {
 		generic_fillattr(inode, stat);
 		stat->ino = nfs_compat_user_ino64(NFS_FILEID(inode));
@@ -967,9 +989,7 @@ int nfs_attribute_cache_expired(struct inode *inode)
  */
 int nfs_revalidate_inode(struct nfs_server *server, struct inode *inode)
 {
-	if (!(NFS_I(inode)->cache_validity &
-			(NFS_INO_INVALID_ATTR|NFS_INO_INVALID_LABEL))
-			&& !nfs_attribute_cache_expired(inode))
+	if (!nfs_need_revalidate_inode(inode))
 		return NFS_STALE(inode) ? -ESTALE : 0;
 	return __nfs_revalidate_inode(server, inode);
 }
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index fafdddac8271..7f7c476d0c2c 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -300,6 +300,7 @@ extern struct nfs_client *nfs_init_client(struct nfs_client *clp,
 			   const char *ip_addr);
 
 /* dir.c */
+extern void nfs_force_use_readdirplus(struct inode *dir);
 extern unsigned long nfs_access_cache_count(struct shrinker *shrink,
 					    struct shrink_control *sc);
 extern unsigned long nfs_access_cache_scan(struct shrinker *shrink,
diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
index 9123ce3fc6a5..2c22722b406f 100644
--- a/include/linux/nfs_fs.h
+++ b/include/linux/nfs_fs.h
@@ -92,6 +92,7 @@ struct nfs_open_context {
 };
 
 struct nfs_open_dir_context {
+	struct list_head list;
 	struct rpc_cred *cred;
 	unsigned long attr_gencount;
 	__u64 dir_cookie;
-- 
1.8.5.3


-- 
Trond Myklebust
Linux NFS client maintainer, PrimaryData
trond.myklebust@primarydata.com


