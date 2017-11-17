Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:36905 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161128AbdKQRqK (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 12:46:10 -0500
Received: by mail-it0-f66.google.com with SMTP id m191so4973093itg.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2017 09:46:10 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v4 2/9] SUNRPC: Expose kill_new_tasks in debugfs
Date: Fri, 17 Nov 2017 11:45:45 -0600
Message-Id: <20171117174552.18722-3-JPEWhacker@gmail.com>
In-Reply-To: <20171117174552.18722-1-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 net/sunrpc/debugfs.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/sunrpc/debugfs.c b/net/sunrpc/debugfs.c
index e980d2a493de..72d9d074abd2 100644
--- a/net/sunrpc/debugfs.c
+++ b/net/sunrpc/debugfs.c
@@ -160,6 +160,11 @@ rpc_clnt_debugfs_register(struct rpc_clnt *clnt)
 	if (!debugfs_create_symlink("xprt", clnt->cl_debugfs, name))
 		goto out_err;
 
+	if (!debugfs_create_atomic_t("kill_new_tasks", S_IRUSR | S_IWUSR,
+				     clnt->cl_debugfs,
+				     &clnt->cl_kill_new_tasks))
+		goto out_err;
+
 	return;
 out_err:
 	debugfs_remove_recursive(clnt->cl_debugfs);
-- 
2.13.6

