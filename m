From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 5/7] NFS: Don't call nfs_renew_times() in
	nfs_dentry_iput()
Date: Mon, 24 Sep 2007 15:40:06 -0400
Message-ID: <20070924194005.3568.815.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IZtnb-0001S8-EL
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:40:55 -0700
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]
	helo=flpi195.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IZtnf-0007mK-AL
	for nfs@lists.sourceforge.net; Mon, 24 Sep 2007 12:41:00 -0700
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

Negative dentries need to be reverified after an asynchronous unlink.

Quoth Trond:

"Unfortunately I don't think that we can avoid revalidating the
resulting negative dentry since the UNLINK call is asynchronous,
and so the new verifier on the directory will only be known a
posteriori."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/dir.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 44d298b..3235ef5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -872,8 +872,6 @@ static void nfs_dentry_iput(struct dentry *dentry, struct inode *inode)
 		nfs_complete_unlink(dentry, inode);
 		unlock_kernel();
 	}
-	/* When creating a negative dentry, we want to renew d_time */
-	nfs_renew_times(dentry);
 	iput(inode);
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
