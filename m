Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:39899 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080Ab3AUUrz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:47:55 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 06/13] nfs: Use srcaddr in nfs_match_client.
Date: Mon, 21 Jan 2013 12:45:52 -0800
Message-Id: <1358801159-18829-7-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

For bound clients, we have to make sure we do not re-use
a client that is bound differently.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/client.c   |   10 ++++++++++
 fs/nfs/internal.h |    2 ++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 809fd1e..e5230fe 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -408,6 +408,9 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
 
 	list_for_each_entry(clp, &nn->nfs_client_list, cl_share_link) {
 	        const struct sockaddr *clap = (struct sockaddr *)&clp->cl_addr;
+		const struct sockaddr *sa;
+		sa = (const struct sockaddr *)&clp->srcaddr;
+
 		/* Don't match clients that failed to initialise properly */
 		if (clp->cl_cons_state < 0)
 			continue;
@@ -425,6 +428,13 @@ static struct nfs_client *nfs_match_client(const struct nfs_client_initdata *dat
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
diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
index 11c5ac7..dbb2ee7 100644
--- a/fs/nfs/internal.h
+++ b/fs/nfs/internal.h
@@ -89,7 +89,9 @@ struct nfs_client_initdata {
 	unsigned long init_flags;
 	const char *hostname;
 	const struct sockaddr *addr;
+	const struct sockaddr *srcaddr;
 	size_t addrlen;
+	size_t srcaddrlen;
 	struct nfs_subversion *nfs_mod;
 	int proto;
 	u32 minorversion;
-- 
1.7.3.4

