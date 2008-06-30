From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/16] lockd: Use sockaddr_storage + length for h_addr field
Date: Mon, 30 Jun 2008 18:58:54 -0400
Message-ID: <20080630225853.25407.44579.stgit@ellison.1015granger.net>
References: <20080630225011.25407.61357.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com, bfields@citi.umich.edu
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:51318 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764126AbYF3W7h (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 18:59:37 -0400
In-Reply-To: <20080630225011.25407.61357.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To store larger addresses in the nlm_host structure, make h_addr a
sockaddr_storage, and add an address length field.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/lockd/clntlock.c         |    2 +-
 fs/lockd/host.c             |   11 ++++++-----
 include/linux/lockd/lockd.h |   16 +++++++++++++++-
 3 files changed, 22 insertions(+), 7 deletions(-)


diff --git a/fs/lockd/clntlock.c b/fs/lockd/clntlock.c
index 0b45fd3..0df5587 100644
--- a/fs/lockd/clntlock.c
+++ b/fs/lockd/clntlock.c
@@ -166,7 +166,7 @@ __be32 nlmclnt_grant(const struct sockaddr_in *addr, const struct nlm_lock *lock
 		 */
 		if (fl_blocked->fl_u.nfs_fl.owner->pid != lock->svid)
 			continue;
-		if (!nlm_cmp_addr(&block->b_host->h_addr, addr))
+		if (!nlm_cmp_addr(nlm_addr_in(block->b_host), addr))
 			continue;
 		if (nfs_compare_fh(NFS_FH(fl_blocked->fl_file->f_path.dentry->d_inode) ,fh) != 0)
 			continue;
diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index f87066d..e2f6212 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -114,7 +114,7 @@ static struct nlm_host *nlm_lookup_host(int server,
 	 */
 	chain = &nlm_hosts[hash];
 	hlist_for_each_entry(host, pos, chain, h_hash) {
-		if (!nlm_cmp_addr(&host->h_addr, sin))
+		if (!nlm_cmp_addr(nlm_addr_in(host), sin))
 			continue;
 
 		/* See if we have an NSM handle for this client */
@@ -163,8 +163,9 @@ static struct nlm_host *nlm_lookup_host(int server,
 		goto out;
 	}
 	host->h_name	   = nsm->sm_name;
-	host->h_addr       = *sin;
-	nlm_clear_port((struct sockaddr *)&host->h_addr);
+	memcpy(nlm_addr(host), sin, sizeof(*sin));
+	host->h_addrlen = sizeof(*sin);
+	nlm_clear_port(nlm_addr(host));
 	host->h_saddr	   = *ssin;
 	host->h_version    = version;
 	host->h_proto      = proto;
@@ -289,8 +290,8 @@ nlm_bind_host(struct nlm_host *host)
 		};
 		struct rpc_create_args args = {
 			.protocol	= host->h_proto,
-			.address	= (struct sockaddr *)&host->h_addr,
-			.addrsize	= sizeof(host->h_addr),
+			.address	= nlm_addr(host),
+			.addrsize	= host->h_addrlen,
 			.saddress	= (struct sockaddr *)&host->h_saddr,
 			.timeout	= &timeparms,
 			.servername	= host->h_name,
diff --git a/include/linux/lockd/lockd.h b/include/linux/lockd/lockd.h
index 5774d6e..217b32a 100644
--- a/include/linux/lockd/lockd.h
+++ b/include/linux/lockd/lockd.h
@@ -38,7 +38,8 @@
  */
 struct nlm_host {
 	struct hlist_node	h_hash;		/* doubly linked list */
-	struct sockaddr_in	h_addr;		/* peer address */
+	struct sockaddr_storage	h_addr;		/* peer address */
+	size_t			h_addrlen;
 	struct sockaddr_in	h_saddr;	/* our address (optional) */
 	struct rpc_clnt	*	h_rpcclnt;	/* RPC client to talk to peer */
 	char *			h_name;		/* remote hostname */
@@ -76,6 +77,19 @@ struct nsm_handle {
 };
 
 /*
+ * Rigorous type checking on sockaddr type conversions
+ */
+static inline struct sockaddr_in *nlm_addr_in(const struct nlm_host *host)
+{
+	return (struct sockaddr_in *)&host->h_addr;
+}
+
+static inline struct sockaddr *nlm_addr(const struct nlm_host *host)
+{
+	return (struct sockaddr *)&host->h_addr;
+}
+
+/*
  * Map an fl_owner_t into a unique 32-bit "pid"
  */
 struct nlm_lockowner {

