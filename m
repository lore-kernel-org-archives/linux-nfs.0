From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] spinlock recursion on inode number mismatches
Date: Thu, 17 Nov 2005 18:30:32 -0500
Message-ID: <1132270232.8017.2.camel@lade.trondhjem.org>
References: <437CFF13.50606@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: NFS@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91] helo=mail.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1EctDR-0007aa-30
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 15:30:53 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44)
	id 1EctDQ-0002El-MP
	for nfs@lists.sourceforge.net; Thu, 17 Nov 2005 15:30:53 -0800
To: Steve Dickson <SteveD@redhat.com>
In-Reply-To: <437CFF13.50606@RedHat.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>

On Thu, 2005-11-17 at 17:07 -0500, Steve Dickson wrote:
> The attached patch solve the problem by the problem by moving
> the call to nfs_invalidate_inode() out of nfs_invalidate_inode().

Hmm... That will cause us to call make_bad_inode on all errors in
nfs_update_inode().

Given the sort of things we have in NFSv4 these days (delegations etc)
that need to be cleaned up on inode release, I'm not sure we should ever
be calling make_bad_inode().

How about something like the appended patch instead?

Cheers,
  Trond
-------
NFS: Fix a spinlock recursion inside nfs_update_inode()

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/inode.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
index 6391d89..aaab1a5 100644
--- a/fs/nfs/inode.c
+++ b/fs/nfs/inode.c
@@ -643,14 +643,11 @@ static int nfs_show_options(struct seq_f
 /*
  * Invalidate the local caches
  */
-void
-nfs_zap_caches(struct inode *inode)
+static void nfs_zap_caches_locked(struct inode *inode)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
 	int mode = inode->i_mode;
 
-	spin_lock(&inode->i_lock);
-
 	NFS_ATTRTIMEO(inode) = NFS_MINATTRTIMEO(inode);
 	NFS_ATTRTIMEO_UPDATE(inode) = jiffies;
 
@@ -659,7 +656,12 @@ nfs_zap_caches(struct inode *inode)
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
 	else
 		nfsi->cache_validity |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL|NFS_INO_REVAL_PAGECACHE;
+}
 
+void nfs_zap_caches(struct inode *inode)
+{
+	spin_lock(&inode->i_lock);
+	nfs_zap_caches_locked(inode);
 	spin_unlock(&inode->i_lock);
 }
 
@@ -676,16 +678,13 @@ static void nfs_zap_acl_cache(struct ino
 }
 
 /*
- * Invalidate, but do not unhash, the inode
+ * Invalidate, but do not unhash, the inode.
+ * NB: must be called with inode->i_lock held!
  */
-static void
-nfs_invalidate_inode(struct inode *inode)
+static void nfs_invalidate_inode(struct inode *inode)
 {
-	umode_t save_mode = inode->i_mode;
-
-	make_bad_inode(inode);
-	inode->i_mode = save_mode;
-	nfs_zap_caches(inode);
+	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
+	nfs_zap_caches_locked(inode);
 }
 
 struct nfs_find_desc {
@@ -1528,14 +1527,13 @@ static int nfs_update_inode(struct inode
 	printk(KERN_DEBUG "%s: inode %ld mode changed, %07o to %07o\n",
 			__FUNCTION__, inode->i_ino, inode->i_mode, fattr->mode);
 #endif
+ out_err:
 	/*
 	 * No need to worry about unhashing the dentry, as the
 	 * lookup validation will know that the inode is bad.
 	 * (But we fall through to invalidate the caches.)
 	 */
 	nfs_invalidate_inode(inode);
- out_err:
-	set_bit(NFS_INO_STALE, &NFS_FLAGS(inode));
 	return -ESTALE;
 }
 




-------------------------------------------------------
This SF.Net email is sponsored by the JBoss Inc.  Get Certified Today
Register for a JBoss Training Course.  Free Certification Exam
for All Training Attendees Through End of 2005. For more info visit:
http://ads.osdn.com/?ad_id=7628&alloc_id=16845&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
