From: Frank van Maarseveen <frankvm@frankvm.com>
Subject: [PATCH 2.6.11-rc4+NFS_ALL 1/1]: tidy up nfs3proc.c
Date: Thu, 17 Feb 2005 20:37:05 +0100
Message-ID: <20050217193705.GA2158@janus>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="huq684BweRXVnRxX"
Cc: Linux NFS mailing list <nfs@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.12] helo=sc8-sf-mx2.sourceforge.net)
	by sc8-sf-list2.sourceforge.net with esmtp (Exim 4.30)
	id 1D1rSi-0006kk-GF
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 11:37:20 -0800
Received: from frankvm.xs4all.nl ([80.126.170.174] helo=janus.localdomain)
	by sc8-sf-mx2.sourceforge.net with esmtp (Exim 4.41)
	id 1D1rSe-0006Ta-PY
	for nfs@lists.sourceforge.net; Thu, 17 Feb 2005 11:37:20 -0800
To: Trond Myklebust <trond.myklebust@fys.uio.no>
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


--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Remove function style macros hiding real functions. Reduce the number
of functions which instantiate a struct rpc_message.

Signed-off-by: Frank van Maarseveen <frankvm@frankvm.com>

-- 
Frank

--huq684BweRXVnRxX
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline; filename="nfs3proc-cleanup.patch"

--- ./fs/nfs/nfs3proc.c.orig	2005-02-17 19:57:55.000000000 +0100
+++ ./fs/nfs/nfs3proc.c	2005-02-17 20:01:08.000000000 +0100
@@ -24,13 +24,21 @@
 
 /* A wrapper to handle the EJUKEBOX error message */
 static int
-nfs3_rpc_wrapper(struct rpc_clnt *clnt, struct rpc_message *msg, int flags)
+nfs3_rpc_call(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp,
+	      struct rpc_cred *cred, int flags)
 {
-	sigset_t oldset;
-	int res;
+	struct rpc_message msg = {
+		.rpc_proc	= &nfs3_procedures[proc],
+		.rpc_argp	= argp,
+		.rpc_resp	= resp,
+		.rpc_cred	= cred,
+	};
+	sigset_t		oldset;
+	int			res;
+
 	rpc_clnt_sigmask(clnt, &oldset);
 	do {
-		res = rpc_call_sync(clnt, msg, flags);
+		res = rpc_call_sync(clnt, &msg, flags);
 		if (res != -EJUKEBOX)
 			break;
 		set_current_state(TASK_INTERRUPTIBLE);
@@ -41,22 +49,12 @@
 	return res;
 }
 
-static inline int
-nfs3_rpc_call_wrapper(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp, int flags)
+static __inline__ int
+nfs3_rpc(struct rpc_clnt *clnt, u32 proc, void *argp, void *resp)
 {
-	struct rpc_message msg = {
-		.rpc_proc	= &nfs3_procedures[proc],
-		.rpc_argp	= argp,
-		.rpc_resp	= resp,
-	};
-	return nfs3_rpc_wrapper(clnt, &msg, flags);
+	return nfs3_rpc_call(clnt, proc, argp, resp, NULL, 0);
 }
 
-#define rpc_call(clnt, proc, argp, resp, flags) \
-		nfs3_rpc_call_wrapper(clnt, proc, argp, resp, flags)
-#define rpc_call_sync(clnt, msg, flags) \
-		nfs3_rpc_wrapper(clnt, msg, flags)
-
 static int
 nfs3_async_handle_jukebox(struct rpc_task *task)
 {
@@ -79,10 +77,10 @@
 
 	dprintk("%s: call  fsinfo\n", __FUNCTION__);
 	info->fattr->valid = 0;
-	status = rpc_call(server->client_sys, NFS3PROC_FSINFO, fhandle, info, 0);
+	status = nfs3_rpc(server->client_sys, NFS3PROC_FSINFO, fhandle, info);
 	dprintk("%s: reply fsinfo: %d\n", __FUNCTION__, status);
 	if (!(info->fattr->valid & NFS_ATTR_FATTR)) {
-		status = rpc_call(server->client_sys, NFS3PROC_GETATTR, fhandle, info->fattr, 0);
+		status = nfs3_rpc(server->client_sys, NFS3PROC_GETATTR, fhandle, info->fattr);
 		dprintk("%s: reply getattr: %d\n", __FUNCTION__, status);
 	}
 	return status;
@@ -99,8 +97,7 @@
 
 	dprintk("NFS call  getattr\n");
 	fattr->valid = 0;
-	status = rpc_call(server->client, NFS3PROC_GETATTR,
-			  fhandle, fattr, 0);
+	status = nfs3_rpc(server->client, NFS3PROC_GETATTR, fhandle, fattr);
 	dprintk("NFS reply getattr: %d\n", status);
 	return status;
 }
@@ -118,7 +115,7 @@
 
 	dprintk("NFS call  setattr\n");
 	fattr->valid = 0;
-	status = rpc_call(NFS_CLIENT(inode), NFS3PROC_SETATTR, &arg, fattr, 0);
+	status = nfs3_rpc(NFS_CLIENT(inode), NFS3PROC_SETATTR, &arg, fattr);
 	dprintk("NFS reply setattr: %d\n", status);
 	return status;
 }
@@ -143,10 +140,10 @@
 	dprintk("NFS call  lookup %s\n", name->name);
 	dir_attr.valid = 0;
 	fattr->valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_LOOKUP, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_LOOKUP, &arg, &res);
 	if (status >= 0 && !(fattr->valid & NFS_ATTR_FATTR))
-		status = rpc_call(NFS_CLIENT(dir), NFS3PROC_GETATTR,
-			 fhandle, fattr, 0);
+		status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_GETATTR,
+				  fhandle, fattr);
 	dprintk("NFS reply lookup: %d\n", status);
 	if (status >= 0)
 		status = nfs_refresh_inode(dir, &dir_attr);
@@ -162,12 +159,6 @@
 	struct nfs3_accessres	res = {
 		.fattr		= &fattr,
 	};
-	struct rpc_message msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_ACCESS],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
-		.rpc_cred	= entry->cred
-	};
 	int mode = entry->mask;
 	int status;
 
@@ -187,7 +178,8 @@
 		if (mode & MAY_EXEC)
 			arg.access |= NFS3_ACCESS_EXECUTE;
 	}
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	status = nfs3_rpc_call(NFS_CLIENT(inode), NFS3PROC_ACCESS,
+			  &arg, &res, entry->cred, 0);
 	nfs_refresh_inode(inode, &fattr);
 	if (status == 0) {
 		entry->mask = 0;
@@ -216,8 +208,7 @@
 
 	dprintk("NFS call  readlink\n");
 	fattr.valid = 0;
-	status = rpc_call(NFS_CLIENT(inode), NFS3PROC_READLINK,
-			  &args, &fattr, 0);
+	status = nfs3_rpc(NFS_CLIENT(inode), NFS3PROC_READLINK, &args, &fattr);
 	nfs_refresh_inode(inode, &fattr);
 	dprintk("NFS reply readlink: %d\n", status);
 	return status;
@@ -228,18 +219,13 @@
 	int			flags = rdata->flags;
 	struct inode *		inode = rdata->inode;
 	struct nfs_fattr *	fattr = rdata->res.fattr;
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_READ],
-		.rpc_argp	= &rdata->args,
-		.rpc_resp	= &rdata->res,
-		.rpc_cred	= rdata->cred,
-	};
 	int			status;
 
 	dprintk("NFS call  read %d @ %Ld\n", rdata->args.count,
 			(long long) rdata->args.offset);
 	fattr->valid = 0;
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, flags);
+	status = nfs3_rpc_call(NFS_CLIENT(inode), NFS3PROC_READ,
+			  &rdata->args, &rdata->res, rdata->cred, flags);
 	if (status >= 0)
 		nfs_refresh_inode(inode, fattr);
 	dprintk("NFS reply read: %d\n", status);
@@ -251,18 +237,13 @@
 	int			rpcflags = wdata->flags;
 	struct inode *		inode = wdata->inode;
 	struct nfs_fattr *	fattr = wdata->res.fattr;
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_WRITE],
-		.rpc_argp	= &wdata->args,
-		.rpc_resp	= &wdata->res,
-		.rpc_cred	= wdata->cred,
-	};
 	int			status;
 
 	dprintk("NFS call  write %d @ %Ld\n", wdata->args.count,
 			(long long) wdata->args.offset);
 	fattr->valid = 0;
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, rpcflags);
+	status = nfs3_rpc_call(NFS_CLIENT(inode), NFS3PROC_WRITE,
+			  &wdata->args, &wdata->res, wdata->cred, rpcflags);
 	if (status >= 0)
 		nfs_refresh_inode(inode, fattr);
 	dprintk("NFS reply write: %d\n", status);
@@ -273,18 +254,13 @@
 {
 	struct inode *		inode = cdata->inode;
 	struct nfs_fattr *	fattr = cdata->res.fattr;
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_COMMIT],
-		.rpc_argp	= &cdata->args,
-		.rpc_resp	= &cdata->res,
-		.rpc_cred	= cdata->cred,
-	};
 	int			status;
 
 	dprintk("NFS call  commit %d @ %Ld\n", cdata->args.count,
 			(long long) cdata->args.offset);
 	fattr->valid = 0;
-	status = rpc_call_sync(NFS_CLIENT(inode), &msg, 0);
+	status = nfs3_rpc_call(NFS_CLIENT(inode), NFS3PROC_COMMIT,
+			  &cdata->args, &cdata->res, cdata->cred, 0);
 	if (status >= 0)
 		nfs_refresh_inode(inode, fattr);
 	dprintk("NFS reply commit: %d\n", status);
@@ -326,7 +302,7 @@
 again:
 	dir_attr.valid = 0;
 	fattr.valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_CREATE, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_CREATE, &arg, &res);
 	nfs_refresh_inode(dir, &dir_attr);
 
 	/* If the server doesn't support the exclusive creation semantics,
@@ -376,8 +352,8 @@
 		 * not sure this buys us anything (and I'd have
 		 * to revamp the NFSv3 XDR code) */
 		fattr.valid = 0;
-		status = rpc_call(NFS_CLIENT(dir), NFS3PROC_SETATTR,
-						&arg, &fattr, 0);
+		status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_SETATTR,
+				  &arg, &fattr);
 		dprintk("NFS reply setattr (post-create): %d\n", status);
 	}
 	if (status == 0) {
@@ -400,16 +376,11 @@
 		.name		= name->name,
 		.len		= name->len
 	};
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_REMOVE],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &dir_attr,
-	};
 	int			status;
 
 	dprintk("NFS call  remove %s\n", name->name);
 	dir_attr.valid = 0;
-	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_REMOVE, &arg, &dir_attr);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply remove: %d\n", status);
 	return status;
@@ -474,7 +445,7 @@
 	dprintk("NFS call  rename %s -> %s\n", old_name->name, new_name->name);
 	old_dir_attr.valid = 0;
 	new_dir_attr.valid = 0;
-	status = rpc_call(NFS_CLIENT(old_dir), NFS3PROC_RENAME, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(old_dir), NFS3PROC_RENAME, &arg, &res);
 	nfs_refresh_inode(old_dir, &old_dir_attr);
 	nfs_refresh_inode(new_dir, &new_dir_attr);
 	dprintk("NFS reply rename: %d\n", status);
@@ -500,7 +471,7 @@
 	dprintk("NFS call  link %s\n", name->name);
 	dir_attr.valid = 0;
 	fattr.valid = 0;
-	status = rpc_call(NFS_CLIENT(inode), NFS3PROC_LINK, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(inode), NFS3PROC_LINK, &arg, &res);
 	nfs_refresh_inode(dir, &dir_attr);
 	nfs_refresh_inode(inode, &fattr);
 	dprintk("NFS reply link: %d\n", status);
@@ -533,7 +504,7 @@
 	dprintk("NFS call  symlink %s -> %s\n", name->name, path->name);
 	dir_attr.valid = 0;
 	fattr->valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_SYMLINK, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_SYMLINK, &arg, &res);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply symlink: %d\n", status);
 	return status;
@@ -560,7 +531,7 @@
 	dprintk("NFS call  mkdir %s\n", name->name);
 	dir_attr.valid = 0;
 	fattr->valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_MKDIR, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_MKDIR, &arg, &res);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply mkdir: %d\n", status);
 	return status;
@@ -579,7 +550,7 @@
 
 	dprintk("NFS call  rmdir %s\n", name->name);
 	dir_attr.valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_RMDIR, &arg, &dir_attr, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_RMDIR, &arg, &dir_attr);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply rmdir: %d\n", status);
 	return status;
@@ -614,24 +585,19 @@
 		.verf		= verf,
 		.plus		= plus
 	};
-	struct rpc_message	msg = {
-		.rpc_proc	= &nfs3_procedures[NFS3PROC_READDIR],
-		.rpc_argp	= &arg,
-		.rpc_resp	= &res,
-		.rpc_cred	= cred
-	};
 	int			status;
+	u32			proc = NFS3PROC_READDIR;
 
 	lock_kernel();
 
 	if (plus)
-		msg.rpc_proc = &nfs3_procedures[NFS3PROC_READDIRPLUS];
+		proc = NFS3PROC_READDIRPLUS;
 
 	dprintk("NFS call  readdir%s %d\n",
 			plus? "plus" : "", (unsigned int) cookie);
 
 	dir_attr.valid = 0;
-	status = rpc_call_sync(NFS_CLIENT(dir), &msg, 0);
+	status = nfs3_rpc_call(NFS_CLIENT(dir), proc, &arg, &res, cred, 0);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply readdir: %d\n", status);
 	unlock_kernel();
@@ -669,7 +635,7 @@
 			MAJOR(rdev), MINOR(rdev));
 	dir_attr.valid = 0;
 	fattr->valid = 0;
-	status = rpc_call(NFS_CLIENT(dir), NFS3PROC_MKNOD, &arg, &res, 0);
+	status = nfs3_rpc(NFS_CLIENT(dir), NFS3PROC_MKNOD, &arg, &res);
 	nfs_refresh_inode(dir, &dir_attr);
 	dprintk("NFS reply mknod: %d\n", status);
 	return status;
@@ -683,7 +649,7 @@
 
 	dprintk("NFS call  fsstat\n");
 	stat->fattr->valid = 0;
-	status = rpc_call(server->client, NFS3PROC_FSSTAT, fhandle, stat, 0);
+	status = nfs3_rpc(server->client, NFS3PROC_FSSTAT, fhandle, stat);
 	dprintk("NFS reply statfs: %d\n", status);
 	return status;
 }
@@ -696,7 +662,7 @@
 
 	dprintk("NFS call  fsinfo\n");
 	info->fattr->valid = 0;
-	status = rpc_call(server->client_sys, NFS3PROC_FSINFO, fhandle, info, 0);
+	status = nfs3_rpc(server->client_sys, NFS3PROC_FSINFO, fhandle, info);
 	dprintk("NFS reply fsinfo: %d\n", status);
 	return status;
 }
@@ -709,7 +675,7 @@
 
 	dprintk("NFS call  pathconf\n");
 	info->fattr->valid = 0;
-	status = rpc_call(server->client, NFS3PROC_PATHCONF, fhandle, info, 0);
+	status = nfs3_rpc(server->client, NFS3PROC_PATHCONF, fhandle, info);
 	dprintk("NFS reply pathconf: %d\n", status);
 	return status;
 }

--huq684BweRXVnRxX--


-------------------------------------------------------
SF email is sponsored by - The IT Product Guide
Read honest & candid reviews on hundreds of IT Products from real users.
Discover which products truly live up to the hype. Start reading now.
http://ads.osdn.com/?ad_id=6595&alloc_id=14396&op=click
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
