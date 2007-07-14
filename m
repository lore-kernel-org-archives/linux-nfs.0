From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 1/3] NFS: Use dentry->d_time to store the parent
	directory	verifier.
Date: Sat, 14 Jul 2007 18:12:09 -0400
Message-ID: <20070714221209.13914.10001.stgit@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Chuck Lever <Chuck.Lever@oracle.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I9sEO-0004FG-P2
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:45:04 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I9sES-0008Sx-7T
	for nfs@lists.sourceforge.net; Sat, 14 Jul 2007 17:45:04 -0700
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

From: Trond Myklebust <Trond.Myklebust@netapp.com>

This will free up the d_fsdata field for other use.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/dir.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 322141f..0fa1dbc 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -654,7 +654,7 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 
 	if (IS_ROOT(dentry))
 		return 1;
-	verf = (unsigned long)dentry->d_fsdata;
+	verf = dentry->d_time;
 	if (nfs_caches_unstable(dir)
 			|| verf != NFS_I(dir)->cache_change_attribute)
 		return 0;
@@ -663,7 +663,7 @@ static int nfs_check_verifier(struct inode *dir, struct dentry *dentry)
 
 static inline void nfs_set_verifier(struct dentry * dentry, unsigned long verf)
 {
-	dentry->d_fsdata = (void *)verf;
+	dentry->d_time = verf;
 }
 
 static void nfs_refresh_verifier(struct dentry * dentry, unsigned long verf)

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
