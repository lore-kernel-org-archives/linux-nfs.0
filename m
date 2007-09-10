From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 05/19] NFS: use in-kernel mount argument structure for
 nfsv4 mounts
Date: Mon, 10 Sep 2007 13:44:33 -0400
Message-ID: <EXNANE01AP4MWU5SyR1000004b4@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnY0-00038h-DS
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:59:44 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnY4-0006Zm-M0
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:59:49 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AHxfQP020563
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 10:59:41 -0700 (PDT)
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

NFS: use in-kernel mount argument structure for nfsv4 mounts

The user-visible nfs4_mount_data does not contain sufficient data to
describe new mount options, and also is now a legacy structure. Replace
it with the internal nfs_parsed_mount_data for nfsv4 in-kernel use.

Signed-off-by: Tom Talpey <tmt@netapp.com>
Acked-by: Chuck Lever <chuck.lever@oracle.com>

---

 fs/nfs/client.c   |   24 ++++-----
 fs/nfs/internal.h |   11 +---
 fs/nfs/super.c    |  144 ++++++++++++++++++++++++------------------------------
 3 files changed, 80 insertions(+), 99 deletions(-)

Index: kernel/fs/nfs/client.c
===================================================================
--- kernel.orig/fs/nfs/client.c
+++ kernel/fs/nfs/client.c
@@ -908,7 +908,7 @@ error:
  * Create a version 4 volume record
  */
 static int nfs4_init_server(struct nfs_server *server,
-		const struct nfs4_mount_data *data, rpc_authflavor_t authflavour)
+		const struct nfs_parsed_mount_data *data)
 {
 	int error;
 
@@ -928,7 +928,7 @@ static int nfs4_init_server(struct nfs_s
 	server->acdirmin = data->acdirmin * HZ;
 	server->acdirmax = data->acdirmax * HZ;
 
-	error = nfs_init_server_rpcclient(server, authflavour);
+	error = nfs_init_server_rpcclient(server, data->auth_flavors[0]);
 
 	/* Done */
 	dprintk("<-- nfs4_init_server() = %d\n", error);
@@ -939,12 +939,7 @@ static int nfs4_init_server(struct nfs_s
  * Create a version 4 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs4_create_server(const struct nfs4_mount_data *data,
-				      const char *hostname,
-				      const struct sockaddr_in *addr,
-				      const char *mntpath,
-				      const char *ip_addr,
-				      rpc_authflavor_t authflavour,
+struct nfs_server *nfs4_create_server(const struct nfs_parsed_mount_data *data,
 				      struct nfs_fh *mntfh)
 {
 	struct nfs_fattr fattr;
@@ -958,13 +953,18 @@ struct nfs_server *nfs4_create_server(co
 		return ERR_PTR(-ENOMEM);
 
 	/* Get a client record */
-	error = nfs4_set_client(server, hostname, addr, ip_addr, authflavour,
-			data->proto, data->timeo, data->retrans);
+	error = nfs4_set_client(server,
+			data->nfs_server.hostname,
+			&data->nfs_server.address,
+			data->client_address,
+			data->auth_flavors[0],
+			data->nfs_server.protocol,
+			data->timeo, data->retrans);
 	if (error < 0)
 		goto error;
 
 	/* set up the general RPC client */
-	error = nfs4_init_server(server, data, authflavour);
+	error = nfs4_init_server(server, data);
 	if (error < 0)
 		goto error;
 
@@ -973,7 +973,7 @@ struct nfs_server *nfs4_create_server(co
 	BUG_ON(!server->nfs_client->rpc_ops->file_inode_ops);
 
 	/* Probe the root fh to retrieve its FSID */
-	error = nfs4_path_walk(server, mntfh, mntpath);
+	error = nfs4_path_walk(server, mntfh, data->nfs_server.export_path);
 	if (error < 0)
 		goto error;
 
Index: kernel/fs/nfs/internal.h
===================================================================
--- kernel.orig/fs/nfs/internal.h
+++ kernel/fs/nfs/internal.h
@@ -5,7 +5,6 @@
 #include <linux/mount.h>
 
 struct nfs_string;
-struct nfs4_mount_data;
 
 /* Maximum number of readahead requests
  * FIXME: this should really be a sysctl so that users may tune it to suit
@@ -66,13 +65,9 @@ extern struct nfs_client *nfs_find_clien
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
-extern struct nfs_server *nfs4_create_server(const struct nfs4_mount_data *,
-					     const char *,
-					     const struct sockaddr_in *,
-					     const char *,
-					     const char *,
-					     rpc_authflavor_t,
-					     struct nfs_fh *);
+extern struct nfs_server *nfs4_create_server(
+					const struct nfs_parsed_mount_data *,
+					struct nfs_fh *);
 extern struct nfs_server *nfs4_create_referral_server(struct nfs_clone_mount *,
 						      struct nfs_fh *);
 extern void nfs_free_server(struct nfs_server *server);
Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -1522,38 +1522,49 @@ static void nfs4_fill_super(struct super
 /*
  * Validate NFSv4 mount options
  */
-static int nfs4_validate_mount_data(struct nfs4_mount_data **options,
-				    const char *dev_name,
-				    struct sockaddr_in *addr,
-				    rpc_authflavor_t *authflavour,
-				    char **hostname,
-				    char **mntpath,
-				    char **ip_addr)
+static int nfs4_validate_mount_data(void *options,
+				    struct nfs_parsed_mount_data *args,
+				    const char *dev_name)
 {
-	struct nfs4_mount_data *data = *options;
+	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
 	char *c;
 
 	if (data == NULL)
 		goto out_no_data;
 
+	memset(args, 0, sizeof(*args));
+	args->rsize		= NFS_MAX_FILE_IO_SIZE;
+	args->wsize		= NFS_MAX_FILE_IO_SIZE;
+	args->timeo		= 600;
+	args->retrans		= 2;
+	args->acregmin		= 3;
+	args->acregmax		= 60;
+	args->acdirmin		= 30;
+	args->acdirmax		= 60;
+	args->nfs_server.protocol = IPPROTO_TCP;
+
 	switch (data->version) {
 	case 1:
-		if (data->host_addrlen != sizeof(*addr))
+		if (data->host_addrlen != sizeof(args->nfs_server.address))
 			goto out_no_address;
-		if (copy_from_user(addr, data->host_addr, sizeof(*addr)))
+		if (copy_from_user(&args->nfs_server.address,
+				   data->host_addr,
+				   sizeof(&args->nfs_server.address)))
 			return -EFAULT;
-		if (addr->sin_port == 0)
-			addr->sin_port = htons(NFS_PORT);
-		if (!nfs_verify_server_address((struct sockaddr *) addr))
+		if (args->nfs_server.address.sin_port == 0)
+			args->nfs_server.address.sin_port = htons(NFS_PORT);
+		if (!nfs_verify_server_address((struct sockaddr *)
+						&args->nfs_server.address))
 			goto out_no_address;
 
 		switch (data->auth_flavourlen) {
 		case 0:
-			*authflavour = RPC_AUTH_UNIX;
+			args->auth_flavors[0] = RPC_AUTH_UNIX;
 			break;
 		case 1:
-			if (copy_from_user(authflavour, data->auth_flavours,
-					   sizeof(*authflavour)))
+			if (copy_from_user(args->auth_flavors,
+					   data->auth_flavours,
+					   sizeof(args->auth_flavors)))
 				return -EFAULT;
 			break;
 		default:
@@ -1563,75 +1574,57 @@ static int nfs4_validate_mount_data(stru
 		c = strndup_user(data->hostname.data, NFS4_MAXNAMLEN);
 		if (IS_ERR(c))
 			return PTR_ERR(c);
-		*hostname = c;
+		args->nfs_server.hostname = c;
 
 		c = strndup_user(data->mnt_path.data, NFS4_MAXPATHLEN);
 		if (IS_ERR(c))
 			return PTR_ERR(c);
-		*mntpath = c;
-		dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *mntpath);
+		args->nfs_server.export_path = c;
+		dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", c);
 
 		c = strndup_user(data->client_addr.data, 16);
 		if (IS_ERR(c))
 			return PTR_ERR(c);
-		*ip_addr = c;
+		args->client_address = c;
+
+		/*
+		 * Translate to nfs_parsed_mount_data, which nfs4_fill_super
+		 * can deal with.
+		 */
+
+		args->flags	= data->flags & NFS4_MOUNT_FLAGMASK;
+		args->rsize	= data->rsize;
+		args->wsize	= data->wsize;
+		args->timeo	= data->timeo;
+		args->retrans	= data->retrans;
+		args->acregmin	= data->acregmin;
+		args->acregmax	= data->acregmax;
+		args->acdirmin	= data->acdirmin;
+		args->acdirmax	= data->acdirmax;
+		args->nfs_server.protocol = data->proto;
 
 		break;
 	default: {
 		unsigned int len;
-		struct nfs_parsed_mount_data args = {
-			.rsize		= NFS_MAX_FILE_IO_SIZE,
-			.wsize		= NFS_MAX_FILE_IO_SIZE,
-			.timeo		= 600,
-			.retrans	= 2,
-			.acregmin	= 3,
-			.acregmax	= 60,
-			.acdirmin	= 30,
-			.acdirmax	= 60,
-			.nfs_server.protocol = IPPROTO_TCP,
-		};
 
-		if (nfs_parse_mount_options((char *) *options, &args) == 0)
+		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
 		if (!nfs_verify_server_address((struct sockaddr *)
-						&args.nfs_server.address))
+						&args->nfs_server.address))
 			return -EINVAL;
-		*addr = args.nfs_server.address;
 
-		switch (args.auth_flavor_len) {
+		switch (args->auth_flavor_len) {
 		case 0:
-			*authflavour = RPC_AUTH_UNIX;
+			args->auth_flavors[0] = RPC_AUTH_UNIX;
 			break;
 		case 1:
-			*authflavour = (rpc_authflavor_t) args.auth_flavors[0];
 			break;
 		default:
 			goto out_inval_auth;
 		}
 
 		/*
-		 * Translate to nfs4_mount_data, which nfs4_fill_super
-		 * can deal with.
-		 */
-		data = kzalloc(sizeof(*data), GFP_KERNEL);
-		if (data == NULL)
-			return -ENOMEM;
-		*options = data;
-
-		data->version	= 1;
-		data->flags	= args.flags & NFS4_MOUNT_FLAGMASK;
-		data->rsize	= args.rsize;
-		data->wsize	= args.wsize;
-		data->timeo	= args.timeo;
-		data->retrans	= args.retrans;
-		data->acregmin	= args.acregmin;
-		data->acregmax	= args.acregmax;
-		data->acdirmin	= args.acdirmin;
-		data->acdirmax	= args.acdirmax;
-		data->proto	= args.nfs_server.protocol;
-
-		/*
 		 * Split "dev_name" into "hostname:mntpath".
 		 */
 		c = strchr(dev_name, ':');
@@ -1641,27 +1634,25 @@ static int nfs4_validate_mount_data(stru
 		len = c - dev_name;
 		if (len > NFS4_MAXNAMLEN)
 			return -ENAMETOOLONG;
-		*hostname = kzalloc(len, GFP_KERNEL);
-		if (*hostname == NULL)
+		args->nfs_server.hostname = kzalloc(len, GFP_KERNEL);
+		if (args->nfs_server.hostname == NULL)
 			return -ENOMEM;
-		strncpy(*hostname, dev_name, len - 1);
+		strncpy(args->nfs_server.hostname, dev_name, len - 1);
 
 		c++;			/* step over the ':' */
 		len = strlen(c);
 		if (len > NFS4_MAXPATHLEN)
 			return -ENAMETOOLONG;
-		*mntpath = kzalloc(len + 1, GFP_KERNEL);
-		if (*mntpath == NULL)
+		args->nfs_server.export_path = kzalloc(len + 1, GFP_KERNEL);
+		if (args->nfs_server.export_path == NULL)
 			return -ENOMEM;
-		strncpy(*mntpath, c, len);
+		strncpy(args->nfs_server.export_path, c, len);
 
-		dprintk("MNTPATH: %s\n", *mntpath);
+		dprintk("MNTPATH: %s\n", args->nfs_server.export_path);
 
-		if (args.client_address == NULL)
+		if (args->client_address == NULL)
 			goto out_no_client_address;
 
-		*ip_addr = args.client_address;
-
 		break;
 		}
 	}
@@ -1692,14 +1683,11 @@ out_no_client_address:
 static int nfs4_get_sb(struct file_system_type *fs_type,
 	int flags, const char *dev_name, void *raw_data, struct vfsmount *mnt)
 {
-	struct nfs4_mount_data *data = raw_data;
+	struct nfs_parsed_mount_data data;
 	struct super_block *s;
 	struct nfs_server *server;
-	struct sockaddr_in addr;
-	rpc_authflavor_t authflavour;
 	struct nfs_fh mntfh;
 	struct dentry *mntroot;
-	char *mntpath = NULL, *hostname = NULL, *ip_addr = NULL;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
 		.mntflags = flags,
@@ -1707,14 +1695,12 @@ static int nfs4_get_sb(struct file_syste
 	int error;
 
 	/* Validate the mount data */
-	error = nfs4_validate_mount_data(&data, dev_name, &addr, &authflavour,
-					 &hostname, &mntpath, &ip_addr);
+	error = nfs4_validate_mount_data(raw_data, &data, dev_name);
 	if (error < 0)
 		goto out;
 
 	/* Get a volume representation */
-	server = nfs4_create_server(data, hostname, &addr, mntpath, ip_addr,
-				    authflavour, &mntfh);
+	server = nfs4_create_server(&data, &mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out;
@@ -1753,9 +1739,9 @@ static int nfs4_get_sb(struct file_syste
 	error = 0;
 
 out:
-	kfree(ip_addr);
-	kfree(mntpath);
-	kfree(hostname);
+	kfree(data.client_address);
+	kfree(data.nfs_server.export_path);
+	kfree(data.nfs_server.hostname);
 	return error;
 
 out_free:

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
