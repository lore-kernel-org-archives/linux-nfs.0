Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:32321 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752775Ab2AZLMK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 26 Jan 2012 06:12:10 -0500
Subject: [PATCH 3/5] NFS: search for client session id in proper network
 namespace
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Thu, 26 Jan 2012 15:11:49 +0400
Message-ID: <20120126111149.8386.51043.stgit@localhost6.localdomain6>
In-Reply-To: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
References: <20120126110955.8386.34551.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Network namespace is taken from request transport and passed as a part of
cb_process_state structure.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 fs/nfs/callback.h      |    1 +
 fs/nfs/callback_proc.c |    2 +-
 fs/nfs/callback_xdr.c  |    1 +
 fs/nfs/client.c        |    4 ++--
 fs/nfs/internal.h      |    3 ++-
 5 files changed, 7 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index c89d3b9..197e0d3 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -39,6 +39,7 @@ struct cb_process_state {
 	__be32			drc_status;
 	struct nfs_client	*clp;
 	int			slotid;
+	struct net		*net;
 };
 
 struct cb_compound_hdr_arg {
diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 0e6e63f..f71978d 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -461,7 +461,7 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	int i;
 	__be32 status = htonl(NFS4ERR_BADSESSION);
 
-	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
+	clp = nfs4_find_client_sessionid(cps->net, args->csa_addr, &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index f2be3e1e..8c2a969 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -861,6 +861,7 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp, void *argp, void *r
 		.drc_status = 0,
 		.clp = NULL,
 		.slotid = -1,
+		.net = rqstp->rq_xprt->xpt_net,
 	};
 	unsigned int nops = 0;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 9e11d29..2328dcb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1232,11 +1232,11 @@ nfs4_find_client_ident(struct net *net, int cb_ident)
  * Returns NULL if no such client
  */
 struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *addr,
+nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 			   struct nfs4_sessionid *sid)
 {
 	struct nfs_client *clp;
-	struct nfs_net *nn = net_generic(&init_net, nfs_net_id);
+	struct nfs_net *nn = net_generic(net, nfs_net_id);
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index b38b733..0c3648a 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -152,7 +152,8 @@ extern void nfs_cleanup_cb_ident_idr(struct net *);
 extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *);
+nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
+				struct nfs4_sessionid *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);

