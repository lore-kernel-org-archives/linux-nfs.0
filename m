Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4361 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755111Ab0KEXMo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Nov 2010 19:12:44 -0400
From: Joe Perches <joe@perches.com>
To: Jiri Kosina <trivial@kernel.org>
Cc: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: [PATCH 7/7] net/sunrpc/clnt.c: Convert sprintf_symbol to %ps
Date: Fri,  5 Nov 2010 16:12:40 -0700
Message-Id: <1288998760-11775-8-git-send-email-joe@perches.com>
In-Reply-To: <1288998760-11775-1-git-send-email-joe@perches.com>
References: <1288998760-11775-1-git-send-email-joe@perches.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Joe Perches <joe@perches.com>
---
 net/sunrpc/clnt.c |   12 ++----------
 1 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index 9dab957..0c3d395 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1824,23 +1824,15 @@ static void rpc_show_task(const struct rpc_clnt *clnt,
 			  const struct rpc_task *task)
 {
 	const char *rpc_waitq = "none";
-	char *p, action[KSYM_SYMBOL_LEN];
 
 	if (RPC_IS_QUEUED(task))
 		rpc_waitq = rpc_qname(task->tk_waitqueue);
 
-	/* map tk_action pointer to a function name; then trim off
-	 * the "+0x0 [sunrpc]" */
-	sprint_symbol(action, (unsigned long)task->tk_action);
-	p = strchr(action, '+');
-	if (p)
-		*p = '\0';
-
-	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%s q:%s\n",
+	printk(KERN_INFO "%5u %04x %6d %8p %8p %8ld %8p %sv%u %s a:%ps q:%s\n",
 		task->tk_pid, task->tk_flags, task->tk_status,
 		clnt, task->tk_rqstp, task->tk_timeout, task->tk_ops,
 		clnt->cl_protname, clnt->cl_vers, rpc_proc_name(task),
-		action, rpc_waitq);
+		task->tk_action, rpc_waitq);
 }
 
 void rpc_show_tasks(void)
-- 
1.7.3.2.146.gca209

