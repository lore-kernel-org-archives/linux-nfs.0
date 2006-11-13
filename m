From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/13] SUNRPC: Provide room in svc_rqst for larger
	addresses
Date: Mon, 13 Nov 2006 07:58:19 -0500
Message-ID: <20061113125819.4435.84338.stgit@localhost.localdomain>
References: <20061113125640.4435.11957.stgit@localhost.localdomain>
Reply-To: Chuck Lever <chucklever@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1GjdfX-0004E0-Al
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:24:19 -0800
Received: from rgminet01.oracle.com ([148.87.113.118])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1GjdfX-0004PX-RL
	for nfs@lists.sourceforge.net; Mon, 13 Nov 2006 07:24:20 -0800
To: neilb@suse.de
In-Reply-To: <20061113125640.4435.11957.stgit@localhost.localdomain>
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

 fs/lockd/host.c            |    4 ++--
 fs/lockd/svc4proc.c        |    7 +++++--
 fs/lockd/svcproc.c         |    7 +++++--
 fs/nfs/callback.c          |    2 +-
 fs/nfs/callback_xdr.c      |    4 ++--
 fs/nfsd/nfs4state.c        |   18 +++++++++---------
 fs/nfsd/nfscache.c         |    2 +-
 include/linux/sunrpc/svc.h |    2 +-
 net/sunrpc/svcauth_unix.c  |    3 ++-
 net/sunrpc/svcsock.c       |   14 ++++++++------
 10 files changed, 36 insertions(+), 27 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index fb24a97..ca625dd 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -55,9 +55,9 @@ struct nlm_host *
 nlmsvc_lookup_host(struct svc_rqst *rqstp,
 			const char *hostname, int hostname_len)
 {
-	return nlm_lookup_host(1, &rqstp->rq_addr,
+	return nlm_lookup_host(1, (struct sockaddr_in *) &rqstp->rq_addr,
 			       rqstp->rq_prot, rqstp->rq_vers,
-			       hostname, hostname_len);
+				hostname, hostname_len);
 }
 
 /*
diff --git a/fs/lockd/svc4proc.c b/fs/lockd/svc4proc.c
index d724eac..15fa167 100644
--- a/fs/lockd/svc4proc.c
+++ b/fs/lockd/svc4proc.c
@@ -224,7 +224,8 @@ nlm4svc_proc_granted(struct svc_rqst *rq
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&rqstp->rq_addr, &argp->lock);
+	resp->status = nlmclnt_grant((struct sockaddr_in *) &rqstp->rq_addr,
+								&argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
@@ -421,7 +422,9 @@ static __be32
 nlm4svc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_in	saddr;
+
+	memcpy(&saddr, &rqstp->rq_addr, sizeof(saddr));
 
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
diff --git a/fs/lockd/svcproc.c b/fs/lockd/svcproc.c
index f590304..0cc9ab1 100644
--- a/fs/lockd/svcproc.c
+++ b/fs/lockd/svcproc.c
@@ -253,7 +253,8 @@ nlmsvc_proc_granted(struct svc_rqst *rqs
 	resp->cookie = argp->cookie;
 
 	dprintk("lockd: GRANTED       called\n");
-	resp->status = nlmclnt_grant(&rqstp->rq_addr, &argp->lock);
+	resp->status = nlmclnt_grant((struct sockaddr_in *) &rqstp->rq_addr,
+								&argp->lock);
 	dprintk("lockd: GRANTED       status %d\n", ntohl(resp->status));
 	return rpc_success;
 }
@@ -452,7 +453,9 @@ static __be32
 nlmsvc_proc_sm_notify(struct svc_rqst *rqstp, struct nlm_reboot *argp,
 					      void	        *resp)
 {
-	struct sockaddr_in	saddr = rqstp->rq_addr;
+	struct sockaddr_in	saddr;
+
+	memcpy(&saddr, &rqstp->rq_addr, sizeof(saddr));
 
 	dprintk("lockd: SM_NOTIFY     called\n");
 	if (saddr.sin_addr.s_addr != htonl(INADDR_LOOPBACK)
diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index d277ff9..c6be8ac 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -166,7 +166,7 @@ void nfs_callback_down(void)
 
 static int nfs_callback_authenticate(struct svc_rqst *rqstp)
 {
-	struct sockaddr_in *addr = &rqstp->rq_addr;
+	struct sockaddr_in *addr = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct nfs_client *clp;
 	char buf[RPC_MAX_ADDRBUFLEN];
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f8ea1f5..70ae2ef 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -176,7 +176,7 @@ static __be32 decode_getattr_args(struct
 	status = decode_fh(xdr, &args->fh);
 	if (unlikely(status != 0))
 		goto out;
-	args->addr = &rqstp->rq_addr;
+	args->addr = (struct sockaddr_in *) &rqstp->rq_addr;
 	status = decode_bitmap(xdr, args->bitmap);
 out:
 	dprintk("%s: exit with status = %d\n", __FUNCTION__, status);
@@ -188,7 +188,7 @@ static __be32 decode_recall_args(struct 
 	__be32 *p;
 	__be32 status;
 
-	args->addr = &rqstp->rq_addr;
+	args->addr = (struct sockaddr_in *) &rqstp->rq_addr;
 	status = decode_stateid(xdr, &args->stateid);
 	if (unlikely(status != 0))
 		goto out;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 293b649..f6af541 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -713,7 +713,7 @@ out_err:
 __be32
 nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_setclientid *setclid)
 {
-	__be32 			ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	struct sockaddr_in	*sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct xdr_netobj 	clname = { 
 		.len = setclid->se_namelen,
 		.data = setclid->se_name,
@@ -748,7 +748,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		 */
 		status = nfserr_clid_inuse;
 		if (!cmp_creds(&conf->cl_cred, &rqstp->rq_cred)
-				|| conf->cl_addr != ip_addr) {
+				|| conf->cl_addr != sin->sin_addr.s_addr) {
 			printk("NFSD: setclientid: string in use by client"
 			"(clientid %08x/%08x)\n",
 			conf->cl_clientid.cl_boot, conf->cl_clientid.cl_id);
@@ -768,7 +768,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new, &clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -800,7 +800,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&conf->cl_verifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		copy_clid(new, conf);
 		gen_confirm(new);
@@ -819,7 +819,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -846,7 +846,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp
 		if (new == NULL)
 			goto out;
 		copy_verf(new,&clverifier);
-		new->cl_addr = ip_addr;
+		new->cl_addr = sin->sin_addr.s_addr;
 		copy_cred(&new->cl_cred,&rqstp->rq_cred);
 		gen_clid(new);
 		gen_confirm(new);
@@ -878,7 +878,7 @@ out:
 __be32
 nfsd4_setclientid_confirm(struct svc_rqst *rqstp, struct nfsd4_setclientid_confirm *setclientid_confirm)
 {
-	__be32 ip_addr = rqstp->rq_addr.sin_addr.s_addr;
+	struct sockaddr_in *sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct nfs4_client *conf, *unconf;
 	nfs4_verifier confirm = setclientid_confirm->sc_confirm; 
 	clientid_t * clid = &setclientid_confirm->sc_clientid;
@@ -897,9 +897,9 @@ nfsd4_setclientid_confirm(struct svc_rqs
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
index 6100bbe..b2da4f9 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -186,7 +186,7 @@ nfsd_cache_lookup(struct svc_rqst *rqstp
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
 	rp->c_proc = proc;
-	rp->c_addr = rqstp->rq_addr;
+	memcpy(&rp->c_addr, &rqstp->rq_addr, sizeof(rp->c_addr));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
 	rp->c_timestamp = jiffies;
diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 8720aa5..7aa11f2 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -197,7 +197,7 @@ struct svc_rqst {
 	struct list_head	rq_list;	/* idle list */
 	struct list_head	rq_all;		/* all threads list */
 	struct svc_sock *	rq_sock;	/* socket */
-	struct sockaddr_in	rq_addr;	/* peer address */
+	struct sockaddr_storage	rq_addr;	/* peer address */
 	int			rq_addrlen;
 
 	struct svc_serv *	rq_server;	/* RPC service definition */
diff --git a/net/sunrpc/svcauth_unix.c b/net/sunrpc/svcauth_unix.c
index e1bd933..21d392a 100644
--- a/net/sunrpc/svcauth_unix.c
+++ b/net/sunrpc/svcauth_unix.c
@@ -417,6 +417,7 @@ svcauth_unix_info_release(void *info)
 static int
 svcauth_unix_set_client(struct svc_rqst *rqstp)
 {
+	struct sockaddr_in *sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct ip_map *ipm;
 
 	rqstp->rq_client = NULL;
@@ -426,7 +427,7 @@ svcauth_unix_set_client(struct svc_rqst 
 	ipm = ip_map_cached_get(rqstp);
 	if (ipm == NULL)
 		ipm = ip_map_lookup(rqstp->rq_server->sv_program->pg_class,
-				    rqstp->rq_addr.sin_addr);
+				    sin->sin_addr);
 
 	if (ipm == NULL)
 		return SVC_DENIED;
diff --git a/net/sunrpc/svcsock.c b/net/sunrpc/svcsock.c
index d93b7cb..2e6e3e4 100644
--- a/net/sunrpc/svcsock.c
+++ b/net/sunrpc/svcsock.c
@@ -435,7 +435,7 @@ svc_sendto(struct svc_rqst *rqstp, struc
 		/* set the source and destination */
 		struct msghdr	msg;
 		msg.msg_name    = &rqstp->rq_addr;
-		msg.msg_namelen = sizeof(rqstp->rq_addr);
+		msg.msg_namelen = rqstp->rq_addrlen;
 		msg.msg_iov     = NULL;
 		msg.msg_iovlen  = 0;
 		msg.msg_flags	= MSG_MORE;
@@ -658,6 +658,7 @@ svc_write_space(struct sock *sk)
 static int
 svc_udp_recvfrom(struct svc_rqst *rqstp)
 {
+	struct sockaddr_in *sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct svc_sock	*svsk = rqstp->rq_sock;
 	struct svc_serv	*serv = svsk->sk_server;
 	struct sk_buff	*skb;
@@ -713,9 +714,9 @@ svc_udp_recvfrom(struct svc_rqst *rqstp)
 	rqstp->rq_prot        = IPPROTO_UDP;
 
 	/* Get sender address */
-	rqstp->rq_addr.sin_family = AF_INET;
-	rqstp->rq_addr.sin_port = skb->h.uh->source;
-	rqstp->rq_addr.sin_addr.s_addr = skb->nh.iph->saddr;
+	sin->sin_family = AF_INET;
+	sin->sin_port = skb->h.uh->source;
+	sin->sin_addr.s_addr = skb->nh.iph->saddr;
 	rqstp->rq_daddr = skb->nh.iph->daddr;
 
 	if (skb_is_nonlinear(skb)) {
@@ -1245,7 +1246,8 @@ svc_sock_update_bufs(struct svc_serv *se
 int
 svc_recv(struct svc_rqst *rqstp, long timeout)
 {
-	struct svc_sock		*svsk =NULL;
+	struct svc_sock		*svsk = NULL;
+	struct sockaddr_in	*sin = (struct sockaddr_in *) &rqstp->rq_addr;
 	struct svc_serv		*serv = rqstp->rq_server;
 	struct svc_pool		*pool = rqstp->rq_pool;
 	int			len, i;
@@ -1340,7 +1342,7 @@ svc_recv(struct svc_rqst *rqstp, long ti
 	svsk->sk_lastrecv = get_seconds();
 	clear_bit(SK_OLD, &svsk->sk_flags);
 
-	rqstp->rq_secure  = ntohs(rqstp->rq_addr.sin_port) < 1024;
+	rqstp->rq_secure = ntohs(sin->sin_port) < 1024;
 	rqstp->rq_chandle.defer = svc_defer;
 
 	if (serv->sv_stats)

-------------------------------------------------------------------------
Using Tomcat but need to do more? Need to support web services, security?
Get stuff done quickly with pre-integrated technology to make your job easier
Download IBM WebSphere Application Server v.1.0.1 based on Apache Geronimo
http://sel.as-us.falkag.net/sel?cmd=lnk&kid=120709&bid=263057&dat=121642
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
