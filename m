From: Ian Kent <raven@themaw.net>
Subject: Re: time_after cannot be used alone by NFS code
	in	32bit	architectures
Date: Tue, 08 May 2007 10:37:04 +0800
Message-ID: <1178591824.3918.10.camel@raven.themaw.net>
References: <20070426043344.GO10449@sleipnir.redhat.com>
	<1178106770.5960.28.camel@raven.themaw.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: linux-nfs <nfs@lists.sourceforge.net>
To: Fabio Olive Leite <fleite@redhat.com>
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1HlFZh-0000Ui-6n
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 19:37:13 -0700
Received: from out1.smtp.messagingengine.com ([66.111.4.25])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1HlFZi-0006b0-Bq
	for nfs@lists.sourceforge.net; Mon, 07 May 2007 19:37:16 -0700
In-Reply-To: <1178106770.5960.28.camel@raven.themaw.net>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

On Wed, 2007-05-02 at 19:52 +0800, Ian Kent wrote:
> On Thu, 2007-04-26 at 01:33 -0300, Fabio Olive Leite wrote: 
> > This leads to several problematic situations in long-lived NFS mounts.
> > We can see old attributes not being updated, negative dentries that do
> > not revalidate even after touching their parent dir, etc.
> > 
> 
> This is quite an interesting issue and I'm still having trouble
> understanding it so let me try and explain my understanding of part of
> it.
> 

snip ...

> So the problem you describe actually happens when the directory inode
> cache_change_attribute warps and the dentry d_fstada timestamp is later
> than inode cache_change_attribute. So updating the
> cache_change_attribute field, as in the patch that Neil referred to,
> will often not fix it.

I believe the patch that Neil refers to will ensure that the inode
cache_change_attribute is updated to a reasonably recent time.

> 
> Have I got this right yet?

No response so I guess so!

Then how about this patch.
It doesn't step on other dentry fields.
I haven't tested this except that it compiles because I'm after comments
as to whether it is a sensible approach.

---
--- linux-2.6.21/fs/nfs/dir.c.use-timespec-for-verifier	2007-05-08 09:37:14.000000000 +0800
+++ linux-2.6.21/fs/nfs/dir.c	2007-05-08 10:33:31.000000000 +0800
@@ -633,28 +633,49 @@
 }
 
 /*
+ * Allocate verifier timespec once during lookup and free
+ * it during d_release.
+ */
+static inline int nfs_alloc_verifier(struct dentry *dentry)
+{
+	dentry->d_fsdata = kmalloc(sizeof(struct timespec), GFP_KERNEL);
+	if (!dentry->d_fsdata)
+		return 0;
+	return 1;
+}
+
+/*
  * A check for whether or not the parent directory has changed.
  * In the case it has, we assume that the dentries are untrustworthy
  * and may need to be looked up again.
  */
 static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 {
+	struct timespec *chattr = dentry->d_fsdata;
+	struct timespec cache_chattr;
+
 	if (IS_ROOT(dentry))
 		return 1;
 	if ((NFS_I(dir)->cache_validity & NFS_INO_INVALID_ATTR) != 0
 			|| nfs_attribute_timeout(dir))
 		return 0;
-	return nfs_verify_change_attribute(dir, (unsigned long)dentry->d_fsdata);
+	jiffies_to_timespec(NFS_I(dir)->cache_change_attribute, &cache_chattr);
+	return !nfs_caches_unstable(dir)
+		&& (timespec_compare(chattr, &cache_chattr) >= 0);
 }
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 {
-	dentry->d_fsdata = (void *)verf;
+	jiffies_to_timespec(verf, (struct timespec *) &dentry->d_fsdata);
 }
 
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
 {
-	if (time_after(verf, (unsigned long)dentry->d_fsdata))
+	struct timespec *last = dentry->d_fsdata;
+	struct timespec verifier;
+
+	jiffies_to_timespec(verf, &verifier);
+	if (timespec_compare(&verifier, last) > 0)
 		nfs_set_verifier(dentry, verf);
 }
 
@@ -860,10 +881,17 @@
 	iput(inode);
 }
 
+static void nfs_dentry_release(struct dentry *dentry)
+{
+	if (dentry->d_fsdata)
+		kfree(dentry->d_fsdata);
+}
+
 struct dentry_operations nfs_dentry_operations = {
 	.d_revalidate	= nfs_lookup_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
+	.d_release	= nfs_dentry_release,
 };
 
 /*
@@ -909,6 +937,8 @@
 
 	res = ERR_PTR(-ENOMEM);
 	dentry->d_op = NFS_PROTO(dir)->dentry_ops;
+	if (!nfs_alloc_verifier(dentry))
+		goto out;
 
 	lock_kernel();
 
@@ -967,6 +997,7 @@
 	.d_revalidate	= nfs_open_revalidate,
 	.d_delete	= nfs_dentry_delete,
 	.d_iput		= nfs_dentry_iput,
+	.d_release	= nfs_dentry_release,
 };
 
 /*



-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
