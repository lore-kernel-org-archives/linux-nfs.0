From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 6/7] NFS: Eliminate nfs_renew_times()
Date: Mon, 24 Sep 2007 15:40:11 -0400
Message-ID: <20070924194011.3568.43518.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnh-0001Sb-Dt
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:41:01 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtnl-0007s1-9Y
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:41:06 -0700
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

The nfs_renew_times() function plants the current time in jiffies in
dentry->d_time.  But a call to nfs_renew_times() is always followed by
another call that overwrites dentry->d_time.  Get rid of the
nfs_renew_times() calls.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |   20 --------------------
 1 files changed, 0 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 3235ef5..0ed590d 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -672,15 +672,6 @@ static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
 }
 
 /*
- * Whenever an NFS operation succeeds, we know that the dentry
- * is valid, so we update the revalidation timestamp.
- */
-static inline void nfs_renew_times(struct dentry * dentry)
-{
-	dentry->d_time = jiffies;
-}
-
-/*
  * Return the intent data that applies to this particular path component
  *
  * Note that the current set of intents only apply to the very last
@@ -803,7 +794,6 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
 		goto out_bad;
 
-	nfs_renew_times(dentry);
 	nfs_refresh_verifier(dentry, verifier);
  out_valid:
 	unlock_kernel();
@@ -966,7 +956,6 @@ no_entry:
 		dput(parent);
 		dentry = res;
 	}
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out_unlock:
 	unlock_kernel();
@@ -1061,7 +1050,6 @@ static struct dentry *nfs_atomic_lookup(struct inode *dir, struct dentry *dentry
 		}
 	} else if (res != NULL)
 		dentry = res;
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 out:
 	return res;
@@ -1181,11 +1169,9 @@ static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
 		dentry = alias;
 	}
 
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	return dentry;
 out_renew:
-	nfs_renew_times(dentry);
 	nfs_refresh_verifier(dentry, nfs_save_change_attribute(dir));
 	return dentry;
 }
@@ -1252,7 +1238,6 @@ static int nfs_create(struct inode *dir, struct dentry *dentry, int mode,
 	nfs_end_data_update(dir);
 	if (error != 0)
 		goto out_err;
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	unlock_kernel();
 	return 0;
@@ -1286,7 +1271,6 @@ nfs_mknod(struct inode *dir, struct dentry *dentry, int mode, dev_t rdev)
 	nfs_end_data_update(dir);
 	if (status != 0)
 		goto out_err;
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	unlock_kernel();
 	return 0;
@@ -1316,7 +1300,6 @@ static int nfs_mkdir(struct inode *dir, struct dentry *dentry, int mode)
 	nfs_end_data_update(dir);
 	if (error != 0)
 		goto out_err;
-	nfs_renew_times(dentry);
 	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	unlock_kernel();
 	return 0;
@@ -1409,7 +1392,6 @@ static int nfs_sillyrename(struct inode *dir, struct dentry *dentry)
 				dir, &qsilly);
 	nfs_end_data_update(dir);
 	if (!error) {
-		nfs_renew_times(dentry);
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 		d_move(dentry, sdentry);
 		error = nfs_async_unlink(dir, dentry);
@@ -1492,7 +1474,6 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
 	spin_unlock(&dcache_lock);
 	error = nfs_safe_remove(dentry);
 	if (!error) {
-		nfs_renew_times(dentry);
 		nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	} else if (need_rehash)
 		d_rehash(dentry);
@@ -1714,7 +1695,6 @@ out:
 		d_rehash(rehash);
 	if (!error) {
 		d_move(old_dentry, new_dentry);
-		nfs_renew_times(new_dentry);
 		nfs_refresh_verifier(new_dentry, nfs_save_change_attribute(new_dir));
 	}
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
