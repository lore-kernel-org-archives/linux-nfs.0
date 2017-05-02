Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:33267 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750927AbdEBQi2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 2 May 2017 12:38:28 -0400
Received: by mail-io0-f196.google.com with SMTP id o22so7016040iod.0
        for <linux-nfs@vger.kernel.org>; Tue, 02 May 2017 09:38:28 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [RFC PATCH 5/5] NFS: Display the "nconnect" mount option if it is set.
Date: Tue,  2 May 2017 12:38:12 -0400
Message-Id: <20170502163812.6211-9-trond.myklebust@primarydata.com>
In-Reply-To: <20170502163812.6211-8-trond.myklebust@primarydata.com>
References: <20170502163812.6211-1-trond.myklebust@primarydata.com>
 <20170502163812.6211-2-trond.myklebust@primarydata.com>
 <20170502163812.6211-3-trond.myklebust@primarydata.com>
 <20170502163812.6211-4-trond.myklebust@primarydata.com>
 <20170502163812.6211-5-trond.myklebust@primarydata.com>
 <20170502163812.6211-6-trond.myklebust@primarydata.com>
 <20170502163812.6211-7-trond.myklebust@primarydata.com>
 <20170502163812.6211-8-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/super.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7eb48934dc79..0e07a6684235 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -673,6 +673,8 @@ static void nfs_show_mount_options(struct seq_file *m, struct nfs_server *nfss,
 	seq_printf(m, ",proto=%s",
 		   rpc_peeraddr2str(nfss->client, RPC_DISPLAY_NETID));
 	rcu_read_unlock();
+	if (clp->cl_nconnect > 0)
+		seq_printf(m, ",nconnect=%u", clp->cl_nconnect);
 	if (version == 4) {
 		if (nfss->port != NFS_PORT)
 			seq_printf(m, ",port=%u", nfss->port);
-- 
2.9.3

