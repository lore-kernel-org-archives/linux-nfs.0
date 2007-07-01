From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 21/21] NFS: Add support for mounting NFSv4 file
	systems with	string options
Date: Sun, 01 Jul 2007 12:13:59 -0400
Message-ID: <20070701161359.2786.84678.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I52ic-00007s-5w
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:14 -0700
Received: from flpvm09.prodigy.net ([207.115.20.39])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I52if-0007QL-EY
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:56:17 -0700
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

 fs/nfs/super.c                |   91 ++++++++++++++++++++++++++++++++++++++---
 include/asm-blackfin/macros.h |    0 
 include/linux/nfs4_mount.h    |    2 -
 3 files changed, 85 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 480dcfa..261b933 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1599,8 +1599,90 @@ static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
 		*ip_addr = c;
 
 		break;
-	default:
-		goto out_bad_version;
+	default: {
+		unsigned int len;
+		struct nfs_parsed_mount_data args = {
+			.rsize		= NFS_MAX_FILE_IO_SIZE,
+			.wsize		= NFS_MAX_FILE_IO_SIZE,
+			.timeo		= 600,
+			.retrans	= 2,
+			.acregmin	= 3,
+			.acregmax	= 60,
+			.acdirmin	= 30,
+			.acdirmax	= 60,
+			.nfs_server.protocol = IPPROTO_TCP,
+		};
+
+		if (nfs_parse_mount_options((char *) *options, &args) == 0)
+			return -EINVAL;
+
+		if (!nfs_verify_server_address((struct sockaddr *)
+						&args.nfs_server.address))
+			return -EINVAL;
+		*addr = args.nfs_server.address;
+
+		switch (args.auth_flavor_len) {
+		case 0:
+			*authflavour = RPC_AUTH_UNIX;
+			break;
+		case 1:
+			*authflavour = (rpc_authflavor_t) args.auth_flavors[0];
+			break;
+		default:
+			goto out_inval_auth;
+		}
+
+		/*
+		 * Translate to nfs4_mount_data, which nfs4_fill_super
+		 * can deal with.
+		 */
+		data = kzalloc(sizeof(*data), GFP_KERNEL);
+		if (data == NULL)
+			return -ENOMEM;
+		*options = data;
+
+		data->version	= 1;
+		data->flags	= args.flags & NFS4_MOUNT_FLAGMASK;
+		data->rsize	= args.rsize;
+		data->wsize	= args.wsize;
+		data->timeo	= args.timeo;
+		data->retrans	= args.retrans;
+		data->acregmin	= args.acregmin;
+		data->acregmax	= args.acregmax;
+		data->acdirmin	= args.acdirmin;
+		data->acdirmax	= args.acdirmax;
+		data->proto	= args.nfs_server.protocol;
+
+		/*
+		 * Split "dev_name" into "hostname:mntpath".
+		 */
+		c = strchr(dev_name, ':');
+		if (c == NULL)
+			return -EINVAL;
+		/* while calculating len, pretend ':' is '\0' */
+		len = c - dev_name;
+		if (len > NFS4_MAXNAMLEN)
+			return -EINVAL;
+		*hostname = kzalloc(len, GFP_KERNEL);
+		if (*hostname == NULL)
+			return -ENOMEM;
+		strncpy(*hostname, dev_name, len - 1);
+
+		c++;			/* step over the ':' */
+		len = strlen(c);
+		if (len > NFS4_MAXPATHLEN)
+			return -EINVAL;
+		*mntpath = kzalloc(len + 1, GFP_KERNEL);
+		if (*mntpath == NULL)
+			return -ENOMEM;
+		strncpy(*mntpath, c, len);
+
+		dprintk("MNTPATH: %s\n", *mntpath);
+
+		*ip_addr = args.client_address;
+
+		break;
+		}
 	}
 
 	return 0;
@@ -1617,11 +1699,6 @@ out_inval_auth:
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;
-
-out_bad_version:
-	dfprintk(MOUNT, "NFS4: bad nfs_mount_data version %d\n",
-		 data->version);
-	return -EINVAL;
 }
 
 /*
diff --git a/include/asm-blackfin/macros.h b/include/asm-blackfin/macros.h
deleted file mode 100644
index e69de29..0000000
diff --git a/include/linux/nfs4_mount.h b/include/linux/nfs4_mount.h
index ad1bd4a..a0dcf66 100644
--- a/include/linux/nfs4_mount.h
+++ b/include/linux/nfs4_mount.h
@@ -66,6 +66,6 @@ struct nfs4_mount_data {
 #define NFS4_MOUNT_NOAC		0x0020	/* 1 */
 #define NFS4_MOUNT_STRICTLOCK	0x1000	/* 1 */
 #define NFS4_MOUNT_UNSHARED	0x8000	/* 1 */
-#define NFS4_MOUNT_FLAGMASK	0xFFFF
+#define NFS4_MOUNT_FLAGMASK	0x9033
 
 #endif


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
