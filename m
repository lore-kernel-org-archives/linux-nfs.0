From: "Talpey, Thomas" <Thomas.Talpey@netapp.com>
Subject: [PATCH 04/19] NFS: use in-kernel mount argument structure for
 nfsv[23] mounts
Date: Mon, 10 Sep 2007 13:43:56 -0400
Message-ID: <EXNANE01QoPAzdaQYrV000004b3@exnane01.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IUnXU-00037A-IX
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:59:12 -0700
Received: from mx2.netapp.com ([216.240.18.37])
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IUnXY-0006PV-Tp
	for nfs@lists.sourceforge.net; Mon, 10 Sep 2007 10:59:17 -0700
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com
	[10.57.156.158])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id
	l8AHxAuF020354
	for <nfs@lists.sourceforge.net>; Mon, 10 Sep 2007 10:59:10 -0700 (PDT)
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

NFS: use in-kernel mount argument structure for nfsv[23] mounts

The user-visible nfs_mount_data does not contain sufficient data to
describe new mount options, and also is now a legacy structure. Replace
it with the internal nfs_parsed_mount_data for nfsv[23] in-kernel use.

Signed-off-by: Tom Talpey <tmt@netapp.com>
Acked-by: Chuck Lever <chuck.lever@oracle.com>

---

 fs/nfs/client.c   |   18 ++++----
 fs/nfs/internal.h |    6 +-
 fs/nfs/super.c    |  121 +++++++++++++++++++++++++-----------------------------
 3 files changed, 70 insertions(+), 75 deletions(-)

Index: kernel/fs/nfs/client.c
===================================================================
--- kernel.orig/fs/nfs/client.c
+++ kernel/fs/nfs/client.c
@@ -501,9 +501,9 @@ static int nfs_init_server_rpcclient(str
 /*
  * Initialise an NFS2 or NFS3 client
  */
-static int nfs_init_client(struct nfs_client *clp, const struct nfs_mount_data *data)
+static int nfs_init_client(struct nfs_client *clp,
+			   const struct nfs_parsed_mount_data *data)
 {
-	int proto = (data->flags & NFS_MOUNT_TCP) ? IPPROTO_TCP : IPPROTO_UDP;
 	int error;
 
 	if (clp->cl_cons_state == NFS_CS_READY) {
@@ -522,8 +522,8 @@ static int nfs_init_client(struct nfs_cl
 	 * Create a client RPC handle for doing FSSTAT with UNIX auth only
 	 * - RFC 2623, sec 2.3.2
 	 */
-	error = nfs_create_rpc_client(clp, proto, data->timeo, data->retrans,
-					RPC_AUTH_UNIX, 0);
+	error = nfs_create_rpc_client(clp, data->nfs_server.protocol,
+				data->timeo, data->retrans, RPC_AUTH_UNIX, 0);
 	if (error < 0)
 		goto error;
 	nfs_mark_client_ready(clp, NFS_CS_READY);
@@ -538,7 +538,8 @@ error:
 /*
  * Create a version 2 or 3 client
  */
-static int nfs_init_server(struct nfs_server *server, const struct nfs_mount_data *data)
+static int nfs_init_server(struct nfs_server *server,
+			   const struct nfs_parsed_mount_data *data)
 {
 	struct nfs_client *clp;
 	int error, nfsvers = 2;
@@ -551,7 +552,8 @@ static int nfs_init_server(struct nfs_se
 #endif
 
 	/* Allocate or find a client reference we can use */
-	clp = nfs_get_client(data->hostname, &data->addr, nfsvers);
+	clp = nfs_get_client(data->nfs_server.hostname,
+				&data->nfs_server.address, nfsvers);
 	if (IS_ERR(clp)) {
 		dprintk("<-- nfs_init_server() = error %ld\n", PTR_ERR(clp));
 		return PTR_ERR(clp);
@@ -581,7 +583,7 @@ static int nfs_init_server(struct nfs_se
 	if (error < 0)
 		goto error;
 
-	error = nfs_init_server_rpcclient(server, data->pseudoflavor);
+	error = nfs_init_server_rpcclient(server, data->auth_flavors[0]);
 	if (error < 0)
 		goto error;
 
@@ -770,7 +772,7 @@ void nfs_free_server(struct nfs_server *
  * Create a version 2 or 3 volume record
  * - keyed on server and FSID
  */
-struct nfs_server *nfs_create_server(const struct nfs_mount_data *data,
+struct nfs_server *nfs_create_server(const struct nfs_parsed_mount_data *data,
 				     struct nfs_fh *mntfh)
 {
 	struct nfs_server *server;
Index: kernel/fs/nfs/super.c
===================================================================
--- kernel.orig/fs/nfs/super.c
+++ kernel/fs/nfs/super.c
@@ -1049,15 +1049,31 @@ out_err:
  * XXX: as far as I can tell, changing the NFS program number is not
  *      supported in the NFS client.
  */
-static int nfs_validate_mount_data(struct nfs_mount_data **options,
+static int nfs_validate_mount_data(void *options,
+				   struct nfs_parsed_mount_data *args,
 				   struct nfs_fh *mntfh,
 				   const char *dev_name)
 {
-	struct nfs_mount_data *data = *options;
+	struct nfs_mount_data *data = (struct nfs_mount_data *)options;
 
 	if (data == NULL)
 		goto out_no_data;
 
+	memset(args, 0, sizeof(*args));
+	args->flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP);
+	args->rsize		= NFS_MAX_FILE_IO_SIZE;
+	args->wsize		= NFS_MAX_FILE_IO_SIZE;
+	args->timeo		= 600;
+	args->retrans		= 2;
+	args->acregmin		= 3;
+	args->acregmax		= 60;
+	args->acdirmin		= 30;
+	args->acdirmax		= 60;
+	args->mount_server.protocol = IPPROTO_UDP;
+	args->mount_server.program = NFS_MNT_PROGRAM;
+	args->nfs_server.protocol = IPPROTO_TCP;
+	args->nfs_server.program = NFS_PROGRAM;
+
 	switch (data->version) {
 	case 1:
 		data->namlen = 0;
@@ -1086,90 +1102,67 @@ static int nfs_validate_mount_data(struc
 		if (mntfh->size < sizeof(mntfh->data))
 			memset(mntfh->data + mntfh->size, 0,
 			       sizeof(mntfh->data) - mntfh->size);
+		/*
+		 * Translate to nfs_parsed_mount_data, which nfs_fill_super
+		 * can deal with.
+		 */
+		args->flags		= data->flags;
+		args->rsize		= data->rsize;
+		args->wsize		= data->wsize;
+		args->flags		= data->flags;
+		args->timeo		= data->timeo;
+		args->retrans		= data->retrans;
+		args->acregmin		= data->acregmin;
+		args->acregmax		= data->acregmax;
+		args->acdirmin		= data->acdirmin;
+		args->acdirmax		= data->acdirmax;
+		args->nfs_server.address = data->addr;
+		if (!(data->flags & NFS_MOUNT_TCP))
+			args->nfs_server.protocol = IPPROTO_UDP;
+		/* N.B. caller will free nfs_server.hostname in all cases */
+		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
+		args->namlen		= data->namlen;
+		args->bsize		= data->bsize;
+		args->auth_flavors[0]	= data->pseudoflavor;
 		break;
 	default: {
 		unsigned int len;
 		char *c;
 		int status;
-		struct nfs_parsed_mount_data args = {
-			.flags		= (NFS_MOUNT_VER3 | NFS_MOUNT_TCP),
-			.rsize		= NFS_MAX_FILE_IO_SIZE,
-			.wsize		= NFS_MAX_FILE_IO_SIZE,
-			.timeo		= 600,
-			.retrans	= 2,
-			.acregmin	= 3,
-			.acregmax	= 60,
-			.acdirmin	= 30,
-			.acdirmax	= 60,
-			.mount_server.protocol = IPPROTO_UDP,
-			.mount_server.program = NFS_MNT_PROGRAM,
-			.nfs_server.protocol = IPPROTO_TCP,
-			.nfs_server.program = NFS_PROGRAM,
-		};
 
-		if (nfs_parse_mount_options((char *) *options, &args) == 0)
+		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		data = kzalloc(sizeof(*data), GFP_KERNEL);
-		if (data == NULL)
-			return -ENOMEM;
-
-		/*
-		 * NB: after this point, caller will free "data"
-		 * if we return an error
-		 */
-		*options = data;
-
 		c = strchr(dev_name, ':');
 		if (c == NULL)
 			return -EINVAL;
 		len = c - dev_name;
-		if (len > sizeof(data->hostname))
-			return -ENAMETOOLONG;
-		strncpy(data->hostname, dev_name, len);
-		args.nfs_server.hostname = data->hostname;
+		/* N.B. caller will free nfs_server.hostname in all cases */
+		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
 
 		c++;
 		if (strlen(c) > NFS_MAXPATHLEN)
 			return -ENAMETOOLONG;
-		args.nfs_server.export_path = c;
+		args->nfs_server.export_path = c;
 
-		status = nfs_try_mount(&args, mntfh);
+		status = nfs_try_mount(args, mntfh);
 		if (status)
 			return status;
 
-		/*
-		 * Translate to nfs_mount_data, which nfs_fill_super
-		 * can deal with.
-		 */
-		data->version		= 6;
-		data->flags		= args.flags;
-		data->rsize		= args.rsize;
-		data->wsize		= args.wsize;
-		data->timeo		= args.timeo;
-		data->retrans		= args.retrans;
-		data->acregmin		= args.acregmin;
-		data->acregmax		= args.acregmax;
-		data->acdirmin		= args.acdirmin;
-		data->acdirmax		= args.acdirmax;
-		data->addr		= args.nfs_server.address;
-		data->namlen		= args.namlen;
-		data->bsize		= args.bsize;
-		data->pseudoflavor	= args.auth_flavors[0];
-
 		break;
 		}
 	}
 
-	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
-		data->pseudoflavor = RPC_AUTH_UNIX;
+	if (!(args->flags & NFS_MOUNT_SECFLAVOUR))
+		args->auth_flavors[0] = RPC_AUTH_UNIX;
 
 #ifndef CONFIG_NFS_V3
-	if (data->flags & NFS_MOUNT_VER3)
+	if (args->flags & NFS_MOUNT_VER3)
 		goto out_v3_not_compiled;
 #endif /* !CONFIG_NFS_V3 */
 
-	if (!nfs_verify_server_address((struct sockaddr *) &data->addr))
+	if (!nfs_verify_server_address((struct sockaddr *)
+						&args->nfs_server.address))
 		goto out_no_address;
 
 	return 0;
@@ -1228,7 +1221,8 @@ static inline void nfs_initialise_sb(str
 /*
  * Finish setting up an NFS2/3 superblock
  */
-static void nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data)
+static void nfs_fill_super(struct super_block *sb,
+			   struct nfs_parsed_mount_data *data)
 {
 	struct nfs_server *server = NFS_SB(sb);
 
@@ -1349,7 +1343,7 @@ static int nfs_get_sb(struct file_system
 	struct nfs_server *server = NULL;
 	struct super_block *s;
 	struct nfs_fh mntfh;
-	struct nfs_mount_data *data = raw_data;
+	struct nfs_parsed_mount_data data;
 	struct dentry *mntroot;
 	int (*compare_super)(struct super_block *, void *) = nfs_compare_super;
 	struct nfs_sb_mountdata sb_mntdata = {
@@ -1358,12 +1352,12 @@ static int nfs_get_sb(struct file_system
 	int error;
 
 	/* Validate the mount data */
-	error = nfs_validate_mount_data(&data, &mntfh, dev_name);
+	error = nfs_validate_mount_data(raw_data, &data, &mntfh, dev_name);
 	if (error < 0)
 		goto out;
 
 	/* Get a volume representation */
-	server = nfs_create_server(data, &mntfh);
+	server = nfs_create_server(&data, &mntfh);
 	if (IS_ERR(server)) {
 		error = PTR_ERR(server);
 		goto out;
@@ -1387,7 +1381,7 @@ static int nfs_get_sb(struct file_system
 
 	if (!s->s_root) {
 		/* initial superblock/root creation */
-		nfs_fill_super(s, data);
+		nfs_fill_super(s, &data);
 	}
 
 	mntroot = nfs_get_root(s, &mntfh);
@@ -1402,8 +1396,7 @@ static int nfs_get_sb(struct file_system
 	error = 0;
 
 out:
-	if (data != raw_data)
-		kfree(data);
+	kfree(data.nfs_server.hostname);
 	return error;
 
 out_err_nosb:
Index: kernel/fs/nfs/internal.h
===================================================================
--- kernel.orig/fs/nfs/internal.h
+++ kernel/fs/nfs/internal.h
@@ -5,7 +5,6 @@
 #include <linux/mount.h>
 
 struct nfs_string;
-struct nfs_mount_data;
 struct nfs4_mount_data;
 
 /* Maximum number of readahead requests
@@ -64,8 +63,9 @@ extern struct rpc_program nfs_program;
 
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs_find_client(const struct sockaddr_in *, int);
-extern struct nfs_server *nfs_create_server(const struct nfs_mount_data *,
-					    struct nfs_fh *);
+extern struct nfs_server *nfs_create_server(
+					const struct nfs_parsed_mount_data *,
+					struct nfs_fh *);
 extern struct nfs_server *nfs4_create_server(const struct nfs4_mount_data *,
 					     const char *,
 					     const struct sockaddr_in *,

-------------------------------------------------------------------------
This SF.net email is sponsored by: Microsoft
Defy all challenges. Microsoft(R) Visual Studio 2005.
http://clk.atdmt.com/MRT/go/vse0120000070mrt/direct/01/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
