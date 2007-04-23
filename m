From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] NFS: More nfs in-kernel mount option
	parsing	infrastructure
Date: Mon, 23 Apr 2007 18:04:34 -0400
Message-ID: <20070423220434.24305.18675.stgit@schiele.dsl.sfldmi.ameritech.net>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Hg6eJ-0003RD-Ci
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:43 -0700
Received: from flpi102.sbcis.sbc.com ([207.115.20.71])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Hg6eL-0008TT-Od
	for nfs@lists.sourceforge.net; Mon, 23 Apr 2007 15:04:46 -0700
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Add function for switching between an nfs_mount_data structure from user
space (the current nfs mount mechanism) and generating an nfs_mount_data
structure from a text string containing nfs mount options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  125 ++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 80 insertions(+), 45 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5896973..08dee08 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -964,71 +964,76 @@ out_length:
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  */
-static int nfs_validate_mount_data(struct nfs_mount_data *data,
-				   struct nfs_fh *mntfh)
+static int nfs_validate_mount_data(struct nfs_mount_data **options,
+				   struct nfs_fh *mntfh,
+				   const char *dev_name)
 {
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		return -EINVAL;
-	}
+	struct nfs_mount_data *data = *options;
 
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
+		data->bsize  = 0;
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
+		break;
+	default: {
+		int status;
+		unsigned int len;
+		char *c;
+
+		data = nfs_convert_mount_opts((char *) data);
+		if (IS_ERR(data))
+			return PTR_ERR(data);
+		*options = data;
+
+		c = strchr(dev_name, ':');
+		if (c == NULL)
+			return -EINVAL;
+		len = c - dev_name - 1;
+		if (len > 256)
+			return -EINVAL;
+		strncpy(data->hostname, dev_name, len);
+
+		status = nfs_try_mount(data, ++c);
+		if (status)
+			return status;
+		}
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
 
 	/* We now require that the mount process passes the remote address */
 	if (!nfs_verify_server_address((struct sockaddr *) &data->addr,
 						sizeof(data->addr)))
  		return -EINVAL;
 
-	/* Prepare the root filehandle */
 	if (data->flags & NFS_MOUNT_VER3)
 		mntfh->size = data->root.size;
 	else
 		mntfh->size = NFS2_FHSIZE;
 
-	if (mntfh->size > sizeof(mntfh->data)) {
-		dprintk("%s: invalid root filehandle\n", __FUNCTION__);
-		return -EINVAL;
-	}
+	if (mntfh->size > sizeof(mntfh->data))
+		goto out_invalid_fh;
 
 	memcpy(mntfh->data, data->root.data, mntfh->size);
 	if (mntfh->size < sizeof(mntfh->data))
@@ -1036,6 +1041,30 @@ static int nfs_validate_mount_data(struct nfs_mount_data *data,
 		       sizeof(mntfh->data) - mntfh->size);
 
 	return 0;
+
+out_no_data:
+	dprintk("NFS: mount program didn't pass any mount data\n");
+	return -EINVAL;
+
+out_no_v3:
+	dprintk("NFS: nfs_mount_data version %d does not support NFSv3\n",
+		data->version);
+	return -EINVAL;
+
+out_no_sec:
+	dprintk("NFS: nfs_mount_data version %d supports only AUTH_SYS\n",
+		data->version);
+	return -EINVAL;
+
+#ifndef CONFIG_NFS_V3
+out_v3_not_compiled:
+	dprintk("NFS: NFSv3 is not compiled into kernel\n");
+	return -EPROTONOSUPPORT;
+#endif /* !CONFIG_NFS_V3 */
+
+out_invalid_fh:
+	dprintk("NFS: invalid root filehandle\n");
+	return -EINVAL;
 }
 
 /*
@@ -1143,7 +1172,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	int error;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(data, &mntfh);
+	error = nfs_validate_mount_data(&data, &mntfh, dev_name);
 	if (error < 0)
 		return error;
 
@@ -1181,16 +1210,22 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	s->s_flags |= MS_ACTIVE;
 	mnt->mnt_sb = s;
 	mnt->mnt_root = mntroot;
+	if (data->version == 7)
+		kfree(data);
 	return 0;
 
 out_err_nosb:
 	nfs_free_server(server);
 out_err_noserver:
+	if (data->version == 7)
+		kfree(data);
 	return error;
 
 error_splat_super:
 	up_write(&s->s_umount);
 	deactivate_super(s);
+	if (data->version == 7)
+		kfree(data);
 	return error;
 }
 


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
