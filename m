From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [3/7]
Date: Thu, 31 Oct 2002 21:20:53 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.37029.342094.922853@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187LoO-0003YT-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:21:05 -0800
To: Linus Torvalds <torvalds@transmeta.com>,
    NFS maillist <nfs@lists.sourceforge.net>,nfsv4-wg@citi.umich.edu
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


Clean up the initialization of struct rpc_message. Use C99 designated
initializers.

Add fields to allow RPCSEC_GSS to do out-of-band message passing
in NULL RPC calls. The 2 new fields provide a way to override the
standard encode/decode functions.

Cheers,
  Trond


diff -u --recursive --new-file linux-2.5.44-00-fixes/fs/lockd/clntproc.c linux-2.5.44-01-rpc_msg/fs/lockd/clntproc.c
--- linux-2.5.44-00-fixes/fs/lockd/clntproc.c	2002-09-29 10:15:13.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/fs/lockd/clntproc.c	2002-10-28 16:01:37.000000000 -0500
@@ -241,19 +241,18 @@
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*filp = argp->lock.fl.fl_file;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_proc	= proc,
+		.rpc_argp	= argp,
+		.rpc_resp	= resp,
+	};
 	int		status;
 
 	dprintk("lockd: call procedure %s on %s\n",
 			nlm_procname(proc), host->h_name);
 
-	msg.rpc_proc = proc;
-	msg.rpc_argp = argp;
-	msg.rpc_resp = resp;
 	if (filp)
 		msg.rpc_cred = nfs_file_cred(filp);
-	else
-		msg.rpc_cred = NULL;
 
 	do {
 		if (host->h_reclaiming && !argp->reclaim) {
@@ -321,9 +320,11 @@
 {
 	struct nlm_host	*host = req->a_host;
 	struct rpc_clnt	*clnt;
-	struct nlm_args	*argp = &req->a_args;
-	struct nlm_res	*resp = &req->a_res;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_proc	= proc,
+		.rpc_argp	= &req->a_args,
+		.rpc_resp	= &req->a_res,
+	};
 	int		status;
 
 	dprintk("lockd: call procedure %s on %s (async)\n",
@@ -334,10 +335,6 @@
 		return -ENOLCK;
 
         /* bootstrap and kick off the async RPC call */
-	msg.rpc_proc = proc;
-	msg.rpc_argp = argp;
-	msg.rpc_resp =resp;
-	msg.rpc_cred = NULL;	
         status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, callback, req);
 
 	return status;
@@ -351,7 +348,11 @@
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*file = argp->lock.fl.fl_file;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_proc	= proc,
+		.rpc_argp	= argp,
+		.rpc_resp	= resp,
+	};
 	int		status;
 
 	dprintk("lockd: call procedure %s on %s (async)\n",
@@ -362,13 +363,8 @@
 		return -ENOLCK;
 
         /* bootstrap and kick off the async RPC call */
-	msg.rpc_proc = proc;
-	msg.rpc_argp = argp;
-	msg.rpc_resp =resp;
 	if (file)
 		msg.rpc_cred = nfs_file_cred(file);
-	else
-		msg.rpc_cred = NULL;
 	/* Increment host refcount */
 	nlm_get_host(host);
         status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, callback, req);
diff -u --recursive --new-file linux-2.5.44-00-fixes/fs/nfs/nfs3proc.c linux-2.5.44-01-rpc_msg/fs/nfs/nfs3proc.c
--- linux-2.5.44-00-fixes/fs/nfs/nfs3proc.c	2002-10-12 19:56:07.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/fs/nfs/nfs3proc.c	2002-10-28 16:01:37.000000000 -0500
@@ -697,7 +697,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= NFS3PROC_READ,
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
@@ -718,10 +723,6 @@
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
 
-	msg.rpc_proc = NFS3PROC_READ;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -744,7 +745,12 @@
 	struct nfs_page		*req;
 	int			stable;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= NFS3PROC_WRITE,
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	if (how & FLUSH_STABLE) {
 		if (!NFS_I(inode)->ncommit)
@@ -774,10 +780,6 @@
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
 
-	msg.rpc_proc = NFS3PROC_WRITE;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -795,7 +797,12 @@
 	struct rpc_task		*task = &data->task;
 	struct inode		*inode = data->inode;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= NFS3PROC_COMMIT,
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	data->u.v3.args.fh     = NFS_FH(data->inode);
 	data->u.v3.args.offset = start;
@@ -813,10 +820,6 @@
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
 	
-	msg.rpc_proc = NFS3PROC_COMMIT;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
diff -u --recursive --new-file linux-2.5.44-00-fixes/fs/nfs/nfs4proc.c linux-2.5.44-01-rpc_msg/fs/nfs/nfs4proc.c
--- linux-2.5.44-00-fixes/fs/nfs/nfs4proc.c	2002-10-14 10:03:48.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/fs/nfs/nfs4proc.c	2002-10-28 16:01:37.000000000 -0500
@@ -1516,7 +1516,9 @@
 	struct renew_desc *rp;
 	struct rpc_task *task;
 	struct nfs4_compound *cp;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_proc	= NFSPROC4_COMPOUND,
+	};
 
 	rp = (struct renew_desc *) kmalloc(sizeof(*rp), GFP_KERNEL);
 	if (!rp)
@@ -1527,10 +1529,8 @@
 	nfs4_setup_compound(cp, rp->ops, server, "renew");
 	nfs4_setup_renew(cp);
 	
-	msg.rpc_proc = NFSPROC4_COMPOUND;
 	msg.rpc_argp = cp;
 	msg.rpc_resp = cp;
-	msg.rpc_cred = NULL;
 	rpc_init_task(task, server->client, renew_done, RPC_TASK_ASYNC);
 	rpc_call_setup(task, &msg, 0);
 	task->tk_calldata = rp;
diff -u --recursive --new-file linux-2.5.44-00-fixes/fs/nfs/proc.c linux-2.5.44-01-rpc_msg/fs/nfs/proc.c
--- linux-2.5.44-00-fixes/fs/nfs/proc.c	2002-10-16 08:44:29.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/fs/nfs/proc.c	2002-10-28 16:01:37.000000000 -0500
@@ -532,7 +532,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= NFSPROC_READ,
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
@@ -553,10 +558,6 @@
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
 
-	msg.rpc_proc = NFSPROC_READ;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -575,7 +576,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= NFSPROC_WRITE,
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
 	
@@ -599,10 +605,6 @@
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
 
-	msg.rpc_proc = NFSPROC_WRITE;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
diff -u --recursive --new-file linux-2.5.44-00-fixes/fs/nfs/unlink.c linux-2.5.44-01-rpc_msg/fs/nfs/unlink.c
--- linux-2.5.44-00-fixes/fs/nfs/unlink.c	2002-10-11 18:22:12.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/fs/nfs/unlink.c	2002-10-28 18:22:08.000000000 -0500
@@ -93,14 +93,14 @@
 {
 	struct nfs_unlinkdata	*data = (struct nfs_unlinkdata *)task->tk_calldata;
 	struct dentry		*dir = data->dir;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_cred	= data->cred,
+	};
 	int			status = -ENOENT;
 
 	if (!data->name.len)
 		goto out_err;
 
-	memset(&msg, 0, sizeof(msg));
-	msg.rpc_cred = data->cred;
 	status = NFS_PROTO(dir->d_inode)->unlink_setup(&msg, dir, &data->name);
 	if (status < 0)
 		goto out_err;
diff -u --recursive --new-file linux-2.5.44-00-fixes/include/linux/sunrpc/sched.h linux-2.5.44-01-rpc_msg/include/linux/sunrpc/sched.h
--- linux-2.5.44-00-fixes/include/linux/sunrpc/sched.h	2002-10-01 04:54:49.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/include/linux/sunrpc/sched.h	2002-10-28 17:00:27.000000000 -0500
@@ -27,6 +27,8 @@
 	void *			rpc_argp;	/* Arguments */
 	void *			rpc_resp;	/* Result */
 	struct rpc_cred *	rpc_cred;	/* Credentials */
+	int			(*xdr_encode)(void *, u32 *, void *);
+	int			(*xdr_decode)(void *, u32 *, void *);
 };
 
 /*
diff -u --recursive --new-file linux-2.5.44-00-fixes/net/sunrpc/clnt.c linux-2.5.44-01-rpc_msg/net/sunrpc/clnt.c
--- linux-2.5.44-00-fixes/net/sunrpc/clnt.c	2002-09-29 10:15:28.000000000 -0400
+++ linux-2.5.44-01-rpc_msg/net/sunrpc/clnt.c	2002-10-28 17:05:26.000000000 -0500
@@ -327,8 +327,16 @@
 void
 rpc_call_setup(struct rpc_task *task, struct rpc_message *msg, int flags)
 {
-	task->tk_msg   = *msg;
+	struct rpc_message *tk_msg = &task->tk_msg;
+
+	memcpy(tk_msg, msg, sizeof(*tk_msg));
 	task->tk_flags |= flags;
+	if (msg->xdr_encode == NULL)
+		task->tk_msg.xdr_encode = rpcproc_encode(task->tk_client,
+							 msg->rpc_proc);
+	if (msg->xdr_decode == NULL)
+		task->tk_msg.xdr_decode = rpcproc_decode(task->tk_client,
+							 msg->rpc_proc);
 	/* Bind the user cred */
 	if (task->tk_msg.rpc_cred != NULL) {
 		rpcauth_holdcred(task);
@@ -538,7 +546,7 @@
 	memset(task->tk_buffer, 0, bufsiz);
 
 	/* Encode header and provided arguments */
-	encode = rpcproc_encode(clnt, task->tk_msg.rpc_proc);
+	encode = task->tk_msg.xdr_encode;
 	if (!(p = call_header(task))) {
 		printk(KERN_INFO "RPC: call_header failed, exit EIO\n");
 		rpc_exit(task, -EIO);
@@ -629,7 +637,7 @@
 	if (task->tk_status < 0)
 		return;
 	xprt_transmit(task);
-	if (!rpcproc_decode(clnt, task->tk_msg.rpc_proc) && task->tk_status >= 0) {
+	if (!task->tk_msg.xdr_decode && task->tk_status >= 0) {
 		task->tk_action = NULL;
 		rpc_wake_up_task(task);
 	}
@@ -732,7 +740,7 @@
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrproc_t	decode = rpcproc_decode(clnt, task->tk_msg.rpc_proc);
+	kxdrproc_t	decode = task->tk_msg.xdr_decode;
 	u32		*p;
 
 	dprintk("RPC: %4d call_decode (status %d)\n", 


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
