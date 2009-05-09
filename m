From: Frank Filz <ffilzlnx@us.ibm.com>
Subject: [NFS] [PATCH] nfs: Fix NFS v4 client handling of MAY_EXEC
	in	nfs_permission.
Date: Fri, 08 May 2009 19:55:34 -0700
Message-ID: <1241837734.2404.4.camel@dyn9047022153>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Bruce Fields <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>
To: NFS List <nfs@lists.sourceforge.net>,
	NFS V4 Mailing List <nfsv4@linux-nfs.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from neil.brown.name ([220.233.11.133]:60522 "EHLO neil.brown.name"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751197AbZEICtu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 May 2009 22:49:50 -0400
Received: from brown by neil.brown.name with local (Exim 4.69)
	(envelope-from <nfs-bounces@lists.sourceforge.net>)
	id 1M2cdI-0007Ue-St
	for linux-nfs@vger.kernel.org; Sat, 09 May 2009 12:49:48 +1000
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The problem is that permission checking is skipped if atomic open is
possible, but when exec opens a file, it just opens it O_READONLY which
means EXEC permission will not be checked at that time.

This problem is observed by the following sequence (executed as root):

mount -t nfs4 server:/ /mnt4
echo "ls" >/mnt4/foo
chmod 744 /mnt4/foo
su guest -c "mnt4/foo"

Signed-off-by: Frank Filz <ffilzlnx@us.ibm.com>
---
 fs/nfs/dir.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 370b190..89f98e9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1943,7 +1943,8 @@ int nfs_permission(struct inode *inode, int mask)
 		case S_IFREG:
 			/* NFSv4 has atomic_open... */
 			if (nfs_server_capable(inode, NFS_CAP_ATOMIC_OPEN)
-					&& (mask & MAY_OPEN))
+					&& (mask & MAY_OPEN)
+					&& !(mask & MAY_EXEC))
 				goto out;
 			break;
 		case S_IFDIR:
-- 
1.5.2.2




------------------------------------------------------------------------------
The NEW KODAK i700 Series Scanners deliver under ANY circumstances! Your
production scanning environment may not be a perfect world - but thanks to
Kodak, there's a perfect scanner to get the job done! With the NEW KODAK i700
Series Scanner you'll get full speed at 300 dpi even with all image 
processing features enabled. http://p.sf.net/sfu/kodak-com
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

