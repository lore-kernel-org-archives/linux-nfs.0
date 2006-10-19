From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 04/11] nfs4: initialize cl_ipaddr
Date: Thu, 19 Oct 2006 13:04:32 -0400
Message-ID: <20061019170432.8171.30968.stgit@lade.trondhjem.org>
References: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=fixed
Cc: linux-kernel@vger.kernel.org, nfs@lists.sourceforge.net
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1946242AbWJSRGh@vger.kernel.org>
To: Linus Torvalds <torvalds@osdl.org>
In-Reply-To: <20061019170432.8171.75076.stgit@lade.trondhjem.org>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <nfs.lists.sourceforge.net>

From: J. Bruce Fields <bfields@fieldses.org>

David forgot to do this.  I'm not sure if this is the right place to put
it....

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/client.c |    8 ++++++--
 1 files changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 34c3996..8b123f6 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -849,6 +849,7 @@ #ifdef CONFIG_NFS_V4
  */
 static int nfs4_init_client(struct nfs_client *clp,
 		int proto, int timeo, int retrans,
+		const char *ip_addr,
 		rpc_authflavor_t authflavour)
 {
 	int error;
@@ -865,6 +866,7 @@ static int nfs4_init_client(struct nfs_c
 	error = nfs_create_rpc_client(clp, proto, timeo, retrans, authflavour);
 	if (error < 0)
 		goto error;
+	memcpy(clp->cl_ipaddr, ip_addr, sizeof(clp->cl_ipaddr));
 
 	error = nfs_idmap_new(clp);
 	if (error < 0) {
@@ -888,6 +890,7 @@ error:
  */
 static int nfs4_set_client(struct nfs_server *server,
 		const char *hostname, const struct sockaddr_in *addr,
+		const char *ip_addr,
 		rpc_authflavor_t authflavour,
 		int proto, int timeo, int retrans)
 {
@@ -902,7 +905,7 @@ static int nfs4_set_client(struct nfs_se
 		error = PTR_ERR(clp);
 		goto error;
 	}
-	error = nfs4_init_client(clp, proto, timeo, retrans, authflavour);
+	error = nfs4_init_client(clp, proto, timeo, retrans, ip_addr, authflavour);
 	if (error < 0)
 		goto error_put;
 
@@ -971,7 +974,7 @@ struct nfs_server *nfs4_create_server(co
 		return ERR_PTR(-ENOMEM);
 
 	/* Get a client record */
-	error = nfs4_set_client(server, hostname, addr, authflavour,
+	error = nfs4_set_client(server, hostname, addr, ip_addr, authflavour,
 			data->proto, data->timeo, data->retrans);
 	if (error < 0)
 		goto error;
@@ -1041,6 +1044,7 @@ struct nfs_server *nfs4_create_referral_
 	/* Get a client representation.
 	 * Note: NFSv4 always uses TCP, */
 	error = nfs4_set_client(server, data->hostname, data->addr,
+			parent_client->cl_ipaddr,
 			data->authflavor,
 			parent_server->client->cl_xprt->prot,
 			parent_client->retrans_timeo,
