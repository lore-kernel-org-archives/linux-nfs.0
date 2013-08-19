Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:31623 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751341Ab3HSKPR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 19 Aug 2013 06:15:17 -0400
From: Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Cc: "David S. Miller" <davem@davemloft.net>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org,
        Cong Wang <amwang@redhat.com>
Subject: [Patch net-next v3 6/9] sunrpc: use generic union inet_addr
Date: Mon, 19 Aug 2013 18:14:35 +0800
Message-Id: <1376907278-26377-7-git-send-email-amwang@redhat.com>
In-Reply-To: <1376907278-26377-1-git-send-email-amwang@redhat.com>
References: <1376907278-26377-1-git-send-email-amwang@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>

sunrpc defines some helper functions for sockaddr, actually they
can re-use the generic functions for union inet_addr too.

Cc: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Signed-off-by: Cong Wang <amwang@redhat.com>
---
 fs/lockd/clntlock.c             |    2 +-
 fs/lockd/host.c                 |    8 +-
 fs/lockd/mon.c                  |    2 +-
 fs/lockd/svcsubs.c              |    2 +-
 fs/nfs/nfs4namespace.c          |    2 +-
 fs/nfs/super.c                  |    6 +-
 fs/nfsd/nfs4state.c             |    6 +-
 fs/nfsd/nfscache.c              |    8 +-
 include/linux/sunrpc/addr.h     |  131 +--------------------------------------
 include/net/inet_addr.h         |   99 ++++++++++++++++++++++++-----
 net/core/utils.c                |   25 ++++++++
 net/sunrpc/clnt.c               |    2 +-
 net/sunrpc/rpcb_clnt.c          |    2 +-
 net/sunrpc/xprtrdma/transport.c |    4 +-
 net/sunrpc/xprtsock.c           |    8 +-
 15 files changed, 134 insertions(+), 173 deletions(-)

diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 41e491b..289444e 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -184,7 +184,7 @@ __be32 nlmclnt_grant(const struct sockaddr *addr, const struct nlm_lock *lock)
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!rpc_cmp_addr(nlm_addr(block->b_host), addr))
+		if (!sockaddr_equal(nlm_addr(block->b_host), addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(file_inode(fl_blocked->fl_file)) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 969d589..155c720 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -134,7 +134,7 @@ static struct nlm_host *nlm_alloc_host(struct nlm_lookup_host_info *ni,
 
 	memcpy(nlm_addr(host), ni->sap, ni->salen);
 	host->h_addrlen    = ni->salen;
-	rpc_set_port(nlm_addr(host), 0);
+	sockaddr_set_port(nlm_addr(host), 0);
 	host->h_srcaddrlen = 0;
 
 	host->h_rpcclnt    = NULL;
@@ -240,7 +240,7 @@ struct nlm_host *nlmclnt_lookup_host(const struct sockaddr *sap,
 	hlist_for_each_entry(host, chain, h_hash) {
 		if (host->net != net)
 			continue;
-		if (!rpc_cmp_addr(nlm_addr(host), sap))
+		if (!sockaddr_equal(nlm_addr(host), sap))
 			continue;
 
 		/* Same address. Share an NSM handle if we already have one */
@@ -352,7 +352,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 	hlist_for_each_entry(host, chain, h_hash) {
 		if (host->net != net)
 			continue;
-		if (!rpc_cmp_addr(nlm_addr(host), ni.sap))
+		if (!sockaddr_equal(nlm_addr(host), ni.sap))
 			continue;
 
 		/* Same address. Share an NSM handle if we already have one */
@@ -363,7 +363,7 @@ struct nlm_host *nlmsvc_lookup_host(const struct svc_rqst *rqstp,
 			continue;
 		if (host->h_version != ni.version)
 			continue;
-		if (!rpc_cmp_addr(nlm_srcaddr(host), src_sap))
+		if (!sockaddr_equal(nlm_srcaddr(host), src_sap))
 			continue;
 
 		/* Move to head of hash chain. */
diff --git a/fs/lockd/mon.c b/fs/lockd/mon.c
index 1812f02..d36d65a 100644
--- a/fs/lockd/mon.c
+++ b/fs/lockd/mon.c
@@ -270,7 +270,7 @@ static struct nsm_handle *nsm_lookup_addr(const struct sockaddr *sap)
 	struct nsm_handle *nsm;
 
 	list_for_each_entry(nsm, &nsm_handles, sm_link)
-		if (rpc_cmp_addr(nsm_addr(nsm), sap))
+		if (sockaddr_equal(nsm_addr(nsm), sap))
 			return nsm;
 	return NULL;
 }
diff --git a/fs/lockd/svcsubs.c b/fs/lockd/svcsubs.c
index dc5c759..a9f4a6f 100644
--- a/fs/lockd/svcsubs.c
+++ b/fs/lockd/svcsubs.c
@@ -431,7 +431,7 @@ EXPORT_SYMBOL_GPL(nlmsvc_unlock_all_by_sb);
 static int
 nlmsvc_match_ip(void *datap, struct nlm_host *host)
 {
-	return rpc_cmp_addr(nlm_srcaddr(host), datap);
+	return sockaddr_equal(nlm_srcaddr(host), datap);
 }
 
 /**
diff --git a/fs/nfs/nfs4namespace.c b/fs/nfs/nfs4namespace.c
index cdb0b41..79767fc 100644
--- a/fs/nfs/nfs4namespace.c
+++ b/fs/nfs/nfs4namespace.c
@@ -243,7 +243,7 @@ static struct vfsmount *try_location(struct nfs_clone_mount *mountdata,
 		if (mountdata->addrlen == 0)
 			continue;
 
-		rpc_set_port(mountdata->addr, NFS_PORT);
+		sockaddr_set_port(mountdata->addr, NFS_PORT);
 
 		memcpy(page2, buf->data, buf->len);
 		page2[buf->len] = '\0';
diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f6db66d..ac7c359 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -978,7 +978,7 @@ static void nfs_set_port(struct sockaddr *sap, int *port,
 	if (*port == NFS_UNSPEC_PORT)
 		*port = default_port;
 
-	rpc_set_port(sap, *port);
+	sockaddr_set_port(sap, *port);
 }
 
 /*
@@ -2133,8 +2133,8 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	    data->timeo != (10U * nfss->client->cl_timeout->to_initval / HZ) ||
 	    data->nfs_server.port != nfss->port ||
 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
-	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
-			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
+	    !sockaddr_equal((struct sockaddr *)&data->nfs_server.address,
+			    (struct sockaddr *)&nfss->nfs_client->cl_addr))
 		return -EINVAL;
 
 	return 0;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 43f4229..92689bf 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1009,7 +1009,7 @@ static void init_session(struct svc_rqst *rqstp, struct nfsd4_session *new, stru
 		 * the rpc client not to require an address in the
 		 * future:
 		 */
-		rpc_copy_addr((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
+		sockaddr_copy((struct sockaddr *)&clp->cl_cb_conn.cb_addr, sa);
 		clp->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
 	}
 }
@@ -1362,7 +1362,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	clear_bit(0, &clp->cl_cb_slot_busy);
 	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	copy_verf(clp, verf);
-	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
+	sockaddr_copy((struct sockaddr *) &clp->cl_addr, sa);
 	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
 	clp->net = net;
@@ -1939,7 +1939,7 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 	} else if (unconf) {
 		struct nfs4_client *old;
 		if (!same_creds(&unconf->cl_cred, &rqstp->rq_cred) ||
-		    !rpc_cmp_addr(sa, (struct sockaddr *) &unconf->cl_addr)) {
+		    !sockaddr_equal(sa, (struct sockaddr *) &unconf->cl_addr)) {
 			status = nfserr_clid_inuse;
 			goto out_free_conn;
 		}
diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
index e76244e..e2561d6 100644
--- a/fs/nfsd/nfscache.c
+++ b/fs/nfsd/nfscache.c
@@ -318,8 +318,8 @@ nfsd_cache_match(struct svc_rqst *rqstp, __wsum csum, struct svc_cacherep *rp)
 	if (rqstp->rq_xid != rp->c_xid || rqstp->rq_proc != rp->c_proc ||
 	    rqstp->rq_prot != rp->c_prot || rqstp->rq_vers != rp->c_vers ||
 	    rqstp->rq_arg.len != rp->c_len ||
-	    !rpc_cmp_addr(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
-	    rpc_get_port(svc_addr(rqstp)) != rpc_get_port((struct sockaddr *)&rp->c_addr))
+	    !sockaddr_equal(svc_addr(rqstp), (struct sockaddr *)&rp->c_addr) ||
+	    sockaddr_get_port(svc_addr(rqstp)) != sockaddr_get_port((struct sockaddr *)&rp->c_addr))
 		return false;
 
 	/* compare checksum of NFS data */
@@ -446,8 +446,8 @@ search_cache:
 	rp->c_state = RC_INPROG;
 	rp->c_xid = xid;
 	rp->c_proc = proc;
-	rpc_copy_addr((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
-	rpc_set_port((struct sockaddr *)&rp->c_addr, rpc_get_port(svc_addr(rqstp)));
+	sockaddr_equal((struct sockaddr *)&rp->c_addr, svc_addr(rqstp));
+	sockaddr_set_port((struct sockaddr *)&rp->c_addr, sockaddr_get_port(svc_addr(rqstp)));
 	rp->c_prot = proto;
 	rp->c_vers = vers;
 	rp->c_len = rqstp->rq_arg.len;
diff --git a/include/linux/sunrpc/addr.h b/include/linux/sunrpc/addr.h
index 07d8e53..002be97 100644
--- a/include/linux/sunrpc/addr.h
+++ b/include/linux/sunrpc/addr.h
@@ -11,6 +11,7 @@
 #include <linux/in.h>
 #include <linux/in6.h>
 #include <net/ipv6.h>
+#include <net/inet_addr.h>
 
 size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(struct net *, const char *, const size_t,
@@ -19,139 +20,9 @@ char *		rpc_sockaddr2uaddr(const struct sockaddr *, gfp_t);
 size_t		rpc_uaddr2sockaddr(struct net *, const char *, const size_t,
 				   struct sockaddr *, const size_t);
 
-static inline unsigned short rpc_get_port(const struct sockaddr *sap)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		return ntohs(((struct sockaddr_in *)sap)->sin_port);
-	case AF_INET6:
-		return ntohs(((struct sockaddr_in6 *)sap)->sin6_port);
-	}
-	return 0;
-}
-
-static inline void rpc_set_port(struct sockaddr *sap,
-				const unsigned short port)
-{
-	switch (sap->sa_family) {
-	case AF_INET:
-		((struct sockaddr_in *)sap)->sin_port = htons(port);
-		break;
-	case AF_INET6:
-		((struct sockaddr_in6 *)sap)->sin6_port = htons(port);
-		break;
-	}
-}
-
 #define IPV6_SCOPE_DELIMITER		'%'
 #define IPV6_SCOPE_ID_LEN		sizeof("%nnnnnnnnnn")
 
-static inline bool __rpc_cmp_addr4(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in *sin1 = (const struct sockaddr_in *)sap1;
-	const struct sockaddr_in *sin2 = (const struct sockaddr_in *)sap2;
-
-	return sin1->sin_addr.s_addr == sin2->sin_addr.s_addr;
-}
-
-static inline bool __rpc_copy_addr4(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in *ssin = (struct sockaddr_in *) src;
-	struct sockaddr_in *dsin = (struct sockaddr_in *) dst;
-
-	dsin->sin_family = ssin->sin_family;
-	dsin->sin_addr.s_addr = ssin->sin_addr.s_addr;
-	return true;
-}
-
-#if IS_ENABLED(CONFIG_IPV6)
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	const struct sockaddr_in6 *sin1 = (const struct sockaddr_in6 *)sap1;
-	const struct sockaddr_in6 *sin2 = (const struct sockaddr_in6 *)sap2;
-
-	if (!ipv6_addr_equal(&sin1->sin6_addr, &sin2->sin6_addr))
-		return false;
-	else if (ipv6_addr_type(&sin1->sin6_addr) & IPV6_ADDR_LINKLOCAL)
-		return sin1->sin6_scope_id == sin2->sin6_scope_id;
-
-	return true;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	const struct sockaddr_in6 *ssin6 = (const struct sockaddr_in6 *) src;
-	struct sockaddr_in6 *dsin6 = (struct sockaddr_in6 *) dst;
-
-	dsin6->sin6_family = ssin6->sin6_family;
-	dsin6->sin6_addr = ssin6->sin6_addr;
-	dsin6->sin6_scope_id = ssin6->sin6_scope_id;
-	return true;
-}
-#else	/* !(IS_ENABLED(CONFIG_IPV6) */
-static inline bool __rpc_cmp_addr6(const struct sockaddr *sap1,
-				   const struct sockaddr *sap2)
-{
-	return false;
-}
-
-static inline bool __rpc_copy_addr6(struct sockaddr *dst,
-				    const struct sockaddr *src)
-{
-	return false;
-}
-#endif	/* !(IS_ENABLED(CONFIG_IPV6) */
-
-/**
- * rpc_cmp_addr - compare the address portion of two sockaddrs.
- * @sap1: first sockaddr
- * @sap2: second sockaddr
- *
- * Just compares the family and address portion. Ignores port, but
- * compares the scope if it's a link-local address.
- *
- * Returns true if the addrs are equal, false if they aren't.
- */
-static inline bool rpc_cmp_addr(const struct sockaddr *sap1,
-				const struct sockaddr *sap2)
-{
-	if (sap1->sa_family == sap2->sa_family) {
-		switch (sap1->sa_family) {
-		case AF_INET:
-			return __rpc_cmp_addr4(sap1, sap2);
-		case AF_INET6:
-			return __rpc_cmp_addr6(sap1, sap2);
-		}
-	}
-	return false;
-}
-
-/**
- * rpc_copy_addr - copy the address portion of one sockaddr to another
- * @dst: destination sockaddr
- * @src: source sockaddr
- *
- * Just copies the address portion and family. Ignores port, scope, etc.
- * Caller is responsible for making certain that dst is large enough to hold
- * the address in src. Returns true if address family is supported. Returns
- * false otherwise.
- */
-static inline bool rpc_copy_addr(struct sockaddr *dst,
-				 const struct sockaddr *src)
-{
-	switch (src->sa_family) {
-	case AF_INET:
-		return __rpc_copy_addr4(dst, src);
-	case AF_INET6:
-		return __rpc_copy_addr6(dst, src);
-	}
-	return false;
-}
-
 /**
  * rpc_get_scope_id - return scopeid for a given sockaddr
  * @sa: sockaddr to get scopeid from
diff --git a/include/net/inet_addr.h b/include/net/inet_addr.h
index ee80df4..44179c8 100644
--- a/include/net/inet_addr.h
+++ b/include/net/inet_addr.h
@@ -36,17 +36,6 @@ bool in_addr_gen_equal(const struct in_addr_gen *a, const struct in_addr_gen *b)
 }
 
 #if IS_ENABLED(CONFIG_IPV6)
-static inline
-bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
-{
-	if (a->sa.sa_family != b->sa.sa_family)
-		return false;
-	if (a->sa.sa_family == AF_INET6)
-		return ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr);
-	else
-		return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
-}
-
 static inline bool inet_addr_any(const union inet_addr *ipa)
 {
 	if (ipa->sa.sa_family == AF_INET6)
@@ -65,12 +54,6 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
 
 #else /* !CONFIG_IPV6 */
 
-static inline
-bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
-{
-	return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
-}
-
 static inline bool inet_addr_any(const union inet_addr *ipa)
 {
 	return ipa->sin.sin_addr.s_addr == htonl(INADDR_ANY);
@@ -82,6 +65,88 @@ static inline bool inet_addr_multicast(const union inet_addr *ipa)
 }
 #endif
 
+/**
+ * inet_addr_copy - copy the address portion of one inet_addr to another
+ * @dst: destination sockaddr
+ * @src: source sockaddr
+ *
+ * Just copies the address portion and family. Ignores port, scope, etc.
+ * Caller is responsible for making certain that dst is large enough to hold
+ * the address in src. Returns true if address family is supported. Returns
+ * false otherwise.
+ */
+static inline bool inet_addr_copy(union inet_addr *dst,
+				  const union inet_addr *src)
+{
+	dst->sa.sa_family = src->sa.sa_family;
+
+	switch (src->sa.sa_family) {
+	case AF_INET:
+		dst->sin.sin_addr.s_addr = src->sin.sin_addr.s_addr;
+		return true;
+#if IS_ENABLED(CONFIG_IPV6)
+	case AF_INET6:
+		dst->sin6.sin6_addr = src->sin6.sin6_addr;
+		dst->sin6.sin6_scope_id = src->sin6.sin6_scope_id;
+		return true;
+#endif
+	}
+
+	return false;
+}
+
+static inline
+unsigned short inet_addr_get_port(const union inet_addr *sap)
+{
+	switch (sap->sa.sa_family) {
+	case AF_INET:
+		return ntohs(sap->sin.sin_port);
+	case AF_INET6:
+		return ntohs(sap->sin6.sin6_port);
+	}
+	return 0;
+}
+
+static inline
+void inet_addr_set_port(union inet_addr *sap,
+			const unsigned short port)
+{
+	switch (sap->sa.sa_family) {
+	case AF_INET:
+		sap->sin.sin_port = htons(port);
+		break;
+	case AF_INET6:
+		sap->sin6.sin6_port = htons(port);
+		break;
+	}
+}
+
+bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b);
 int simple_inet_pton(const char *str, union inet_addr *addr);
 
+static inline bool sockaddr_equal(const struct sockaddr *sap1,
+				  const struct sockaddr *sap2)
+{
+	return inet_addr_equal((const union inet_addr *)sap1,
+			       (const union inet_addr *)sap2);
+}
+
+static inline bool sockaddr_copy(struct sockaddr *dst,
+				 const struct sockaddr *src)
+{
+	return inet_addr_copy((union inet_addr *)dst,
+			      (const union inet_addr *)src);
+}
+
+static inline unsigned short sockaddr_get_port(const struct sockaddr *sap)
+{
+	return inet_addr_get_port((const union inet_addr *)sap);
+}
+
+static inline void sockaddr_set_port(struct sockaddr *sap,
+				const unsigned short port)
+{
+	inet_addr_set_port((union inet_addr *)sap, port);
+}
+
 #endif
diff --git a/net/core/utils.c b/net/core/utils.c
index 22dd621..837bb18 100644
--- a/net/core/utils.c
+++ b/net/core/utils.c
@@ -374,3 +374,28 @@ int simple_inet_pton(const char *str, union inet_addr *addr)
 	return -EINVAL;
 }
 EXPORT_SYMBOL(simple_inet_pton);
+
+#if IS_ENABLED(CONFIG_IPV6)
+bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
+{
+	if (a->sa.sa_family != b->sa.sa_family)
+		return false;
+	else if (a->sa.sa_family == AF_INET6) {
+		if (!ipv6_addr_equal(&a->sin6.sin6_addr, &b->sin6.sin6_addr))
+			return false;
+		else if (__ipv6_addr_needs_scope_id(__ipv6_addr_type(&a->sin6.sin6_addr)))
+			return a->sin6.sin6_scope_id == b->sin6.sin6_scope_id;
+		else
+			return true;
+	} else
+		return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+#else
+bool inet_addr_equal(const union inet_addr *a, const union inet_addr *b)
+{
+	if (a->sa.sa_family == AF_UNSPEC)
+		return a->sa.sa_family == b->sa.sa_family;
+	return a->sin.sin_addr.s_addr == b->sin.sin_addr.s_addr;
+}
+#endif
+EXPORT_SYMBOL(inet_addr_equal);
diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index ecbc4e3..49fe013 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1137,7 +1137,7 @@ int rpc_localaddr(struct rpc_clnt *clnt, struct sockaddr *buf, size_t buflen)
 	net = get_net(xprt->xprt_net);
 	rcu_read_unlock();
 
-	rpc_set_port(sap, 0);
+	sockaddr_set_port(sap, 0);
 	err = rpc_sockname(net, sap, salen, buf, buflen);
 	put_net(net);
 	if (err != 0)
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 1891a10..8078161 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -971,7 +971,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	if (rpc_uaddr2sockaddr(req->rq_xprt->xprt_net, (char *)p, len,
 				sap, sizeof(address)) == 0)
 		goto out_fail;
-	rpcb->r_port = rpc_get_port(sap);
+	rpcb->r_port = sockaddr_get_port(sap);
 
 	return 0;
 
diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 285dc08..aa09a36 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -162,7 +162,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 	(void)rpc_ntop(sap, buf, sizeof(buf));
 	xprt->address_strings[RPC_DISPLAY_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%u", sockaddr_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	xprt->address_strings[RPC_DISPLAY_PROTO] = "rdma";
@@ -170,7 +170,7 @@ xprt_rdma_format_addresses(struct rpc_xprt *xprt)
 	snprintf(buf, sizeof(buf), "%08x", ntohl(sin->sin_addr.s_addr));
 	xprt->address_strings[RPC_DISPLAY_HEX_ADDR] = kstrdup(buf, GFP_KERNEL);
 
-	snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%4hx", sockaddr_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 
 	/* netid */
diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index d6656d7..5922c8b 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -333,10 +333,10 @@ static void xs_format_common_peer_ports(struct rpc_xprt *xprt)
 	struct sockaddr *sap = xs_addr(xprt);
 	char buf[128];
 
-	snprintf(buf, sizeof(buf), "%u", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%u", sockaddr_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_PORT] = kstrdup(buf, GFP_KERNEL);
 
-	snprintf(buf, sizeof(buf), "%4hx", rpc_get_port(sap));
+	snprintf(buf, sizeof(buf), "%4hx", sockaddr_get_port(sap));
 	xprt->address_strings[RPC_DISPLAY_HEX_PORT] = kstrdup(buf, GFP_KERNEL);
 }
 
@@ -1674,7 +1674,7 @@ static void xs_set_port(struct rpc_xprt *xprt, unsigned short port)
 {
 	dprintk("RPC:       setting port for xprt %p to %u\n", xprt, port);
 
-	rpc_set_port(xs_addr(xprt), port);
+	sockaddr_set_port(xs_addr(xprt), port);
 	xs_update_peer_port(xprt);
 }
 
@@ -1706,7 +1706,7 @@ static int xs_bind(struct sock_xprt *transport, struct socket *sock)
 
 	memcpy(&myaddr, &transport->srcaddr, transport->xprt.addrlen);
 	do {
-		rpc_set_port((struct sockaddr *)&myaddr, port);
+		sockaddr_set_port((struct sockaddr *)&myaddr, port);
 		err = kernel_bind(sock, (struct sockaddr *)&myaddr,
 				transport->xprt.addrlen);
 		if (port == 0)
-- 
1.7.7.6

