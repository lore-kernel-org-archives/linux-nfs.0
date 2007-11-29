From: Chuck Lever <chuck.lever@oracle.com>
Subject: [NFS] [PATCH 10/29] NFS: Address a couple of nits in
	nfs_follow_referral()
Date: Thu, 29 Nov 2007 14:40:46 -0500
Message-ID: <20071129194046.4170.91463.stgit@picasso.1015granger.net>
References: <20071129193153.4170.29598.stgit@picasso.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net, aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IxpGj-0001WS-Qx
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:41:53 -0800
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IxpGo-0007vy-P6
	for nfs@lists.sourceforge.net; Thu, 29 Nov 2007 11:42:00 -0800
In-Reply-To: <20071129193153.4170.29598.stgit-uiCyzNpeAnB9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

Clean up: fix an outdated block comment, and address a comparison
between a signed and unsigned integer.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/nfs4namespace.c |    8 +++-----
 1 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index dd5fef2..bd1b161 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -114,10 +114,7 @@ static inline int valid_ipaddr4(const char *buf)
  * nfs_follow_referral - set up mountpoint when hitting a referral on moved error
  * @mnt_parent - mountpoint of parent directory
  * @dentry - parent directory
- * @fspath - fs path returned in fs_locations
- * @mntpath - mount path to new server
- * @hostname - hostname of new server
- * @addr - host addr of new server
+ * @locations - array of NFSv4 server location information
  *
  */
 static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
@@ -131,7 +128,8 @@ static struct vfsmount *nfs_follow_referral(const struct vfsmount *mnt_parent,
 		.authflavor = NFS_SB(mnt_parent->mnt_sb)->client->cl_auth->au_flavor,
 	};
 	char *page = NULL, *page2 = NULL;
-	int loc, s, error;
+	unsigned int s;
+	int loc, error;
 
 	if (locations == NULL || locations->nlocations <= 0)
 		goto out;


-------------------------------------------------------------------------
SF.Net email is sponsored by: The Future of Linux Business White Paper
from Novell.  From the desktop to the data center, Linux is going
mainstream.  Let it simplify your IT future.
http://altfarm.mediaplex.com/ad/ck/8857-50307-18918-4
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
_______________________________________________
Please note that nfs@lists.sourceforge.net is being discontinued.
Please subscribe to linux-nfs@vger.kernel.org instead.
    http://vger.kernel.org/vger-lists.html#linux-nfs

