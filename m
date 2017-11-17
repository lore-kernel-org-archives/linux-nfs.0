Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36906 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161134AbdKQRqM (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Nov 2017 12:46:12 -0500
Received: by mail-it0-f65.google.com with SMTP id m191so4973152itg.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Nov 2017 09:46:11 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J . Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC v4 3/9] SUNRPC: Simplify client shutdown
Date: Fri, 17 Nov 2017 11:45:46 -0600
Message-Id: <20171117174552.18722-4-JPEWhacker@gmail.com>
In-Reply-To: <20171117174552.18722-1-JPEWhacker@gmail.com>
References: <20171117174552.18722-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the flag to kill all new tasks when shutting down instead of
repeatedly killing all the pending tasks.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 net/sunrpc/clnt.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index d5eedabf0b4d..c3abcc800f25 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -852,11 +852,9 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 			clnt->cl_program->name,
 			rcu_dereference(clnt->cl_xprt)->servername);
 
-	while (!list_empty(&clnt->cl_tasks)) {
-		rpc_killall_tasks(clnt);
-		wait_event_timeout(destroy_wait,
-			list_empty(&clnt->cl_tasks), 1*HZ);
-	}
+	atomic_inc(&clnt->cl_kill_new_tasks);
+	rpc_killall_tasks(clnt);
+	wait_event(destroy_wait, list_empty(&clnt->cl_tasks));
 
 	rpc_release_client(clnt);
 }
-- 
2.13.6

