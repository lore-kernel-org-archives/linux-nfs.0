Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39879 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752250Ab3AUUrO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:47:14 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 05/13] nfs: Pay attention to srcaddr in v4.1 callback logic.
Date: Mon, 21 Jan 2013 12:45:51 -0800
Message-Id: <1358801159-18829-6-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/callback_proc.c |    3 ++-
 fs/nfs/internal.h      |    6 ++++--
 fs/nfs/nfs4client.c    |   24 +++++++++++++++++++++++-
 3 files changed, 29 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index 36b2e7a..24a3457 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -451,7 +451,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 	int i;
 	__be32 status = htonl(NFS4ERR_BADSESSION);
 
-	clp = nfs4_find_client_sessionid(cps->net, args->csa_addr, &args->csa_sessionid);
+	clp = nfs4_find_client_sessionid(cps->net, args->csa_daddr, args->csa_addr,
+					 &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 80504e1..11c5ac7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -190,8 +190,10 @@ extern void nfs_put_client(struct nfs_client *);
 extern void nfs_free_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_ident(struct net *, int);
 extern struct nfs_client *
-nfs4_find_client_sessionid(struct net *, const struct sockaddr *,
-				struct nfs4_sessionid *);
+nfs4_find_client_sessionid(struct net *,
+			   const struct sockaddr *srcaddr,
+			   const struct sockaddr *addr,
+			   struct nfs4_sessionid *);
 extern struct nfs_server *nfs_create_server(struct nfs_mount_info *,
 					struct nfs_subversion *);
 extern struct nfs_server *nfs4_create_server(
diff --git a/fs/nfs/nfs4client.c b/fs/nfs/nfs4client.c
index 1f55131..7c4dc21 100644
--- a/fs/nfs/nfs4client.c
+++ b/fs/nfs/nfs4client.c
@@ -543,11 +543,13 @@ static bool nfs4_cb_match_client(const struct sockaddr *addr,
  * Returns NULL if no such client
  */
 struct nfs_client *
-nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
+nfs4_find_client_sessionid(struct net *net, const struct sockaddr *srcaddr,
+			   const struct sockaddr *addr,
 			   struct nfs4_sessionid *sid)
 {
 	struct nfs_client *clp;
 	struct nfs_net *nn = net_generic(net, nfs_net_id);
+	struct nfs_client *ok_fit = NULL;
 
 	spin_lock(&nn->nfs_client_lock);
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
@@ -562,10 +564,30 @@ nfs4_find_client_sessionid(struct net *net, const struct sockaddr *addr,
 		    sid->data, NFS4_MAX_SESSIONID_LEN) != 0)
 			continue;
 
+		if (srcaddr) {
+			const struct sockaddr *sa;
+			sa = (const struct sockaddr *)&clp->cl_addr;
+			if (!nfs_sockaddr_match_ipaddr(srcaddr, sa)) {
+				/* If clp doesn't bind to srcaddr, then
+				 * it is a potential match if we don't find
+				 * a better one.
+				 */
+				if (sa->sa_family == AF_UNSPEC && !ok_fit)
+					ok_fit = clp;
+				continue;
+			}
+		}
+found_one:
 		atomic_inc(&clp->cl_count);
 		spin_unlock(&nn->nfs_client_lock);
 		return clp;
 	}
+
+	if (ok_fit) {
+		clp = ok_fit;
+		goto found_one;
+	}
+
 	spin_unlock(&nn->nfs_client_lock);
 	return NULL;
 }
-- 
1.7.3.4

