Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:38251 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754530Ab2KMPp4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 13 Nov 2012 10:45:56 -0500
Subject: [PATCH 02/15] nfsd: make nfs4_client network namespace dependent
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, devel@openvz.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, jlayton@redhat.com
Date: Tue, 13 Nov 2012 18:48:28 +0300
Message-ID: <20121113154828.12577.80401.stgit@localhost.localdomain>
In-Reply-To: <20121113154722.12577.57671.stgit@localhost.localdomain>
References: <20121113154722.12577.57671.stgit@localhost.localdomain>
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
index 151921b..83d2669 100644
--- a/fs/nfsd/nfs4recover.c
+++ b/fs/nfsd/nfs4recover.c
@@ -786,8 +786,7 @@ nfsd4_cld_create(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if it's already stored */
@@ -824,8 +823,7 @@ nfsd4_cld_remove(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if it's already removed */
@@ -862,8 +860,7 @@ nfsd4_cld_check(struct nfs4_client *clp)
 {
 	int ret;
 	struct cld_upcall *cup;
-	/* FIXME: determine net from clp */
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
+	struct nfsd_net *nn = net_generic(clp->net, nfsd_net_id);
 	struct cld_net *cn = nn->cld_net;
 
 	/* Don't upcall if one was already stored during this grace pd */
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 6a3661b..865a793 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1247,10 +1247,9 @@ same_creds(struct svc_cred *cr1, struct svc_cred *cr2)
 	return 0 == strcmp(cr1->cr_principal, cr2->cr_principal);
 }
 
-static void gen_clid(struct nfs4_client *clp)
+static void gen_clid(struct nfs4_client *clp, struct nfsd_net *nn)
 {
 	static u32 current_clientid = 1;
-	struct nfsd_net *nn = net_generic(&init_net, nfsd_net_id);
 
 	clp->cl_clientid.cl_boot = nn->boot_time;
 	clp->cl_clientid.cl_id = current_clientid++; 
@@ -1289,6 +1288,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	struct nfs4_client *clp;
 	struct sockaddr *sa = svc_addr(rqstp);
 	int ret;
+	struct net *net = SVC_NET(rqstp);
 
 	clp = alloc_client(name);
 	if (clp == NULL)
@@ -1321,6 +1321,7 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir,
 	rpc_copy_addr((struct sockaddr *) &clp->cl_addr, sa);
 	gen_confirm(clp);
 	clp->cl_cb_session = NULL;
+	clp->net = net;
 	return clp;
 }
 
@@ -1428,7 +1429,7 @@ gen_callback(struct nfs4_client *clp, struct nfsd4_setclientid *se, struct svc_r
 	else
 		goto out_err;
 
-	conn->cb_addrlen = rpc_uaddr2sockaddr(&init_net, se->se_callback_addr_val,
+	conn->cb_addrlen = rpc_uaddr2sockaddr(clp->net, se->se_callback_addr_val,
 					    se->se_callback_addr_len,
 					    (struct sockaddr *)&conn->cb_addr,
 					    sizeof(conn->cb_addr));
@@ -1578,6 +1579,7 @@ nfsd4_exchange_id(struct svc_rqst *rqstp,
 	nfs4_verifier		verf = exid->verifier;
 	struct sockaddr		*sa = svc_addr(rqstp);
 	bool	update = exid->flags & EXCHGID4_FLAG_UPD_CONFIRMED_REC_A;
+	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
 
 	rpc_ntop(sa, addr_str, sizeof(addr_str));
 	dprintk("%s rqstp=%p exid=%p clname.len=%u clname.data=%p "
@@ -1667,7 +1669,7 @@ out_new:
 	}
 	new->cl_minorversion = 1;
 
-	gen_clid(new);
+	gen_clid(new, nn);
 	add_to_unconfirmed(new, strhashval);
 out_copy:
 	exid->clientid.cl_boot = new->cl_clientid.cl_boot;
@@ -2199,7 +2201,8 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 	struct nfs4_client	*conf, *unconf, *new;
 	__be32 			status;
 	char                    dname[HEXDIR_LEN];
-	
+	struct nfsd_net		*nn = net_generic(SVC_NET(rqstp), nfsd_net_id);
+
 	status = nfs4_make_rec_clidname(dname, &clname);
 	if (status)
 		return status;
@@ -2234,7 +2237,7 @@ nfsd4_setclientid(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		/* case 1: probable callback update */
 		copy_clid(new, conf);
 	else /* case 4 (new client) or cases 2, 3 (client reboot): */
-		gen_clid(new);
+		gen_clid(new, nn);
 	new->cl_minorversion = 0;
 	gen_callback(new, setclid, rqstp);
 	add_to_unconfirmed(new, strhashval);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 8053b57..b064577 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -283,6 +283,7 @@ struct nfs4_client {
 	unsigned long		cl_cb_slot_busy;
 	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
 						/* wait here for slots */
+	struct net		*net;
 };
 
 static inline void

