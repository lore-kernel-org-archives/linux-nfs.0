From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/21] NFS: Clean up nfs_validate_mount_data
Date: Sun, 01 Jul 2007 12:12:56 -0400
Message-ID: <20070701161256.2786.99672.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I525l-0004lo-90
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:16:05 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I525l-0005ak-S3
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:16:08 -0700
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

Move error handling code out of the main code path.  The switch statement
was also improperly indented, according to Documentation/CodingStyle.  This
prepares nfs_validate_mount_data for the addition of option string parsing.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  125 ++++++++++++++++++++++++++++++--------------------------
 1 files changed, 67 insertions(+), 58 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f7fd2e7..bdfab72 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -471,77 +471,86 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 static int nfs_validate_mount_data(struct nfs_mount_data *data,
 				   struct nfs_fh *mntfh)
 {
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		return -EINVAL;
-	}
-
-	if (data->version <= 0 || data->version > NFS_MOUNT_VERSION) {
-		dprintk("%s: bad mount version\n", __FUNCTION__);
-		return -EINVAL;
-	}
+	if (data == NULL)
+		goto out_no_data;
 
 	switch (data->version) {
-		case 1:
-			data->namlen = 0;
-		case 2:
-			data->bsize  = 0;
-		case 3:
-			if (data->flags & NFS_MOUNT_VER3) {
-				dprintk("%s: mount structure version %d does not support NFSv3\n",
-						__FUNCTION__,
-						data->version);
-				return -EINVAL;
-			}
-			data->root.size = NFS2_FHSIZE;
-			memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
-		case 4:
-			if (data->flags & NFS_MOUNT_SECFLAVOUR) {
-				dprintk("%s: mount structure version %d does not support strong security\n",
-						__FUNCTION__,
-						data->version);
-				return -EINVAL;
-			}
-		case 5:
-			memset(data->context, 0, sizeof(data->context));
+	case 1:
+		data->namlen = 0;
+	case 2:
+		data->bsize = 0;
+	case 3:
+		if (data->flags & NFS_MOUNT_VER3)
+			goto out_no_v3;
+		data->root.size = NFS2_FHSIZE;
+		memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
+	case 4:
+		if (data->flags & NFS_MOUNT_SECFLAVOUR)
+			goto out_no_sec;
+	case 5:
+		memset(data->context, 0, sizeof(data->context));
+	case 6:
+		if (data->flags & NFS_MOUNT_VER3)
+			mntfh->size = data->root.size;
+		else
+			mntfh->size = NFS2_FHSIZE;
+
+		if (mntfh->size > sizeof(mntfh->data))
+			goto out_invalid_fh;
+
+		memcpy(mntfh->data, data->root.data, mntfh->size);
+		if (mntfh->size < sizeof(mntfh->data))
+			memset(mntfh->data + mntfh->size, 0,
+			       sizeof(mntfh->data) - mntfh->size);
+		break;
+	default:
+		goto out_bad_version;
 	}
 
-	/* Set the pseudoflavor */
 	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
 		data->pseudoflavor = RPC_AUTH_UNIX;
 
 #ifndef CONFIG_NFS_V3
-	/* If NFSv3 is not compiled in, return -EPROTONOSUPPORT */
-	if (data->flags & NFS_MOUNT_VER3) {
-		dprintk("%s: NFSv3 not compiled into kernel\n", __FUNCTION__);
-		return -EPROTONOSUPPORT;
-	}
-#endif /* CONFIG_NFS_V3 */
+	if (data->flags & NFS_MOUNT_VER3)
+		goto out_v3_not_compiled;
+#endif /* !CONFIG_NFS_V3 */
 
-	/* We now require that the mount process passes the remote address */
-	if (!nfs_verify_server_address((struct sockaddr *) &data->addr)) {
-		dprintk("%s: mount program didn't pass remote address!\n",
-			__FUNCTION__);
-		return -EINVAL;
-	}
+	if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
+		goto out_no_address;
 
-	/* Prepare the root filehandle */
-	if (data->flags & NFS_MOUNT_VER3)
-		mntfh->size = data->root.size;
-	else
-		mntfh->size = NFS2_FHSIZE;
+	return 0;
 
-	if (mntfh->size > sizeof(mntfh->data)) {
-		dprintk("%s: invalid root filehandle\n", __FUNCTION__);
-		return -EINVAL;
-	}
+out_no_data:
+	dfprintk(MOUNT, "NFS: mount program didn't pass any mount data\n");
+	return -EINVAL;
 
-	memcpy(mntfh->data, data->root.data, mntfh->size);
-	if (mntfh->size < sizeof(mntfh->data))
-		memset(mntfh->data + mntfh->size, 0,
-		       sizeof(mntfh->data) - mntfh->size);
+out_no_v3:
+	dfprintk(MOUNT, "NFS: nfs_mount_data version %d does not support v3\n",
+		 data->version);
+	return -EINVAL;
 
-	return 0;
+out_no_sec:
+	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
+	return -EINVAL;
+
+out_bad_version:
+	dfprintk(MOUNT, "NFS: bad nfs_mount_data version %d\n",
+		 data->version);
+	return -EINVAL;
+
+#ifndef CONFIG_NFS_V3
+out_v3_not_compiled:
+	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
+	return -EPROTONOSUPPORT;
+#endif /* !CONFIG_NFS_V3 */
+
+out_no_address:
+	dfprintk(MOUNT, "NFS: mount program didn't pass remote address\n");
+	return -EINVAL;
+
+out_invalid_fh:
+	dfprintk(MOUNT, "NFS: invalid root filehandle\n");
+	return -EINVAL;
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
