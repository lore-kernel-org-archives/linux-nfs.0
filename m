From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: [PATCH] Secure user authentication using RPCSEC_GSS [1/7]
Date: Thu, 31 Oct 2002 21:19:55 +0100
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <15809.36971.71108.598989@charged.uio.no>
Reply-To: trond.myklebust@fys.uio.no
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from pat.uio.no ([129.240.130.16])
	by usw-sf-list1.sourceforge.net with esmtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 187LnR-0003RK-00
	for <nfs@lists.sourceforge.net>; Thu, 31 Oct 2002 12:20:06 -0800
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


Clean up RPC auth credential cache.

  - Convert creds to use list_head rather than singly linked list
    for efficiency.

  - Fix race in rpcauth_lookup_credcache(). Ensure that we only
    create one entry per user.

  - Clean out unused routines rpcauth_remove_credcache() and
    rpcauth_insert_credcache().

  - Perform garbage collection automatically while traversing the
    hashchain.

  - Clean out unused exported symbols.

Cheers,
  Trond


diff -u --recursive --new-file linux-2.5.44-00-fixes/include/linux/sunrpc/auth.h linux-2.5.44-01-auth/include/linux/sunrpc/auth.h
--- linux-2.5.44-00-fixes/include/linux/sunrpc/auth.h	2002-09-18 06:05:34.000000000 -0400
+++ linux-2.5.44-01-auth/include/linux/sunrpc/auth.h	2002-10-30 18:42:34.000000000 -0500
@@ -23,7 +23,7 @@
  * Client user credentials
  */
 struct rpc_cred {
-	struct rpc_cred *	cr_next;	/* linked list */
+	struct list_head	cr_hash;	/* hash chain */
 	struct rpc_auth *	cr_auth;
 	struct rpc_credops *	cr_ops;
 	unsigned long		cr_expire;	/* when to gc */
@@ -49,7 +49,7 @@
 #define RPC_CREDCACHE_NR	8
 #define RPC_CREDCACHE_MASK	(RPC_CREDCACHE_NR - 1)
 struct rpc_auth {
-	struct rpc_cred *	au_credcache[RPC_CREDCACHE_NR];
+	struct list_head	au_credcache[RPC_CREDCACHE_NR];
 	unsigned long		au_expire;	/* cache expiry interval */
 	unsigned long		au_nextgc;	/* next garbage collection */
 	unsigned int		au_cslack;	/* call cred size estimate */
@@ -101,8 +101,6 @@
 void			rpcauth_holdcred(struct rpc_task *);
 void			put_rpccred(struct rpc_cred *);
 void			rpcauth_unbindcred(struct rpc_task *);
-int			rpcauth_matchcred(struct rpc_auth *,
-					  struct rpc_cred *, int);
 u32 *			rpcauth_marshcred(struct rpc_task *, u32 *);
 u32 *			rpcauth_checkverf(struct rpc_task *, u32 *);
 int			rpcauth_refreshcred(struct rpc_task *);
@@ -110,8 +108,6 @@
 int			rpcauth_uptodatecred(struct rpc_task *);
 void			rpcauth_init_credcache(struct rpc_auth *);
 void			rpcauth_free_credcache(struct rpc_auth *);
-void			rpcauth_insert_credcache(struct rpc_auth *,
-						struct rpc_cred *);
 
 static inline
 struct rpc_cred *	get_rpccred(struct rpc_cred *cred)
diff -u --recursive --new-file linux-2.5.44-00-fixes/net/sunrpc/auth.c linux-2.5.44-01-auth/net/sunrpc/auth.c
--- linux-2.5.44-00-fixes/net/sunrpc/auth.c	2002-09-18 06:05:34.000000000 -0400
+++ linux-2.5.44-01-auth/net/sunrpc/auth.c	2002-10-30 20:31:37.000000000 -0500
@@ -75,7 +75,9 @@
 void
 rpcauth_init_credcache(struct rpc_auth *auth)
 {
-	memset(auth->au_credcache, 0, sizeof(auth->au_credcache));
+	int i;
+	for (i = 0; i < RPC_CREDCACHE_NR; i++)
+		INIT_LIST_HEAD(&auth->au_credcache[i]);
 	auth->au_nextgc = jiffies + (auth->au_expire >> 1);
 }
 
@@ -86,11 +88,10 @@
 rpcauth_crdestroy(struct rpc_cred *cred)
 {
 #ifdef RPC_DEBUG
-	if (cred->cr_magic != RPCAUTH_CRED_MAGIC)
-		BUG();
+	BUG_ON(cred->cr_magic != RPCAUTH_CRED_MAGIC ||
+			atomic_read(&cred->cr_count) ||
+			!list_empty(&cred->cr_hash));
 	cred->cr_magic = 0;
-	if (atomic_read(&cred->cr_count) || cred->cr_auth)
-		BUG();
 #endif
 	cred->cr_ops->crdestroy(cred);
 }
@@ -99,12 +100,13 @@
  * Destroy a list of credentials
  */
 static inline
-void rpcauth_destroy_credlist(struct rpc_cred *head)
+void rpcauth_destroy_credlist(struct list_head *head)
 {
 	struct rpc_cred *cred;
 
-	while ((cred = head) != NULL) {
-		head = cred->cr_next;
+	while (!list_empty(head)) {
+		cred = list_entry(head->next, struct rpc_cred, cr_hash);
+		list_del_init(&cred->cr_hash);
 		rpcauth_crdestroy(cred);
 	}
 }
@@ -116,137 +118,117 @@
 void
 rpcauth_free_credcache(struct rpc_auth *auth)
 {
-	struct rpc_cred	**q, *cred, *free = NULL;
+	LIST_HEAD(free);
+	struct list_head *pos, *next;
+	struct rpc_cred	*cred;
 	int		i;
 
 	spin_lock(&rpc_credcache_lock);
 	for (i = 0; i < RPC_CREDCACHE_NR; i++) {
-		q = &auth->au_credcache[i];
-		while ((cred = *q) != NULL) {
-			*q = cred->cr_next;
+		list_for_each_safe(pos, next, &auth->au_credcache[i]) {
+			cred = list_entry(pos, struct rpc_cred, cr_hash);
 			cred->cr_auth = NULL;
-			if (atomic_read(&cred->cr_count) == 0) {
-				cred->cr_next = free;
-				free = cred;
-			} else
-				cred->cr_next = NULL;
+			list_del_init(&cred->cr_hash);
+			if (atomic_read(&cred->cr_count) == 0)
+				list_add(&cred->cr_hash, &free);
 		}
 	}
 	spin_unlock(&rpc_credcache_lock);
-	rpcauth_destroy_credlist(free);
+	rpcauth_destroy_credlist(&free);
+}
+
+static inline int
+rpcauth_prune_expired(struct rpc_cred *cred, struct list_head *free)
+{
+	if (atomic_read(&cred->cr_count) != 0)
+	       return 0;
+	if (time_before(jiffies, cred->cr_expire))
+		return 0;
+	cred->cr_auth = NULL;
+	list_del(&cred->cr_hash);
+	list_add(&cred->cr_hash, free);
+	return 1;
 }
 
 /*
  * Remove stale credentials. Avoid sleeping inside the loop.
  */
 static void
-rpcauth_gc_credcache(struct rpc_auth *auth)
+rpcauth_gc_credcache(struct rpc_auth *auth, struct list_head *free)
 {
-	struct rpc_cred	**q, *cred, *free = NULL;
+	struct list_head *pos, *next;
+	struct rpc_cred	*cred;
 	int		i;
 
 	dprintk("RPC: gc'ing RPC credentials for auth %p\n", auth);
-	spin_lock(&rpc_credcache_lock);
 	for (i = 0; i < RPC_CREDCACHE_NR; i++) {
-		q = &auth->au_credcache[i];
-		while ((cred = *q) != NULL) {
-			if (!atomic_read(&cred->cr_count) &&
-			    time_before(cred->cr_expire, jiffies)) {
-				*q = cred->cr_next;
-				cred->cr_auth = NULL;
-				cred->cr_next = free;
-				free = cred;
-				continue;
-			}
-			q = &cred->cr_next;
+		list_for_each_safe(pos, next, &auth->au_credcache[i]) {
+			cred = list_entry(pos, struct rpc_cred, cr_hash);
+			rpcauth_prune_expired(cred, free);
 		}
 	}
-	spin_unlock(&rpc_credcache_lock);
-	rpcauth_destroy_credlist(free);
 	auth->au_nextgc = jiffies + auth->au_expire;
 }
 
 /*
- * Insert credential into cache
- */
-void
-rpcauth_insert_credcache(struct rpc_auth *auth, struct rpc_cred *cred)
-{
-	int		nr;
-
-	nr = (cred->cr_uid & RPC_CREDCACHE_MASK);
-	spin_lock(&rpc_credcache_lock);
-	cred->cr_next = auth->au_credcache[nr];
-	auth->au_credcache[nr] = cred;
-	cred->cr_auth = auth;
-	get_rpccred(cred);
-	spin_unlock(&rpc_credcache_lock);
-}
-
-/*
  * Look up a process' credentials in the authentication cache
  */
 static struct rpc_cred *
 rpcauth_lookup_credcache(struct rpc_auth *auth, int taskflags)
 {
-	struct rpc_cred	**q, *cred = NULL;
+	LIST_HEAD(free);
+	struct list_head *pos, *next;
+	struct rpc_cred	*new = NULL,
+			*cred = NULL;
 	int		nr = 0;
 
 	if (!(taskflags & RPC_TASK_ROOTCREDS))
 		nr = current->uid & RPC_CREDCACHE_MASK;
-
-	if (time_before(auth->au_nextgc, jiffies))
-		rpcauth_gc_credcache(auth);
-
+retry:
 	spin_lock(&rpc_credcache_lock);
-	q = &auth->au_credcache[nr];
-	while ((cred = *q) != NULL) {
-		if (!(cred->cr_flags & RPCAUTH_CRED_DEAD) &&
-		    cred->cr_ops->crmatch(cred, taskflags)) {
-			*q = cred->cr_next;
+	if (time_before(auth->au_nextgc, jiffies))
+		rpcauth_gc_credcache(auth, &free);
+	list_for_each_safe(pos, next, &auth->au_credcache[nr]) {
+		struct rpc_cred *entry;
+	       	entry = list_entry(pos, struct rpc_cred, cr_hash);
+		if (entry->cr_flags & RPCAUTH_CRED_DEAD)
+			continue;
+		if (rpcauth_prune_expired(entry, &free))
+			continue;
+		if (entry->cr_ops->crmatch(entry, taskflags)) {
+			list_del(&entry->cr_hash);
+			cred = entry;
 			break;
 		}
-		q = &cred->cr_next;
+	}
+	if (new) {
+		if (cred)
+			list_add(&new->cr_hash, &free);
+		else
+			cred = new;
+	}
+	if (cred) {
+		list_add(&cred->cr_hash, &auth->au_credcache[nr]);
+		cred->cr_auth = auth;
+		get_rpccred(cred);
 	}
 	spin_unlock(&rpc_credcache_lock);
 
+	rpcauth_destroy_credlist(&free);
+
 	if (!cred) {
-		cred = auth->au_ops->crcreate(taskflags);
+		new = auth->au_ops->crcreate(taskflags);
+		if (new) {
 #ifdef RPC_DEBUG
-		if (cred)
-			cred->cr_magic = RPCAUTH_CRED_MAGIC;
+			new->cr_magic = RPCAUTH_CRED_MAGIC;
 #endif
+			goto retry;
+		}
 	}
 
-	if (cred)
-		rpcauth_insert_credcache(auth, cred);
-
 	return (struct rpc_cred *) cred;
 }
 
-/*
- * Remove cred handle from cache
- */
-static void
-rpcauth_remove_credcache(struct rpc_cred *cred)
-{
-	struct rpc_auth *auth = cred->cr_auth;
-	struct rpc_cred	**q, *cr;
-	int		nr;
-
-	nr = (cred->cr_uid & RPC_CREDCACHE_MASK);
-	q = &auth->au_credcache[nr];
-	while ((cr = *q) != NULL) {
-		if (cred == cr) {
-			*q = cred->cr_next;
-			cred->cr_next = NULL;
-			cred->cr_auth = NULL;
-			break;
-		}
-		q = &cred->cr_next;
-	}
-}
-
 struct rpc_cred *
 rpcauth_lookupcred(struct rpc_auth *auth, int taskflags)
 {
@@ -268,14 +250,6 @@
 	return task->tk_msg.rpc_cred;
 }
 
-int
-rpcauth_matchcred(struct rpc_auth *auth, struct rpc_cred *cred, int taskflags)
-{
-	dprintk("RPC:     matching %s cred %d\n",
-		auth->au_ops->au_name, taskflags);
-	return cred->cr_ops->crmatch(cred, taskflags);
-}
-
 void
 rpcauth_holdcred(struct rpc_task *task)
 {
@@ -291,10 +265,10 @@
 	if (!atomic_dec_and_lock(&cred->cr_count, &rpc_credcache_lock))
 		return;
 
-	if (cred->cr_auth && cred->cr_flags & RPCAUTH_CRED_DEAD)
-		rpcauth_remove_credcache(cred);
+	if ((cred->cr_flags & RPCAUTH_CRED_DEAD) && !list_empty(&cred->cr_hash))
+		list_del_init(&cred->cr_hash);
 
-	if (!cred->cr_auth) {
+	if (list_empty(&cred->cr_hash)) {
 		spin_unlock(&rpc_credcache_lock);
 		rpcauth_crdestroy(cred);
 		return;
diff -u --recursive --new-file linux-2.5.44-00-fixes/net/sunrpc/sunrpc_syms.c linux-2.5.44-01-auth/net/sunrpc/sunrpc_syms.c
--- linux-2.5.44-00-fixes/net/sunrpc/sunrpc_syms.c	2002-10-16 00:47:02.000000000 -0400
+++ linux-2.5.44-01-auth/net/sunrpc/sunrpc_syms.c	2002-10-30 18:42:34.000000000 -0500
@@ -62,12 +62,7 @@
 /* Client credential cache */
 EXPORT_SYMBOL(rpcauth_register);
 EXPORT_SYMBOL(rpcauth_unregister);
-EXPORT_SYMBOL(rpcauth_init_credcache);
-EXPORT_SYMBOL(rpcauth_free_credcache);
-EXPORT_SYMBOL(rpcauth_insert_credcache);
 EXPORT_SYMBOL(rpcauth_lookupcred);
-EXPORT_SYMBOL(rpcauth_bindcred);
-EXPORT_SYMBOL(rpcauth_matchcred);
 EXPORT_SYMBOL(put_rpccred);
 
 /* RPC server stuff */


-------------------------------------------------------
This sf.net email is sponsored by: Influence the future 
of Java(TM) technology. Join the Java Community 
Process(SM) (JCP(SM)) program now. 
http://ads.sourceforge.net/cgi-bin/redirect.pl?sunm0004en
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
