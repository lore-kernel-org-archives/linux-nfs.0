From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] cleanup: switch to passing *(struct rpc_procinfo) in rpc_message.
Date: Sat, 16 Nov 2002 01:24:48 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15829.36944.88909.585833@helicity.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: NFS maillist <nfs@lists.sourceforge.net>
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16] ident=7411)
	by sc8-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 18Cqlf-0004XV-00
	for <nfs@lists.sourceforge.net>; Fri, 15 Nov 2002 16:24:59 -0800
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
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>


The "procedure number" has been used for 2 purposes in the kernel
client RPC implementation:

  1) As a number to pass to the server in the RPC header.

  2) As an index into the "procedure array" of type 'struct
     rpc_procinfo', from which the RPC layer can find the XDR
     encode/decode functions, buffer size, and all the other static
     data that it needs to construct the on-wire RPC message.

This works fine for NFSv2, v3 and for the NLM locking code for which
there is a one-to-one mapping between NFS file operations, and RPC
procedures.
For NFSv4 on the other hand, the mapping is many-to-one, since there
is only one RPC procedure number: NFSPROC4_COMPOUND.

For efficiency purposes, we want to have a one-to-one mapping between
NFS file operations and the corresponding XDR encode/decode routines,
but currently this is not possible because of (2). The result is the
mess that is 'struct nfs4_op' and encode/decode_compound.

In the process eliminating (2), we might as well change to passing a
pointer to the appropriate procedure array entry instead of an
index. This change can be made transparent 

The appended patch therefore does the following:

   - Substitute a pointer to the rpc_procinfo instead of the RPC
     procedure number in the struct rpc_message.
   - Make the RPC procedure number an entry in the struct
     rpc_procinfo.
   - Clean out the largely unused (except in some obscure lockd
     debugging code) p_name field. The latter was just a stringified
     version of the RPC procedure name, so for those lockd cases, we
     can use the RPC procedure number instead.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.47/fs/lockd/clntproc.c linux-2.5.47-01-rpc_msg/fs/lockd/clntproc.c
--- linux-2.5.47/fs/lockd/clntproc.c	2002-09-29 10:15:13.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/lockd/clntproc.c	2002-11-13 09:45:47.000000000 -0500
@@ -241,19 +241,17 @@
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*filp = argp->lock.fl.fl_file;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_argp	= argp,
+		.rpc_resp	= resp,
+	};
 	int		status;
 
-	dprintk("lockd: call procedure %s on %s\n",
-			nlm_procname(proc), host->h_name);
+	dprintk("lockd: call procedure %d on %s\n",
+			(int)proc, host->h_name);
 
-	msg.rpc_proc = proc;
-	msg.rpc_argp = argp;
-	msg.rpc_resp = resp;
 	if (filp)
 		msg.rpc_cred = nfs_file_cred(filp);
-	else
-		msg.rpc_cred = NULL;
 
 	do {
 		if (host->h_reclaiming && !argp->reclaim) {
@@ -264,6 +262,7 @@
 		/* If we have no RPC client yet, create one. */
 		if ((clnt = nlm_bind_host(host)) == NULL)
 			return -ENOLCK;
+		msg.rpc_proc = &clnt->cl_procinfo[proc];
 
 		/* Perform the RPC call. If an error occurs, try again */
 		if ((status = rpc_call_sync(clnt, &msg, 0)) < 0) {
@@ -321,23 +320,21 @@
 {
 	struct nlm_host	*host = req->a_host;
 	struct rpc_clnt	*clnt;
-	struct nlm_args	*argp = &req->a_args;
-	struct nlm_res	*resp = &req->a_res;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_argp	= &req->a_args,
+		.rpc_resp	= &req->a_res,
+	};
 	int		status;
 
-	dprintk("lockd: call procedure %s on %s (async)\n",
-			nlm_procname(proc), host->h_name);
+	dprintk("lockd: call procedure %d on %s (async)\n",
+			(int)proc, host->h_name);
 
 	/* If we have no RPC client yet, create one. */
 	if ((clnt = nlm_bind_host(host)) == NULL)
 		return -ENOLCK;
+	msg.rpc_proc = &clnt->cl_procinfo[proc];
 
         /* bootstrap and kick off the async RPC call */
-	msg.rpc_proc = proc;
-	msg.rpc_argp = argp;
-	msg.rpc_resp =resp;
-	msg.rpc_cred = NULL;	
         status = rpc_call_async(clnt, &msg, RPC_TASK_ASYNC, callback, req);
 
 	return status;
@@ -351,24 +348,23 @@
 	struct nlm_args	*argp = &req->a_args;
 	struct nlm_res	*resp = &req->a_res;
 	struct file	*file = argp->lock.fl.fl_file;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_argp	= argp,
+		.rpc_resp	= resp,
+	};
 	int		status;
 
-	dprintk("lockd: call procedure %s on %s (async)\n",
-			nlm_procname(proc), host->h_name);
+	dprintk("lockd: call procedure %d on %s (async)\n",
+			(int)proc, host->h_name);
 
 	/* If we have no RPC client yet, create one. */
 	if ((clnt = nlm_bind_host(host)) == NULL)
 		return -ENOLCK;
+	msg.rpc_proc = &clnt->cl_procinfo[proc];
 
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
diff -u --recursive --new-file linux-2.5.47/fs/lockd/mon.c linux-2.5.47-01-rpc_msg/fs/lockd/mon.c
--- linux-2.5.47/fs/lockd/mon.c	2002-09-10 21:28:27.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/lockd/mon.c	2002-11-13 09:02:25.000000000 -0500
@@ -134,11 +134,6 @@
 /*
  * XDR functions for NSM.
  */
-static int
-xdr_error(struct rpc_rqst *rqstp, u32 *p, void *dummy)
-{
-	return -EACCES;
-}
 
 static int
 xdr_encode_mon(struct rpc_rqst *rqstp, u32 *p, struct nsm_args *argp)
@@ -206,43 +201,18 @@
 #endif
 
 static struct rpc_procinfo	nsm_procedures[] = {
-        {
-		.p_procname	= "sm_null",
-		.p_encode	= (kxdrproc_t) xdr_error,
-		.p_decode	= (kxdrproc_t) xdr_error,
-	},
-        {
-		.p_procname	= "sm_stat",
-		.p_encode	= (kxdrproc_t) xdr_error,
-		.p_decode	= (kxdrproc_t) xdr_error,
-	},
-        {
-		.p_procname	= "sm_mon",
+[SM_MON] = {
+		.p_proc		= SM_MON,
 		.p_encode	= (kxdrproc_t) xdr_encode_mon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat_res,
 		.p_bufsiz	= MAX(SM_mon_sz, SM_monres_sz) << 2,
 	},
-        {
-		.p_procname	= "sm_unmon",
+[SM_UNMON] = {
+		.p_proc		= SM_UNMON,
 		.p_encode	= (kxdrproc_t) xdr_encode_mon,
 		.p_decode	= (kxdrproc_t) xdr_decode_stat,
 		.p_bufsiz	= MAX(SM_mon_id_sz, SM_unmonres_sz) << 2,
 	},
-        {
-		.p_procname	= "sm_unmon_all",
-		.p_encode	= (kxdrproc_t) xdr_error,
-		.p_decode	= (kxdrproc_t) xdr_error,
-	},
-        {
-		.p_procname	= "sm_simu_crash",
-		.p_encode	= (kxdrproc_t) xdr_error,
-		.p_decode	= (kxdrproc_t) xdr_error,
-	},
-        {
-		.p_procname	= "sm_notify",
-		.p_encode	= (kxdrproc_t) xdr_error,
-		.p_decode	= (kxdrproc_t) xdr_error,
-	},
 };
 
 static struct rpc_version	nsm_version1 = {
diff -u --recursive --new-file linux-2.5.47/fs/lockd/xdr.c linux-2.5.47-01-rpc_msg/fs/lockd/xdr.c
--- linux-2.5.47/fs/lockd/xdr.c	2002-10-30 17:41:16.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/lockd/xdr.c	2002-11-13 09:14:21.000000000 -0500
@@ -544,43 +544,34 @@
 #define nlmclt_decode_norep	NULL
 
 #define PROC(proc, argtype, restype)	\
-    { .p_procname  = "nlm_" #proc,					\
-      .p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
-      .p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
-      .p_bufsiz    = MAX(NLM_##argtype##_sz, NLM_##restype##_sz) << 2	\
-    }
+[NLMPROC_##proc] = {							\
+	.p_proc      = NLMPROC_##proc,					\
+	.p_encode    = (kxdrproc_t) nlmclt_encode_##argtype,		\
+	.p_decode    = (kxdrproc_t) nlmclt_decode_##restype,		\
+	.p_bufsiz    = MAX(NLM_##argtype##_sz, NLM_##restype##_sz) << 2	\
+	}
 
 static struct rpc_procinfo	nlm_procedures[] = {
-    PROC(null,		void,		void),
-    PROC(test,		testargs,	testres),
-    PROC(lock,		lockargs,	res),
-    PROC(canc,		cancargs,	res),
-    PROC(unlock,	unlockargs,	res),
-    PROC(granted,	testargs,	res),
-    PROC(test_msg,	testargs,	norep),
-    PROC(lock_msg,	lockargs,	norep),
-    PROC(canc_msg,	cancargs,	norep),
-    PROC(unlock_msg,	unlockargs,	norep),
-    PROC(granted_msg,	testargs,	norep),
-    PROC(test_res,	testres,	norep),
-    PROC(lock_res,	res,		norep),
-    PROC(canc_res,	res,		norep),
-    PROC(unlock_res,	res,		norep),
-    PROC(granted_res,	res,		norep),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
+    PROC(TEST,		testargs,	testres),
+    PROC(LOCK,		lockargs,	res),
+    PROC(CANCEL,	cancargs,	res),
+    PROC(UNLOCK,	unlockargs,	res),
+    PROC(GRANTED,	testargs,	res),
+    PROC(TEST_MSG,	testargs,	norep),
+    PROC(LOCK_MSG,	lockargs,	norep),
+    PROC(CANCEL_MSG,	cancargs,	norep),
+    PROC(UNLOCK_MSG,	unlockargs,	norep),
+    PROC(GRANTED_MSG,	testargs,	norep),
+    PROC(TEST_RES,	testres,	norep),
+    PROC(LOCK_RES,	res,		norep),
+    PROC(CANCEL_RES,	res,		norep),
+    PROC(UNLOCK_RES,	res,		norep),
+    PROC(GRANTED_RES,	res,		norep),
 #ifdef NLMCLNT_SUPPORT_SHARES
-    PROC(share,		shareargs,	shareres),
-    PROC(unshare,	shareargs,	shareres),
-    PROC(nm_lock,	lockargs,	res),
-    PROC(free_all,	notify,		void),
-#else
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
+    PROC(SHARE,		shareargs,	shareres),
+    PROC(UNSHARE,	shareargs,	shareres),
+    PROC(NM_LOCK,	lockargs,	res),
+    PROC(FREE_ALL,	notify,		void),
 #endif
 };
 
@@ -618,13 +609,3 @@
 		.stats		= &nlm_stats,
 };
 
-#ifdef LOCKD_DEBUG
-char *
-nlm_procname(u32 proc)
-{
-	if (proc < sizeof(nlm_procedures)/sizeof(nlm_procedures[0]))
-		return nlm_procedures[proc].p_procname;
-	return "unknown";
-}
-#endif
-
diff -u --recursive --new-file linux-2.5.47/fs/lockd/xdr4.c linux-2.5.47-01-rpc_msg/fs/lockd/xdr4.c
--- linux-2.5.47/fs/lockd/xdr4.c	2002-10-30 17:41:16.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/lockd/xdr4.c	2002-11-13 09:03:24.000000000 -0500
@@ -547,43 +547,34 @@
 #define nlm4clt_decode_norep	NULL
 
 #define PROC(proc, argtype, restype)					\
-    { .p_procname  = "nlm4_" #proc,					\
-      .p_encode    = (kxdrproc_t) nlm4clt_encode_##argtype,		\
-      .p_decode    = (kxdrproc_t) nlm4clt_decode_##restype,		\
-      .p_bufsiz    = MAX(NLM4_##argtype##_sz, NLM4_##restype##_sz) << 2	\
-    }
+[NLMPROC_##proc] = {							\
+	.p_proc      = NLMPROC_##proc,					\
+	.p_encode    = (kxdrproc_t) nlm4clt_encode_##argtype,		\
+	.p_decode    = (kxdrproc_t) nlm4clt_decode_##restype,		\
+	.p_bufsiz    = MAX(NLM4_##argtype##_sz, NLM4_##restype##_sz) << 2	\
+	}
 
 static struct rpc_procinfo	nlm4_procedures[] = {
-    PROC(null,		void,		void),
-    PROC(test,		testargs,	testres),
-    PROC(lock,		lockargs,	res),
-    PROC(canc,		cancargs,	res),
-    PROC(unlock,	unlockargs,	res),
-    PROC(granted,	testargs,	res),
-    PROC(test_msg,	testargs,	norep),
-    PROC(lock_msg,	lockargs,	norep),
-    PROC(canc_msg,	cancargs,	norep),
-    PROC(unlock_msg,	unlockargs,	norep),
-    PROC(granted_msg,	testargs,	norep),
-    PROC(test_res,	testres,	norep),
-    PROC(lock_res,	res,		norep),
-    PROC(canc_res,	res,		norep),
-    PROC(unlock_res,	res,		norep),
-    PROC(granted_res,	res,		norep),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
+    PROC(TEST,		testargs,	testres),
+    PROC(LOCK,		lockargs,	res),
+    PROC(CANCEL,	cancargs,	res),
+    PROC(UNLOCK,	unlockargs,	res),
+    PROC(GRANTED,	testargs,	res),
+    PROC(TEST_MSG,	testargs,	norep),
+    PROC(LOCK_MSG,	lockargs,	norep),
+    PROC(CANCEL_MSG,	cancargs,	norep),
+    PROC(UNLOCK_MSG,	unlockargs,	norep),
+    PROC(GRANTED_MSG,	testargs,	norep),
+    PROC(TEST_RES,	testres,	norep),
+    PROC(LOCK_RES,	res,		norep),
+    PROC(CANCEL_RES,	res,		norep),
+    PROC(UNLOCK_RES,	res,		norep),
+    PROC(GRANTED_RES,	res,		norep),
 #ifdef NLMCLNT_SUPPORT_SHARES
-    PROC(share,		shareargs,	shareres),
-    PROC(unshare,	shareargs,	shareres),
-    PROC(nm_lock,	lockargs,	res),
-    PROC(free_all,	notify,		void),
-#else
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
-    PROC(undef,		void,		void),
+    PROC(SHARE,		shareargs,	shareres),
+    PROC(UNSHARE,	shareargs,	shareres),
+    PROC(NM_LOCK,	lockargs,	res),
+    PROC(FREE_ALL,	notify,		void),
 #endif
 };
 
diff -u --recursive --new-file linux-2.5.47/fs/nfs/mount_clnt.c linux-2.5.47-01-rpc_msg/fs/nfs/mount_clnt.c
--- linux-2.5.47/fs/nfs/mount_clnt.c	2002-11-07 12:29:59.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/nfs/mount_clnt.c	2002-11-13 09:15:56.000000000 -0500
@@ -140,24 +140,18 @@
 #define MNT_dirpath_sz		(1 + 256)
 #define MNT_fhstatus_sz		(1 + 8)
 
-static struct rpc_procinfo	mnt_procedures[2] = {
-	{ .p_procname		= "mnt_null",
-	  .p_encode		= (kxdrproc_t) xdr_error,	
-	  .p_decode		= (kxdrproc_t) xdr_error,
-	},
-	{ .p_procname		= "mnt_mount",
+static struct rpc_procinfo	mnt_procedures[] = {
+[MNTPROC_MNT] = {
+	  .p_proc		= MNTPROC_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,	
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus,
 	  .p_bufsiz		= MNT_dirpath_sz << 2,
 	},
 };
 
-static struct rpc_procinfo mnt3_procedures[2] = {
-	{ .p_procname		= "mnt3_null",
-	  .p_encode		= (kxdrproc_t) xdr_error,
-	  .p_decode		= (kxdrproc_t) xdr_error,
-	},
-	{ .p_procname		= "mnt3_mount",
+static struct rpc_procinfo mnt3_procedures[] = {
+[MOUNTPROC3_MNT] = {
+	  .p_proc		= MOUNTPROC3_MNT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_dirpath,
 	  .p_decode		= (kxdrproc_t) xdr_decode_fhstatus3,
 	  .p_bufsiz		= MNT_dirpath_sz << 2,
diff -u --recursive --new-file linux-2.5.47/fs/nfs/nfs2xdr.c linux-2.5.47-01-rpc_msg/fs/nfs/nfs2xdr.c
--- linux-2.5.47/fs/nfs/nfs2xdr.c	2002-11-08 11:59:28.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/nfs/nfs2xdr.c	2002-11-13 09:13:13.000000000 -0500
@@ -663,31 +663,29 @@
 #endif
 
 #define PROC(proc, argtype, restype, timer)				\
-    { .p_procname =  "nfs_" #proc,					\
-      .p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
-      .p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
-      .p_bufsiz   =  MAX(NFS_##argtype##_sz,NFS_##restype##_sz) << 2,	\
-      .p_timer    =  timer						\
-    }
-static struct rpc_procinfo	nfs_procedures[18] = {
-    PROC(null,		enc_void,	dec_void, 0),
-    PROC(getattr,	fhandle,	attrstat, 1),
-    PROC(setattr,	sattrargs,	attrstat, 0),
-    PROC(root,		enc_void,	dec_void, 0),
-    PROC(lookup,	diropargs,	diropres, 2),
-    PROC(readlink,	readlinkargs,	readlinkres, 3),
-    PROC(read,		readargs,	readres, 3),
-    PROC(writecache,	enc_void,	dec_void, 0),
-    PROC(write,		writeargs,	writeres, 4),
-    PROC(create,	createargs,	diropres, 0),
-    PROC(remove,	diropargs,	stat, 0),
-    PROC(rename,	renameargs,	stat, 0),
-    PROC(link,		linkargs,	stat, 0),
-    PROC(symlink,	symlinkargs,	stat, 0),
-    PROC(mkdir,		createargs,	diropres, 0),
-    PROC(rmdir,		diropargs,	stat, 0),
-    PROC(readdir,	readdirargs,	readdirres, 3),
-    PROC(statfs,	fhandle,	statfsres, 0),
+[NFSPROC_##proc] = {							\
+	.p_proc	    =  NFSPROC_##proc,					\
+	.p_encode   =  (kxdrproc_t) nfs_xdr_##argtype,			\
+	.p_decode   =  (kxdrproc_t) nfs_xdr_##restype,			\
+	.p_bufsiz   =  MAX(NFS_##argtype##_sz,NFS_##restype##_sz) << 2,	\
+	.p_timer    =  timer						\
+	}
+struct rpc_procinfo	nfs_procedures[] = {
+    PROC(GETATTR,	fhandle,	attrstat, 1),
+    PROC(SETATTR,	sattrargs,	attrstat, 0),
+    PROC(LOOKUP,	diropargs,	diropres, 2),
+    PROC(READLINK,	readlinkargs,	readlinkres, 3),
+    PROC(READ,		readargs,	readres, 3),
+    PROC(WRITE,		writeargs,	writeres, 4),
+    PROC(CREATE,	createargs,	diropres, 0),
+    PROC(REMOVE,	diropargs,	stat, 0),
+    PROC(RENAME,	renameargs,	stat, 0),
+    PROC(LINK,		linkargs,	stat, 0),
+    PROC(SYMLINK,	symlinkargs,	stat, 0),
+    PROC(MKDIR,		createargs,	diropres, 0),
+    PROC(RMDIR,		diropargs,	stat, 0),
+    PROC(READDIR,	readdirargs,	readdirres, 3),
+    PROC(STATFS,	fhandle,	statfsres, 0),
 };
 
 struct rpc_version		nfs_version2 = {
diff -u --recursive --new-file linux-2.5.47/fs/nfs/nfs3proc.c linux-2.5.47-01-rpc_msg/fs/nfs/nfs3proc.c
--- linux-2.5.47/fs/nfs/nfs3proc.c	2002-11-08 15:40:48.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/nfs/nfs3proc.c	2002-11-13 09:59:23.000000000 -0500
@@ -19,6 +19,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
+extern struct rpc_procinfo nfs3_procedures[];
+
 /* A wrapper to handle the EJUKEBOX error message */
 static int
 nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
@@ -42,7 +44,7 @@
 nfs3_rpc_call_wrapper(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp, int flags)
 {
 	struct rpc_message msg = {
-		.rpc_proc	= proc,
+		.rpc_proc	= &nfs3_procedures[proc],
 		.rpc_argp	= argp,
 		.rpc_resp	= resp,
 	};
@@ -156,7 +158,7 @@
 		.fattr		= &fattr,
 	};
 	struct rpc_message msg = {
-		.rpc_proc	= NFS3PROC_ACCESS,
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_ACCESS],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -227,7 +229,7 @@
 		.count		= count,
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFS3PROC_READ,
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_READ],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -262,7 +264,7 @@
 		.verf		= verf,
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFS3PROC_WRITE,
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_WRITE],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -369,7 +371,7 @@
 		.len		= name->len
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFS3PROC_REMOVE,
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_REMOVE],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &dir_attr,
 	};
@@ -397,7 +399,7 @@
 	arg->name = name->name;
 	arg->len = name->len;
 	res->valid = 0;
-	msg->rpc_proc = NFS3PROC_REMOVE;
+	msg->rpc_proc = &nfs3_procedures[NFS3PROC_REMOVE];
 	msg->rpc_argp = arg;
 	msg->rpc_resp = res;
 	return 0;
@@ -580,7 +582,7 @@
 		.plus		= plus
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFS3PROC_READDIR,
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_READDIR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -590,7 +592,7 @@
 	lock_kernel();
 
 	if (plus)
-		msg.rpc_proc = NFS3PROC_READDIRPLUS;
+		msg.rpc_proc = &nfs3_procedures[NFS3PROC_READDIRPLUS];
 
 	dprintk("NFS call  readdir%s %d\n",
 			plus? "plus" : "", (unsigned int) cookie);
@@ -697,7 +699,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_READ],
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
@@ -718,10 +725,6 @@
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
 
-	msg.rpc_proc = NFS3PROC_READ;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -744,7 +747,12 @@
 	struct nfs_page		*req;
 	int			stable;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_WRITE],
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	if (how & FLUSH_STABLE) {
 		if (!NFS_I(inode)->ncommit)
@@ -774,10 +782,6 @@
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
 
-	msg.rpc_proc = NFS3PROC_WRITE;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -795,7 +799,12 @@
 	struct rpc_task		*task = &data->task;
 	struct inode		*inode = data->inode;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= &nfs3_procedures[NFS3PROC_COMMIT],
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	data->u.v3.args.fh     = NFS_FH(data->inode);
 	data->u.v3.args.offset = start;
@@ -813,10 +822,6 @@
 	/* Release requests */
 	task->tk_release = nfs_commit_release;
 	
-	msg.rpc_proc = NFS3PROC_COMMIT;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
diff -u --recursive --new-file linux-2.5.47/fs/nfs/nfs3xdr.c linux-2.5.47-01-rpc_msg/fs/nfs/nfs3xdr.c
--- linux-2.5.47/fs/nfs/nfs3xdr.c	2002-10-12 19:41:19.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/nfs/nfs3xdr.c	2002-11-13 10:02:49.000000000 -0500
@@ -48,7 +48,6 @@
 #define NFS3_pathconf_sz		
 #define NFS3_entry_sz		NFS3_filename_sz+3
 
-#define NFS3_enc_void_sz	0
 #define NFS3_sattrargs_sz	NFS3_fh_sz+NFS3_sattr_sz+3
 #define NFS3_diropargs_sz	NFS3_fh_sz+NFS3_filename_sz
 #define NFS3_accessargs_sz	NFS3_fh_sz+1
@@ -64,7 +63,6 @@
 #define NFS3_readdirargs_sz	NFS3_fh_sz+2
 #define NFS3_commitargs_sz	NFS3_fh_sz+3
 
-#define NFS3_dec_void_sz	0
 #define NFS3_attrstat_sz	1+NFS3_fattr_sz
 #define NFS3_wccstat_sz		1+NFS3_wcc_data_sz
 #define NFS3_lookupres_sz	1+NFS3_fh_sz+(2 * NFS3_post_op_attr_sz)
@@ -268,15 +266,6 @@
 /*
  * NFS encode functions
  */
-/*
- * Encode void argument
- */
-static int
-nfs3_xdr_enc_void(struct rpc_rqst *req, u32 *p, void *dummy)
-{
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
 
 /*
  * Encode file handle argument
@@ -652,14 +641,6 @@
 /*
  * NFS XDR decode functions
  */
-/*
- * Decode void reply
- */
-static int
-nfs3_xdr_dec_void(struct rpc_rqst *req, u32 *p, void *dummy)
-{
-	return 0;
-}
 
 /*
  * Decode attrstat reply.
@@ -1004,36 +985,36 @@
 #endif
 
 #define PROC(proc, argtype, restype, timer)				\
-    { .p_procname  = "nfs3_" #proc,					\
-      .p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
-      .p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
-      .p_bufsiz    = MAX(NFS3_##argtype##_sz,NFS3_##restype##_sz) << 2,	\
-      .p_timer     = timer						\
-    }
-
-static struct rpc_procinfo	nfs3_procedures[22] = {
-  PROC(null,		enc_void,	dec_void, 0),
-  PROC(getattr,		fhandle,	attrstat, 1),
-  PROC(setattr, 	sattrargs,	wccstat, 0),
-  PROC(lookup,		diropargs,	lookupres, 2),
-  PROC(access,		accessargs,	accessres, 1),
-  PROC(readlink,	readlinkargs,	readlinkres, 3),
-  PROC(read,		readargs,	readres, 3),
-  PROC(write,		writeargs,	writeres, 4),
-  PROC(create,		createargs,	createres, 0),
-  PROC(mkdir,		mkdirargs,	createres, 0),
-  PROC(symlink,		symlinkargs,	createres, 0),
-  PROC(mknod,		mknodargs,	createres, 0),
-  PROC(remove,		diropargs,	wccstat, 0),
-  PROC(rmdir,		diropargs,	wccstat, 0),
-  PROC(rename,		renameargs,	renameres, 0),
-  PROC(link,		linkargs,	linkres, 0),
-  PROC(readdir,		readdirargs,	readdirres, 3),
-  PROC(readdirplus,	readdirargs,	readdirres, 3),
-  PROC(fsstat,		fhandle,	fsstatres, 0),
-  PROC(fsinfo,  	fhandle,	fsinfores, 0),
-  PROC(pathconf,	fhandle,	pathconfres, 0),
-  PROC(commit,		commitargs,	commitres, 5),
+[NFS3PROC_##proc] = {							\
+	.p_proc      = NFS3PROC_##proc,					\
+	.p_encode    = (kxdrproc_t) nfs3_xdr_##argtype,			\
+	.p_decode    = (kxdrproc_t) nfs3_xdr_##restype,			\
+	.p_bufsiz    = MAX(NFS3_##argtype##_sz,NFS3_##restype##_sz) << 2,	\
+	.p_timer     = timer						\
+	}
+
+struct rpc_procinfo	nfs3_procedures[] = {
+  PROC(GETATTR,		fhandle,	attrstat, 1),
+  PROC(SETATTR, 	sattrargs,	wccstat, 0),
+  PROC(LOOKUP,		diropargs,	lookupres, 2),
+  PROC(ACCESS,		accessargs,	accessres, 1),
+  PROC(READLINK,	readlinkargs,	readlinkres, 3),
+  PROC(READ,		readargs,	readres, 3),
+  PROC(WRITE,		writeargs,	writeres, 4),
+  PROC(CREATE,		createargs,	createres, 0),
+  PROC(MKDIR,		mkdirargs,	createres, 0),
+  PROC(SYMLINK,		symlinkargs,	createres, 0),
+  PROC(MKNOD,		mknodargs,	createres, 0),
+  PROC(REMOVE,		diropargs,	wccstat, 0),
+  PROC(RMDIR,		diropargs,	wccstat, 0),
+  PROC(RENAME,		renameargs,	renameres, 0),
+  PROC(LINK,		linkargs,	linkres, 0),
+  PROC(READDIR,		readdirargs,	readdirres, 3),
+  PROC(READDIRPLUS,	readdirargs,	readdirres, 3),
+  PROC(FSSTAT,		fhandle,	fsstatres, 0),
+  PROC(FSINFO,  	fhandle,	fsinfores, 0),
+  PROC(PATHCONF,	fhandle,	pathconfres, 0),
+  PROC(COMMIT,		commitargs,	commitres, 5),
 };
 
 struct rpc_version		nfs_version3 = {
diff -u --recursive --new-file linux-2.5.47/fs/nfs/nfs4proc.c linux-2.5.47-01-rpc_msg/fs/nfs/nfs4proc.c
--- linux-2.5.47/fs/nfs/nfs4proc.c	2002-11-08 15:40:48.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/fs/nfs/nfs4proc.c	2002-11-13 09:58:44.000000000 -0500
@@ -52,6 +52,7 @@
 #define OPNUM(cp)		cp->ops[cp->req_nops].opnum
 
 extern u32 *nfs4_decode_dirent(u32 *p, struct nfs_entry *entry, int plus);
+extern struct rpc_procinfo nfs4_procedures[];
 
 static nfs4_stateid zero_stateid =
   { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 };
@@ -642,7 +643,7 @@
 {
 	int status;
 	struct rpc_message msg = {
-		.rpc_proc = NFSPROC4_COMPOUND,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = cred,
@@ -1106,7 +1107,7 @@
 	nfs4_setup_remove(cp, name, &up->cinfo);
 	nfs4_setup_getattr(cp, &up->attrs, bmres);
 	
-	msg->rpc_proc = NFSPROC4_COMPOUND;
+	msg->rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND];
 	msg->rpc_argp = cp;
 	msg->rpc_resp = cp;
 	return 0;
@@ -1367,7 +1368,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = NFSPROC4_COMPOUND,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1411,7 +1412,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = NFSPROC4_COMPOUND,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1462,7 +1463,7 @@
 	struct rpc_task	*task = &data->task;
 	struct nfs4_compound *cp = &data->u.v4.compound;
 	struct rpc_message msg = {
-		.rpc_proc = NFSPROC4_COMPOUND,
+		.rpc_proc = &nfs4_procedures[NFSPROC4_COMPOUND],
 		.rpc_argp = cp,
 		.rpc_resp = cp,
 		.rpc_cred = data->cred,
@@ -1516,7 +1517,9 @@
 	struct renew_desc *rp;
 	struct rpc_task *task;
 	struct nfs4_compound *cp;
-	struct rpc_message msg;
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs4_procedures[NFSPROC4_COMPOUND],
+	};
 
 	rp = (struct renew_desc *) kmalloc(sizeof(*rp), GFP_KERNEL);
 	if (!rp)
@@ -1527,10 +1530,8 @@
 	nfs4_setup_compound(cp, rp->ops, server, "renew");
 	nfs4_setup_renew(cp);
 	
-	msg.rpc_proc = NFSPROC4_COMPOUND;
 	msg.rpc_argp = cp;
 	msg.rpc_resp = cp;
-	msg.rpc_cred = NULL;
 	rpc_init_task(task, server->client, renew_done, RPC_TASK_ASYNC);
 	rpc_call_setup(task, &msg, 0);
 	task->tk_calldata = rp;
diff -u --recursive --new-file linux-2.5.47/fs/nfs/nfs4xdr.c linux-2.5.47-01-rpc_msg/fs/nfs/nfs4xdr.c
--- linux-2.5.47/fs/nfs/nfs4xdr.c	2002-10-16 08:44:04.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/nfs/nfs4xdr.c	2002-11-13 10:03:03.000000000 -0500
@@ -66,8 +66,6 @@
 
 extern int			nfs_stat_to_errno(int);
 
-#define NFS4_enc_void_sz	0
-#define NFS4_dec_void_sz	0
 #define NFS4_enc_compound_sz	1024  /* XXX: large enough? */
 #define NFS4_dec_compound_sz	1024  /* XXX: large enough? */
 
@@ -722,6 +720,7 @@
 	ENCODE_TAIL;
 }
 
+/* FIXME: this sucks */
 static int
 encode_compound(struct nfs4_compound *cp, struct rpc_rqst *req)
 {
@@ -826,16 +825,6 @@
 
 
 /*
- * Encode void argument
- */
-static int
-nfs4_xdr_enc_void(struct rpc_rqst *req, u32 *p, void *dummy)
-{
-	req->rq_slen = xdr_adjust_iovec(req->rq_svec, p);
-	return 0;
-}
-
-/*
  * Encode COMPOUND argument
  */
 static int
@@ -1546,6 +1535,7 @@
 	DECODE_TAIL;
 }
 
+/* FIXME: this sucks */
 static int
 decode_compound(struct nfs4_compound *cp, struct rpc_rqst *req)
 {
@@ -1680,15 +1670,6 @@
  */
 
 /*
- * Decode void reply
- */
-static int
-nfs4_xdr_dec_void(struct rpc_rqst *req, u32 *p, void *dummy)
-{
-	return 0;
-}
-
-/*
  * Decode COMPOUND response
  */
 static int
@@ -1753,16 +1734,15 @@
 #endif
 
 #define PROC(proc, argtype, restype)				\
-    { "nfs4_" #proc,						\
-      (kxdrproc_t) nfs4_xdr_##argtype,				\
-      (kxdrproc_t) nfs4_xdr_##restype,				\
-      MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,	\
-      0							\
+[NFSPROC4_##proc] = {						\
+	.p_proc   = NFSPROC4_##proc,				\
+	.p_encode = (kxdrproc_t) nfs4_xdr_##argtype,		\
+	.p_decode = (kxdrproc_t) nfs4_xdr_##restype,		\
+	.p_bufsiz = MAX(NFS4_##argtype##_sz,NFS4_##restype##_sz) << 2,	\
     }
 
-static struct rpc_procinfo	nfs4_procedures[] = {
-  PROC(null,		enc_void,	dec_void),
-  PROC(compound,	enc_compound,	dec_compound)
+struct rpc_procinfo	nfs4_procedures[] = {
+  PROC(COMPOUND,	enc_compound,	dec_compound)
 };
 
 struct rpc_version		nfs_version4 = {
diff -u --recursive --new-file linux-2.5.47/fs/nfs/proc.c linux-2.5.47-01-rpc_msg/fs/nfs/proc.c
--- linux-2.5.47/fs/nfs/proc.c	2002-10-16 08:44:29.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/nfs/proc.c	2002-11-13 09:57:48.000000000 -0500
@@ -46,6 +46,8 @@
 
 #define NFSDBG_FACILITY		NFSDBG_PROC
 
+extern struct rpc_procinfo nfs_procedures[];
+
 /*
  * Bare-bones access to getattr: this is for nfs_read_super.
  */
@@ -153,7 +155,7 @@
 		.count		= count
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFSPROC_READ,
+		.rpc_proc	= &nfs_procedures[NFSPROC_READ],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -190,7 +192,7 @@
 		.count		= count
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFSPROC_WRITE,
+		.rpc_proc	= &nfs_procedures[NFSPROC_WRITE],
 		.rpc_argp	= &arg,
 		.rpc_resp	= &res,
 		.rpc_cred	= cred
@@ -282,7 +284,7 @@
 		.len		= name->len
 	};
 	struct rpc_message	msg = { 
-		.rpc_proc	= NFSPROC_REMOVE,
+		.rpc_proc	= &nfs_procedures[NFSPROC_REMOVE],
 		.rpc_argp	= &arg,
 		.rpc_resp	= NULL,
 		.rpc_cred	= NULL
@@ -307,7 +309,7 @@
 	arg->fh = NFS_FH(dir->d_inode);
 	arg->name = name->name;
 	arg->len = name->len;
-	msg->rpc_proc = NFSPROC_REMOVE;
+	msg->rpc_proc = &nfs_procedures[NFSPROC_REMOVE];
 	msg->rpc_argp = arg;
 	return 0;
 }
@@ -441,7 +443,7 @@
 		.pages		= &page
 	};
 	struct rpc_message	msg = {
-		.rpc_proc	= NFSPROC_READDIR,
+		.rpc_proc	= &nfs_procedures[NFSPROC_READDIR],
 		.rpc_argp	= &arg,
 		.rpc_resp	= NULL,
 		.rpc_cred	= cred
@@ -532,7 +534,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= &nfs_procedures[NFSPROC_READ],
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 	
 	req = nfs_list_entry(data->pages.next);
 	data->u.v3.args.fh     = NFS_FH(inode);
@@ -553,10 +560,6 @@
 	/* Release requests */
 	task->tk_release = nfs_readdata_release;
 
-	msg.rpc_proc = NFSPROC_READ;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
@@ -575,7 +578,12 @@
 	struct inode		*inode = data->inode;
 	struct nfs_page		*req;
 	int			flags;
-	struct rpc_message	msg;
+	struct rpc_message	msg = {
+		.rpc_proc	= &nfs_procedures[NFSPROC_WRITE],
+		.rpc_argp	= &data->u.v3.args,
+		.rpc_resp	= &data->u.v3.res,
+		.rpc_cred	= data->cred,
+	};
 
 	/* Note: NFSv2 ignores @stable and always uses NFS_FILE_SYNC */
 	
@@ -599,10 +607,6 @@
 	/* Release requests */
 	task->tk_release = nfs_writedata_release;
 
-	msg.rpc_proc = NFSPROC_WRITE;
-	msg.rpc_argp = &data->u.v3.args;
-	msg.rpc_resp = &data->u.v3.res;
-	msg.rpc_cred = data->cred;
 	rpc_call_setup(&data->task, &msg, 0);
 }
 
diff -u --recursive --new-file linux-2.5.47/fs/nfs/unlink.c linux-2.5.47-01-rpc_msg/fs/nfs/unlink.c
--- linux-2.5.47/fs/nfs/unlink.c	2002-10-11 18:22:12.000000000 -0400
+++ linux-2.5.47-01-rpc_msg/fs/nfs/unlink.c	2002-11-13 07:31:50.000000000 -0500
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
diff -u --recursive --new-file linux-2.5.47/include/linux/lockd/debug.h linux-2.5.47-01-rpc_msg/include/linux/lockd/debug.h
--- linux-2.5.47/include/linux/lockd/debug.h	2002-02-05 12:39:41.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/include/linux/lockd/debug.h	2002-11-13 09:12:12.000000000 -0500
@@ -28,10 +28,6 @@
 # define ifdebug(flag)		if (0)
 #endif
 
-#ifdef LOCKD_DEBUG
-char *		  nlm_procname(u32);
-#endif
-
 #endif /* __KERNEL__ */
 
 /*
diff -u --recursive --new-file linux-2.5.47/include/linux/sunrpc/clnt.h linux-2.5.47-01-rpc_msg/include/linux/sunrpc/clnt.h
--- linux-2.5.47/include/linux/sunrpc/clnt.h	2002-11-07 12:25:04.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/include/linux/sunrpc/clnt.h	2002-11-13 09:09:19.000000000 -0500
@@ -87,7 +87,7 @@
  * Procedure information
  */
 struct rpc_procinfo {
-	char *			p_procname;	/* procedure name */
+	u32			p_proc;		/* RPC procedure number */
 	kxdrproc_t		p_encode;	/* XDR encode function */
 	kxdrproc_t		p_decode;	/* XDR decode function */
 	unsigned int		p_bufsiz;	/* req. buffer size */
@@ -95,13 +95,6 @@
 	unsigned int		p_timer;	/* Which RTT timer to use */
 };
 
-#define rpcproc_bufsiz(clnt, proc)	((clnt)->cl_procinfo[proc].p_bufsiz)
-#define rpcproc_encode(clnt, proc)	((clnt)->cl_procinfo[proc].p_encode)
-#define rpcproc_decode(clnt, proc)	((clnt)->cl_procinfo[proc].p_decode)
-#define rpcproc_name(clnt, proc)	((clnt)->cl_procinfo[proc].p_procname)
-#define rpcproc_count(clnt, proc)	((clnt)->cl_procinfo[proc].p_count)
-#define rpcproc_timer(clnt, proc)	((clnt)->cl_procinfo[proc].p_timer)
-
 #define RPC_CONGESTED(clnt)	(RPCXPRT_CONGESTED((clnt)->cl_xprt))
 #define RPC_PEERADDR(clnt)	(&(clnt)->cl_xprt->addr)
 
@@ -131,7 +124,7 @@
 int rpc_call(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp, int flags)
 {
 	struct rpc_message msg = {
-		.rpc_proc	= proc,
+		.rpc_proc	= &clnt->cl_procinfo[proc],
 		.rpc_argp	= argp,
 		.rpc_resp	= resp,
 		.rpc_cred	= NULL
diff -u --recursive --new-file linux-2.5.47/include/linux/sunrpc/sched.h linux-2.5.47-01-rpc_msg/include/linux/sunrpc/sched.h
--- linux-2.5.47/include/linux/sunrpc/sched.h	2002-11-08 20:22:24.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/include/linux/sunrpc/sched.h	2002-11-13 07:34:36.000000000 -0500
@@ -16,8 +16,9 @@
 /*
  * This is the actual RPC procedure call info.
  */
+struct rpc_procinfo;
 struct rpc_message {
-	__u32			rpc_proc;	/* Procedure number */
+	struct rpc_procinfo *	rpc_proc;	/* Procedure information */
 	void *			rpc_argp;	/* Arguments */
 	void *			rpc_resp;	/* Result */
 	struct rpc_cred *	rpc_cred;	/* Credentials */
diff -u --recursive --new-file linux-2.5.47/net/sunrpc/clnt.c linux-2.5.47-01-rpc_msg/net/sunrpc/clnt.c
--- linux-2.5.47/net/sunrpc/clnt.c	2002-11-08 20:50:06.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/net/sunrpc/clnt.c	2002-11-13 10:06:23.000000000 -0500
@@ -379,20 +379,12 @@
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 
-	if (task->tk_msg.rpc_proc > clnt->cl_maxproc) {
-		printk(KERN_ERR "%s (vers %d): bad procedure number %d\n",
-				clnt->cl_protname, clnt->cl_vers,
-				task->tk_msg.rpc_proc);
-		rpc_exit(task, -EIO);
-		return;
-	}
-
 	dprintk("RPC: %4d call_start %s%d proc %d (%s)\n", task->tk_pid,
-		clnt->cl_protname, clnt->cl_vers, task->tk_msg.rpc_proc,
+		clnt->cl_protname, clnt->cl_vers, task->tk_msg.rpc_proc->p_proc,
 		(RPC_IS_ASYNC(task) ? "async" : "sync"));
 
 	/* Increment call count */
-	rpcproc_count(clnt, task->tk_msg.rpc_proc)++;
+	task->tk_msg.rpc_proc->p_count++;
 	clnt->cl_stats->rpccnt++;
 	task->tk_action = call_reserve;
 }
@@ -474,7 +466,6 @@
 static void
 call_allocate(struct rpc_task *task)
 {
-	struct rpc_clnt	*clnt = task->tk_client;
 	unsigned int	bufsiz;
 
 	dprintk("RPC: %4d call_allocate (status %d)\n", 
@@ -485,7 +476,7 @@
 
 	/* FIXME: compute buffer requirements more exactly using
 	 * auth->au_wslack */
-	bufsiz = rpcproc_bufsiz(clnt, task->tk_msg.rpc_proc) + RPC_SLACK_SPACE;
+	bufsiz = task->tk_msg.rpc_proc->p_bufsiz + RPC_SLACK_SPACE;
 
 	if (rpc_malloc(task, bufsiz << 1) != NULL)
 		return;
@@ -538,7 +529,7 @@
 	memset(task->tk_buffer, 0, bufsiz);
 
 	/* Encode header and provided arguments */
-	encode = rpcproc_encode(clnt, task->tk_msg.rpc_proc);
+	encode = task->tk_msg.rpc_proc->p_encode;
 	if (!(p = call_header(task))) {
 		printk(KERN_INFO "RPC: call_header failed, exit EIO\n");
 		rpc_exit(task, -EIO);
@@ -620,8 +611,6 @@
 static void
 call_transmit(struct rpc_task *task)
 {
-	struct rpc_clnt	*clnt = task->tk_client;
-
 	dprintk("RPC: %4d call_transmit (status %d)\n", 
 				task->tk_pid, task->tk_status);
 
@@ -629,7 +618,7 @@
 	if (task->tk_status < 0)
 		return;
 	xprt_transmit(task);
-	if (!rpcproc_decode(clnt, task->tk_msg.rpc_proc) && task->tk_status >= 0) {
+	if (!task->tk_msg.rpc_proc->p_decode && task->tk_status >= 0) {
 		task->tk_action = NULL;
 		rpc_wake_up_task(task);
 	}
@@ -732,7 +721,7 @@
 {
 	struct rpc_clnt	*clnt = task->tk_client;
 	struct rpc_rqst	*req = task->tk_rqstp;
-	kxdrproc_t	decode = rpcproc_decode(clnt, task->tk_msg.rpc_proc);
+	kxdrproc_t	decode = task->tk_msg.rpc_proc->p_decode;
 	u32		*p;
 
 	dprintk("RPC: %4d call_decode (status %d)\n", 
@@ -832,7 +821,7 @@
 	*p++ = htonl(RPC_VERSION);	/* RPC version */
 	*p++ = htonl(clnt->cl_prog);	/* program number */
 	*p++ = htonl(clnt->cl_vers);	/* program version */
-	*p++ = htonl(task->tk_msg.rpc_proc);	/* procedure */
+	*p++ = htonl(task->tk_msg.rpc_proc->p_proc);	/* procedure */
 	return rpcauth_marshcred(task, p);
 }
 
diff -u --recursive --new-file linux-2.5.47/net/sunrpc/pmap_clnt.c linux-2.5.47-01-rpc_msg/net/sunrpc/pmap_clnt.c
--- linux-2.5.47/net/sunrpc/pmap_clnt.c	2002-11-07 12:25:04.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/net/sunrpc/pmap_clnt.c	2002-11-13 10:08:03.000000000 -0500
@@ -28,6 +28,7 @@
 #define PMAP_UNSET		2
 #define PMAP_GETPORT		3
 
+static struct rpc_procinfo	pmap_procedures[];
 static struct rpc_clnt *	pmap_create(char *, struct sockaddr_in *, int);
 static void			pmap_getport_done(struct rpc_task *);
 extern struct rpc_program	pmap_program;
@@ -43,7 +44,7 @@
 	struct rpc_portmap *map = &clnt->cl_pmap;
 	struct sockaddr_in *sap = &clnt->cl_xprt->addr;
 	struct rpc_message msg = {
-		.rpc_proc	= PMAP_GETPORT,
+		.rpc_proc	= &pmap_procedures[PMAP_GETPORT],
 		.rpc_argp	= map,
 		.rpc_resp	= &clnt->cl_port,
 		.rpc_cred	= NULL
@@ -219,12 +220,6 @@
  * XDR encode/decode functions for PMAP
  */
 static int
-xdr_error(struct rpc_rqst *req, u32 *p, void *dummy)
-{
-	return -EIO;
-}
-
-static int
 xdr_encode_mapping(struct rpc_rqst *req, u32 *p, struct rpc_portmap *map)
 {
 	dprintk("RPC: xdr_encode_mapping(%d, %d, %d, %d)\n",
@@ -252,26 +247,23 @@
 	return 0;
 }
 
-static struct rpc_procinfo	pmap_procedures[4] = {
-	{ .p_procname		= "pmap_null",
-	  .p_encode		= (kxdrproc_t) xdr_error,	
-	  .p_decode		= (kxdrproc_t) xdr_error,
-	  .p_bufsiz		= 0,
-	  .p_count		= 0,
-	},
-	{ .p_procname		= "pmap_set",
+static struct rpc_procinfo	pmap_procedures[] = {
+[PMAP_SET] = {
+	  .p_proc		= PMAP_SET,
 	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,	
 	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
 	  .p_bufsiz		= 4,
 	  .p_count		= 1,
 	},
-	{ .p_procname		= "pmap_unset",
+[PMAP_UNSET] = {
+	  .p_proc		= PMAP_UNSET,
 	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,	
 	  .p_decode		= (kxdrproc_t) xdr_decode_bool,
 	  .p_bufsiz		= 4,
 	  .p_count		= 1,
 	},
-	{ .p_procname		= "pmap_get",
+[PMAP_GETPORT] = {
+	  .p_proc		= PMAP_GETPORT,
 	  .p_encode		= (kxdrproc_t) xdr_encode_mapping,
 	  .p_decode		= (kxdrproc_t) xdr_decode_port,
 	  .p_bufsiz		= 4,
diff -u --recursive --new-file linux-2.5.47/net/sunrpc/sched.c linux-2.5.47-01-rpc_msg/net/sunrpc/sched.c
--- linux-2.5.47/net/sunrpc/sched.c	2002-11-08 20:47:26.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/net/sunrpc/sched.c	2002-11-13 10:09:37.000000000 -0500
@@ -1123,7 +1123,8 @@
 		"-rpcwait -action- --exit--\n");
 	alltask_for_each(t, le, &all_tasks)
 		printk("%05d %04d %04x %06d %8p %6d %8p %08ld %8s %8p %8p\n",
-			t->tk_pid, t->tk_msg.rpc_proc, t->tk_flags, t->tk_status,
+			t->tk_pid, t->tk_msg.rpc_proc->p_proc,
+			t->tk_flags, t->tk_status,
 			t->tk_client, t->tk_client->cl_prog,
 			t->tk_rqstp, t->tk_timeout,
 			t->tk_rpcwait ? rpc_qname(t->tk_rpcwait) : " <NULL> ",
diff -u --recursive --new-file linux-2.5.47/net/sunrpc/xprt.c linux-2.5.47-01-rpc_msg/net/sunrpc/xprt.c
--- linux-2.5.47/net/sunrpc/xprt.c	2002-11-08 19:24:34.000000000 -0500
+++ linux-2.5.47-01-rpc_msg/net/sunrpc/xprt.c	2002-11-13 07:51:46.000000000 -0500
@@ -585,7 +585,7 @@
 		__xprt_put_cong(xprt, req);
 	       	if (!req->rq_nresend) {
 			unsigned timer =
-				rpcproc_timer(clnt, task->tk_msg.rpc_proc);
+				task->tk_msg.rpc_proc->p_timer;
 			if (timer)
 				rpc_update_rtt(&clnt->cl_rtt, timer,
 						(long)jiffies - req->rq_xtime);
@@ -1223,7 +1223,7 @@
 	/* Set the task's receive timeout value */
 	if (!xprt->nocong) {
 		task->tk_timeout = rpc_calc_rto(&clnt->cl_rtt,
-				rpcproc_timer(clnt, task->tk_msg.rpc_proc));
+				task->tk_msg.rpc_proc->p_timer);
 		req->rq_ntimeo = 0;
 		if (task->tk_timeout > req->rq_timeout.to_maxval)
 			task->tk_timeout = req->rq_timeout.to_maxval;


-------------------------------------------------------
This sf.net email is sponsored by: To learn the basics of securing 
your web site with SSL, click here to get a FREE TRIAL of a Thawte 
Server Certificate: http://www.gothawte.com/rd524.html
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
