From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 10 of 17 - Provide support for request deferral and revisit.
Date: Fri, 11 Oct 2002 15:27:47 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <E17zsKx-0003be-00@notabene.cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17zshx-0004m3-00
	for <nfs@lists.sourceforge.net>; Thu, 10 Oct 2002 22:51:33 -0700
Received: From
	notabene.cse.unsw.edu.au ([129.94.242.45] == bartok.orchestra.cse.unsw.EDU.AU)
	(for <torvalds@transmeta.com>) (for <nfs@lists.sourceforge.net>) By
	tone With Smtp ; Fri, 11 Oct 2002 15:51:24 +1000
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


### Comments for ChangeSet

cache.c gets code to allow a 'request' to be referred pending
an update of a cache item, and revisited when the item is
updates.

svcsock.c gets code to store the relevant part of a request on deferral, and
to re-queue it when the cache item that caused the deferral is
filled in.



 ----------- Diffstat output ------------
 ./Documentation/rpc-cache.txt    |   10 +++
 ./fs/nfsd/export.c               |   26 ++++----
 ./fs/nfsd/nfsfh.c                |    4 -
 ./fs/nfsd/vfs.c                  |    6 +
 ./include/linux/nfsd/export.h    |   16 +++--
 ./include/linux/sunrpc/cache.h   |   24 +++++++
 ./include/linux/sunrpc/svc.h     |   14 ++++
 ./include/linux/sunrpc/svcsock.h |    4 +
 ./net/sunrpc/cache.c             |  118 +++++++++++++++++++++++++++++++++++++
 ./net/sunrpc/svcauth_unix.c      |    4 -
 ./net/sunrpc/svcsock.c           |  122 +++++++++++++++++++++++++++++++++++++--
 11 files changed, 316 insertions(+), 32 deletions(-)

--- ./include/linux/nfsd/export.h	2002/10/11 01:41:42	1.5
+++ ./include/linux/nfsd/export.h	2002/10/11 02:00:11	1.6
@@ -86,13 +86,16 @@ void			nfsd_export_shutdown(void);
 void			exp_readlock(void);
 void			exp_readunlock(void);
 struct svc_expkey *	exp_find_key(struct auth_domain *clp, 
-				     int fsid_type, u32 *fsidv);
+				     int fsid_type, u32 *fsidv,
+				     struct cache_req *reqp);
 struct svc_export *	exp_get_by_name(struct auth_domain *clp,
 					struct vfsmount *mnt,
-					struct dentry *dentry);
+					struct dentry *dentry,
+					struct cache_req *reqp);
 struct svc_export *	exp_parent(struct auth_domain *clp,
 				   struct vfsmount *mnt,
-				   struct dentry *dentry);
+				   struct dentry *dentry,
+				   struct cache_req *reqp);
 int			exp_rootfh(struct auth_domain *, 
 					char *path, struct knfsd_fh *, int maxsize);
 int			exp_pseudoroot(struct auth_domain *, struct svc_fh *fhp);
@@ -108,16 +111,17 @@ static inline void exp_put(struct svc_ex
 }
 
 static inline struct svc_export *
-exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv)
+exp_find(struct auth_domain *clp, int fsid_type, u32 *fsidv,
+	 struct cache_req *reqp)
 {
-	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv);
+	struct svc_expkey *ek = exp_find_key(clp, fsid_type, fsidv, reqp);
 	if (ek && !IS_ERR(ek)) {
 		struct svc_export *exp = ek->ek_export;
 		int err;
 		cache_get(&exp->h);
 		expkey_put(&ek->h, &svc_expkey_cache);
 		if (exp &&
-		    (err = cache_check(&svc_export_cache, &exp->h))) 
+		    (err = cache_check(&svc_export_cache, &exp->h, reqp)))
 			exp = ERR_PTR(err);
 		return exp;
 	} else
--- ./include/linux/sunrpc/svc.h	2002/10/11 00:57:14	1.4
+++ ./include/linux/sunrpc/svc.h	2002/10/11 02:00:11	1.5
@@ -101,6 +101,7 @@ struct svc_rqst {
 	struct auth_ops *	rq_authop;	/* authentication flavour */
 	struct svc_cred		rq_cred;	/* auth info */
 	struct sk_buff *	rq_skbuff;	/* fast recv inet buffer */
+	struct svc_deferred_req*rq_deferred;	/* deferred request we are replaying */
 	struct svc_buf		rq_defbuf;	/* default buffer */
 	struct svc_buf		rq_argbuf;	/* argument buffer */
 	struct svc_buf		rq_resbuf;	/* result buffer */
@@ -121,6 +122,9 @@ struct svc_rqst {
 						 * reserved for this request
 						 */
 
+	struct cache_req	rq_chandle;	/* handle passed to caches for 
+						 * request delaying 
+						 */
 	/* Catering to nfsd */
 	struct auth_domain *	rq_client;	/* RPC peer info */
 	struct svc_cacherep *	rq_cacherep;	/* cache info */
@@ -132,6 +136,16 @@ struct svc_rqst {
 	wait_queue_head_t	rq_wait;	/* synchronization */
 };
 
+struct svc_deferred_req {
+	struct svc_serv		*serv;
+	u32			prot;	/* protocol (UDP or TCP) */
+	struct sockaddr_in	addr;
+	struct svc_sock		*svsk;	/* where reply must go */
+	struct cache_deferred_req handle;
+	int			argslen;
+	u32			args[0];
+};
+
 /*
  * RPC program
  */
--- ./include/linux/sunrpc/cache.h	2002/10/11 00:41:59	1.2
+++ ./include/linux/sunrpc/cache.h	2002/10/11 02:00:11	1.3
@@ -86,6 +86,25 @@ struct cache_detail {
 };
 
 
+/* this must be embedded in any request structure that
+ * identifies an object that will want a callback on
+ * a cache fill
+ */
+struct cache_req {
+	struct cache_deferred_req *(*defer)(struct cache_req *req);
+};
+/* this must be embedded in a deferred_request that is being
+ * delayed awaiting cache-fill
+ */
+struct cache_deferred_req {
+	struct list_head	hash;	/* on hash chain */
+	struct list_head	recent; /* on fifo */
+	struct cache_head	*item;  /* cache item we wait on */
+	time_t			recv_time;
+	void			(*revisit)(struct cache_deferred_req *req,
+					   int too_many);
+};
+
 /*
  * just like a template in C++, this macro does cache lookup
  * for us.
@@ -206,6 +225,9 @@ RTN *FNAME ARGS										\
 
 	     
 
+extern void cache_defer_req(struct cache_req *req, struct cache_head *item);
+extern void cache_revisit_request(struct cache_head *item);
+
 static inline struct cache_head  *cache_get(struct cache_head *h)
 {
 	atomic_inc(&h->refcnt);
@@ -230,7 +252,7 @@ extern void cache_init(struct cache_head
 extern void cache_fresh(struct cache_detail *detail,
 			struct cache_head *head, time_t expiry);
 extern int cache_check(struct cache_detail *detail,
-		       struct cache_head *h);
+		       struct cache_head *h, struct cache_req *rqstp);
 extern int cache_clean(void);
 extern void cache_flush(void);
 extern void cache_purge(struct cache_detail *detail);
--- ./include/linux/sunrpc/svcsock.h	2002/10/11 01:59:25	1.1
+++ ./include/linux/sunrpc/svcsock.h	2002/10/11 02:00:11	1.2
@@ -31,9 +31,13 @@ struct svc_sock {
 #define	SK_QUED		5			/* on serv->sk_sockets */
 #define	SK_DEAD		6			/* socket closed */
 #define	SK_CHNGBUF	7			/* need to change snd/rcv buffer sizes */
+#define	SK_DEFERRED	8			/* request on sk_deferred */
 
 	int			sk_reserved;	/* space on outq that is reserved */
 
+	struct list_head	sk_deferred;	/* deferred requests that need to
+						 * be revisted */
+
 	int			(*sk_recvfrom)(struct svc_rqst *rqstp);
 	int			(*sk_sendto)(struct svc_rqst *rqstp);
 
--- ./fs/nfsd/export.c	2002/10/11 01:41:42	1.6
+++ ./fs/nfsd/export.c	2002/10/11 02:00:11	1.7
@@ -180,7 +180,7 @@ static DefineSimpleCacheLookup(svc_expor
 
 
 struct svc_expkey *
-exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv)
+exp_find_key(svc_client *clp, int fsid_type, u32 *fsidv, struct cache_req *reqp)
 {
 	struct svc_expkey key, *ek;
 	int err;
@@ -195,7 +195,7 @@ exp_find_key(svc_client *clp, int fsid_t
 
 	ek = svc_expkey_lookup(&key, 0);
 	if (ek != NULL)
-		if ((err = cache_check(&svc_expkey_cache, &ek->h)))
+		if ((err = cache_check(&svc_expkey_cache, &ek->h, reqp)))
 			ek = ERR_PTR(err);
 	return ek;
 }
@@ -230,7 +230,7 @@ exp_get_key(svc_client *clp, dev_t dev, 
 	u32 fsidv[2];
 	
 	mk_fsid_v0(fsidv, dev, ino);
-	return exp_find_key(clp, 0, fsidv);
+	return exp_find_key(clp, 0, fsidv, NULL);
 }
 
 /*
@@ -243,11 +243,12 @@ exp_get_fsid_key(svc_client *clp, int fs
 
 	mk_fsid_v1(fsidv, fsid);
 
-	return exp_find_key(clp, 1, fsidv);
+	return exp_find_key(clp, 1, fsidv, NULL);
 }
 
 svc_export *
-exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
+exp_get_by_name(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry,
+		struct cache_req *reqp)
 {
 	struct svc_export *exp, key;
 	
@@ -260,7 +261,7 @@ exp_get_by_name(svc_client *clp, struct 
 
 	exp = svc_export_lookup(&key, 0);
 	if (exp != NULL) 
-		if (cache_check(&svc_export_cache, &exp->h))
+		if (cache_check(&svc_export_cache, &exp->h, reqp))
 			exp = NULL;
 
 	return exp;
@@ -270,15 +271,16 @@ exp_get_by_name(svc_client *clp, struct 
  * Find the export entry for a given dentry.
  */
 struct svc_export *
-exp_parent(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry)
+exp_parent(svc_client *clp, struct vfsmount *mnt, struct dentry *dentry,
+	   struct cache_req *reqp)
 {
 	svc_export *exp;
 
 	read_lock(&dparent_lock);
-	exp = exp_get_by_name(clp, mnt, dentry);
+	exp = exp_get_by_name(clp, mnt, dentry, reqp);
 	while (exp == NULL && dentry != dentry->d_parent) {
 		dentry = dentry->d_parent;
-		exp = exp_get_by_name(clp, mnt, dentry);
+		exp = exp_get_by_name(clp, mnt, dentry, reqp);
 	}
 	read_unlock(&dparent_lock);
 	return exp;
@@ -409,7 +411,7 @@ exp_export(struct nfsctl_export *nxp)
 	inode = nd.dentry->d_inode;
 	err = -EINVAL;
 
-	exp = exp_get_by_name(clp, nd.mnt, nd.dentry);
+	exp = exp_get_by_name(clp, nd.mnt, nd.dentry, NULL);
 
 	/* must make sure there wont be an ex_fsid clash */
 	if ((nxp->ex_flags & NFSEXP_FSID) &&
@@ -598,7 +600,7 @@ exp_rootfh(svc_client *clp, char *path, 
 	dprintk("nfsd: exp_rootfh(%s [%p] %s:%s/%ld)\n",
 		 path, nd.dentry, clp->name,
 		 inode->i_sb->s_id, inode->i_ino);
-	exp = exp_parent(clp, nd.mnt, nd.dentry);
+	exp = exp_parent(clp, nd.mnt, nd.dentry, NULL);
 	if (!exp) {
 		dprintk("nfsd: exp_rootfh export not found.\n");
 		goto out;
@@ -763,7 +765,7 @@ static int e_show(struct seq_file *m, vo
 
 	clp = exp->ex_client;
 	cache_get(&exp->h);
-	if (cache_check(&svc_export_cache, &exp->h))
+	if (cache_check(&svc_export_cache, &exp->h, NULL))
 		return 0;
 	if (cache_put(&exp->h, &svc_export_cache)) BUG();
 	pbuf = m->private;
--- ./fs/nfsd/vfs.c	2002/10/11 01:56:31	1.4
+++ ./fs/nfsd/vfs.c	2002/10/11 02:00:11	1.5
@@ -130,7 +130,8 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			dput(dentry);
 			dentry = dp;
 
-			exp2 = exp_parent(exp->ex_client, mnt, dentry);
+			exp2 = exp_parent(exp->ex_client, mnt, dentry,
+					  &rqstp->rq_chandle);
 			if (!exp2) {
 				dput(dentry);
 				dentry = dget(dparent);
@@ -155,7 +156,8 @@ nfsd_lookup(struct svc_rqst *rqstp, stru
 			struct dentry *mounts = dget(dentry);
 			while (follow_down(&mnt,&mounts)&&d_mountpoint(mounts))
 				;
-			exp2 = exp_get_by_name(exp->ex_client, mnt, mounts);
+			exp2 = exp_get_by_name(exp->ex_client, mnt, 
+					       mounts, &rqstp->rq_chandle);
 			if (exp2 && EX_CROSSMNT(exp2)) {
 				/* successfully crossed mount point */
 				exp_put(exp);
--- ./fs/nfsd/nfsfh.c	2002/10/11 01:41:42	1.3
+++ ./fs/nfsd/nfsfh.c	2002/10/11 02:00:11	1.4
@@ -130,7 +130,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 				goto out;
 			}
 			if ((data_left -= len)<0) goto out;
-			exp = exp_find(rqstp->rq_client, fh->fh_fsid_type, datap);
+			exp = exp_find(rqstp->rq_client, fh->fh_fsid_type, datap, &rqstp->rq_chandle);
 			datap += len;
 		} else {
 			dev_t xdev;
@@ -141,7 +141,7 @@ fh_verify(struct svc_rqst *rqstp, struct
 			xdev = u32_to_dev_t(fh->ofh_xdev);
 			xino = u32_to_ino_t(fh->ofh_xino);
 			mk_fsid_v0(tfh, xdev, xino);
-			exp = exp_find(rqstp->rq_client, 0, tfh);
+			exp = exp_find(rqstp->rq_client, 0, tfh, &rqstp->rq_chandle);
 		}
 
 		error = nfserr_dropit;
--- ./net/sunrpc/svcsock.c	2002/10/11 01:51:33	1.3
+++ ./net/sunrpc/svcsock.c	2002/10/11 02:00:12	1.4
@@ -69,6 +69,9 @@ static void		svc_udp_data_ready(struct s
 static int		svc_udp_recvfrom(struct svc_rqst *);
 static int		svc_udp_sendto(struct svc_rqst *);
 
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk);
+static int svc_deferred_recv(struct svc_rqst *rqstp);
+static struct cache_deferred_req *svc_defer(struct cache_req *req);
 
 /*
  * Queue up an idle server thread.  Must have serv->sv_lock held.
@@ -98,13 +101,18 @@ static inline void
 svc_release_skb(struct svc_rqst *rqstp)
 {
 	struct sk_buff *skb = rqstp->rq_skbuff;
+	struct svc_deferred_req *dr = rqstp->rq_deferred;
 
-	if (!skb)
-		return;
-	rqstp->rq_skbuff = NULL;
+	if (skb) {
+		rqstp->rq_skbuff = NULL;
 
-	dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
-	skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
+		dprintk("svc: service %p, releasing skb %p\n", rqstp, skb);
+		skb_free_datagram(rqstp->rq_sock->sk_sk, skb);
+	}
+	if (dr) {
+		rqstp->rq_deferred = NULL;
+		kfree(dr);
+	}
 }
 
 /*
@@ -119,7 +127,7 @@ svc_sock_enqueue(struct svc_sock *svsk)
 	struct svc_rqst	*rqstp;
 
 	if (!(svsk->sk_flags &
-	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)) ))
+	      ( (1<<SK_CONN)|(1<<SK_DATA)|(1<<SK_CLOSE)|(1<<SK_DEFERRED)) ))
 		return;
 
 	spin_lock_bh(&serv->sv_lock);
@@ -491,6 +499,9 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 				(serv->sv_nrthreads+3) * serv->sv_bufsz,
 				(serv->sv_nrthreads+3) * serv->sv_bufsz);
 
+	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk)))
+		return svc_deferred_recv(rqstp);
+
 	clear_bit(SK_DATA, &svsk->sk_flags);
 	while ((skb = skb_recv_datagram(svsk->sk_sk, 0, 1, &err)) == NULL) {
 		svc_sock_received(svsk);
@@ -782,6 +793,9 @@ svc_tcp_recvfrom(struct svc_rqst *rqstp)
 		test_bit(SK_CONN, &svsk->sk_flags),
 		test_bit(SK_CLOSE, &svsk->sk_flags));
 
+	if ((rqstp->rq_deferred = svc_deferred_dequeue(svsk)))
+		return svc_deferred_recv(rqstp);
+
 	if (test_bit(SK_CLOSE, &svsk->sk_flags)) {
 		svc_delete_socket(svsk);
 		return 0;
@@ -1093,6 +1107,7 @@ svc_recv(struct svc_serv *serv, struct s
 
 	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
 	rqstp->rq_userset = 0;
+	rqstp->rq_chandle.defer = svc_defer;
 
 	svc_getu32(&rqstp->rq_argbuf, rqstp->rq_xid);
 	svc_putu32(&rqstp->rq_resbuf, rqstp->rq_xid);
@@ -1168,6 +1183,7 @@ svc_setup_socket(struct svc_serv *serv, 
 	svsk->sk_owspace = inet->write_space;
 	svsk->sk_server = serv;
 	svsk->sk_lastrecv = CURRENT_TIME;
+	INIT_LIST_HEAD(&svsk->sk_deferred);
 
 	/* Initialize the socket */
 	if (sock->type == SOCK_DGRAM)
@@ -1308,3 +1324,97 @@ svc_makesock(struct svc_serv *serv, int 
 	return svc_create_socket(serv, protocol, &sin);
 }
 
+/*
+ * Handle defer and revisit of requests 
+ */
+
+static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
+{
+	struct svc_deferred_req *dr = container_of(dreq, struct svc_deferred_req, handle);
+	struct svc_serv *serv = dr->serv;
+	struct svc_sock *svsk;
+
+	if (too_many) {
+		svc_sock_put(dr->svsk);
+		kfree(dr);
+		return;
+	}
+	dprintk("revisit queued\n");
+	svsk = dr->svsk;
+	dr->svsk = NULL;
+	spin_lock(&serv->sv_lock);
+	list_add(&dr->handle.recent, &svsk->sk_deferred);
+	spin_unlock(&serv->sv_lock);
+	set_bit(SK_DEFERRED, &svsk->sk_flags);
+	svc_sock_enqueue(svsk);
+	svc_sock_put(svsk);
+}
+
+static struct cache_deferred_req *
+svc_defer(struct cache_req *req)
+{
+	struct svc_rqst *rqstp = container_of(req, struct svc_rqst, rq_chandle);
+	int size = sizeof(struct svc_deferred_req) + (rqstp->rq_argbuf.buflen << 2);
+	struct svc_deferred_req *dr;
+
+	if (rqstp->rq_deferred) {
+		dr = rqstp->rq_deferred;
+		rqstp->rq_deferred = NULL;
+	} else {
+		/* FIXME maybe discard if size too large */
+		dr = kmalloc(size<<2, GFP_KERNEL);
+		if (dr == NULL)
+			return NULL;
+
+		dr->serv = rqstp->rq_server;
+		dr->prot = rqstp->rq_prot;
+		dr->addr = rqstp->rq_addr;
+		dr->argslen = rqstp->rq_argbuf.buflen;
+		memcpy(dr->args, rqstp->rq_argbuf.base, dr->argslen<<2);
+	}
+	spin_lock(&rqstp->rq_server->sv_lock);
+	rqstp->rq_sock->sk_inuse++;
+	dr->svsk = rqstp->rq_sock;
+	spin_unlock(&rqstp->rq_server->sv_lock);
+
+	dr->handle.revisit = svc_revisit;
+	return &dr->handle;
+}
+
+/*
+ * recv data from a defered request into an active one
+ */
+static int svc_deferred_recv(struct svc_rqst *rqstp)
+{
+	struct svc_deferred_req *dr = rqstp->rq_deferred;
+
+	rqstp->rq_argbuf.base = dr->args;
+	rqstp->rq_argbuf.buf  = dr->args;
+	rqstp->rq_argbuf.len  = dr->argslen;
+	rqstp->rq_argbuf.buflen = dr->argslen;
+	rqstp->rq_prot        = dr->prot;
+	rqstp->rq_addr        = dr->addr;
+	return dr->argslen<<2;
+}
+
+
+static struct svc_deferred_req *svc_deferred_dequeue(struct svc_sock *svsk)
+{
+	struct svc_deferred_req *dr = NULL;
+	struct svc_serv	*serv = svsk->sk_server;
+	
+	if (!test_bit(SK_DEFERRED, &svsk->sk_flags))
+		return NULL;
+	spin_lock(&serv->sv_lock);
+	clear_bit(SK_DEFERRED, &svsk->sk_flags);
+	if (!list_empty(&svsk->sk_deferred)) {
+		dr = list_entry(svsk->sk_deferred.next,
+				struct svc_deferred_req,
+				handle.recent);
+		list_del_init(&dr->handle.recent);
+		set_bit(SK_DEFERRED, &svsk->sk_flags);
+	}
+	spin_unlock(&serv->sv_lock);
+	svc_sock_received(svsk);
+	return dr;
+}
--- ./net/sunrpc/cache.c	2002/10/11 00:42:00	1.2
+++ ./net/sunrpc/cache.c	2002/10/11 02:00:12	1.3
@@ -46,7 +46,8 @@ void cache_init(struct cache_head *h)
  * -EAGAIN if upcall is pending,
  * -ENOENT if cache entry was negative
  */
-int cache_check(struct cache_detail *detail, struct cache_head *h)
+int cache_check(struct cache_detail *detail,
+		    struct cache_head *h, struct cache_req *rqstp)
 {
 	int rv;
 
@@ -64,6 +65,13 @@ int cache_check(struct cache_detail *det
 	}
 
 	/* up-call processing goes here later */
+	/* if cache_pending, initiate upcall if none pending.
+	 * if upcall cannot be initiated, change to CACHE_NEGATIVE
+	 */
+	if (rv == CACHE_PENDING) rv = CACHE_NEGATIVE;
+
+	if (rv == CACHE_PENDING)
+		cache_defer_req(rqstp, h);
 
 	if (rv == -EAGAIN /* && cannot do upcall */)
 		rv = -ENOENT;
@@ -274,3 +282,111 @@ void cache_purge(struct cache_detail *de
 	cache_flush();
 }
 
+
+
+/*
+ * Deferral and Revisiting of Requests.
+ *
+ * If a cache lookup finds a pending entry, we
+ * need to defer the request and revisit it later.
+ * All deferred requests are stored in a hash table,
+ * indexed by "struct cache_head *".
+ * As it may be wasteful to store a whole request
+ * structure, we allow the request to provide a 
+ * deferred form, which must contain a
+ * 'struct cache_deferred_req'
+ * This cache_deferred_req contains a method to allow
+ * it to be revisited when cache info is available
+ */
+
+#define	DFR_HASHSIZE	(PAGE_SIZE/sizeof(struct list_head))
+#define	DFR_HASH(item)	((((long)item)>>4 ^ (((long)item)>>13)) % DFR_HASHSIZE)
+
+#define	DFR_MAX	300	/* ??? */
+
+spinlock_t cache_defer_lock = SPIN_LOCK_UNLOCKED;
+static LIST_HEAD(cache_defer_list);
+static struct list_head cache_defer_hash[DFR_HASHSIZE];
+static int cache_defer_cnt;
+
+void cache_defer_req(struct cache_req *req, struct cache_head *item)
+{
+	struct cache_deferred_req *dreq;
+	int hash = DFR_HASH(item);
+
+	dreq = req->defer(req);
+	if (dreq == NULL)
+		return;
+
+	dreq->item = item;
+	dreq->recv_time = CURRENT_TIME;
+
+	spin_lock(&cache_defer_lock);
+
+	list_add(&dreq->recent, &cache_defer_list);
+
+	if (cache_defer_hash[hash].next == NULL)
+		INIT_LIST_HEAD(&cache_defer_hash[hash]);
+	list_add(&dreq->hash, &cache_defer_hash[hash]);
+
+	/* it is in, now maybe clean up */
+	dreq = NULL;
+	if (++cache_defer_cnt > DFR_MAX) {
+		/* too much in the cache, randomly drop
+		 * first or last
+		 */
+		if (net_random()&1) 
+			dreq = list_entry(cache_defer_list.next,
+					  struct cache_deferred_req,
+					  recent);
+		else
+			dreq = list_entry(cache_defer_list.prev,
+					  struct cache_deferred_req,
+					  recent);
+		list_del(&dreq->recent);
+		list_del(&dreq->hash);
+		cache_defer_cnt--;
+	}
+	spin_unlock(&cache_defer_lock);
+
+	if (dreq) {
+		/* there was one too many */
+		dreq->revisit(dreq, 1);
+	}
+	if (test_bit(CACHE_VALID, &item->flags)) {
+		/* must have just been validated... */
+		cache_revisit_request(item);
+	}
+}
+
+void cache_revisit_request(struct cache_head *item)
+{
+	struct cache_deferred_req *dreq;
+	struct list_head pending;
+
+	struct list_head *lp;
+	int hash = DFR_HASH(item);
+
+	INIT_LIST_HEAD(&pending);
+	spin_lock(&cache_defer_lock);
+	
+	lp = cache_defer_hash[hash].next;
+	if (lp) {
+		while (lp != &cache_defer_hash[hash]) {
+			dreq = list_entry(lp, struct cache_deferred_req, hash);
+			lp = lp->next;
+			if (dreq->item == item) {
+				list_del(&dreq->hash);
+				list_move(&dreq->recent, &pending);
+				cache_defer_cnt--;
+			}
+		}
+	}
+	spin_unlock(&cache_defer_lock);
+
+	while (!list_empty(&pending)) {
+		dreq = list_entry(pending.next, struct cache_deferred_req, recent);
+		list_del_init(&dreq->recent);
+		dreq->revisit(dreq, 0);
+	}
+}
--- ./net/sunrpc/svcauth_unix.c	2002/10/11 00:57:15	1.3
+++ ./net/sunrpc/svcauth_unix.c	2002/10/11 02:00:12	1.4
@@ -235,7 +235,7 @@ svcauth_null_accept(struct svc_rqst *rqs
 	rqstp->rq_client = NULL;
 
 	if (ipm)
-		switch (cache_check(&ip_map_cache, &ipm->h)) {
+		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		case -EAGAIN:
 			rv = SVC_DROP;
 			break;
@@ -330,7 +330,7 @@ svcauth_unix_accept(struct svc_rqst *rqs
 	rqstp->rq_client = NULL;
 
 	if (ipm)
-		switch (cache_check(&ip_map_cache, &ipm->h)) {
+		switch (cache_check(&ip_map_cache, &ipm->h, &rqstp->rq_chandle)) {
 		case -EAGAIN:
 			rv = SVC_DROP;
 			break;
--- ./Documentation/rpc-cache.txt	2002/10/11 00:42:00	1.2
+++ ./Documentation/rpc-cache.txt	2002/10/11 02:00:12	1.3
@@ -80,3 +80,13 @@ may contain valid content, or may not.
 This datum is typically passed to cache_check which determines the
 validity of the datum and may later initiate an upcall to fill
 in the data.
+
+cache_check can be passed a "struct cache_req *".  This structure is
+typically embedded in the actual request and can be used to create a
+deferred copy of the request (struct cache_deferred_req).  This is
+done when the found cache item is not uptodate, but the is reason to
+believe that userspace might provide information soon.  When the cache
+item does become valid, the deferred copy of the request will be
+revisited (->revisit).  It is expected that this method will
+reschedule the request for processing.
+


-------------------------------------------------------
This sf.net email is sponsored by:ThinkGeek
Welcome to geek heaven.
http://thinkgeek.com/sf
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
