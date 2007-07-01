From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 19/21] NFS: Introduce generic mount client API
Date: Sun, 01 Jul 2007 12:13:49 -0400
Message-ID: <20070701161349.2786.64088.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52ia-00007k-KA
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:12 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52id-0007Px-V4
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:16 -0700
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

For NFSv2 and v3 mounts, the first step is to contact the server's MOUNTD
and request the file handle for the root of the mounted share.  Add a
function to the NFS client that handles this operation.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   57 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 57 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3f24d63..c5ca68d 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1002,6 +1002,63 @@ out_unknown:
 }
 
 /*
+ * Use the remote server's MOUNT service to request the NFS file handle
+ * corresponding to the provided path.
+ */
+static int nfs_try_mount(struct nfs_parsed_mount_data *args,
+			 struct nfs_fh *root_fh)
+{
+	struct sockaddr_in sin;
+	int status;
+
+	if (args->mount_server.version == 0) {
+		if (args->flags & NFS_MOUNT_VER3)
+			args->mount_server.version = NFS_MNT3_VERSION;
+		else
+			args->mount_server.version = NFS_MNT_VERSION;
+	}
+
+	/*
+	 * Construct the mount server's address.
+	 */
+	if (args->mount_server.address.sin_addr.s_addr != INADDR_ANY)
+		sin = args->mount_server.address;
+	else
+		sin = args->nfs_server.address;
+	if (args->mount_server.port == 0) {
+		status = rpcb_getport_sync(&sin,
+					   args->mount_server.program,
+					   args->mount_server.version,
+					   args->mount_server.protocol);
+		if (status < 0)
+			goto out_err;
+		sin.sin_port = htons(status);
+	} else
+		sin.sin_port = htons(args->mount_server.port);
+
+	/*
+	 * Now ask the mount server to map our export path
+	 * to a file handle.
+	 */
+	status = nfs_mount((struct sockaddr *) &sin,
+			   sizeof(sin),
+			   args->nfs_server.hostname,
+			   args->nfs_server.export_path,
+			   args->mount_server.version,
+			   args->mount_server.protocol,
+			   root_fh);
+	if (status < 0)
+		goto out_err;
+
+	return status;
+
+out_err:
+	dfprintk(MOUNT, "NFS: unable to contact server on host "
+		 NIPQUAD_FMT "\n", NIPQUAD(sin.sin_addr.s_addr));
+	return status;
+}
+
+/*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  */


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
