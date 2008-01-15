From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: [NFS] [PATCH] nfs4: allow nfsv4 acls on non-regular-files
Date: Tue, 15 Jan 2008 16:43:19 -0500
Message-ID: <20080115214319.GC5028@fieldses.org>
References: <20080108174645.GH22155@fieldses.org>
	<200801082126.m08LQTZm021972@agora.fsl.cs.sunysb.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>, nfs@lists.sourceforge.net
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60339 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755995AbYAOVnh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Jan 2008 16:43:37 -0500
Received: from brown by neil.brown.name with local (Exim 4.63)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1JEtZH-0004Dh-55
	for linux-nfs@vger.kernel.org; Wed, 16 Jan 2008 08:43:35 +1100
In-Reply-To: <200801082126.m08LQTZm021972-zop+azHP2WsZjdeEBZXbMidm6ipF23ct@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: J. Bruce Fields <bfields@citi.umich.edu>

The rfc doesn't give any reason it shouldn't be possible to set an
attribute on a non-regular file.  And if the server supports it, then it
shouldn't be up to us to prevent it.

Thanks to Erez for the report and Trond for further analysis.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Tested-by: Erez Zadok <ezk-EX0cT3Az47bauI2f2gSDlQ@public.gmane.org>
---
 fs/nfs/nfs4proc.c |    4 ----
 1 files changed, 0 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 92bfbcb..ffe5584 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -3621,10 +3621,6 @@ int nfs4_setxattr(struct dentry *dentry, const char *key, const void *buf,
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
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2008.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

