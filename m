Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:52538 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752620AbdKHPAV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 8 Nov 2017 10:00:21 -0500
Received: by mail-it0-f68.google.com with SMTP id j140so6799934itj.1
        for <linux-nfs@vger.kernel.org>; Wed, 08 Nov 2017 07:00:21 -0800 (PST)
From: Joshua Watt <jpewhacker@gmail.com>
To: NeilBrown <neilb@suse.com>, Jeff Layton <jlayton@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
        "J . Bruce Fields" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>,
        Joshua Watt <JPEWhacker@gmail.com>
Subject: [RFC 3/4] SUNRPC: Simplify client shutdown
Date: Wed,  8 Nov 2017 08:59:41 -0600
Message-Id: <20171108145942.5127-4-JPEWhacker@gmail.com>
In-Reply-To: <20171108145942.5127-1-JPEWhacker@gmail.com>
References: <CAJdd5GZ-EMj8f3RaV_WUdeZs6aWbEAeC6xX8BadMD-aOFL3_jA@mail.gmail.com>
 <20171108145942.5127-1-JPEWhacker@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use the flag to kill all new tasks when shutting down instead of
repeatedly killing all the pending tasks.

Signed-off-by: Joshua Watt <JPEWhacker@gmail.com>
---
 net/sunrpc/clnt.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 70005252b32f..8d51e0788a63 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -860,8 +860,8 @@ void rpc_shutdown_client(struct rpc_clnt *clnt)
 			clnt->cl_program->name,
 			rcu_dereference(clnt->cl_xprt)->servername);
 
+	rpc_killall_tasks(clnt, 1);
 	while (!list_empty(&clnt->cl_tasks)) {
-		rpc_killall_tasks(clnt, 0);
 		wait_event_timeout(destroy_wait,
 			list_empty(&clnt->cl_tasks), 1*HZ);
 	}
-- 
2.13.6

