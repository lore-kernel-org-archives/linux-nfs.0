From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [2/7]
Date: Thu, 31 Oct 2002 21:20:25 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.37001.970472.707535@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187Lnx-0003VS-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:20:37 -0800
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


Clean up RPC credcache lookups.

   - Provide support for looking up credentials other than for
     current->task.

Cheers,
  Trond

diff -u --recursive --new-file linux-2.5.44-01-auth/include/linux/sunrpc/auth.h linux-2.5.44-02-auth2/include/linux/sunrpc/auth.h
--- linux-2.5.44-01-auth/include/linux/sunrpc/auth.h	2002-10-30 18:42:34.000000000 -0500
+++ linux-2.5.44-02-auth2/include/linux/sunrpc/auth.h	2002-10-30 19:55:00.000000000 -0500
@@ -19,6 +19,14 @@
 /* size of the nodename buffer */
 #define UNX_MAXNODENAME	32
 
+/* Work around the lack of a VFS credential */
+struct auth_cred {
+	uid_t	uid;
+	gid_t	gid;
+	int	ngroups;
+	gid_t	*groups;
+};
+
 /*
  * Client user credentials
  */
@@ -74,13 +82,13 @@
 	struct rpc_auth *	(*create)(struct rpc_clnt *);
 	void			(*destroy)(struct rpc_auth *);
 
-	struct rpc_cred *	(*crcreate)(int);
+	struct rpc_cred *	(*crcreate)(struct auth_cred *, int);
 };
 
 struct rpc_credops {
 	void			(*crdestroy)(struct rpc_cred *);
 
-	int			(*crmatch)(struct rpc_cred *, int);
+	int			(*crmatch)(struct auth_cred *, struct rpc_cred *, int);
 	u32 *			(*crmarshal)(struct rpc_task *, u32 *, int);
 	int			(*crrefresh)(struct rpc_task *);
 	u32 *			(*crvalidate)(struct rpc_task *, u32 *);
diff -u --recursive --new-file linux-2.5.44-01-auth/net/sunrpc/auth.c linux-2.5.44-02-auth2/net/sunrpc/auth.c
--- linux-2.5.44-01-auth/net/sunrpc/auth.c	2002-10-30 20:31:37.000000000 -0500
+++ linux-2.5.44-02-auth2/net/sunrpc/auth.c	2002-10-30 20:30:40.000000000 -0500
@@ -174,7 +174,8 @@
  * Look up a process' credentials in the authentication cache
  */
 static struct rpc_cred *
-rpcauth_lookup_credcache(struct rpc_auth *auth, int taskflags)
+rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
+		int taskflags)
 {
 	LIST_HEAD(free);
 	struct list_head *pos, *next;
@@ -183,7 +184,7 @@
 	int		nr = 0;
 
 	if (!(taskflags & RPC_TASK_ROOTCREDS))
-		nr = current->uid & RPC_CREDCACHE_MASK;
+		nr = acred->uid & RPC_CREDCACHE_MASK;
 retry:
 	spin_lock(&rpc_credcache_lock);
 	if (time_before(auth->au_nextgc, jiffies))
@@ -195,7 +196,7 @@
 			continue;
 		if (rpcauth_prune_expired(entry, &free))
 			continue;
-		if (entry->cr_ops->crmatch(entry, taskflags)) {
+		if (entry->cr_ops->crmatch(acred, entry, taskflags)) {
 			list_del(&entry->cr_hash);
 			cred = entry;
 			break;
@@ -217,7 +218,7 @@
 	rpcauth_destroy_credlist(&free);
 
 	if (!cred) {
-		new = auth->au_ops->crcreate(taskflags);
+		new = auth->au_ops->crcreate(acred, taskflags);
 		if (new) {
 #ifdef RPC_DEBUG
 			new->cr_magic = RPCAUTH_CRED_MAGIC;
@@ -232,19 +233,31 @@
 struct rpc_cred *
 rpcauth_lookupcred(struct rpc_auth *auth, int taskflags)
 {
+	struct auth_cred acred = {
+		.uid = current->fsuid,
+		.gid = current->fsgid,
+		.ngroups = current->ngroups,
+		.groups = current->groups,
+	};
 	dprintk("RPC:     looking up %s cred\n",
 		auth->au_ops->au_name);
-	return rpcauth_lookup_credcache(auth, taskflags);
+	return rpcauth_lookup_credcache(auth, &acred, taskflags);
 }
 
 struct rpc_cred *
 rpcauth_bindcred(struct rpc_task *task)
 {
 	struct rpc_auth *auth = task->tk_auth;
+	struct auth_cred acred = {
+		.uid = current->fsuid,
+		.gid = current->fsgid,
+		.ngroups = current->ngroups,
+		.groups = current->groups,
+	};
 
 	dprintk("RPC: %4d looking up %s cred\n",
 		task->tk_pid, task->tk_auth->au_ops->au_name);
-	task->tk_msg.rpc_cred = rpcauth_lookup_credcache(auth, task->tk_flags);
+	task->tk_msg.rpc_cred = rpcauth_lookup_credcache(auth, &acred, task->tk_flags);
 	if (task->tk_msg.rpc_cred == 0)
 		task->tk_status = -ENOMEM;
 	return task->tk_msg.rpc_cred;
diff -u --recursive --new-file linux-2.5.44-01-auth/net/sunrpc/auth_null.c linux-2.5.44-02-auth2/net/sunrpc/auth_null.c
--- linux-2.5.44-01-auth/net/sunrpc/auth_null.c	2002-10-07 10:44:54.000000000 -0400
+++ linux-2.5.44-02-auth2/net/sunrpc/auth_null.c	2002-10-30 19:42:20.000000000 -0500
@@ -48,7 +48,7 @@
  * Create NULL creds for current process
  */
 static struct rpc_cred *
-nul_create_cred(int flags)
+nul_create_cred(struct auth_cred *acred, int flags)
 {
 	struct rpc_cred	*cred;
 
@@ -56,7 +56,7 @@
 		return NULL;
 	atomic_set(&cred->cr_count, 0);
 	cred->cr_flags = RPCAUTH_CRED_UPTODATE;
-	cred->cr_uid = current->uid;
+	cred->cr_uid = acred->uid;
 	cred->cr_ops = &null_credops;
 
 	return cred;
@@ -75,7 +75,7 @@
  * Match cred handle against current process
  */
 static int
-nul_match(struct rpc_cred *cred, int taskflags)
+nul_match(struct auth_cred *acred, struct rpc_cred *cred, int taskflags)
 {
 	return 1;
 }
diff -u --recursive --new-file linux-2.5.44-01-auth/net/sunrpc/auth_unix.c linux-2.5.44-02-auth2/net/sunrpc/auth_unix.c
--- linux-2.5.44-01-auth/net/sunrpc/auth_unix.c	2002-10-07 10:44:54.000000000 -0400
+++ linux-2.5.44-02-auth2/net/sunrpc/auth_unix.c	2002-10-30 20:03:08.000000000 -0500
@@ -14,10 +14,12 @@
 #include <linux/sunrpc/auth.h>
 
 #define NFS_NGROUPS	16
+
 struct unx_cred {
 	struct rpc_cred		uc_base;
-	uid_t			uc_fsuid;
-	gid_t			uc_gid, uc_fsgid;
+	gid_t			uc_gid;
+	uid_t			uc_puid;		/* process uid */
+	gid_t			uc_pgid;		/* process gid */
 	gid_t			uc_gids[NFS_NGROUPS];
 };
 #define uc_uid			uc_base.cr_uid
@@ -62,13 +64,13 @@
 }
 
 static struct rpc_cred *
-unx_create_cred(int flags)
+unx_create_cred(struct auth_cred *acred, int flags)
 {
 	struct unx_cred	*cred;
 	int		i;
 
 	dprintk("RPC:      allocating UNIX cred for uid %d gid %d\n",
-				current->uid, current->gid);
+				acred->uid, acred->gid);
 
 	if (!(cred = (struct unx_cred *) rpc_allocate(flags, sizeof(*cred))))
 		return NULL;
@@ -76,20 +78,20 @@
 	atomic_set(&cred->uc_count, 0);
 	cred->uc_flags = RPCAUTH_CRED_UPTODATE;
 	if (flags & RPC_TASK_ROOTCREDS) {
-		cred->uc_uid = cred->uc_fsuid = 0;
-		cred->uc_gid = cred->uc_fsgid = 0;
+		cred->uc_uid = cred->uc_puid = 0;
+		cred->uc_gid = cred->uc_pgid = 0;
 		cred->uc_gids[0] = NOGROUP;
 	} else {
-		int groups = current->ngroups;
+		int groups = acred->ngroups;
 		if (groups > NFS_NGROUPS)
 			groups = NFS_NGROUPS;
 
-		cred->uc_uid = current->uid;
-		cred->uc_gid = current->gid;
-		cred->uc_fsuid = current->fsuid;
-		cred->uc_fsgid = current->fsgid;
+		cred->uc_uid = acred->uid;
+		cred->uc_gid = acred->gid;
+		cred->uc_puid = current->uid;
+		cred->uc_pgid = current->gid;
 		for (i = 0; i < groups; i++)
-			cred->uc_gids[i] = (gid_t) current->groups[i];
+			cred->uc_gids[i] = (gid_t) acred->groups[i];
 		if (i < NFS_NGROUPS)
 		  cred->uc_gids[i] = NOGROUP;
 	}
@@ -98,28 +100,6 @@
 	return (struct rpc_cred *) cred;
 }
 
-struct rpc_cred *
-authunix_fake_cred(struct rpc_task *task, uid_t uid, gid_t gid)
-{
-	struct unx_cred	*cred;
-
-	dprintk("RPC:      allocating fake UNIX cred for uid %d gid %d\n",
-				uid, gid);
-
-	if (!(cred = (struct unx_cred *) rpc_malloc(task, sizeof(*cred))))
-		return NULL;
-
-	atomic_set(&cred->uc_count, 1);
-	cred->uc_flags = RPCAUTH_CRED_DEAD|RPCAUTH_CRED_UPTODATE;
-	cred->uc_uid   = uid;
-	cred->uc_gid   = gid;
-	cred->uc_fsuid = uid;
-	cred->uc_fsgid = gid;
-	cred->uc_gids[0] = (gid_t) NOGROUP;
-
-	return task->tk_msg.rpc_cred = (struct rpc_cred *) cred;
-}
-
 static void
 unx_destroy_cred(struct rpc_cred *cred)
 {
@@ -132,7 +112,7 @@
  * request root creds (e.g. for NFS swapping).
  */
 static int
-unx_match(struct rpc_cred *rcred, int taskflags)
+unx_match(struct auth_cred *acred, struct rpc_cred *rcred, int taskflags)
 {
 	struct unx_cred	*cred = (struct unx_cred *) rcred;
 	int		i;
@@ -140,22 +120,22 @@
 	if (!(taskflags & RPC_TASK_ROOTCREDS)) {
 		int groups;
 
-		if (cred->uc_uid != current->uid
-		 || cred->uc_gid != current->gid
-		 || cred->uc_fsuid != current->fsuid
-		 || cred->uc_fsgid != current->fsgid)
+		if (cred->uc_uid != acred->uid
+		 || cred->uc_gid != acred->gid
+		 || cred->uc_puid != current->uid
+		 || cred->uc_pgid != current->gid)
 			return 0;
 
-		groups = current->ngroups;
+		groups = acred->ngroups;
 		if (groups > NFS_NGROUPS)
 			groups = NFS_NGROUPS;
 		for (i = 0; i < groups ; i++)
-			if (cred->uc_gids[i] != (gid_t) current->groups[i])
+			if (cred->uc_gids[i] != (gid_t) acred->groups[i])
 				return 0;
 		return 1;
 	}
-	return (cred->uc_uid == 0 && cred->uc_fsuid == 0
-	     && cred->uc_gid == 0 && cred->uc_fsgid == 0
+	return (cred->uc_uid == 0 && cred->uc_puid == 0
+	     && cred->uc_gid == 0 && cred->uc_pgid == 0
 	     && cred->uc_gids[0] == (gid_t) NOGROUP);
 }
 
@@ -184,12 +164,12 @@
 	p += (n + 3) >> 2;
 
 	/* Note: we don't use real uid if it involves raising priviledge */
-	if (ruid && cred->uc_uid != 0 && cred->uc_gid != 0) {
+	if (ruid && cred->uc_puid != 0 && cred->uc_pgid != 0) {
+		*p++ = htonl((u32) cred->uc_puid);
+		*p++ = htonl((u32) cred->uc_pgid);
+	} else {
 		*p++ = htonl((u32) cred->uc_uid);
 		*p++ = htonl((u32) cred->uc_gid);
-	} else {
-		*p++ = htonl((u32) cred->uc_fsuid);
-		*p++ = htonl((u32) cred->uc_fsgid);
 	}
 	hold = p++;
 	for (i = 0; i < 16 && cred->uc_gids[i] != (gid_t) NOGROUP; i++)


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
