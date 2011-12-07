Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25632 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755610Ab1LGLU5 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Dec 2011 06:20:57 -0500
Subject: [PATCH 4/4] SUNRPC: use passed network namespace context in
 rpc_uaddr2sockaddr()
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 07 Dec 2011 15:20:40 +0300
Message-ID: <20111207112039.17273.45973.stgit@localhost6.localdomain6>
In-Reply-To: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
References: <20111207111716.17273.63010.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use incomming network context in rpc_uaddr2sockaddr() instead of hard-coded
"init_net".

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfsd/nfs4state.c         |    2 +-
 include/linux/sunrpc/clnt.h |    2 +-
 net/sunrpc/addr.c           |    8 +++++---
 net/sunrpc/rpcb_clnt.c      |    2 +-
 4 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 47e94e3..e18f46f 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1301,7 +1301,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
 	else
 		goto out_err;
 
-	conn->cb_addrlen = rpc_uaddr2sockaddr(se->se_callback_addr_val,
+	conn->cb_addrlen = rpc_uaddr2sockaddr(&init_net, se->se_callback_addr_val,
 					    se->se_callback_addr_len,
 					    (struct sockaddr *)&conn->cb_addr,
 					    sizeof(conn->cb_addr));
diff --git a/include/linux/sunrpc/clnt.h b/include/linux/sunrpc/clnt.h
index 877a466..029fb48 100644
--- a/include/linux/sunrpc/clnt.h
+++ b/include/linux/sunrpc/clnt.h
@@ -165,7 +165,7 @@ size_t		rpc_ntop(const struct sockaddr *, char *, const size_t);
 size_t		rpc_pton(struct net *, const char *, const size_t,
 			 struct sockaddr *, const size_t);
 char *		rpc_sockaddr2uaddr(const struct sockaddr *, gfp_t);
-size_t		rpc_uaddr2sockaddr(const char *, const size_t,
+size_t		rpc_uaddr2sockaddr(struct net *, const char *, const size_t,
 				   struct sockaddr *, const size_t);
 
 static inline unsigned short rpc_get_port(const struct sockaddr *sap)
diff --git a/net/sunrpc/addr.c b/net/sunrpc/addr.c
index 982fac7..bad31da 100644
--- a/net/sunrpc/addr.c
+++ b/net/sunrpc/addr.c
@@ -297,6 +297,7 @@ char *rpc_sockaddr2uaddr(const struct sockaddr *sap, gfp_t gfp_flags)
 
 /**
  * rpc_uaddr2sockaddr - convert a universal address to a socket address.
+ * @net: applicable network namespace
  * @uaddr: C string containing universal address to convert
  * @uaddr_len: length of universal address string
  * @sap: buffer into which to plant socket address
@@ -308,8 +309,9 @@ char *rpc_sockaddr2uaddr(const struct sockaddr *sap, gfp_t gfp_flags)
  * Returns the size of the socket address if successful; otherwise
  * zero is returned.
  */
-size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
-			  struct sockaddr *sap, const size_t salen)
+size_t rpc_uaddr2sockaddr(struct net *net, const char *uaddr,
+			  const size_t uaddr_len, struct sockaddr *sap,
+			  const size_t salen)
 {
 	char *c, buf[RPCBIND_MAXUADDRLEN + sizeof('\0')];
 	unsigned long portlo, porthi;
@@ -341,7 +343,7 @@ size_t rpc_uaddr2sockaddr(const char *uaddr, const size_t uaddr_len,
 	port = (unsigned short)((porthi << 8) | portlo);
 
 	*c = '\0';
-	if (rpc_pton(&init_net, buf, strlen(buf), sap, salen) == 0)
+	if (rpc_pton(net, buf, strlen(buf), sap, salen) == 0)
 		return 0;
 
 	switch (sap->sa_family) {
diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 8761bf8..42e1b2e 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -925,7 +925,7 @@ static int rpcb_dec_getaddr(struct rpc_rqst *req, struct xdr_stream *xdr,
 	dprintk("RPC: %5u RPCB_%s reply: %s\n", task->tk_pid,
 			task->tk_msg.rpc_proc->p_name, (char *)p);
 
-	if (rpc_uaddr2sockaddr((char *)p, len, sap, sizeof(address)) == 0)
+	if (rpc_uaddr2sockaddr(&init_net, (char *)p, len, sap, sizeof(address)) == 0)
 		goto out_fail;
 	rpcb->r_port = rpc_get_port(sap);
 

