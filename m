Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail.candelatech.com ([208.74.158.172]:43643 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752631Ab3AUUs1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2013 15:48:27 -0500
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 11/13] nfs: Add srcaddr to /proc/fs/nfsfs/servers
Date: Mon, 21 Jan 2013 12:45:57 -0800
Message-Id: <1358801159-18829-12-git-send-email-greearb@candelatech.com>
In-Reply-To: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
References: <1358801159-18829-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ben Greear <greearb@candelatech.com>

Helps users understand whether a server instance is
bound to a local IP or not.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
 fs/nfs/client.c |   17 +++++++++++++++--
 1 files changed, 15 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index bb0a8ce..43b6205 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1311,7 +1311,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 
 	/* display header on line 1 */
 	if (v == &nn->nfs_client_list) {
-		seq_puts(m, "NV SERVER   PORT USE HOSTNAME\n");
+		seq_puts(m, "NV SERVER   PORT USE HOSTNAME           SRCADDR\n");
 		return 0;
 	}
 
@@ -1323,7 +1323,7 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 		return 0;
 
 	rcu_read_lock();
-	seq_printf(m, "v%u %s %s %3d %s\n",
+	seq_printf(m, "v%u %s %s %3d %s",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
@@ -1331,6 +1331,19 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 		   clp->cl_hostname);
 	rcu_read_unlock();
 
+	if (clp->srcaddr.ss_family == AF_INET) {
+		const struct sockaddr_in *sin;
+		sin = (const struct sockaddr_in *)&clp->srcaddr;
+		seq_printf(m, "   %pI4\n", &sin->sin_addr.s_addr);
+	} else if (clp->srcaddr.ss_family == AF_INET6) {
+		const struct sockaddr_in6 *sin6;
+		sin6 = (const struct sockaddr_in6 *)&clp->srcaddr;
+		seq_printf(m, "   %pI6c\n", &sin6->sin6_addr);
+	} else if (clp->srcaddr.ss_family == AF_UNSPEC)
+		seq_printf(m, "   ANY\n");
+	else
+		seq_printf(m, "   UNKNOWN_%i\n", (int)(clp->srcaddr.ss_family));
+
 	return 0;
 }
 
-- 
1.7.3.4

