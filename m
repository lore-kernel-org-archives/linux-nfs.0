From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Re: corruption over NFS with 2.6 client, locking,
	truncating and appending...
Date: Tue, 05 Apr 2005 16:24:21 -0400
Message-ID: <1112732661.10536.8.camel@lade.trondhjem.org>
References: <16977.57630.766727.608029@cse.unsw.edu.au>
	 <1112664792.11910.12.camel@lade.trondhjem.org>
	 <16977.60501.153237.389021@cse.unsw.edu.au>
	 <1112667216.11740.4.camel@lade.trondhjem.org>
	 <16978.3509.329730.989580@cse.unsw.edu.au>
	 <1112676829.11900.4.camel@lade.trondhjem.org>
	 <16978.9443.679431.70613@cse.unsw.edu.au>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-KXrgZubb+KK0Be3ywQRi"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DIubH-0001iw-4T
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 13:24:39 -0700
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DIubF-0006Ep-6D
	for nfs@lists.sourceforge.net; Tue, 05 Apr 2005 13:24:39 -0700
To: Neil Brown <neilb@cse.unsw.edu.au>
In-Reply-To: <16978.9443.679431.70613@cse.unsw.edu.au>
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


--=-KXrgZubb+KK0Be3ywQRi
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

ty den 05.04.2005 Klokka 15:40 (+1000) skreiv Neil Brown:
> The thing is that it seems to break down even without locking, though
> I don't fully understand why yet.
> When I use .lock file locking I get the same problem.
> However I have found that if I open the file for read, and then close
> it, immediately before opening for write+append, then the problem goes
> away.  This is for the .lock file locking, and the .lock file is held
> over both opens.

OK. Attached is a patch that appears to fix things up for me (at least
for the case of fcntl() locking). It should apply on top of the latest
-mm kernel with the SEEKDIR_END patch that I sent you last night.

Basically, it says that the client must synchronize to the server-given
value of fattr->size _unless_ we still have pending writes (in which
case we only accept size values > inode->i_size) or if the getattr() RPC
call raced with an attribute-changing RPC call (a cached write would
indeed count as an "attribute-changing RPC call").

Note that this differs greatly from the current behaviour where we only
accept updates to inode->i_size if the file is not open for writing and
we didn't race.

Cheers,
  Trond

-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-KXrgZubb+KK0Be3ywQRi
Content-Disposition: inline; filename=linux-2.6.12-38-fix_writes.dif
Content-Type: text/plain; name=linux-2.6.12-38-fix_writes.dif; charset=UTF-8
Content-Transfer-Encoding: 7bit

NFS: Fix the file size revalidation

 Instead of looking at whether or not the file is open for writes before
 we accept to update the length using the server value, we should rather
 be looking at whether or not we are currently caching any writes.

 Failure to do so means in particular that we're not updating the file
 length correctly after obtaining a POSIX or BSD lock.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/direct.c        |    2 -
 fs/nfs/inode.c         |   69 ++++++++++++-------------------------------------
 fs/nfs/write.c         |    4 +-
 include/linux/nfs_fs.h |    1 
 4 files changed, 21 insertions(+), 55 deletions(-)

Index: linux-2.6.12-rc1/fs/nfs/inode.c
===================================================================
--- linux-2.6.12-rc1.orig/fs/nfs/inode.c
+++ linux-2.6.12-rc1/fs/nfs/inode.c
@@ -1148,27 +1148,6 @@ void nfs_end_data_update(struct inode *i
 }
 
 /**
- * nfs_end_data_update_defer
- * @inode - pointer to inode
- * Declare end of the operations that will update file data
- * This will defer marking the inode as needing revalidation
- * unless there are no other pending updates.
- */
-void nfs_end_data_update_defer(struct inode *inode)
-{
-	struct nfs_inode *nfsi = NFS_I(inode);
-
-	if (atomic_dec_and_test(&nfsi->data_updates)) {
-		/* Mark the attribute cache for revalidation */
-		nfsi->flags |= NFS_INO_INVALID_ATTR;
-		/* Directories and symlinks: invalidate page cache too */
-		if (S_ISDIR(inode->i_mode) || S_ISLNK(inode->i_mode))
-			nfsi->flags |= NFS_INO_INVALID_DATA;
-		nfsi->cache_change_attribute ++;
-	}
-}
-
-/**
  * nfs_refresh_inode - verify consistency of the inode attribute cache
  * @inode - pointer to inode
  * @fattr - updated attributes
@@ -1222,8 +1201,8 @@ int nfs_refresh_inode(struct inode *inod
 		if (!timespec_equal(&inode->i_mtime, &fattr->mtime)
 				|| cur_size != new_isize)
 			nfsi->flags |= NFS_INO_INVALID_ATTR;
-	} else if (S_ISREG(inode->i_mode) && new_isize > cur_size)
-			nfsi->flags |= NFS_INO_INVALID_ATTR;
+	} else if (new_isize != cur_size && nfsi->npages == 0)
+		nfsi->flags |= NFS_INO_INVALID_ATTR;
 
 	/* Have any file permissions changed? */
 	if ((inode->i_mode & S_IALLUGO) != (fattr->mode & S_IALLUGO)
@@ -1257,10 +1236,8 @@ int nfs_refresh_inode(struct inode *inod
 static int nfs_update_inode(struct inode *inode, struct nfs_fattr *fattr, unsigned long verifier)
 {
 	struct nfs_inode *nfsi = NFS_I(inode);
-	__u64		new_size;
-	loff_t		new_isize;
+	loff_t cur_isize, new_isize;
 	unsigned int	invalid = 0;
-	loff_t		cur_isize;
 	int data_unstable;
 
 	dfprintk(VFS, "NFS: %s(%s/%ld ct=%d info=0x%x)\n",
@@ -1293,49 +1270,39 @@ static int nfs_update_inode(struct inode
 	/* Are we racing with known updates of the metadata on the server? */
 	data_unstable = ! nfs_verify_change_attribute(inode, verifier);
 
-	/* Check if the file size agrees */
-	new_size = fattr->size;
+	/* Check if our cached file size is stale */
  	new_isize = nfs_size_to_loff_t(fattr->size);
 	cur_isize = i_size_read(inode);
-	if (cur_isize != new_size) {
-#ifdef NFS_DEBUG_VERBOSE
-		printk(KERN_DEBUG "NFS: isize change on %s/%ld\n", inode->i_sb->s_id, inode->i_ino);
-#endif
-		/*
-		 * If we have pending writebacks, things can get
-		 * messy.
-		 */
-		if (S_ISREG(inode->i_mode) && data_unstable) {
-			if (new_isize > cur_isize) {
+	if (new_isize != cur_isize) {
+		/* Do we perhaps have any outstanding writes? */
+		if (nfsi->npages == 0) {
+			/* No, but did we race with nfs_end_data_update()? */
+			if (verifier  ==  nfsi->cache_change_attribute) {
 				inode->i_size = new_isize;
-				invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
+				invalid |= NFS_INO_INVALID_DATA;
 			}
-		} else {
+			invalid |= NFS_INO_INVALID_ATTR;
+		} else if (new_isize > cur_isize) {
 			inode->i_size = new_isize;
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 		}
+		dprintk("NFS: isize change on server for file %s/%ld\n",
+				inode->i_sb->s_id, inode->i_ino);
 	}
 
-	/*
-	 * Note: we don't check inode->i_mtime since pipes etc.
-	 *       can change this value in VFS without requiring a
-	 *	 cache revalidation.
-	 */
+	/* Check if the mtime agrees */
 	if (!timespec_equal(&inode->i_mtime, &fattr->mtime)) {
 		memcpy(&inode->i_mtime, &fattr->mtime, sizeof(inode->i_mtime));
-#ifdef NFS_DEBUG_VERBOSE
-		printk(KERN_DEBUG "NFS: mtime change on %s/%ld\n", inode->i_sb->s_id, inode->i_ino);
-#endif
+		dprintk("NFS: mtime change on server for file %s/%ld\n",
+				inode->i_sb->s_id, inode->i_ino);
 		if (!data_unstable)
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA;
 	}
 
 	if ((fattr->valid & NFS_ATTR_FATTR_V4)
 	    && nfsi->change_attr != fattr->change_attr) {
-#ifdef NFS_DEBUG_VERBOSE
-		printk(KERN_DEBUG "NFS: change_attr change on %s/%ld\n",
+		dprintk("NFS: change_attr change on server for file %s/%ld\n",
 		       inode->i_sb->s_id, inode->i_ino);
-#endif
 		nfsi->change_attr = fattr->change_attr;
 		if (!data_unstable)
 			invalid |= NFS_INO_INVALID_ATTR|NFS_INO_INVALID_DATA|NFS_INO_INVALID_ACCESS|NFS_INO_INVALID_ACL;
Index: linux-2.6.12-rc1/fs/nfs/write.c
===================================================================
--- linux-2.6.12-rc1.orig/fs/nfs/write.c
+++ linux-2.6.12-rc1/fs/nfs/write.c
@@ -220,7 +220,7 @@ static int nfs_writepage_sync(struct nfs
 		ClearPageError(page);
 
 io_error:
-	nfs_end_data_update_defer(inode);
+	nfs_end_data_update(inode);
 	nfs_writedata_free(wdata);
 	return written ? written : result;
 }
@@ -401,7 +401,7 @@ static void nfs_inode_remove_request(str
 	nfsi->npages--;
 	if (!nfsi->npages) {
 		spin_unlock(&nfsi->req_lock);
-		nfs_end_data_update_defer(inode);
+		nfs_end_data_update(inode);
 		iput(inode);
 	} else
 		spin_unlock(&nfsi->req_lock);
Index: linux-2.6.12-rc1/fs/nfs/direct.c
===================================================================
--- linux-2.6.12-rc1.orig/fs/nfs/direct.c
+++ linux-2.6.12-rc1/fs/nfs/direct.c
@@ -517,7 +517,7 @@ retry:
 	result = tot_bytes;
 
 out:
-	nfs_end_data_update_defer(inode);
+	nfs_end_data_update(inode);
 	nfs_writedata_free(wdata);
 	return result;
 
Index: linux-2.6.12-rc1/include/linux/nfs_fs.h
===================================================================
--- linux-2.6.12-rc1.orig/include/linux/nfs_fs.h
+++ linux-2.6.12-rc1/include/linux/nfs_fs.h
@@ -294,7 +294,6 @@ extern void nfs_begin_attr_update(struct
 extern void nfs_end_attr_update(struct inode *);
 extern void nfs_begin_data_update(struct inode *);
 extern void nfs_end_data_update(struct inode *);
-extern void nfs_end_data_update_defer(struct inode *);
 extern struct nfs_open_context *alloc_nfs_open_context(struct dentry *dentry, struct rpc_cred *cred);
 extern struct nfs_open_context *get_nfs_open_context(struct nfs_open_context *ctx);
 extern void put_nfs_open_context(struct nfs_open_context *ctx);

--=-KXrgZubb+KK0Be3ywQRi--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
