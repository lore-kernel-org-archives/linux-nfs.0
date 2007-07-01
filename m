From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 10/21] NFS: Introduce nfs4_validate_mount_options
Date: Sun, 01 Jul 2007 12:13:01 -0400
Message-ID: <20070701161301.2786.72631.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: trond.myklebust@fys.uio.no
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1I524H-0004Yl-73
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:37 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1I524K-0005BQ-Gu
	for nfs@lists.sourceforge.net; Sun, 01 Jul 2007 09:14:36 -0700
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

Refactor NFSv4 mount processing to break out mount data validation
in the same way it's broken out in the NFSv2/v3 mount path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  152 ++++++++++++++++++++++++++++++++------------------------
 1 files changed, 88 insertions(+), 64 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index bdfab72..2b5e681 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -864,6 +864,88 @@ static void nfs4_fill_super(struct super_block *sb)
 }
 
 /*
+ * Validate NFSv4 mount options
+ */
+static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
+				    const char *dev_name,
+				    struct sockaddr_in *addr,
+				    rpc_authflavor_t *authflavour,
+				    char **hostname,
+				    char **mntpath,
+				    char **ip_addr)
+{
+	struct nfs4_mount_data *data = *options;
+	char *c;
+
+	if (data == NULL)
+		goto out_no_data;
+
+	switch (data->version) {
+	case 1:
+		if (data->host_addrlen != sizeof(*addr))
+			goto out_no_address;
+		if (copy_from_user(addr, data->host_addr, sizeof(*addr)))
+			return -EFAULT;
+		if (addr->sin_port == 0)
+			addr->sin_port = htons(NFS_PORT);
+		if (!nfs_verify_server_address((struct sockaddr *) addr))
+			goto out_no_address;
+
+		switch (data->auth_flavourlen) {
+		case 0:
+			*authflavour = RPC_AUTH_UNIX;
+			break;
+		case 1:
+			if (copy_from_user(authflavour, data->auth_flavours,
+					   sizeof(*authflavour)))
+				return -EFAULT;
+		default:
+			goto out_inval_auth;
+		}
+
+		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		*hostname = c;
+
+		c = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		*mntpath = c;
+		dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *mntpath);
+
+		c = strndup_user(data->client_addr.data, 16);
+		if (IS_ERR(c))
+			return PTR_ERR(c);
+		*ip_addr = c;
+
+		break;
+	default:
+		goto out_bad_version;
+	}
+
+	return 0;
+
+out_no_data:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass any mount data\n");
+	return -EINVAL;
+
+out_inval_auth:
+	dfprintk(MOUNT, "NFS4: Invalid number of RPC auth flavours %d\n",
+		 data->auth_flavourlen);
+	return -EINVAL;
+
+out_no_address:
+	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
+	return -EINVAL;
+
+out_bad_version:
+	dfprintk(MOUNT, "NFS4: bad nfs_mount_data version %d\n",
+		 data->version);
+	return -EINVAL;
+}
+
+/*
  * Get the superblock for an NFS4 mountpoint
  */
 static int nfs4_get_sb(struct file_system_type *fs_type,
@@ -876,69 +958,15 @@ static int nfs4_get_sb(struct file_system_type *fs_type,
 	rpc_authflavor_t authflavour;
 	struct nfs_fh mntfh;
 	struct dentry *mntroot;
- 	char *p, *mntpath = NULL, *hostname = NULL, *ip_addr = NULL;
+ 	char *mntpath = NULL, *hostname = NULL, *ip_addr = NULL;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	int error;
 
-	if (data == NULL) {
-		dprintk("%s: missing data argument\n", __FUNCTION__);
-		return -EINVAL;
-	}
-	if (data->version <= 0 || data->version > NFS4_MOUNT_VERSION) {
-		dprintk("%s: bad mount version\n", __FUNCTION__);
-		return -EINVAL;
-	}
-
-	/* We now require that the mount process passes the remote address */
-	if (data->host_addrlen != sizeof(addr))
-		return -EINVAL;
-
-	if (copy_from_user(&addr, data->host_addr, sizeof(addr)))
-		return -EFAULT;
-
-	if (!nfs_verify_server_address((struct sockaddr *) &addr)) {
-		dprintk("%s: mount program didn't pass remote IP address!\n",
-				__FUNCTION__);
-		return -EINVAL;
-	}
-
-	/* RFC3530: The default port for NFS is 2049 */
-	if (addr.sin_port == 0)
-		addr.sin_port = htons(NFS_PORT);
-
-	/* Grab the authentication type */
-	authflavour = RPC_AUTH_UNIX;
-	if (data->auth_flavourlen != 0) {
-		if (data->auth_flavourlen != 1) {
-			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
-					__FUNCTION__, data->auth_flavourlen);
-			error = -EINVAL;
-			goto out;
-		}
-
-		if (copy_from_user(&authflavour, data->auth_flavours,
-				   sizeof(authflavour))) {
-			error = -EFAULT;
-			goto out;
-		}
-	}
-
-	p = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
-	if (IS_ERR(p))
-		goto out_err;
-	hostname = p;
-
-	p = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
-	if (IS_ERR(p))
-		goto out_err;
-	mntpath = p;
-
-	dprintk("MNTPATH: %s\n", mntpath);
-
-	p = strndup_user(data->client_addr.data, 16);
-	if (IS_ERR(p))
-		goto out_err;
-	ip_addr = p;
+ 	/* Validate the mount data */
+ 	error = nfs4_validate_mount_data(&data, dev_name, &addr, &authflavour,
+ 					 &hostname, &mntpath, &ip_addr);
+ 	if (error < 0)
+ 		goto out;
 
 	/* Get a volume representation */
 	server = nfs4_create_server(data, hostname, &addr, mntpath, ip_addr,
@@ -989,10 +1017,6 @@ out:
 	kfree(hostname);
 	return error;
 
-out_err:
-	error = PTR_ERR(p);
-	goto out;
-
 out_free:
 	nfs_free_server(server);
 	goto out;


-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
