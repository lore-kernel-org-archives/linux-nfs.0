From: NeilBrown <neilb@cse.unsw.edu.au>
Subject: [PATCH] kNFSd - 3 of 16 - Increase separation between lockd and nfsd.
Date: Thu, 12 Sep 2002 12:34:32 +1000
Sender: nfs-admin@lists.sourceforge.net
Message-ID: <1020912023432.19553@cse.unsw.edu.au>
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-admin@lists.sourceforge.net>
Received: from tone.orchestra.cse.unsw.edu.au ([129.94.242.28])
	by usw-sf-list1.sourceforge.net with smtp (Exim 3.31-VA-mm2 #1 (Debian))
	id 17pJol-0002C9-00
	for <nfs@lists.sourceforge.net>; Wed, 11 Sep 2002 19:34:55 -0700
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
List-Archive: <http://www.geocrawler.com/redir-sf.php3?list=nfs>


### Comments for ChangeSet

lockd currently asks nfsd for a 'client handle' for each
request.
This is used as a key for finding (or creating) a 'nlm_host' 
structure, so that there is only one of these per client...almost.
There can currently be up to 4 nlm_hosts for a given client,
depending on protocol (udp/tcp) or version (v1 or v4).
But this isn't handled very well.
So the question is: is there any advantage in having only on
nlm_host per real host, or have we simply have one for each IP
address that makes requests, whether they are separate hosts or not.

The nlm_host structure is used:
 1/ to hold a lockd rpc client for talking to the 
    remote lockd.  Having multiple lockd clients cannot hurt
    except possibly to waste a little space.
 2/ to identify resources to free when we receive notification
    from statd that a client has restarted.
    As statd gets a hostname and looks up all IP addresses,
    and then sends a notification for each IP for which it has
    a registration, there is no need to minimise the number
    of nlm_host structures (each of which register for monitoring).
 3/ to identify resources to free when a client sends a
    "free_all" request.  If a client uses multiple IP addresses to
    create locks, and then sends free_all from just one IP address
    we will loose here.
    However it is not clear that a client would ever want to send
    a free_all request, and the linux client doesn't seem to, so
    there is unlikely to be any loss here.

This patch does not ask nfsd for a client identifier, but rather 
finds an nlm_host based on IP, version, protocol (udp/tcp) and
whether we are acting as NFS server or client.

All of this information is then placed in the cookie that is
passed to statd and returned by statd when the client restarts.
Previously only the IP address was passing the cookie, so possibly
not all nlm_host structures would have been found.

Because of these changes, lockd does not need to know
anything about the nfsd export table, so the interface to
nfsd is much more narrow.

Another consequence is that when nfsd is told to delete a client,
it cannot tell lockd to forget all the locks for that client.
However it is not clear that lockd should ever forget any locks
unless it is told to shutdown (or simulate a shutdown), and in
anycase, the current nfsd admin tools never tell nfsd to delete
a client anyway.




 ----------- Diffstat output ------------
 ./fs/lockd/host.c                |   46 +++++++++------------------------------
 ./fs/lockd/lockd_syms.c          |    1 
 ./fs/lockd/mon.c                 |    5 ++--
 ./fs/lockd/svc.c                 |   14 -----------
 ./fs/lockd/svc4proc.c            |   38 +++++++++++---------------------
 ./fs/lockd/svcproc.c             |   36 +++++++++---------------------
 ./fs/lockd/svcsubs.c             |   17 --------------
 ./fs/lockd/xdr.c                 |    2 +
 ./fs/nfsd/export.c               |    1 
 ./fs/nfsd/lockd.c                |   22 ++++++------------
 ./include/linux/lockd/bind.h     |    4 ---
 ./include/linux/lockd/lockd.h    |    5 +---
 ./include/linux/lockd/sm_inter.h |    1 
 ./include/linux/lockd/xdr.h      |    2 +
 14 files changed, 53 insertions(+), 141 deletions(-)

--- ./include/linux/lockd/bind.h	2002/09/11 01:10:25	1.2
+++ ./include/linux/lockd/bind.h	2002/09/11 01:28:27	1.3
@@ -19,9 +19,6 @@ struct svc_client;		/* opaque type */
  * This is the set of functions for lockd->nfsd communication
  */
 struct nlmsvc_binding {
-	void			(*exp_readlock)(void);
-	void			(*exp_unlock)(void);
-	struct svc_client *	(*exp_getclient)(struct sockaddr_in *);
 	u32			(*fopen)(struct svc_rqst *,
 						struct nfs_fh *,
 						struct file *);
@@ -33,7 +30,6 @@ extern struct nlmsvc_binding *	nlmsvc_op
 /*
  * Functions exported by the lockd module
  */
-extern void	nlmsvc_invalidate_client(struct svc_client *clnt);
 extern int	nlmclnt_proc(struct inode *, int, struct file_lock *);
 extern int	lockd_up(void);
 extern void	lockd_down(void);
--- ./include/linux/lockd/lockd.h	2002/09/11 01:10:25	1.2
+++ ./include/linux/lockd/lockd.h	2002/09/11 01:28:27	1.3
@@ -39,13 +39,13 @@
 struct nlm_host {
 	struct nlm_host *	h_next;		/* linked list (hash table) */
 	struct sockaddr_in	h_addr;		/* peer address */
-	struct svc_client *	h_exportent;	/* NFS client */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char			h_name[20];	/* remote hostname */
 	u32			h_version;	/* interface version */
 	unsigned short		h_proto;	/* transport proto */
 	unsigned short		h_authflavor;	/* RPC authentication type */
 	unsigned short		h_reclaiming : 1,
+				h_server     : 1, /* server side, not client side */
 				h_inuse      : 1,
 				h_killed     : 1,
 				h_monitored  : 1;
@@ -143,8 +143,7 @@ void		  nlmclnt_freegrantargs(struct nlm
  */
 struct nlm_host * nlmclnt_lookup_host(struct sockaddr_in *, int, int);
 struct nlm_host * nlmsvc_lookup_host(struct svc_rqst *);
-struct nlm_host * nlm_lookup_host(struct svc_client *,
-					struct sockaddr_in *, int, int);
+struct nlm_host * nlm_lookup_host(int server, struct sockaddr_in *, int, int);
 struct rpc_clnt * nlm_bind_host(struct nlm_host *);
 void		  nlm_rebind_host(struct nlm_host *);
 struct nlm_host * nlm_get_host(struct nlm_host *);
--- ./include/linux/lockd/xdr.h	2002/09/11 01:15:11	1.1
+++ ./include/linux/lockd/xdr.h	2002/09/11 01:28:27	1.2
@@ -76,6 +76,8 @@ struct nlm_reboot {
 	int		len;
 	u32		state;
 	u32		addr;
+	u32		vers;
+	u32		proto;
 };
 
 /*
--- ./include/linux/lockd/sm_inter.h	2002/09/11 01:15:11	1.1
+++ ./include/linux/lockd/sm_inter.h	2002/09/11 01:28:27	1.2
@@ -28,6 +28,7 @@ struct nsm_args {
 	u32		prog;		/* RPC callback info */
 	u32		vers;
 	u32		proc;
+	u32		proto;		/* protocol (udp/tcp) plus server/client flag */
 };
 
 /*
--- ./fs/nfsd/export.c	2002/09/11 01:10:25	1.2
+++ ./fs/nfsd/export.c	2002/09/11 01:28:27	1.3
@@ -840,7 +840,6 @@ exp_freeclient(svc_client *clp)
 
 	/* umap_free(&(clp->cl_umap)); */
 	exp_unexport_all(clp);
-	nfsd_lockd_unexport(clp);
 	kfree (clp);
 }
 
--- ./fs/nfsd/lockd.c	2002/09/11 01:10:25	1.2
+++ ./fs/nfsd/lockd.c	2002/09/11 01:28:27	1.3
@@ -31,12 +31,19 @@ nlm_fopen(struct svc_rqst *rqstp, struct
 	memcpy((char*)&fh.fh_handle.fh_base, f->data, f->size);
 	fh.fh_export = NULL;
 
-	nfserr = nfsd_open(rqstp, &fh, S_IFREG, MAY_LOCK, filp);
+	exp_readlock();
+	rqstp->rq_client = exp_getclient(&rqstp->rq_addr);
+	if (rqstp->rq_client == NULL)
+		nfserr = nfserr_stale;
+	else
+		nfserr = nfsd_open(rqstp, &fh, S_IFREG, MAY_LOCK, filp);
 	if (!nfserr) {
 		dget(filp->f_dentry);
 		mntget(filp->f_vfsmnt);
 	}
 	fh_put(&fh);
+	rqstp->rq_client = NULL;
+	exp_readunlock();
  	/* nlm and nfsd don't share error codes.
 	 * we invent: 0 = no error
 	 *            1 = stale file handle
@@ -61,23 +68,10 @@ nlm_fclose(struct file *filp)
 }
 
 struct nlmsvc_binding		nfsd_nlm_ops = {
-	.exp_readlock	= exp_readlock,		/* lock export table for reading */
-	.exp_unlock	= exp_readunlock,		/* unlock export table */
-	.exp_getclient	= exp_getclient,		/* look up NFS client */
 	.fopen		= nlm_fopen,		/* open file for locking */
 	.fclose		= nlm_fclose,		/* close file */
 };
 
-/*
- * When removing an NFS client entry, notify lockd that it is gone.
- * FIXME: We should do the same when unexporting an NFS volume.
- */
-void
-nfsd_lockd_unexport(struct svc_client *clnt)
-{
-	nlmsvc_invalidate_client(clnt);
-}
-
 void
 nfsd_lockd_init(void)
 {
--- ./fs/lockd/svc.c	2002/09/11 01:10:25	1.3
+++ ./fs/lockd/svc.c	2002/09/11 01:28:27	1.4
@@ -163,22 +163,8 @@ lockd(struct svc_rqst *rqstp)
 		dprintk("lockd: request from %08x\n",
 			(unsigned)ntohl(rqstp->rq_addr.sin_addr.s_addr));
 
-		/*
-		 * Look up the NFS client handle. The handle is needed for
-		 * all but the GRANTED callback RPCs.
-		 */
-		rqstp->rq_client = NULL;
-		if (nlmsvc_ops) {
-			nlmsvc_ops->exp_readlock();
-			rqstp->rq_client =
-				nlmsvc_ops->exp_getclient(&rqstp->rq_addr);
-		}
-
 		svc_process(serv, rqstp);
 
-		/* Unlock export hash tables */
-		if (nlmsvc_ops)
-			nlmsvc_ops->exp_unlock();
 	}
 
 	/*
--- ./fs/lockd/mon.c	2002/09/11 01:07:38	1.2
+++ ./fs/lockd/mon.c	2002/09/11 01:28:27	1.3
@@ -42,6 +42,7 @@ nsm_mon_unmon(struct nlm_host *host, u32
 		goto out;
 
 	args.addr = host->h_addr.sin_addr.s_addr;
+	args.proto= (host->h_proto<<1) | host->h_server;
 	args.prog = NLM_PROGRAM;
 	args.vers = host->h_version;
 	args.proc = NLMPROC_NSM_NOTIFY;
@@ -167,8 +168,8 @@ xdr_encode_mon(struct rpc_rqst *rqstp, u
 	/* This is the private part. Needed only for SM_MON call */
 	if (rqstp->rq_task->tk_msg.rpc_proc == SM_MON) {
 		*p++ = argp->addr;
-		*p++ = 0;
-		*p++ = 0;
+		*p++ = argp->vers;
+		*p++ = argp->proto;
 		*p++ = 0;
 	}
 
--- ./fs/lockd/svc4proc.c	2002/09/11 01:07:38	1.2
+++ ./fs/lockd/svc4proc.c	2002/09/11 01:28:27	1.3
@@ -40,15 +40,6 @@ nlm4svc_retrieve_args(struct svc_rqst *r
 	if (!nlmsvc_ops)
 		return nlm_lck_denied_nolocks;
 
-	/* Obtain handle for client host */
-	if (rqstp->rq_client == NULL) {
-		printk(KERN_NOTICE
-			"lockd: unauthenticated request from (%08x:%d)\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
-		return nlm_lck_denied_nolocks;
-	}
-
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
 	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
@@ -420,8 +411,9 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 					      void	        *resp)
 {
 	struct sockaddr_in	saddr = rqstp->rq_addr;
-	int			vers = rqstp->rq_vers;
-	int			prot = rqstp->rq_prot;
+	int			vers = argp->vers;
+	int			prot = argp->proto >> 1;
+
 	struct nlm_host		*host;
 
 	dprintk("lockd: SM_NOTIFY     called\n");
@@ -438,24 +430,20 @@ nlm4svc_proc_sm_notify(struct svc_rqst *
 	 * reclaim all locks we hold on this server.
 	 */
 	saddr.sin_addr.s_addr = argp->addr;
-	if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
-		nlmclnt_recovery(host, argp->state);
-		nlm_release_host(host);
-	}
 
-	/* If we run on an NFS server, delete all locks held by the client */
-	if (nlmsvc_ops != NULL) {
-		struct svc_client	*clnt;
-		saddr.sin_addr.s_addr = argp->addr;
-		nlmsvc_ops->exp_readlock();
-		if ((clnt = nlmsvc_ops->exp_getclient(&saddr)) != NULL 
-		 && (host = nlm_lookup_host(clnt, &saddr, 0, 0)) != NULL) {
+	if ((argp->proto & 1)==0) {
+		if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
+			nlmclnt_recovery(host, argp->state);
+			nlm_release_host(host);
+		}
+	} else {
+		/* If we run on an NFS server, delete all locks held by the client */
+
+		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
+			nlm_release_host(host);
 		}
-		nlm_release_host(host);
-		nlmsvc_ops->exp_unlock();
 	}
-
 	return rpc_success;
 }
 
--- ./fs/lockd/svcproc.c	2002/09/11 01:07:38	1.2
+++ ./fs/lockd/svcproc.c	2002/09/11 01:28:27	1.3
@@ -69,15 +69,6 @@ nlmsvc_retrieve_args(struct svc_rqst *rq
 	if (!nlmsvc_ops)
 		return nlm_lck_denied_nolocks;
 
-	/* Obtain handle for client host */
-	if (rqstp->rq_client == NULL) {
-		printk(KERN_NOTICE
-			"lockd: unauthenticated request from (%08x:%d)\n",
-			ntohl(rqstp->rq_addr.sin_addr.s_addr),
-			ntohs(rqstp->rq_addr.sin_port));
-		return nlm_lck_denied_nolocks;
-	}
-
 	/* Obtain host handle */
 	if (!(host = nlmsvc_lookup_host(rqstp))
 	 || (argp->monitor && !host->h_monitored && nsm_monitor(host) < 0))
@@ -448,8 +439,8 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 					      void	        *resp)
 {
 	struct sockaddr_in	saddr = rqstp->rq_addr;
-	int			vers = rqstp->rq_vers;
-	int			prot = rqstp->rq_prot;
+	int			vers = argp->vers;
+	int			prot = argp->proto >> 1;
 	struct nlm_host		*host;
 
 	dprintk("lockd: SM_NOTIFY     called\n");
@@ -466,22 +457,17 @@ nlmsvc_proc_sm_notify(struct svc_rqst *r
 	 * reclaim all locks we hold on this server.
 	 */
 	saddr.sin_addr.s_addr = argp->addr;
-	if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
-		nlmclnt_recovery(host, argp->state);
-		nlm_release_host(host);
-	}
-
-	/* If we run on an NFS server, delete all locks held by the client */
-	if (nlmsvc_ops != NULL) {
-		struct svc_client	*clnt;
-		saddr.sin_addr.s_addr = argp->addr;	
-		nlmsvc_ops->exp_readlock();
-		if ((clnt = nlmsvc_ops->exp_getclient(&saddr)) != NULL 
-		 && (host = nlm_lookup_host(clnt, &saddr, 0, 0)) != NULL) {
+	if ((argp->proto & 1)==0) {
+		if ((host = nlmclnt_lookup_host(&saddr, prot, vers)) != NULL) {
+			nlmclnt_recovery(host, argp->state);
+			nlm_release_host(host);
+		}
+	} else {
+		/* If we run on an NFS server, delete all locks held by the client */
+		if ((host = nlm_lookup_host(1, &saddr, prot, vers)) != NULL) {
 			nlmsvc_free_host_resources(host);
+			nlm_release_host(host);
 		}
-		nlm_release_host(host);
-		nlmsvc_ops->exp_unlock();
 	}
 
 	return rpc_success;
--- ./fs/lockd/xdr.c	2002/09/11 01:07:38	1.2
+++ ./fs/lockd/xdr.c	2002/09/11 01:28:27	1.3
@@ -369,6 +369,8 @@ nlmsvc_decode_reboot(struct svc_rqst *rq
 	argp->state = ntohl(*p++);
 	/* Preserve the address in network byte order */
 	argp->addr = *p++;
+	argp->vers = *p++;
+	argp->proto = *p++;
 	return xdr_argsize_check(rqstp, p);
 }
 
--- ./fs/lockd/host.c	2002/09/11 01:10:25	1.2
+++ ./fs/lockd/host.c	2002/09/11 01:28:27	1.3
@@ -22,7 +22,6 @@
 #define NLM_HOST_MAX		64
 #define NLM_HOST_NRHASH		32
 #define NLM_ADDRHASH(addr)	(ntohl(addr) & (NLM_HOST_NRHASH-1))
-#define NLM_PTRHASH(ptr)	((((u32)(unsigned long) ptr) / 32) & (NLM_HOST_NRHASH-1))
 #define NLM_HOST_REBIND		(60 * HZ)
 #define NLM_HOST_EXPIRE		((nrhosts > NLM_HOST_MAX)? 300 * HZ : 120 * HZ)
 #define NLM_HOST_COLLECT	((nrhosts > NLM_HOST_MAX)? 120 * HZ :  60 * HZ)
@@ -42,7 +41,7 @@ static void			nlm_gc_hosts(void);
 struct nlm_host *
 nlmclnt_lookup_host(struct sockaddr_in *sin, int proto, int version)
 {
-	return nlm_lookup_host(NULL, sin, proto, version);
+	return nlm_lookup_host(0, sin, proto, version);
 }
 
 /*
@@ -51,45 +50,25 @@ nlmclnt_lookup_host(struct sockaddr_in *
 struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp)
 {
-	return nlm_lookup_host(rqstp->rq_client, &rqstp->rq_addr,
+	return nlm_lookup_host(1, &rqstp->rq_addr,
 			       rqstp->rq_prot, rqstp->rq_vers);
 }
 
 /*
- * Match the given host against client/address
- */
-static inline int
-nlm_match_host(struct nlm_host *host, struct svc_client *clnt,
-					struct sockaddr_in *sin)
-{
-	if (clnt)
-		return host->h_exportent == clnt;
-	return nlm_cmp_addr(&host->h_addr, sin);
-}
-
-/*
  * Common host lookup routine for server & client
  */
 struct nlm_host *
-nlm_lookup_host(struct svc_client *clnt, struct sockaddr_in *sin,
+nlm_lookup_host(int server, struct sockaddr_in *sin,
 					int proto, int version)
 {
 	struct nlm_host	*host, **hp;
 	u32		addr;
 	int		hash;
 
-	if (!clnt && !sin) {
-		printk(KERN_NOTICE "lockd: no clnt or addr in lookup_host!\n");
-		return NULL;
-	}
-
 	dprintk("lockd: nlm_lookup_host(%08x, p=%d, v=%d)\n",
 			(unsigned)(sin? ntohl(sin->sin_addr.s_addr) : 0), proto, version);
 
-	if (clnt)
-		hash = NLM_PTRHASH(clnt);
-	else
-		hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
+	hash = NLM_ADDRHASH(sin->sin_addr.s_addr);
 
 	/* Lock hash table */
 	down(&nlm_host_sema);
@@ -98,12 +77,14 @@ nlm_lookup_host(struct svc_client *clnt,
 		nlm_gc_hosts();
 
 	for (hp = &nlm_hosts[hash]; (host = *hp); hp = &host->h_next) {
-		if (proto && host->h_proto != proto)
+		if (host->h_proto != proto)
+			continue;
+		if (host->h_version != version)
 			continue;
-		if (version && host->h_version != version)
+		if (host->h_server != server)
 			continue;
 
-		if (nlm_match_host(host, clnt, sin)) {
+		if (nlm_cmp_addr(&host->h_addr, sin)) {
 			if (hp != nlm_hosts + hash) {
 				*hp = host->h_next;
 				host->h_next = nlm_hosts[hash];
@@ -115,10 +96,6 @@ nlm_lookup_host(struct svc_client *clnt,
 		}
 	}
 
-	/* special hack for nlmsvc_invalidate_client */
-	if (sin == NULL)
-		goto nohost;
-
 	/* Ooops, no host found, create it */
 	dprintk("lockd: creating host entry\n");
 
@@ -146,8 +123,7 @@ nlm_lookup_host(struct svc_client *clnt,
 	init_waitqueue_head(&host->h_gracewait);
 	host->h_state      = 0;			/* pseudo NSM state */
 	host->h_nsmstate   = 0;			/* real NSM state */
-	host->h_exportent  = clnt;
-
+	host->h_server	   = server;
 	host->h_next       = nlm_hosts[hash];
 	nlm_hosts[hash]    = host;
 
@@ -170,7 +146,7 @@ nlm_find_client(void)
 	for (hash = 0 ; hash < NLM_HOST_NRHASH; hash++) {
 		struct nlm_host *host, **hp;
 		for (hp = &nlm_hosts[hash]; (host = *hp) ; hp = &host->h_next) {
-			if (host->h_exportent != NULL &&
+			if (host->h_server &&
 			    host->h_killed == 0) {
 				nlm_get_host(host);
 				up(&nlm_host_sema);
--- ./fs/lockd/svcsubs.c	2002/09/11 01:10:25	1.2
+++ ./fs/lockd/svcsubs.c	2002/09/11 01:28:27	1.3
@@ -294,23 +294,6 @@ nlmsvc_free_host_resources(struct nlm_ho
 }
 
 /*
- * Delete a client when the nfsd entry is removed.
- */
-void
-nlmsvc_invalidate_client(struct svc_client *clnt)
-{
-	struct nlm_host	*host;
-
-	if ((host = nlm_lookup_host(clnt, NULL, 0, 0)) != NULL) {
-		dprintk("lockd: invalidating client for %s\n", host->h_name);
-		nlmsvc_free_host_resources(host);
-		host->h_expires = 0;
-		host->h_killed = 1;
-		nlm_release_host(host);
-	}
-}
-
-/*
  * delete all hosts structs for clients
  */
 void
--- ./fs/lockd/lockd_syms.c	2002/09/11 01:15:11	1.1
+++ ./fs/lockd/lockd_syms.c	2002/09/11 01:28:27	1.2
@@ -32,7 +32,6 @@ EXPORT_SYMBOL(lockd_down);
 EXPORT_SYMBOL(nlmclnt_proc);
 
 /* NFS server entry points/hooks */
-EXPORT_SYMBOL(nlmsvc_invalidate_client);
 EXPORT_SYMBOL(nlmsvc_ops);
 
 #endif /* CONFIG_MODULES */


-------------------------------------------------------
In remembrance
www.osdn.com/911/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
