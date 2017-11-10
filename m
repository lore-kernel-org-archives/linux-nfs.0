Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:56133 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdKJWhi (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:38 -0500
Received: by mail-it0-f67.google.com with SMTP id l196so3395256itl.4
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:38 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 7/7] NFS: Propagate operations to unshared clients
Date: Fri, 10 Nov 2017 16:37:07 -0600
Message-Id: <20171110223707.17098-8-JPEWhacker@gmail.com>
In-Reply-To: <20171110223707.17098-1-JPEWhacker@gmail.com>
References: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a struct nfs_server's client is not shared with other superblocks,
propagate the umount_begin and serverfailed behavior to it.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 fs/nfs/super.c | 12 +++++++++++-
 1 file changed, 11 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index bca38e1cdd85..0348fd43ffe4 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -911,6 +911,11 @@ void nfs_umount_begin(struct super_block *sb)
 	rpc = server->client;
 	if (!IS_ERR(rpc))
 		rpc_killall_tasks(rpc);
+
+	rpc = server->nfs_client->cl_rpcclient;
+	if (test_bit(NFS_CS_UNSHARED, &server->nfs_client->cl_flags) &&
+	    !IS_ERR(rpc))
+		rpc_killall_tasks(rpc);
 }
 EXPORT_SYMBOL_GPL(nfs_umount_begin);
 
@@ -2223,6 +2228,7 @@ nfs_compare_and_set_remount_data(struct nfs_server *nfss,
 {
 	int changed_flags_mask = data->flags_mask & NFS_REMOUNT_CHANGE_FLAGS;
 	struct rpc_clnt *cl = nfss->client;
+	bool serverfailed;
 
 	if ((data->flags ^ nfss->flags) & NFS_REMOUNT_CMP_FLAGMASK ||
 	    data->rsize != nfss->rsize ||
@@ -2257,7 +2263,11 @@ nfs_compare_and_set_remount_data(struct nfs_server *nfss,
 		cl->cl_timeout_default.to_initval = data->timeo * HZ / 10U;
 	}
 
-	cl->cl_kill_new_tasks = !!(nfss->flags & NFS_MOUNT_SERVERFAILED);
+	serverfailed = !!(nfss->flags & NFS_MOUNT_SERVERFAILED);
+	cl->cl_kill_new_tasks = serverfailed;
+	if (test_bit(NFS_CS_UNSHARED, &nfss->nfs_client->cl_flags))
+		nfss->nfs_client->cl_rpcclient->cl_kill_new_tasks =
+			serverfailed;
 
 	return 0;
 }
-- 
2.13.6

