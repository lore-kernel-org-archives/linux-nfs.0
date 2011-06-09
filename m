Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34541 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756650Ab1FIXFH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 9 Jun 2011 19:05:07 -0400
From: greearb@candelatech.com
To: linux-nfs@vger.kernel.org
Cc: Ben Greear <greearb@candelatech.com>
Subject: [RFC 07/11] nfs:  Add srcaddr to /proc/fs/nfsfs/servers
Date: Thu,  9 Jun 2011 16:02:51 -0700
Message-Id: <1307660575-6994-8-git-send-email-greearb@candelatech.com>
In-Reply-To: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
References: <1307660575-6994-1-git-send-email-greearb@candelatech.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Ben Greear <greearb@candelatech.com>

Helps users understand whether a server instance is
bound to a local IP or not.

Signed-off-by: Ben Greear <greearb@candelatech.com>
---
:100644 100644 5d8998a... 223785f... M	fs/nfs/client.c
 fs/nfs/client.c |   18 ++++++++++++++++--
 1 files changed, 16 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 5d8998a..223785f 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1895,20 +1895,34 @@ static int nfs_server_list_show(struct seq_file *m, void *v)
 
 	/* display header on line 1 */
 	if (v == &nfs_client_list) {
-		seq_puts(m, "NV SERVER   PORT USE HOSTNAME\n");
+		seq_puts(m, "NV SERVER   PORT USE HOSTNAME"
+			 "           SRCADDR\n");
 		return 0;
 	}
 
 	/* display one transport per line on subsequent lines */
 	clp = list_entry(v, struct nfs_client, cl_share_link);
 
-	seq_printf(m, "v%u %s %s %3d %s\n",
+	seq_printf(m, "v%u %s %s %3d %s",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   atomic_read(&clp->cl_count),
 		   clp->cl_hostname);
 
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

