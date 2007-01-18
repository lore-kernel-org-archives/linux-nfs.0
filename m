From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/13] SUNRPC: Provide room in svc_rqst for larger
	addresses
Date: Thu, 18 Jan 2007 18:50:43 -0500
Message-ID: <20070118235043.24266.29000.stgit@localhost.localdomain>
References: <20070118234855.24266.37463.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1H7h1v-00056N-ST
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:51 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1H7h1x-00019c-3J
	for nfs@lists.sourceforge.net; Thu, 18 Jan 2007 15:50:53 -0800
To: neilb@suse.de
In-Reply-To: <20070118234855.24266.37463.stgit@localhost.localdomain>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

Expand the rq_addr field to allow it to contain larger addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon@ext.bull.net>
---

 fs/lockd/host.c            |    2 +-
 fs/lockd/svc4proc.c        |    6 ++++--
 fs/lockd/svcproc.c         |    6 ++++--
 fs/nfs/callback.c          |    2 +-
 fs/nfs/callback_xdr.c      |    4 ++--
 fs/nfsd/nfs4state.c        |   18 +++++++++---------
 fs/nfsd/nfscache.c         |    2 +-
 include/linux/sunrpc/svc.h |   17 +++++++++++++++--
 net/sunrpc/svcauth_unix.c  |    3 ++-
 net/sunrpc/svcsock.c       |   19 ++++++++++++-------
 10 files changed, 51 insertions(+), 28 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 3d4610c..22d4032 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -192,7 +192,7 @@ struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp,
 			const char *hostname, int hostname_len)
 {
-	return nlm_lookup_host(1, &rqstp->rq_addr,
+	return nlm_lookup_host(1, svc_addr_in(rqstp),
 			       rqstp->rq_prot, rqstp->rq_vers,
 			       hostname, hostname_len);
 }
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index d724eac..9ba4e56 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -224,7 +224,7 @@ nlm4svc_proc_granted(struct svc_rqst *rq
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&rqstp->rq_addr, &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
@@ -421,7 +421,9 @@ static __be32
 nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_in	saddr;
+
+	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
 
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index f590304..31cb484 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -253,7 +253,7 @@ nlmsvc_proc_granted(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&rqstp->rq_addr, &argp->lock);
+	resp->status = nlmclnt_grant(svc_addr_in(rqstp), &argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
@@ -452,7 +452,9 @@ static __be32
 nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_in	saddr;
+
+	memcpy(&saddr, svc_addr_in(rqstp), sizeof(saddr));
 
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 8c790af..75f309c 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -166,7 +166,7 @@ void nfs_callback_down(void)
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *addr = &rqstp->rq_addr;
+	struct sockaddr_in *addr = svc_addr_in(rqstp);
 	struct nfs_client *clp;
 	char buf[RPC_MAX_ADDRBUFLEN];
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f8ea1f5..849a202 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -176,7 +176,7 @@ static __be32 decode_getattr_args(struct
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		goto out;
-	args->addr = &rqstp->rq_addr;
+	args->addr = svc_addr_in(rqstp);
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
@@ -188,7 +188,7 @@ static __be32 decode_recall_args(struct 
 	__be32 *p;
 	__be32 status;
 
-	args->addr = &rqstp->rq_addr;
+	args->addr = svc_addr_in(rqstp);
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 9de89df..9e40679 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -714,7 +714,7 @@ __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		  struct nfsd4_setclientid *setclid)
 {
-	__be32 			ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	struct sockaddr_in	*sin = svc_addr_in(rqstp);
 	struct xdr_netobj 	clname = { 
 		.len = setclid->se_namelen,
 		.data = setclid->se_name,
@@ -749,7 +749,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 */
 		status = nfserr_clid_inuse;
 		if (!cmp_creds(&conf->cl_cred, &rqstp->rq_cred)
-				|| conf->cl_addr != ip_addr) {
+				|| conf->cl_addr != sin->sin_addr.s_addr) {
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
 			conf->cl_clientid.cl_boot, conf->cl_clientid.cl_id);
@@ -769,7 +769,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new, &clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -801,7 +801,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&conf->cl_verifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		copy_clid(new, conf);
 		gen_confirm(new);
@@ -820,7 +820,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -847,7 +847,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -881,7 +881,7 @@ nfsd4_setclientid_confirm(struct svc_rqs
 			 struct nfsd4_compound_state *cstate,
 			 struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
-	__be32 ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	struct sockaddr_in *sin = svc_addr_in(rqstp);
 	struct nfs4_client *conf, *unconf;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
@@ -900,9 +900,9 @@ nfsd4_setclientid_confirm(struct svc_rqs
 	unconf = find_unconfirmed_client(clid);
 
 	status = nfserr_clid_inuse;
-	if (conf && conf->cl_addr != ip_addr)
+	if (conf && conf->cl_addr != sin->sin_addr.s_addr)
 		goto out;
-	if (unconf && unconf->cl_addr != ip_addr)
+	if (unconf && unconf->cl_addr != sin->sin_addr.s_addr)
 		goto out;
 
 	if ((conf && unconf) && 
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index f90d704..578f2c9 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -185,7 +185,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
 	rp->c_proc = proc;
-	rp->c_addr = rqstp->rq_addr;
+	memcpy(&rp->c_addr, svc_addr_in(rqstp), sizeof(rp->c_addr));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
 	rp->c_timestamp = jiffies;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index b33b18f..bdd1f0a 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -197,8 +197,8 @@ struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct list_head	rq_all;		/* all threads list */
 	struct svc_sock *	rq_sock;	/* socket */
-	struct sockaddr_in	rq_addr;	/* peer address */
-	int			rq_addrlen;
+	struct sockaddr_storage	rq_addr;	/* peer address */
+	size_t			rq_addrlen;
 
 	struct svc_serv *	rq_server;	/* RPC service definition */
 	struct svc_pool *	rq_pool;	/* thread pool */
@@ -253,6 +253,19 @@ struct svc_rqst {
 };
 
 /*
+ * Rigorous type checking on sockaddr type conversions
+ */
+static inline struct sockaddr_in *svc_addr_in(struct svc_rqst *rqst)
+{
+	return (struct sockaddr_in *) &rqst->rq_addr;
+}
+
+static inline struct sockaddr *svc_addr(struct svc_rqst *rqst)
+{
+	return (struct sockaddr *) &rqst->rq_addr;
+}
+
+/*
  * Check buffer bounds after decoding arguments
  */
 static inline int
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index 0d1e8fb..30eba41 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -421,6 +421,7 @@ svcauth_unix_info_release(void *info)
 static int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
+	struct sockaddr_in *sin = svc_addr_in(rqstp);
 	struct ip_map *ipm;
 
 	rqstp->rq_client = NULL;
@@ -430,7 +431,7 @@ svcauth_unix_set_client(struct svc_rqst 
 	ipm = ip_map_cached_get(rqstp);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-				    rqstp->rq_addr.sin_addr);
+				    sin->sin_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index a831c95..140ff37 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -146,7 +146,7 @@ #endif
  */
 char *svc_print_addr(struct svc_rqst *rqstp, char *buf, size_t len)
 {
-	return __svc_print_addr((struct sockaddr *) &rqstp->rq_addr, buf, len);
+	return __svc_print_addr(svc_addr(rqstp), buf, len);
 }
 EXPORT_SYMBOL_GPL(svc_print_addr);
 
@@ -465,7 +465,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		/* set the source and destination */
 		struct msghdr	msg;
 		msg.msg_name    = &rqstp->rq_addr;
-		msg.msg_namelen = sizeof(rqstp->rq_addr);
+		msg.msg_namelen = rqstp->rq_addrlen;
 		msg.msg_iov     = NULL;
 		msg.msg_iovlen  = 0;
 		msg.msg_flags	= MSG_MORE;
@@ -688,6 +688,7 @@ svc_write_space(struct sock *sk)
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
+	struct sockaddr_in *sin = svc_addr_in(rqstp);
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
@@ -743,9 +744,12 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */
-	rqstp->rq_addr.sin_family = AF_INET;
-	rqstp->rq_addr.sin_port = skb->h.uh->source;
-	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	sin->sin_family = AF_INET;
+	sin->sin_port = skb->h.uh->source;
+	sin->sin_addr.s_addr = skb->nh.iph->saddr;
+	rqstp->rq_addrlen = sizeof(struct sockaddr_in);
+
+	/* Remember which interface received this request */
 	rqstp->rq_daddr = skb->nh.iph->daddr;
 
 	if (skb_is_nonlinear(skb)) {
@@ -1275,7 +1279,8 @@ svc_sock_update_bufs(struct svc_serv *se
 int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
-	struct svc_sock		*svsk =NULL;
+	struct svc_sock		*svsk = NULL;
+	struct sockaddr_in	*sin = svc_addr_in(rqstp);
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
@@ -1370,7 +1375,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	svsk->sk_lastrecv = get_seconds();
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
-	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
+	rqstp->rq_secure = ntohs(sin->sin_port) < PROT_SOCK;
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)

-------------------------------------------------------------------------
Take Surveys. Earn Cash. Influence the Future of IT
Join SourceForge.net's Techsay panel and you'll get the chance to share your
opinions on IT & business topics through brief surveys - and earn cash
http://www.techsay.com/default.php?page=join.php&p=sourceforge&CID=DEVDEV
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
