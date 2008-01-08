From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 12:46:45 -0500
Message-ID: <20080108174645.GH22155@fieldses.org>
References: <200801080314.m083EVbb011378@agora.fsl.cs.sunysb.edu>
	<1199763245.21371.6.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:53498 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756995AbYAHVOE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 16:14:04 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCLlo-00006q-7d
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 08:14:00 +1100
In-Reply-To: <1199763245.21371.6.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Jan 07, 2008 at 10:34:04PM -0500, Trond Myklebust wrote:
> 
> On Mon, 2008-01-07 at 22:14 -0500, Erez Zadok wrote:
> > Trond, I've discovered an asymmetry in how nfs4 (in v2.6.24-rc7) handles
> > listxattr vs. setxattr for special files.  I caught this with Unionfs when
> > testing a copyup of a character device from a readonly nfs4 mount to a
> > writable nfs4 mount.
> > 
> > nfs4_setxattr returns -EPERM if the inode isn't a regular file or a (sticky)
> > dir.  However, nfs4_listxattr returns XATTR_NAME_NFSV4_ACL (16 bytes,
> > "system.nfs4_acl") regardless of the type of the inode.  So during copyup, I
> > can ->listxattr fine from the source inode, but I get EPERM trying to
> > ->setxattr on the destination branch of of the copyup.  (I already handle
> > the case when copying-up from a f/s which supports xattr's to one which
> > doesn't, but when both file systems are the same and mounted the same, there
> > typically should not be difference).
> > 
> > Assuming that the original intent of the EPERM check in nfs4_setxattr was to
> > prevent setting xattrs over nfs4 for non-files/dirs, then I "fixed" this by
> > adding a similar check in nfs4_listxattr, which returns an empty xattr list
> > for those.  I've included a patch below for your consideration/review.
> 
> I can see no reason in the RFC why you shouldn't be able to set an NFSv4
> ACL on a special file. AFAICS this is a bug in the nfs4_setxattr code,
> which is probably due to some improper cut n' pasting from the posix acl
> code.
> 
> Bruce?

I think you're right.

I'm also mystified by this rule that the sticky bit prevents non-owners
from writing a directory's extended attributes.  (See fs/xattr.c.)  Any
idea what the source of that is?  Anyway, I don't see why the client
should enforce such a rule in this case.

Erez, does just removing this check solve your problem?

--b.

>From 9fa16668ed09b212ec0325786d91ac65734336ea Mon Sep 17 00:00:00 2001
From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Tue, 8 Jan 2008 12:41:41 -0500
Subject: [PATCH] nfs4: allow nfsv4 acls on non-regular-files

The rfc doesn't give any reason it shouldn't be possible to set an
attribute on a non-regular file.  And if the server supports it, then it
shouldn't be up to us to prevent it.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/nfs/nfs4proc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index f03d9d5..e9b9903 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3625,10 +3625,6 @@ int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
 	if (strcmp(key, XATTR_NAME_NFSV4_ACL) != 0)
 		return -EOPNOTSUPP;
 
-	if (!S_ISREG(inode->i_mode) &&
-	    (!S_ISDIR(inode->i_mode) || inode->i_mode & S_ISVTX))
-		return -EPERM;
-
 	return nfs4_proc_set_acl(inode, buf, buflen);
 }
 
-- 
1.5.4.rc2.60.gb2e62


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

