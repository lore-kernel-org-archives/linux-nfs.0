Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f196.google.com ([209.85.223.196]:44803 "EHLO
        mail-io0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754604AbdKJWhf (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 10 Nov 2017 17:37:35 -0500
Received: by mail-io0-f196.google.com with SMTP id m16so15143971iod.1
        for <linux-nfs@vger.kernel.org>; Fri, 10 Nov 2017 14:37:34 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v2 2/7] SUNRPC: Expose kill_new_tasks in debugfs
Date: Fri, 10 Nov 2017 16:37:02 -0600
Message-Id: <20171110223707.17098-3-JPEWhacker@gmail.com>
In-Reply-To: <20171110223707.17098-1-JPEWhacker@gmail.com>
References: <20171110223707.17098-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 net/sunrpc/debugfs.c | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e980d2a493de..2ca67b681c1e 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -160,6 +160,10 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
 		goto out_err;
 
+	if (!debugfs_create_bool("kill_new_tasks", S_IRUSR | S_IWUSR,
+				 clnt->cl_debugfs, &clnt->cl_kill_new_tasks))
+		goto out_err;
+
 	return;
 out_err:
 	debugfs_remove_recursive(clnt->cl_debugfs);
-- 
2.13.6

