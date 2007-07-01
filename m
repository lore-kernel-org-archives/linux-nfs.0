From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/21] NFS: Add final pieces to support in-kernel
	mount option	parsing
Date: Sun, 01 Jul 2007 12:13:54 -0400
Message-ID: <20070701161354.2786.60606.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52iY-00007P-5s
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:10 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52ib-0007QI-1P
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:13 -0700
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

Hook in final components required for supporting in-kernel mount option
parsing for NFSv2 and NFSv3 mounts.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  105 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 95 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index c5ca68d..480dcfa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1061,10 +1061,28 @@ out_err:
 /*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
+ *
+ * For option strings, user space handles the following behaviors:
+ *
+ * + DNS: mapping server host name to IP address ("addr=" option)
+ *
+ * + failure mode: how to behave if a mount request can't be handled
+ *   immediately ("fg/bg" option)
+ *
+ * + retry: how often to retry a mount request ("retry=" option)
+ *
+ * + breaking back: trying proto=udp after proto=tcp, v2 after v3,
+ *   mountproto=tcp after mountproto=udp, and so on
+ *
+ * XXX: as far as I can tell, changing the NFS program number is not
+ *      supported in the NFS client.
  */
-static int nfs_validate_mount_data(struct nfs_mount_data *data,
-				   struct nfs_fh *mntfh)
+static int nfs_validate_mount_data(struct nfs_mount_data **options,
+				   struct nfs_fh *mntfh,
+				   const char *dev_name)
 {
+	struct nfs_mount_data *data = *options;
+
 	if (data == NULL)
 		goto out_no_data;
 
@@ -1097,8 +1115,78 @@ static int nfs_validate_mount_data(struct nfs_mount_data *data,
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
 		break;
-	default:
-		goto out_bad_version;
+	default: {
+		unsigned int len;
+		char *c;
+		int status;
+		struct nfs_parsed_mount_data args = {
+			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
+			.rsize		= NFS_MAX_FILE_IO_SIZE,
+			.wsize		= NFS_MAX_FILE_IO_SIZE,
+			.timeo		= 600,
+			.retrans	= 2,
+			.acregmin	= 3,
+			.acregmax	= 60,
+			.acdirmin	= 30,
+			.acdirmax	= 60,
+			.mount_server.protocol = IPPROTO_UDP,
+			.mount_server.program = NFS_MNT_PROGRAM,
+			.nfs_server.protocol = IPPROTO_TCP,
+			.nfs_server.program = NFS_PROGRAM,
+		};
+
+		if (nfs_parse_mount_options((char *) *options, &args) == 0)
+			return -EINVAL;
+
+		data = kzalloc(sizeof(*data), GFP_KERNEL);
+		if (data == NULL)
+			return -ENOMEM;
+
+		/*
+		 * NB: after this point, caller will free "data"
+		 * if we return an error
+		 */
+		*options = data;
+
+		c = strchr(dev_name, ':');
+		if (c == NULL)
+			return -EINVAL;
+		len = c - dev_name - 1;
+		if (len > sizeof(data->hostname))
+			return -EINVAL;
+		strncpy(data->hostname, dev_name, len);
+		args.nfs_server.hostname = data->hostname;
+
+		c++;
+		if (strlen(c) > NFS_MAXPATHLEN)
+			return -EINVAL;
+		args.nfs_server.export_path = c;
+
+		status = nfs_try_mount(&args, mntfh);
+		if (status)
+			return -EINVAL;
+
+		/*
+		 * Translate to nfs_mount_data, which nfs_fill_super
+		 * can deal with.
+		 */
+		data->version		= 6;
+		data->flags		= args.flags;
+		data->rsize		= args.rsize;
+		data->wsize		= args.wsize;
+		data->timeo		= args.timeo;
+		data->retrans		= args.retrans;
+		data->acregmin		= args.acregmin;
+		data->acregmax		= args.acregmax;
+		data->acdirmin		= args.acdirmin;
+		data->acdirmax		= args.acdirmax;
+		data->addr		= args.nfs_server.address;
+		data->namlen		= args.namlen;
+		data->bsize		= args.bsize;
+		data->pseudoflavor	= args.auth_flavors[0];
+
+		break;
+		}
 	}
 
 	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
@@ -1127,11 +1215,6 @@ out_no_sec:
 	dfprintk(MOUNT, "NFS: nfs_mount_data version supports only AUTH_SYS\n");
 	return -EINVAL;
 
-out_bad_version:
-	dfprintk(MOUNT, "NFS: bad nfs_mount_data version %d\n",
-		 data->version);
-	return -EINVAL;
-
 #ifndef CONFIG_NFS_V3
 out_v3_not_compiled:
 	dfprintk(MOUNT, "NFS: NFSv3 is not compiled into kernel\n");
@@ -1291,7 +1374,7 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	int error;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(data, &mntfh);
+	error = nfs_validate_mount_data(&data, &mntfh, dev_name);
 	if (error < 0)
 		goto out;
 
@@ -1338,6 +1421,8 @@ static int nfs_get_sb(struct file_system_type *fs_type,
 	error = 0;
 
 out:
+	if (data != raw_data)
+		kfree(data);
 	return error;
 
 out_err_nosb:


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
