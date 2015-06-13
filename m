Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f66.google.com ([209.85.220.66]:35109 "EHLO
	mail-pa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753549AbbFMCHG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 22:07:06 -0400
Received: by pabli10 with SMTP id li10so9580648pab.2
        for <linux-nfs@vger.kernel.org>; Fri, 12 Jun 2015 19:07:05 -0700 (PDT)
Message-ID: <557B9044.8060105@gmail.com>
Date: Sat, 13 Jun 2015 10:07:00 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        David Howells <dhowells@redhat.com>, kinglongmee@gmail.com
Subject: [PATCH v2] nfs: Fix showing truncated fsid/dev in, /proc/net/nfsfs/volumes
References: <557AE2E7.1090908@gmail.com> <CAHQdGtSB9s6m12Y2pY+JYToLcak9Q-vw-ybC0-UbBPJQUd0P+A@mail.gmail.com>
In-Reply-To: <CAHQdGtSB9s6m12Y2pY+JYToLcak9Q-vw-ybC0-UbBPJQUd0P+A@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

A truncated fsid showing from /proc/fs/nfsfs/volumes as,
NV SERVER   PORT DEV     FSID              FSC
v4 c0a80881  801 0:43    34931f044c2a439b  no

It should be as,
NV SERVER   PORT DEV          FSID                              FSC
v4 c0a80881  801 0:43         34931f044c2a439b:954c5d830fa4be8c no

The max buffer length for storing "%llx:%llx" format should be
 16 + 1 + 16 + 1 = 34 (16 for %llx, 1 for ':', 1 for '\0').

Also, for storing "%u:%u" of MAJOR() and MINOR() should be
 8 + 1 + 3 + 1 = 13 (8 for 2^24, 1 for ':', 3 for 2^8, 1 for '\0').

v2, add comments for dev/fsid buffer and use sizeof in snprintf.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/client.c | 12 +++++++-----
 1 file changed, 7 insertions(+), 5 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index 892aeff..1e37491 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -1364,27 +1364,29 @@ static int nfs_volume_list_show(struct seq_file *m, void *v)
 {
 	struct nfs_server *server;
 	struct nfs_client *clp;
-	char dev[8], fsid[17];
+	char dev[13];	// 8 for 2^24, 1 for ':', 3 for 2^8, 1 for '\0'
+	char fsid[34];	// 2 * 16 for %llx, 1 for ':', 1 for '\0'
 	struct nfs_net *nn = net_generic(seq_file_net(m), nfs_net_id);
 
 	/* display header on line 1 */
 	if (v == &nn->nfs_volume_list) {
-		seq_puts(m, "NV SERVER   PORT DEV     FSID              FSC\n");
+		seq_puts(m, "NV SERVER   PORT DEV          FSID"
+			    "                              FSC\n");
 		return 0;
 	}
 	/* display one transport per line on subsequent lines */
 	server = list_entry(v, struct nfs_server, master_link);
 	clp = server->nfs_client;
 
-	snprintf(dev, 8, "%u:%u",
+	snprintf(dev, sizeof(dev), "%u:%u",
 		 MAJOR(server->s_dev), MINOR(server->s_dev));
 
-	snprintf(fsid, 17, "%llx:%llx",
+	snprintf(fsid, sizeof(fsid), "%llx:%llx",
 		 (unsigned long long) server->fsid.major,
 		 (unsigned long long) server->fsid.minor);
 
 	rcu_read_lock();
-	seq_printf(m, "v%u %s %s %-7s %-17s %s\n",
+	seq_printf(m, "v%u %s %s %-12s %-33s %s\n",
 		   clp->rpc_ops->version,
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_ADDR),
 		   rpc_peeraddr2str(clp->cl_rpcclient, RPC_DISPLAY_HEX_PORT),
-- 
2.4.3

