Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:46899 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751458AbbEDWBb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 May 2015 18:01:31 -0400
Date: Mon, 4 May 2015 18:01:30 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Kinglong Mee <kinglongmee@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH RFC] NFSD: fix cannot umounting mount points under pseudo
 root
Message-ID: <20150504220130.GB16827@fieldses.org>
References: <20150422150703.GA1247@fieldses.org>
 <20150423094431.1a8aa68b@notabene.brown>
 <5538EB18.7080802@gmail.com>
 <20150424130045.6bbdb2f9@notabene.brown>
 <553E2784.6020906@gmail.com>
 <20150429125728.69ddfc6c@notabene.brown>
 <20150429191934.GA23980@fieldses.org>
 <20150430075225.21a71056@notabene.brown>
 <20150430213602.GB9509@fieldses.org>
 <20150501115326.51f5613a@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20150501115326.51f5613a@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, May 01, 2015 at 11:53:26AM +1000, NeilBrown wrote:
> On Thu, 30 Apr 2015 17:36:02 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> wrote:
> 
> > On Thu, Apr 30, 2015 at 07:52:25AM +1000, NeilBrown wrote:
> > > On Wed, 29 Apr 2015 15:19:34 -0400 "J. Bruce Fields" <bfields@fieldses.org>
> > > wrote:
> > > > Maybe drop the locking from nfsd_buffered_readdir and *just* take the
> > > > i_mutex around lookup_one_len(), if that's the only place we need it?
> > > 
> > > I think it is the only place needed.  Certainly normal path lookup
> > > only takes i_mutex very briefly around __lookup_hash().
> > > 
> > > One cost would be that we would take the mutex for every name instead
> > > of once for a whole set of names.  That is generally frowned upon for
> > > performance reasons.
> > > 
> > > An alternative might be to stop using lookup_one_len, and use
> > > kern_path() instead.  Or kern_path_mountpoint if we don't want to
> > > cross a mountpoint.
> > > 
> > > They would only take the i_mutex if absolutely necessary.
> > > 
> > > The draw back is that they don't take a 'len' argument, so we would
> > > need to make sure the name  is nul terminated (and maybe double-check
> > > that there is no '/'??).  It would be fairly easy to nul-terminate
> > > names from readdir - just use a bit more space  in the buffer in
> > > nfsd_buffered_filldir().
> > 
> > They're also a lot more complicated than lookup_one_len.  Is any of this
> > extra stuff they do (audit?) going to bite us?
> > 
> > For me understanding that would be harder than writing a variant of
> > lookup_one_len that took the i_mutex when required.  But I guess that's
> > my problem, I should try to understand the lookup code better....
> 
> Tempting though ... see below (untested).

With documentation and a stab at the nfsd stuff (also untested.  OK, and
pretty much unread.  Compiles, though!)

--b.

commit 6023d45abd1a
Author: NeilBrown <neilb@suse.de>
Date:   Fri May 1 11:53:26 2015 +1000

    nfsd: don't hold i_mutex over userspace upcalls
    
    We need information about exports when crossing mountpoints during
    lookup or NFSv4 readdir.  If we don't already have that information
    cached, we may have to ask (and wait for) rpc.mountd.
    
    In both cases we currently hold the i_mutex on the parent of the
    directory we're asking rpc.mountd about.  We've seen situations where
    rpc.mountd performs some operation on that directory that tries to take
    the i_mutex again, resulting in deadlock.
    
    With some care, we may be able to avoid that in rpc.mountd.  But it
    seems better just to avoid holding a mutex while waiting on userspace.
    
    It appears that lookup_one_len is pretty much the only operation that
    needs the i_mutex.  So we could just drop the i_mutex elsewhere and do
    something like
    
    	mutex_lock()
    	lookup_one_len()
    	mutex_unlock()
    
    In may cases though the lookup would have been cached and not required
    the i_mutex, so it's more efficient to create a lookup_one_len() variant
    that only takes the i_mutex when necessary.
    
    Signed-off-by: J. Bruce Fields <bfields@redhat.com>

diff --git a/fs/namei.c b/fs/namei.c
index 4a8d998b7274..5ec103d4775d 100644
--- a/fs/namei.c
+++ b/fs/namei.c
@@ -2139,6 +2139,8 @@ static struct dentry *lookup_hash(struct nameidata *nd)
  *
  * Note that this routine is purely a helper for filesystem usage and should
  * not be called by generic code.
+ *
+ * Must be called with the parented i_mutex held.
  */
 struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
 {
@@ -2182,6 +2184,68 @@ struct dentry *lookup_one_len(const char *name, struct dentry *base, int len)
 }
 EXPORT_SYMBOL(lookup_one_len);
 
+/**
+ * lookup_one_len - filesystem helper to lookup single pathname component
+ * @name:	pathname component to lookup
+ * @base:	base directory to lookup from
+ * @len:	maximum length @len should be interpreted to
+ *
+ * Note that this routine is purely a helper for filesystem usage and should
+ * not be called by generic code.
+ *
+ * Unlike lookup_one_len, it should be called without the parent
+ * i_mutex held, and will take the i_mutex itself if necessary.
+ */
+struct dentry *lookup_one_len_unlocked(const char *name,
+				       struct dentry *base, int len)
+{
+	struct qstr this;
+	unsigned int c;
+	int err;
+	struct dentry *ret;
+
+	WARN_ON_ONCE(!mutex_is_locked(&base->d_inode->i_mutex));
+
+	this.name = name;
+	this.len = len;
+	this.hash = full_name_hash(name, len);
+	if (!len)
+		return ERR_PTR(-EACCES);
+
+	if (unlikely(name[0] == '.')) {
+		if (len < 2 || (len == 2 && name[1] == '.'))
+			return ERR_PTR(-EACCES);
+	}
+
+	while (len--) {
+		c = *(const unsigned char *)name++;
+		if (c == '/' || c == '\0')
+			return ERR_PTR(-EACCES);
+	}
+	/*
+	 * See if the low-level filesystem might want
+	 * to use its own hash..
+	 */
+	if (base->d_flags & DCACHE_OP_HASH) {
+		int err = base->d_op->d_hash(base, &this);
+		if (err < 0)
+			return ERR_PTR(err);
+	}
+
+	err = inode_permission(base->d_inode, MAY_EXEC);
+	if (err)
+		return ERR_PTR(err);
+
+	ret = __d_lookup(base, &this);
+	if (ret)
+		return ret;
+	mutex_lock(&base->d_inode->i_mutex);
+	ret =  __lookup_hash(&this, base, 0);
+	mutex_unlock(&base->d_inode->i_mutex);
+	return ret;
+}
+EXPORT_SYMBOL(lookup_one_len_unlocked);
+
 int user_path_at_empty(int dfd, const char __user *name, unsigned flags,
 		 struct path *path, int *empty)
 {
diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 158badf945df..2c1adaa0bd2f 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2804,14 +2804,14 @@ nfsd4_encode_dirent_fattr(struct xdr_stream *xdr, struct nfsd4_readdir *cd,
 	__be32 nfserr;
 	int ignore_crossmnt = 0;
 
-	dentry = lookup_one_len(name, cd->rd_fhp->fh_dentry, namlen);
+	dentry = lookup_one_len_unlocked(name, cd->rd_fhp->fh_dentry, namlen);
 	if (IS_ERR(dentry))
 		return nfserrno(PTR_ERR(dentry));
 	if (d_really_is_negative(dentry)) {
 		/*
-		 * nfsd_buffered_readdir drops the i_mutex between
-		 * readdir and calling this callback, leaving a window
-		 * where this directory entry could have gone away.
+		 * we're not holding the i_mutex here, so there's
+		 * a window where this directory entry could have gone
+		 * away.
 		 */
 		dput(dentry);
 		return nfserr_noent;
diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index a30e79900086..cc7995762190 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -217,6 +217,13 @@ nfsd_lookup_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp,
 		host_err = PTR_ERR(dentry);
 		if (IS_ERR(dentry))
 			goto out_nfserr;
+		if (!S_ISREG(d_inode(dentry)->i_mode)) {
+			/*
+			 * Never mind, we're not going to open this
+			 * anyway.  And we don't want to hold it over
+			 * the userspace upcalls in nfsd_mountpoint. */
+			fh_unlock(fhp);
+		}
 		/*
 		 * check if we have crossed a mount point ...
 		 */
@@ -1876,7 +1883,6 @@ static __be32 nfsd_buffered_readdir(struct file *file, nfsd_filldir_t func,
 	offset = *offsetp;
 
 	while (1) {
-		struct inode *dir_inode = file_inode(file);
 		unsigned int reclen;
 
 		cdp->err = nfserr_eof; /* will be cleared on successful read */
@@ -1895,15 +1901,6 @@ static __be32 nfsd_buffered_readdir(struct file *file, nfsd_filldir_t func,
 		if (!size)
 			break;
 
-		/*
-		 * Various filldir functions may end up calling back into
-		 * lookup_one_len() and the file system's ->lookup() method.
-		 * These expect i_mutex to be held, as it would within readdir.
-		 */
-		host_err = mutex_lock_killable(&dir_inode->i_mutex);
-		if (host_err)
-			break;
-
 		de = (struct buffered_dirent *)buf.dirent;
 		while (size > 0) {
 			offset = de->offset;
@@ -1920,7 +1917,6 @@ static __be32 nfsd_buffered_readdir(struct file *file, nfsd_filldir_t func,
 			size -= reclen;
 			de = (struct buffered_dirent *)((char *)de + reclen);
 		}
-		mutex_unlock(&dir_inode->i_mutex);
 		if (size > 0) /* We bailed out early */
 			break;
 
diff --git a/include/linux/namei.h b/include/linux/namei.h
index c8990779f0c3..bb3a2f7cca67 100644
--- a/include/linux/namei.h
+++ b/include/linux/namei.h
@@ -62,6 +62,7 @@ extern struct dentry *kern_path_locked(const char *, struct path *);
 extern int kern_path_mountpoint(int, const char *, struct path *, unsigned int);
 
 extern struct dentry *lookup_one_len(const char *, struct dentry *, int);
+extern struct dentry *lookup_one_len_unlocked(const char *, struct dentry *, int);
 
 extern int follow_down_one(struct path *);
 extern int follow_down(struct path *);
