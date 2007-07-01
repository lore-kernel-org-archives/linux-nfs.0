From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 03/21] NFS: Clean-up: Define macros for maximum host
	and	export path name lengths
Date: Sun, 01 Jul 2007 12:12:24 -0400
Message-ID: <20070701161224.2786.28187.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I523f-0004Rd-6O
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:56 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I523h-0004y5-II
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:13:58 -0700
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

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c            |    4 ++--
 include/linux/nfs_mount.h |    2 +-
 2 files changed, 3 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index a83cb07..1fedc30 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -918,12 +918,12 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 		}
 	}
 
-	p = nfs_copy_user_string(NULL, &data->hostname, 256);
+	p = nfs_copy_user_string(NULL, &data->hostname, NFS4_MAXNAMLEN);
 	if (IS_ERR(p))
 		goto out_err;
 	hostname = p;
 
-	p = nfs_copy_user_string(NULL, &data->mnt_path, 1024);
+	p = nfs_copy_user_string(NULL, &data->mnt_path, NFS4_MAXPATHLEN);
 	if (IS_ERR(p))
 		goto out_err;
 	mntpath = p;
diff --git a/include/linux/nfs_mount.h b/include/linux/nfs_mount.h
index 3e3b521..a3ade89 100644
--- a/include/linux/nfs_mount.h
+++ b/include/linux/nfs_mount.h
@@ -37,7 +37,7 @@ struct nfs_mount_data {
 	int		acdirmin;		/* 1 */
 	int		acdirmax;		/* 1 */
 	struct sockaddr_in addr;		/* 1 */
-	char		hostname[256];		/* 1 */
+	char		hostname[NFS_MAXNAMLEN + 1];		/* 1 */
 	int		namlen;			/* 2 */
 	unsigned int	bsize;			/* 3 */
 	struct nfs3_fh	root;			/* 4 */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
