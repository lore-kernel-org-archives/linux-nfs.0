From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Makes nfs mount warning less frequent and more
	valuable
Date: Thu, 17 Mar 2005 11:00:32 -0500
Message-ID: <1111075232.13215.14.camel@lade.trondhjem.org>
References: <4237178A.5030003@dgreaves.com>
	 <Pine.LNX.4.61.0503151439250.22235@guppy.limebrokerage.com>
	 <42384B59.3060408@dgreaves.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-brZAiC7RIznjW5C48MC9"
Cc: Neil Brown <neilb@cse.unsw.edu.au>,
	Ion Badulescu <ionut@badula.org>, Erez Zadok <ezk@cs.sunysb.edu>,
	am-utils@fsl.cs.sunysb.edu, nfs@lists.sourceforge.net
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.11] helo=sc8-sf-mx1.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1DBxQn-00048b-0K
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:01:05 -0800
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-mx1.sourceforge.net with esmtp (TLSv1:AES256-SHA:256)
	(Exim 4.41)
	id 1DBxQj-0007lg-UR
	for nfs@lists.sourceforge.net; Thu, 17 Mar 2005 08:01:04 -0800
To: David Greaves <david@dgreaves.com>
In-Reply-To: <42384B59.3060408@dgreaves.com>
Sender: nfs-admin@lists.sourceforge.net
Errors-To: nfs-admin@lists.sourceforge.net
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Id: Discussion of NFS under Linux development,
	interoperability,
	and testing. <nfs.lists.sourceforge.net>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


--=-brZAiC7RIznjW5C48MC9
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

on den 16.03.2005 Klokka 15:06 (+0000) skreiv David Greaves:
> Neil,
> 
> This is in response to an ongoing quest to shut the kernel up when it 
> whines:
>    kernel: nfs warning: mount version older than kernel
> incessantly and uselessly, I spoke to the am-utils people and eventually 
> got some help tracking it down.
> 
> Googling around the error reveals many, many confused souls and no 
> obvious reason for the message.
> 

So, firstly, we do NOT accept mount versions > NFS_MOUNT_VERSION (or
mount versions < 1). There is no reason to, and doing so might be
dangerous, since the format of the structure may change. The "mount"
program is supposed to look at the kernel version in order to determine
which mount structure to use.

Secondly, we need to add reasonable error codes so that people can
actually determine what they are doing wrong. Using the NFSv3 flag with
a version of the nfs_mount_data that doesn't support NFSv3 file handles
is, for instance, one problem that we are not reporting properly.

Thirdly, we still want to make it easy to debug problems for people that
are seeing errors, and can't understand what is wrong. By using
"dprintk()" instead of "printk()", users can still turn on the verbose
debugging: it just won't be reported by default.

I started rethinking this subject last night in between cleanups of the
ACL code. Attached is the resulting patch proposal. It goes a lot
further that what you do, but should hopefully provide better error
reporting in "mount" and clean up some of that code.
In particular, note that it attempts to add an error code that tells you
whether or not NFSv3 is actually supported by the kernel: I used
EPROTONOSUPPORT, since that gives the correct error message with
perror() (although strictly, EPROTONOSUPPORT appears to be a socket
error). If anyone has a better suggestion for an error that makes more
sense, then I'm all ears...

Cheers,
  Trond
-- 
Trond Myklebust <trond.myklebust@fys.uio.no>

--=-brZAiC7RIznjW5C48MC9
Content-Disposition: inline; filename=linux-2.6.11-01-kill_bad_mount_options.dif
Content-Type: text/plain; name=linux-2.6.11-01-kill_bad_mount_options.dif; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

NFS: Kill annoying mount version mismatch printks

 Ensure that we fix up the missing fields in the nfs_mount_data with
 sane defaults for older versions of mount, and return errors in the
 cases where we cannot.

 Convert a bunch of annoying warnings into dprintks()

 Return -EPROTONOSUPPORT rather than EIO if mount() tries to set NFSv3
 without it actually being compiled in.

 Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 inode.c |  179 +++++++++++++++++++++++++++++++++++++---------------------------
 1 files changed, 105 insertions(+), 74 deletions(-)

Index: linux-2.6.11/fs/nfs/inode.c
===================================================================
--- linux-2.6.11.orig/fs/nfs/inode.c
+++ linux-2.6.11/fs/nfs/inode.c
@@ -366,13 +366,15 @@ nfs_create_client(struct nfs_server *ser
 	xprt = xprt_create_proto(tcp ? IPPROTO_TCP : IPPROTO_UDP,
 				 &server->addr, &timeparms);
 	if (IS_ERR(xprt)) {
-		printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
+		dprintk("%s: cannot create RPC transport. Error = %ld\n",
+				__FUNCTION__, PTR_ERR(xprt));
 		return (struct rpc_clnt *)xprt;
 	}
 	clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
 				 server->rpc_ops->version, data->pseudoflavor);
 	if (IS_ERR(clnt)) {
-		printk(KERN_WARNING "NFS: cannot create RPC client.\n");
+		dprintk("%s: cannot create RPC client. Error = %ld\n",
+				__FUNCTION__, PTR_ERR(xprt));
 		goto out_fail;
 	}
 
@@ -427,21 +429,16 @@ nfs_fill_super(struct super_block *sb, s
 
 	/* Check NFS protocol revision and initialize RPC op vector
 	 * and file handle pool. */
-	if (server->flags & NFS_MOUNT_VER3) {
 #ifdef CONFIG_NFS_V3
+	if (server->flags & NFS_MOUNT_VER3) {
 		server->rpc_ops = &nfs_v3_clientops;
 		server->caps |= NFS_CAP_READDIRPLUS;
-		if (data->version < 4) {
-			printk(KERN_NOTICE "NFS: NFSv3 not supported by mount program.\n");
-			return -EIO;
-		}
-#else
-		printk(KERN_NOTICE "NFS: NFSv3 not supported.\n");
-		return -EIO;
-#endif
 	} else {
 		server->rpc_ops = &nfs_v2_clientops;
 	}
+#else
+	server->rpc_ops = &nfs_v2_clientops;
+#endif
 
 	/* Fill in pseudoflavor for mount version < 5 */
 	if (!(data->flags & NFS_MOUNT_SECFLAVOUR))
@@ -1385,74 +1382,94 @@ static struct super_block *nfs_get_sb(st
 	int flags, const char *dev_name, void *raw_data)
 {
 	int error;
-	struct nfs_server *server;
+	struct nfs_server *server = NULL;
 	struct super_block *s;
 	struct nfs_fh *root;
 	struct nfs_mount_data *data = raw_data;
 
-	if (!data) {
-		printk("nfs_read_super: missing data argument\n");
-		return ERR_PTR(-EINVAL);
+	s = ERR_PTR(-EINVAL);
+	if (data == NULL) {
+		dprintk("%s: missing data argument\n", __FUNCTION__);
+		goto out_err;
+	}
+	if (data->version <= 0 || data->version > NFS_MOUNT_VERSION) {
+		dprintk("%s: bad mount version\n", __FUNCTION__);
+		goto out_err;
 	}
+	switch (data->version) {
+		case 1:
+			data->namlen = 0;
+		case 2:
+			data->bsize  = 0;
+		case 3:
+			if (data->flags & NFS_MOUNT_VER3) {
+				dprintk("%s: mount structure version %d does not support NFSv3\n",
+						__FUNCTION__,
+						data->version);
+				goto out_err;
+			}
+			data->root.size = NFS2_FHSIZE;
+			memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
+		case 4:
+			if (data->flags & NFS_MOUNT_SECFLAVOUR) {
+				dprintk("%s: mount structure version %d does not support strong security\n",
+						__FUNCTION__,
+						data->version);
+				goto out_err;
+			}
+		case 5:
+			memset(data->context, 0, sizeof(data->context));
+	}
+#ifndef CONFIG_NFS_V3
+	/* If NFSv3 is not compiled in, return -EPROTONOSUPPORT */
+	s = ERR_PTR(-EPROTONOSUPPORT);
+	if (data->flags & NFS_MOUNT_VER3) {
+		dprintk("%s: NFSv3 not compiled into kernel\n", __FUNCTION__);
+		goto out_err;
+	}
+#endif /* CONFIG_NFS_V3 */
 
+	s = ERR_PTR(-ENOMEM);
 	server = kmalloc(sizeof(struct nfs_server), GFP_KERNEL);
 	if (!server)
-		return ERR_PTR(-ENOMEM);
+		goto out_err;
 	memset(server, 0, sizeof(struct nfs_server));
 	/* Zero out the NFS state stuff */
 	init_nfsv4_state(server);
 
-	if (data->version != NFS_MOUNT_VERSION) {
-		printk("nfs warning: mount version %s than kernel\n",
-			data->version < NFS_MOUNT_VERSION ? "older" : "newer");
-		if (data->version < 2)
-			data->namlen = 0;
-		if (data->version < 3)
-			data->bsize  = 0;
-		if (data->version < 4) {
-			data->flags &= ~NFS_MOUNT_VER3;
-			data->root.size = NFS2_FHSIZE;
-			memcpy(data->root.data, data->old_root.data, NFS2_FHSIZE);
-		}
-		if (data->version < 5)
-			data->flags &= ~NFS_MOUNT_SECFLAVOUR;
-	}
-
 	root = &server->fh;
 	if (data->flags & NFS_MOUNT_VER3)
 		root->size = data->root.size;
 	else
 		root->size = NFS2_FHSIZE;
+	s = ERR_PTR(-EINVAL);
 	if (root->size > sizeof(root->data)) {
-		printk("nfs_get_sb: invalid root filehandle\n");
-		kfree(server);
-		return ERR_PTR(-EINVAL);
+		dprintk("%s: invalid root filehandle\n", __FUNCTION__);
+		goto out_err;
 	}
 	memcpy(root->data, data->root.data, root->size);
 
 	/* We now require that the mount process passes the remote address */
 	memcpy(&server->addr, &data->addr, sizeof(server->addr));
 	if (server->addr.sin_addr.s_addr == INADDR_ANY) {
-		printk("NFS: mount program didn't pass remote address!\n");
-		kfree(server);
-		return ERR_PTR(-EINVAL);
+		dprintk("%s: mount program didn't pass remote address!\n",
+				__FUNCTION__);
+		goto out_err;
 	}
 
-	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
-
-	if (IS_ERR(s) || s->s_root) {
-		kfree(server);
-		return s;
+	/* Fire up rpciod if not yet running */
+	s = ERR_PTR(rpciod_up());
+	if (IS_ERR(s)) {
+		dprintk("%s: couldn't start rpciod! Error = %ld\n",
+				__FUNCTION__, PTR_ERR(s));
+		goto out_err;
 	}
 
-	s->s_flags = flags;
+	s = sget(fs_type, nfs_compare_super, nfs_set_super, server);
+	if (IS_ERR(s) || s->s_root)
+		goto out_rpciod_down;
 
-	/* Fire up rpciod if not yet running */
-	if (rpciod_up() != 0) {
-		printk(KERN_WARNING "NFS: couldn't start rpciod!\n");
-		kfree(server);
-		return ERR_PTR(-EIO);
-	}
+	s->s_flags = flags;
 
 	error = nfs_fill_super(s, data, flags & MS_VERBOSE ? 1 : 0);
 	if (error) {
@@ -1462,6 +1479,11 @@ static struct super_block *nfs_get_sb(st
 	}
 	s->s_flags |= MS_ACTIVE;
 	return s;
+out_rpciod_down:
+	rpciod_down();
+out_err:
+	kfree(server);
+	return s;
 }
 
 static void nfs_kill_super(struct super_block *s)
@@ -1594,15 +1616,19 @@ static int nfs4_fill_super(struct super_
 
 	clp = nfs4_get_client(&server->addr.sin_addr);
 	if (!clp) {
-		printk(KERN_WARNING "NFS: failed to create NFS4 client.\n");
+		dprintk("%s: failed to create NFS4 client.\n", __FUNCTION__);
 		return -EIO;
 	}
 
 	/* Now create transport and client */
 	authflavour = RPC_AUTH_UNIX;
 	if (data->auth_flavourlen != 0) {
-		if (data->auth_flavourlen > 1)
-			printk(KERN_INFO "NFS: cannot yet deal with multiple auth flavours.\n");
+		if (data->auth_flavourlen != 1) {
+			dprintk("%s: Invalid number of RPC auth flavours %d.\n",
+					__FUNCTION__, data->auth_flavourlen);
+			err = -EINVAL;
+			goto out_fail;
+		}
 		if (copy_from_user(&authflavour, data->auth_flavours, sizeof(authflavour))) {
 			err = -EFAULT;
 			goto out_fail;
@@ -1614,17 +1640,19 @@ static int nfs4_fill_super(struct super_
 		xprt = xprt_create_proto(proto, &server->addr, &timeparms);
 		if (IS_ERR(xprt)) {
 			up_write(&clp->cl_sem);
-			printk(KERN_WARNING "NFS: cannot create RPC transport.\n");
 			err = PTR_ERR(xprt);
+			dprintk("%s: cannot create RPC transport. Error = %d\n",
+					__FUNCTION__, err);
 			goto out_fail;
 		}
 		clnt = rpc_create_client(xprt, server->hostname, &nfs_program,
 				server->rpc_ops->version, authflavour);
 		if (IS_ERR(clnt)) {
 			up_write(&clp->cl_sem);
-			printk(KERN_WARNING "NFS: cannot create RPC client.\n");
 			xprt_destroy(xprt);
 			err = PTR_ERR(clnt);
+			dprintk("%s: cannot create RPC client. Error = %d\n",
+					__FUNCTION__, err);
 			goto out_fail;
 		}
 		clnt->cl_intr     = 1;
@@ -1656,20 +1684,22 @@ static int nfs4_fill_super(struct super_
 	clp = NULL;
 
 	if (IS_ERR(clnt)) {
-		printk(KERN_WARNING "NFS: cannot create RPC client.\n");
-		return PTR_ERR(clnt);
+		err = PTR_ERR(clnt);
+		dprintk("%s: cannot create RPC client. Error = %d\n",
+				__FUNCTION__, err);
+		return err;
 	}
 
 	server->client    = clnt;
 
 	if (server->nfs4_state->cl_idmap == NULL) {
-		printk(KERN_WARNING "NFS: failed to create idmapper.\n");
+		dprintk("%s: failed to create idmapper.\n", __FUNCTION__);
 		return -ENOMEM;
 	}
 
 	if (clnt->cl_auth->au_flavor != authflavour) {
 		if (rpcauth_create(authflavour, clnt) == NULL) {
-			printk(KERN_WARNING "NFS: couldn't create credcache!\n");
+			dprintk("%s: couldn't create credcache!\n", __FUNCTION__);
 			return -ENOMEM;
 		}
 	}
@@ -1730,8 +1760,12 @@ static struct super_block *nfs4_get_sb(s
 	struct nfs4_mount_data *data = raw_data;
 	void *p;
 
-	if (!data) {
-		printk("nfs_read_super: missing data argument\n");
+	if (data == NULL) {
+		dprintk("%s: missing data argument\n", __FUNCTION__);
+		return ERR_PTR(-EINVAL);
+	}
+	if (data->version <= 0 || data->version > NFS4_MOUNT_VERSION) {
+		dprintk("%s: bad mount version\n", __FUNCTION__);
 		return ERR_PTR(-EINVAL);
 	}
 
@@ -1742,11 +1776,6 @@ static struct super_block *nfs4_get_sb(s
 	/* Zero out the NFS state stuff */
 	init_nfsv4_state(server);
 
-	if (data->version != NFS4_MOUNT_VERSION) {
-		printk("nfs warning: mount version %s than kernel\n",
-			data->version < NFS4_MOUNT_VERSION ? "older" : "newer");
-	}
-
 	p = nfs_copy_user_string(NULL, &data->hostname, 256);
 	if (IS_ERR(p))
 		goto out_err;
@@ -1773,11 +1802,20 @@ static struct super_block *nfs4_get_sb(s
 	}
 	if (server->addr.sin_family != AF_INET ||
 	    server->addr.sin_addr.s_addr == INADDR_ANY) {
-		printk("NFS: mount program didn't pass remote IP address!\n");
+		dprintk("%s: mount program didn't pass remote IP address!\n",
+				__FUNCTION__);
 		s = ERR_PTR(-EINVAL);
 		goto out_free;
 	}
 
+	/* Fire up rpciod if not yet running */
+	s = ERR_PTR(rpciod_up());
+	if (IS_ERR(s)) {
+		dprintk("%s: couldn't start rpciod! Error = %ld\n",
+				__FUNCTION__, PTR_ERR(s));
+		goto out_free;
+	}
+
 	s = sget(fs_type, nfs4_compare_super, nfs_set_super, server);
 
 	if (IS_ERR(s) || s->s_root)
@@ -1785,13 +1823,6 @@ static struct super_block *nfs4_get_sb(s
 
 	s->s_flags = flags;
 
-	/* Fire up rpciod if not yet running */
-	if (rpciod_up() != 0) {
-		printk(KERN_WARNING "NFS: couldn't start rpciod!\n");
-		s = ERR_PTR(-EIO);
-		goto out_free;
-	}
-
 	error = nfs4_fill_super(s, data, flags & MS_VERBOSE ? 1 : 0);
 	if (error) {
 		up_write(&s->s_umount);

--=-brZAiC7RIznjW5C48MC9--



-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
