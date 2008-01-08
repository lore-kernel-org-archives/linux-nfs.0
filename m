From: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Subject: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Mon, 7 Jan 2008 22:14:31 -0500
Message-ID: <200801080314.m083EVbb011378@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:43184 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753963AbYAHDOx (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 7 Jan 2008 22:14:53 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JC4vS-0006UG-6I
	for linux-nfs@vger.kernel.org; Tue, 08 Jan 2008 14:14:50 +1100
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


Trond, I've discovered an asymmetry in how nfs4 (in v2.6.24-rc7) handles
listxattr vs. setxattr for special files.  I caught this with Unionfs when
testing a copyup of a character device from a readonly nfs4 mount to a
writable nfs4 mount.

nfs4_setxattr returns -EPERM if the inode isn't a regular file or a (sticky)
dir.  However, nfs4_listxattr returns XATTR_NAME_NFSV4_ACL (16 bytes,
"system.nfs4_acl") regardless of the type of the inode.  So during copyup, I
can ->listxattr fine from the source inode, but I get EPERM trying to
->setxattr on the destination branch of of the copyup.  (I already handle
the case when copying-up from a f/s which supports xattr's to one which
doesn't, but when both file systems are the same and mounted the same, there
typically should not be difference).

Assuming that the original intent of the EPERM check in nfs4_setxattr was to
prevent setting xattrs over nfs4 for non-files/dirs, then I "fixed" this by
adding a similar check in nfs4_listxattr, which returns an empty xattr list
for those.  I've included a patch below for your consideration/review.

Cheers,
Erez.

--cut-here----cut-here----cut-here----cut-here----cut-here----cut-here--

NFS4: ignore non files/dirs in nfs4_getxattr, same as nfs4_listxattr

Signed-off-by: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 9e2e1c7..ad46fef 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3656,9 +3656,13 @@ ssize_t nfs4_getxattr(struct dentry *dentry, const char *key, void *buf,
 ssize_t nfs4_listxattr(struct dentry *dentry, char *buf, size_t buflen)
 {
 	size_t len = strlen(XATTR_NAME_NFSV4_ACL) + 1;
+	struct inode *inode = dentry->d_inode;
 
 	if (!nfs4_server_supports_acls(NFS_SERVER(dentry->d_inode)))
 		return 0;
+	if (!S_ISREG(inode->i_mode) &&
+	    (!S_ISDIR(inode->i_mode) || inode->i_mode & S_ISVTX))
+		return 0;
 	if (buf && buflen < len)
 		return -ERANGE;
 	if (buf)


-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

