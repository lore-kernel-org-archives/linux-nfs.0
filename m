Return-Path: linux-nfs-owner@vger.kernel.org
Received: from e36.co.us.ibm.com ([32.97.110.154]:49922 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752270Ab2A3Taq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jan 2012 14:30:46 -0500
Received: from /spool/local
	by e36.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-nfs@vger.kernel.org> from <malahal@us.ibm.com>;
	Mon, 30 Jan 2012 12:30:43 -0700
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 319611FF004F
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:59 -0700 (MST)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q0UJTwuL149788
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q0UJTwBW007318
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
Received: from malahal (malahal.austin.ibm.com [9.53.40.203])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVin) with ESMTP id q0UJTw8r007303
	for <linux-nfs@vger.kernel.org>; Mon, 30 Jan 2012 12:29:58 -0700
From: Malahal Naineni <malahal@us.ibm.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/13] NFS: Add replica servers to volumes proc file.
Date: Mon, 30 Jan 2012 13:29:51 -0600
Message-Id: <1327951795-16400-10-git-send-email-malahal@us.ibm.com>
In-Reply-To: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
References: <1327951795-16400-1-git-send-email-malahal@us.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Malahal Naineni <malahal@us.ibm.com>
---
 fs/nfs/client.c |   16 +++++++++++++---
 1 files changed, 13 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 54de25a..000ebdb 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1997,10 +1997,12 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 	struct nfs_server *server;
 	struct nfs_client *clp;
 	char dev[8], fsid[17];
+	char *p, *end, replicas[256];
+	int i;
 
 	/* display header on line 1 */
 	if (v == &nfs_volume_list) {
-		seq_puts(m, "NV SERVER   PORT DEV     FSID              FSC\n");
+		seq_puts(m, "NV SERVER   PORT DEV     FSID              FSC REPLICAS\n");
 		return 0;
 	}
 	/* display one transport per line on subsequent lines */
@@ -2014,14 +2016,22 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
+	p = replicas;
+	end = replicas + sizeof(replicas);
+	strncpy(replicas, "none", sizeof(replicas));
+	for (i = 0; i < NFS_MAX_REPLI_SERVERS && p < end; i++)
+		if (server->repli_servers[i])
+			p += snprintf(p, end - p, "%s/", server->repli_servers[i]);
+
 	rcu_read_lock();
-	seq_printf(m, "v%u %s %s %-7s %-17s %s\n",
+	seq_printf(m, "v%u %s %s %-7s %-17s %s %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
 		   dev,
 		   fsid,
-		   nfs_server_fscache_state(server));
+		   nfs_server_fscache_state(server),
+		   replicas);
 	rcu_read_unlock();
 
 	return 0;
-- 
1.7.8.3

