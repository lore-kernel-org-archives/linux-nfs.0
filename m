From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH 16/19] A basic NFSv4 client for 2.5.x
Date: Tue, 15 Oct 2002 00:33:57 +0200
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15787.18005.126336.146648@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>,
    nfsv4-wg@citi.umich.edu
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 181Dmn-000409-00
	for <nfs@lists.sourceforge.net>; Mon, 14 Oct 2002 15:34:06 -0700
To: Linus Torvalds <torvalds@transmeta.com>
Errors-To: nfs-admin@lists.sourceforge.net
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchives/forum.php?forum=nfs>

Clean up nfs_fill_super().

Separate the parsing of the nfs_mount_data struct and the
initialization + sanity checking of the resulting super_block.
The latter is now performed in the new function nfs_sb_init().

diff -u --recursive --new-file linux-2.5.42/fs/nfs/inode.c linux-2.5.42-nfsv4-E01/fs/nfs/inode.c
--- linux-2.5.42/fs/nfs/inode.c	2002-10-08 19:43:30.000000000 -0400
+++ linux-2.5.42-nfsv4-E01/fs/nfs/inode.c	2002-10-12 19:22:13.000000000 -0400
@@ -234,131 +234,28 @@
 }
 
 /*
- * The way this works is that the mount process passes a structure
- * in the data argument which contains the server's IP address
- * and the root file handle obtained from the server's mount
- * daemon. We stash these away in the private superblock fields.
+ * Do NFS version-independent mount processing, and sanity checking
  */
-int nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data, int silent)
+int nfs_sb_init(struct super_block *sb)
 {
 	struct nfs_server	*server;
-	struct rpc_xprt		*xprt = NULL;
-	struct rpc_clnt		*clnt = NULL;
 	struct inode		*root_inode = NULL;
-	rpc_authflavor_t	authflavor;
-	struct rpc_timeout	timeparms;
 	struct nfs_fsinfo	fsinfo;
-	int			tcp, version, maxlen;
 
 	/* We probably want something more informative here */
 	snprintf(sb->s_id, sizeof(sb->s_id), "%x:%x", MAJOR(sb->s_dev), MINOR(sb->s_dev));
 
+	server = NFS_SB(sb);
+
 	sb->s_magic      = NFS_SUPER_MAGIC;
 	sb->s_op         = &nfs_sops;
-	sb->s_blocksize_bits = 0;
-	sb->s_blocksize  = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
-	server           = NFS_SB(sb);
-	server->rsize    = nfs_block_size(data->rsize, NULL);
-	server->wsize    = nfs_block_size(data->wsize, NULL);
-	server->flags    = data->flags & NFS_MOUNT_FLAGMASK;
-
-	if (data->flags & NFS_MOUNT_NOAC) {
-		data->acregmin = data->acregmax = 0;
-		data->acdirmin = data->acdirmax = 0;
-		sb->s_flags |= MS_SYNCHRONOUS;
-	}
-	server->acregmin = data->acregmin*HZ;
-	server->acregmax = data->acregmax*HZ;
-	server->acdirmin = data->acdirmin*HZ;
-	server->acdirmax = data->acdirmax*HZ;
-
-	server->namelen  = data->namlen;
-	server->hostname = kmalloc(strlen(data->hostname) + 1, GFP_KERNEL);
-	if (!server->hostname)
-		goto out_unlock;
-	strcpy(server->hostname, data->hostname);
 	INIT_LIST_HEAD(&server->lru_read);
 	INIT_LIST_HEAD(&server->lru_dirty);
 	INIT_LIST_HEAD(&server->lru_commit);
 	INIT_LIST_HEAD(&server->lru_busy);
 
- nfsv3_try_again:
-	server->caps = 0;
-	/* Check NFS protocol revision and initialize RPC op vector
-	 * and file handle pool. */
-	if (data->flags & NFS_MOUNT_VER3) {
-#ifdef CONFIG_NFS_V3
-		server->rpc_ops = &nfs_v3_clientops;
-		version = 3;
-		server->caps |= NFS_CAP_READDIRPLUS;
-		if (data->version < 4) {
-			printk(KERN_NOTICE "NFS: NFSv3 not supported by mount program.\n");
-			goto out_unlock;
-		}
-#else
-		printk(KERN_NOTICE "NFS: NFSv3 not supported.\n");
-		goto out_unlock;
-#endif
-	} else {
-		server->rpc_ops = &nfs_v2_clientops;
-		version = 2;
-        }
-
-	/* Which protocol do we use? */
-	tcp   = (data->flags & NFS_MOUNT_TCP);
-
-	/* Initialize timeout values */
-	timeparms.to_initval = data->timeo * HZ / 10;
-	timeparms.to_retries = data->retrans;
-	timeparms.to_maxval  = tcp? RPC_MAX_TCP_TIMEOUT : RPC_MAX_UDP_TIMEOUT;
-	timeparms.to_exponential = 1;
-
-	if (!timeparms.to_initval)
-		timeparms.to_initval = (tcp ? 600 : 11) * HZ / 10;
-	if (!timeparms.to_retries)
-		timeparms.to_retries = 5;
-
-	/* Now create transport and client */
-	xprt = xprt_create_proto(tcp? IPPROTO_TCP : IPPROTO_UDP,
-						&server->addr, &timeparms);
-	if (xprt == NULL)
-		goto out_no_xprt;
-
-	/* Choose authentication flavor */
-	authflavor = RPC_AUTH_UNIX;
-	if (data->flags & NFS_MOUNT_SECURE)
-		authflavor = RPC_AUTH_DES;
-	else if (data->flags & NFS_MOUNT_KERBEROS)
-		authflavor = RPC_AUTH_KRB;
-
-	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
-				 version, authflavor);
-	if (clnt == NULL)
-		goto out_no_client;
-
-	clnt->cl_intr     = (data->flags & NFS_MOUNT_INTR)? 1 : 0;
-	clnt->cl_softrtry = (data->flags & NFS_MOUNT_SOFT)? 1 : 0;
-	clnt->cl_droppriv = (data->flags & NFS_MOUNT_BROKEN_SUID) ? 1 : 0;
-	clnt->cl_chatty   = 1;
-	server->client    = clnt;
-
-	/* Fire up rpciod if not yet running */
-	if (rpciod_up() != 0)
-		goto out_no_iod;
-
-	/*
-	 * Keep the super block locked while we try to get 
-	 * the root fh attributes.
-	 */
 	/* Did getting the root inode fail? */
-	if (!(root_inode = nfs_get_root(sb, &server->fh))
-	    && (data->flags & NFS_MOUNT_VER3)) {
-		data->flags &= ~NFS_MOUNT_VER3;
-		rpciod_down();
-		rpc_shutdown_client(server->client);
-		goto nfsv3_try_again;
-	}
-
+	root_inode = nfs_get_root(sb, &server->fh);
 	if (!root_inode)
 		goto out_no_root;
 	sb->s_root = d_alloc_root(root_inode);
@@ -377,9 +274,9 @@
         }
 
 	/* Work out a lot of parameters */
-	if (data->rsize == 0)
+	if (server->rsize == 0)
 		server->rsize = nfs_block_size(fsinfo.rtpref, NULL);
-	if (data->wsize == 0)
+	if (server->wsize == 0)
 		server->wsize = nfs_block_size(fsinfo.wtpref, NULL);
 	/* NFSv3: we don't have bsize, but rather rtmult and wtmult... */
 	if (!fsinfo.bsize)
@@ -391,12 +288,12 @@
 	if (fsinfo.bsize < server->wsize)
 		fsinfo.bsize = server->wsize;
 
-	if (data->bsize == 0)
+	if (sb->s_blocksize == 0)
 		sb->s_blocksize = nfs_block_bits(fsinfo.bsize, &sb->s_blocksize_bits);
-	if (server->rsize > fsinfo.rtmax)
-		server->rsize = fsinfo.rtmax;
-	if (server->wsize > fsinfo.wtmax)
-		server->wsize = fsinfo.wtmax;
+	if (fsinfo.rtmax >= 512 && server->rsize > fsinfo.rtmax)
+		server->rsize = nfs_block_size(fsinfo.rtmax, NULL);
+	if (fsinfo.wtmax >= 512 && server->wsize > fsinfo.wtmax)
+		server->wsize = nfs_block_size(fsinfo.wtmax, NULL);
 
 	server->rpages = (server->rsize + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 	if (server->rpages > NFS_READ_MAXIOV) {
@@ -416,10 +313,11 @@
 	if (server->dtsize > server->rsize)
 		server->dtsize = server->rsize;
 
-        maxlen = (version == 2) ? NFS2_MAXNAMLEN : NFS3_MAXNAMLEN;
-
-        if (server->namelen == 0 || server->namelen > maxlen)
-                server->namelen = maxlen;
+	if (server->flags & NFS_MOUNT_NOAC) {
+		server->acregmin = server->acregmax = 0;
+		server->acdirmin = server->acdirmax = 0;
+		sb->s_flags |= MS_SYNCHRONOUS;
+	}
 
 	sb->s_maxbytes = fsinfo.maxfilesize;
 	if (sb->s_maxbytes > MAX_LFS_FILESIZE) 
@@ -432,44 +330,140 @@
 	}
 
 	/* We're airborne Set socket buffersize */
-	rpc_setbufsize(clnt, server->wsize + 100, server->rsize + 100);
-
-	/* Check whether to start the lockd process */
-	if (!(server->flags & NFS_MOUNT_NONLM))
-		lockd_up();
+	rpc_setbufsize(server->client, server->wsize + 100, server->rsize + 100);
 	return 0;
-
 	/* Yargs. It didn't work out. */
- failure_kill_reqlist:
+failure_kill_reqlist:
 	nfs_reqlist_exit(server);
+out_free_all:
+	if (root_inode)
+		iput(root_inode);
+	nfs_reqlist_free(server);
+	return -EINVAL;
 out_no_root:
 	printk("nfs_read_super: get root inode failed\n");
-	iput(root_inode);
-	rpciod_down();
-	goto out_shutdown;
+	goto out_free_all;
+}
 
-out_no_iod:
-	printk(KERN_WARNING "NFS: couldn't start rpciod!\n");
-out_shutdown:
-	rpc_shutdown_client(server->client);
-	goto out_free_host;
+/*
+ * The way this works is that the mount process passes a structure
+ * in the data argument which contains the server's IP address
+ * and the root file handle obtained from the server's mount
+ * daemon. We stash these away in the private superblock fields.
+ */
+int nfs_fill_super(struct super_block *sb, struct nfs_mount_data *data, int silent)
+{
+	struct nfs_server	*server;
+	struct rpc_xprt		*xprt = NULL;
+	struct rpc_clnt		*clnt = NULL;
+	struct rpc_timeout	timeparms;
+	int			tcp, err = -EIO;
+
+	server           = NFS_SB(sb);
+	sb->s_blocksize_bits = 0;
+	sb->s_blocksize = 0;
+	if (data->bsize)
+		sb->s_blocksize = nfs_block_size(data->bsize, &sb->s_blocksize_bits);
+	if (data->rsize)
+		server->rsize = nfs_block_size(data->rsize, NULL);
+	if (data->wsize)
+		server->wsize = nfs_block_size(data->wsize, NULL);
+	server->flags    = data->flags & NFS_MOUNT_FLAGMASK;
 
-out_no_client:
-	printk(KERN_WARNING "NFS: cannot create RPC client.\n");
-	xprt_destroy(xprt);
-	goto out_free_host;
+	server->acregmin = data->acregmin*HZ;
+	server->acregmax = data->acregmax*HZ;
+	server->acdirmin = data->acdirmin*HZ;
+	server->acdirmax = data->acdirmax*HZ;
 
-out_no_xprt:
-	printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
+	server->namelen  = data->namlen;
+	server->hostname = kmalloc(strlen(data->hostname) + 1, GFP_KERNEL);
+	if (!server->hostname)
+		goto out_fail;
+	strcpy(server->hostname, data->hostname);
 
-out_free_host:
-	nfs_reqlist_free(server);
-	kfree(server->hostname);
-out_unlock:
-	goto out_fail;
+	/* Check NFS protocol revision and initialize RPC op vector
+	 * and file handle pool. */
+	if (server->flags & NFS_MOUNT_VER3) {
+#ifdef CONFIG_NFS_V3
+		server->rpc_ops = &nfs_v3_clientops;
+		server->caps |= NFS_CAP_READDIRPLUS;
+		if (data->version < 4) {
+			printk(KERN_NOTICE "NFS: NFSv3 not supported by mount program.\n");
+			goto out_fail;
+		}
+#else
+		printk(KERN_NOTICE "NFS: NFSv3 not supported.\n");
+		goto out_fail;
+#endif
+	} else {
+		server->rpc_ops = &nfs_v2_clientops;
+	}
+
+	/* Which protocol do we use? */
+	tcp   = (data->flags & NFS_MOUNT_TCP);
+
+	/* Initialize timeout values */
+	timeparms.to_initval = data->timeo * HZ / 10;
+	timeparms.to_retries = data->retrans;
+	timeparms.to_maxval  = tcp? RPC_MAX_TCP_TIMEOUT : RPC_MAX_UDP_TIMEOUT;
+	timeparms.to_exponential = 1;
+
+	if (!timeparms.to_initval)
+		timeparms.to_initval = (tcp ? 600 : 11) * HZ / 10;
+	if (!timeparms.to_retries)
+		timeparms.to_retries = 5;
+
+	/* Now create transport and client */
+	xprt = xprt_create_proto(tcp? IPPROTO_TCP : IPPROTO_UDP,
+						&server->addr, &timeparms);
+	if (xprt == NULL) {
+		printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
+		goto out_fail;
+	}
+	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
+				 server->rpc_ops->version, RPC_AUTH_UNIX);
+	if (clnt == NULL) {
+		printk(KERN_WARNING "NFS: cannot create RPC client.\n");
+		xprt_destroy(xprt);
+		goto out_fail;
+	}
+
+	clnt->cl_intr     = (server->flags & NFS_MOUNT_INTR) ? 1 : 0;
+	clnt->cl_softrtry = (server->flags & NFS_MOUNT_SOFT) ? 1 : 0;
+	clnt->cl_droppriv = (server->flags & NFS_MOUNT_BROKEN_SUID) ? 1 : 0;
+	clnt->cl_chatty   = 1;
+	server->client    = clnt;
+
+	/* Fire up rpciod if not yet running */
+	if (rpciod_up() != 0) {
+		printk(KERN_WARNING "NFS: couldn't start rpciod!\n");
+		goto out_shutdown;
+	}
+
+	err = nfs_sb_init(sb);
+	if (err != 0)
+		goto out_noinit;
+
+	if (server->flags & NFS_MOUNT_VER3) {
+		if (server->namelen == 0 || server->namelen > NFS3_MAXNAMLEN)
+			server->namelen = NFS3_MAXNAMLEN;
+	} else {
+		if (server->namelen == 0 || server->namelen > NFS2_MAXNAMLEN)
+			server->namelen = NFS2_MAXNAMLEN;
+	}
 
+	/* Check whether to start the lockd process */
+	if (!(server->flags & NFS_MOUNT_NONLM))
+		lockd_up();
+	return 0;
+out_noinit:
+	rpciod_down();
+out_shutdown:
+	rpc_shutdown_client(server->client);
 out_fail:
-	return -EINVAL;
+	if (server->hostname)
+		kfree(server->hostname);
+	return err;
 }
 
 static int


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
