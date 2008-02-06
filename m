From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/4] NLM: have server-side RPC clients default to soft RPC tasks
Date: Wed,  6 Feb 2008 11:34:11 -0500
Message-ID: <1202315653-11840-3-git-send-email-jlayton@redhat.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
 <1202315653-11840-2-git-send-email-jlayton@redhat.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34202 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755330AbYBFQeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:16 -0500
In-Reply-To: <1202315653-11840-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that it no longer does an RPC ping, lockd always ends up queueing
an RPC task for the GRANT_MSG callback. But, it also requeues the block
for later attempts. Since these are hard RPC tasks, if the client we're
calling back goes unresponsive the GRANT_MSG callbacks can stack up in
the RPC queue.

Fix this by making server-side RPC clients default to soft RPC tasks.
lockd requeues the block anyway, so this should be OK.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 00063ee..f1ef49f 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -243,11 +243,18 @@ nlm_bind_host(struct nlm_host *host)
 			.program	= &nlm_program,
 			.version	= host->h_version,
 			.authflavor	= RPC_AUTH_UNIX,
-			.flags		= (RPC_CLNT_CREATE_HARDRTRY |
-					   RPC_CLNT_CREATE_NOPING |
+			.flags		= (RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
 		};
 
+		/*
+		 * lockd retries server side blocks automatically so we want
+		 * those to be soft RPC calls. Client side calls need to be
+		 * hard RPC tasks.
+		 */
+		if (!host->h_server)
+			args.flags |= RPC_CLNT_CREATE_HARDRTRY;
+
 		clnt = rpc_create(&args);
 		if (!IS_ERR(clnt))
 			host->h_rpcclnt = clnt;
-- 
1.5.3.8

