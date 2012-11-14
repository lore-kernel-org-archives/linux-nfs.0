Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:13564 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752655Ab2KNPSi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Nov 2012 10:18:38 -0500
Subject: [PATCH v2 02/15] nfsd: make nfs4_client network namespace dependent
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Wed, 14 Nov 2012 18:21:10 +0300
Message-ID: <20121114152110.4708.27500.stgit@localhost.localdomain>
In-Reply-To: <20121114152018.4708.63125.stgit@localhost.localdomain>
References: <20121114152018.4708.63125.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

And use it's net where possible.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/nfs4callback.c |    2 +-
 fs/nfsd/nfs4recover.c  |    9 +++------
 fs/nfsd/nfs4state.c    |   15 +++++++++------
 fs/nfsd/state.h        |    1 +
 4 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7bb187a..8bbe873 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -663,7 +663,7 @@ static int setup_callback_client(struct nfs4_client *clp, struct nfs4_cb_conn *c
 		.to_retries	= 0,
 	};
 	struct rpc_create_args args = {
-		.net		= &init_net,
+		.net		= clp->net,
 		.address	= (struct sockaddr *) &conn->cb_addr,
 		.addrsize	= conn->cb_addrlen,
 		.saddress	= (struct sockaddr *) &conn->cb_saddr,
diff --git a/fs/nfsd/nfs4recover.c b/fs/nfsd/nfs4recover.c
index b03b6aa..9881bca 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -859,8 +859,7 @@ nfsd4_cld_create(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if it's already stored */
@@ -897,8 +896,7 @@ nfsd4_cld_remove(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if it's already removed */
@@ -935,8 +933,7 @@ nfsd4_cld_check(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if one was already stored during this grace pd */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 743c622..9b4df00 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1263,10 +1263,9 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
 }
 
-static void gen_clid(struct nfs4_client *clp)
+static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	static u32 current_clientid = 1;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	clp->cl_clientid.cl_boot = nn->boot_time;
 	clp->cl_clientid.cl_id = current_clientid++; 
@@ -1305,6 +1304,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	struct nfs4_client *clp;
 	struct sockaddr *sa = svc_addr(rqstp);
 	int ret;
+	struct net *net = SVC_NET(rqstp);
 
 	clp = alloc_client(name);
 	if (clp == NULL)
@@ -1335,6 +1335,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name,
 	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
 	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
+	clp->net = net;
 	return clp;
 }
 
@@ -1471,7 +1472,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
 	else
 		goto out_err;
 
-	conn->cb_addrlen = rpc_uaddr2sockaddr(&init_net, se->se_callback_addr_val,
+	conn->cb_addrlen = rpc_uaddr2sockaddr(clp->net, se->se_callback_addr_val,
 					    se->se_callback_addr_len,
 					    (struct sockaddr *)&conn->cb_addr,
 					    sizeof(conn->cb_addr));
@@ -1619,6 +1620,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
 	bool	update = exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A;
+	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	rpc_ntop(sa, addr_str, sizeof(addr_str));
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
@@ -1701,7 +1703,7 @@ out_new:
 	}
 	new->cl_minorversion = 1;
 
-	gen_clid(new);
+	gen_clid(new, nn);
 	add_to_unconfirmed(new);
 out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
@@ -2229,7 +2231,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	nfs4_verifier		clverifier = setclid->se_verf;
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
-	
+	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 	/* Cases below refer to rfc 3530 section 14.2.33: */
 	nfs4_lock_state();
 	conf = find_confirmed_client_by_name(&clname);
@@ -2258,7 +2261,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
 	else /* case 4 (new client) or cases 2, 3 (client reboot): */
-		gen_clid(new);
+		gen_clid(new, nn);
 	new->cl_minorversion = 0;
 	gen_callback(new, setclid, rqstp);
 	add_to_unconfirmed(new);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 029217a..ca8ee8c 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -283,6 +283,7 @@ struct nfs4_client {
 	unsigned long		cl_cb_slot_busy;
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
+	struct net		*net;
 };
 
 static inline void

