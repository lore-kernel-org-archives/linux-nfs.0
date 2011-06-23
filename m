Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:44037 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932619Ab1FWTcE (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Jun 2011 15:32:04 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [PATCH v2 06/12] nfs: Use srcaddr in nfs_match_client.
Date: Thu, 23 Jun 2011 12:29:40 -0700
Message-Id: <1308857388-12243-7-git-send-email-greearb@candelatech.com>
In-Reply-To: <1308857388-12243-1-git-send-email-greearb@candelatech.com>
References: <1308857388-12243-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

For bound clients, we have to make sure we do not re-use
a client that is bound differently.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 c571a97... 5d8998a... M	fs/nfs/client.c
 fs/nfs/client.c |   12 ++++++++++++
 1 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index c571a97..5d8998a 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -131,7 +131,9 @@ struct rpc_program		nfsacl_program = {
 struct nfs_client_initdata {
 	const char *hostname;
 	const struct sockaddr *addr;
+	const struct sockaddr *srcaddr;
 	size_t addrlen;
+	size_t srcaddrlen;
 	const struct nfs_rpc_ops *rpc_ops;
 	int proto;
 	u32 minorversion;
@@ -463,6 +465,9 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 	list_for_each_entry(clp, &nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+		const struct sockaddr *sa;
+		sa = (const struct sockaddr *)&clp->srcaddr;
+
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -480,6 +485,13 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 		if (!nfs_sockaddr_cmp(sap, clap))
 			continue;
 
+		/* Check to make sure local-IP bindings match,
+		 * but just the IP-addr.
+		 */
+		if (data->srcaddr &&
+		    !nfs_sockaddr_match_ipaddr(data->srcaddr, sa))
+			continue;
+
 		atomic_inc(&clp->cl_count);
 		return clp;
 	}
-- 
1.7.3.4

