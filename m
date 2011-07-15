Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:58951 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755662Ab1GOR52 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 15 Jul 2011 13:57:28 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH (RESEND) 05/12] nfs:  Pay attention to srcaddr in v4.1 callback logic.
Date: Fri, 15 Jul 2011 10:56:01 -0700
Message-Id: <1310752568-21280-6-git-send-email-greearb@candelatech.com>
In-Reply-To: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
References: <1310752568-21280-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 d4d1954... 5b20987... M	fs/nfs/callback_proc.c
:100644 100644 8ba7e1a... c571a97... M	fs/nfs/client.c
:100644 100644 93979a9... 60a36a2... M	fs/nfs/internal.h
 fs/nfs/callback_proc.c |    3 ++-
 fs/nfs/client.c        |   27 +++++++++++++++++++++++++--
 fs/nfs/internal.h      |    4 +++-
 3 files changed, 30 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback_proc.c b/fs/nfs/callback_proc.c
index d4d1954..5b20987 100644
--- a/fs/nfs/callback_proc.c
+++ b/fs/nfs/callback_proc.c
@@ -424,7 +424,8 @@ __be32 nfs4_callback_sequence(struct cb_sequenceargs *args,
 
 	cps->clp = NULL;
 
-	clp = nfs4_find_client_sessionid(args->csa_addr, &args->csa_sessionid);
+	clp = nfs4_find_client_sessionid(args->csa_daddr, args->csa_addr,
+					 &args->csa_sessionid);
 	if (clp == NULL)
 		goto out;
 
diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 8ba7e1a..c571a97 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1233,10 +1233,12 @@ nfs4_find_client_ident(int cb_ident)
  * Returns NULL if no such client
  */
 struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *addr,
+nfs4_find_client_sessionid(const struct sockaddr *srcaddr,
+			   const struct sockaddr *addr,
 			   struct nfs4_sessionid *sid)
 {
 	struct nfs_client *clp;
+	struct nfs_client *ok_fit = NULL;
 
 	spin_lock(&nfs_client_lock);
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
@@ -1251,10 +1253,30 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
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
 		spin_unlock(&nfs_client_lock);
 		return clp;
 	}
+
+	if (ok_fit) {
+		clp = ok_fit;
+		goto found_one;
+	}
+
 	spin_unlock(&nfs_client_lock);
 	return NULL;
 }
@@ -1262,7 +1284,8 @@ nfs4_find_client_sessionid(const struct sockaddr *addr,
 #else /* CONFIG_NFS_V4_1 */
 
 struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *addr,
+nfs4_find_client_sessionid(const struct sockaddr *srcaddr,
+			   const struct sockaddr *addr,
 			   struct nfs4_sessionid *sid)
 {
 	return NULL;
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 93979a9..60a36a2 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -155,7 +155,9 @@ extern void nfs_put_client(struct nfs_client *);
 extern struct nfs_client *nfs4_find_client_no_ident(const struct sockaddr *);
 extern struct nfs_client *nfs4_find_client_ident(int);
 extern struct nfs_client *
-nfs4_find_client_sessionid(const struct sockaddr *, struct nfs4_sessionid *);
+nfs4_find_client_sessionid(const struct sockaddr *srcaddr,
+			   const struct sockaddr *addr,
+			   struct nfs4_sessionid *);
 extern struct nfs_server *nfs_create_server(
 					const struct nfs_parsed_mount_data *,
 					struct nfs_fh *);
-- 
1.7.3.4

