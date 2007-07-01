From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 17/21] NFS: Improve debugging output in NFS in-kernel
	mount	client
Date: Sun, 01 Jul 2007 12:13:38 -0400
Message-ID: <20070701161338.2786.98532.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52iY-00007Z-Oz
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:10 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52ic-0002Zy-4B
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:14 -0700
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

 fs/nfs/mount_clnt.c |   28 ++++++++++++++++++++++++++--
 1 files changed, 26 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/mount_clnt.c b/fs/nfs/mount_clnt.c
index 8138886..1e4907f 100644
--- a/fs/nfs/mount_clnt.c
+++ b/fs/nfs/mount_clnt.c
@@ -66,7 +66,7 @@ int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
 
 	mnt_clnt = rpc_create(&args);
 	if (IS_ERR(mnt_clnt))
-		return PTR_ERR(mnt_clnt);
+		goto out_clnt_err;
 
 	if (version == NFS_MNT3_VERSION)
 		msg.rpc_proc = &mnt_clnt->cl_procinfo[MOUNTPROC3_MNT];
@@ -75,7 +75,31 @@ int nfs_mount(struct sockaddr *addr, size_t len, char *hostname, char *path,
 
 	status = rpc_call_sync(mnt_clnt, &msg, 0);
 	rpc_shutdown_client(mnt_clnt);
-	return status < 0? status : (result.status? -EACCES : 0);
+
+	if (status < 0)
+		goto out_call_err;
+	if (result.status != 0)
+		goto out_mnt_err;
+
+	dprintk("NFS: MNT request succeeded\n");
+	status = 0;
+
+out:
+	return status;
+
+out_clnt_err:
+	status = PTR_ERR(mnt_clnt);
+	dprintk("NFS: failed to create RPC client, status=%d\n", status);
+	goto out;
+
+out_call_err:
+	dprintk("NFS: failed to start MNT request, status=%d\n", status);
+	goto out;
+
+out_mnt_err:
+	dprintk("NFS: MNT server returned result %d\n", result.status);
+	status = -EACCES;
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
