From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 05/21] NFS: Clean up error handling in nfs_get_sb
Date: Sun, 01 Jul 2007 12:12:35 -0400
Message-ID: <20070701161235.2786.10878.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I524X-0004Z3-04
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:50 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I524Z-00041U-CJ
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:52 -0700
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

The error return logic in nfs_get_sb now matches nfs4_get_sb, and is more maintainable.
A subsequent patch will take advantage of this simplification.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 8ee6dae..e98f7ca 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -673,13 +673,13 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	/* Validate the mount data */
 	error = nfs_validate_mount_data(data, &mntfh);
 	if (error < 0)
-		return error;
+		goto out;
 
 	/* Get a volume representation */
 	server = nfs_create_server(data, &mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
-		goto out_err_noserver;
+		goto out;
 	}
 
 	if (server->flags & NFS_MOUNT_UNSHARED)
@@ -715,17 +715,19 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
-	return 0;
+	error = 0;
+
+out:
+	return error;
 
 out_err_nosb:
 	nfs_free_server(server);
-out_err_noserver:
-	return error;
+	goto out;
 
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
-	return error;
+	goto out;
 }
 
 /*


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
