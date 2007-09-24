From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] NFS: Eliminate nfs_refresh_verifier()
Date: Mon, 24 Sep 2007 15:40:16 -0400
Message-ID: <20070924194016.3568.33431.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnL-0001Qq-08
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:39 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtnO-0007fG-MB
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:44 -0700
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

nfs_set_verifier() and nfs_refresh_verifier() do exactly the same thing, so
replace one with the other.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |   16 +++++-----------
 1 files changed, 5 insertions(+), 11 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0ed590d..2b5e611 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -666,11 +666,6 @@ static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 	dentry->d_time = verf;
 }
 
-static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)
-{
-	nfs_set_verifier(dentry, verf);
-}
-
 /*
  * Return the intent data that applies to this particular path component
  *
@@ -794,7 +789,7 @@ static int nfs_lookup_revalidate(struct dentry * dentry, struct nameidata *nd)
 	if ((error = nfs_refresh_inode(inode, &fattr)) != 0)
 		goto out_bad;
 
-	nfs_refresh_verifier(dentry, verifier);
+	nfs_set_verifier(dentry, verifier);
  out_valid:
 	unlock_kernel();
 	dput(parent);
@@ -1093,7 +1088,7 @@ static int nfs_open_revalidate(struct dentry *dentry, struct nameidata *nd)
 	verifier = nfs_save_change_attribute(dir);
 	ret = nfs4_open_revalidate(dir, dentry, openflags, nd);
 	if (!ret)
-		nfs_refresh_verifier(dentry, verifier);
+		nfs_set_verifier(dentry, verifier);
 	unlock_kernel();
 out:
 	dput(parent);
@@ -1169,10 +1164,8 @@ static struct dentry *nfs_readdir_lookup(nfs_readdir_descriptor_t *desc)
 		dentry = alias;
 	}
 
-	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
-	return dentry;
 out_renew:
-	nfs_refresh_verifier(dentry, nfs_save_change_attribute(dir));
+	nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 	return dentry;
 }
 
@@ -1695,7 +1688,8 @@ out:
 		d_rehash(rehash);
 	if (!error) {
 		d_move(old_dentry, new_dentry);
-		nfs_refresh_verifier(new_dentry, nfs_save_change_attribute(new_dir));
+		nfs_set_verifier(new_dentry,
+					nfs_save_change_attribute(new_dir));
 	}
 
 	/* new dentry created? */


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
