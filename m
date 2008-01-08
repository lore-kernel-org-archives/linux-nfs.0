From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [NFS] [PATCH] nfs4, special files, and set/listxattr asymmetry
Date: Tue, 8 Jan 2008 16:45:30 -0500
Message-ID: <20080108214530.GO22155@fieldses.org>
References: <20080108174645.GH22155@fieldses.org>
	<200801082126.m08LQTZm021972@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	nfs@lists.sourceforge.net
To: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:54878 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751368AbYAHVpj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 8 Jan 2008 16:45:39 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JCMGP-0000AP-5n
	for linux-nfs@vger.kernel.org; Wed, 09 Jan 2008 08:45:37 +1100
In-Reply-To: <200801082126.m08LQTZm021972-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jan 08, 2008 at 04:26:29PM -0500, Erez Zadok wrote:
> Yes, it works equally well for me.  Thanks.

OK, thanks.  

> Acked-by: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>

Maybe that should be Reviewed-by?  Tested-by?  Up to Trond, I guess.

Trond, could you apply?

--b.

From: J. Bruce Fields <bfields@citi.umich.edu>
Date: Tue, 8 Jan 2008 12:41:41 -0500
Subject: [PATCH] nfs4: allow nfsv4 acls on non-regular-files

The rfc doesn't give any reason it shouldn't be possible to set an
attribute on a non-regular file.  And if the server supports it, then it
shouldn't be up to us to prevent it.

Thanks to Erez Zadok for bug report and Trond Myklebust for analysis.

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

