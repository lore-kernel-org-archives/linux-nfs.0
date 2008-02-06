From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 1/4] NLM: set RPC_CLNT_CREATE_NOPING for NLM RPC clients
Date: Wed,  6 Feb 2008 11:34:10 -0500
Message-ID: <1202315653-11840-2-git-send-email-jlayton@redhat.com>
References: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
To: bfields@fieldses.org, linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34201 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755228AbYBFQeQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 6 Feb 2008 11:34:16 -0500
In-Reply-To: <1202315653-11840-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's currently possible for an unresponsive NLM client to completely
lock up a server's lockd. The scenario is something like this:

1) client1 (or a process on the server) takes a lock on a file
2) client2 tries to take a blocking lock on the same file and
   awaits the callback
3) client2 goes unresponsive (plug pulled, network partition, etc)
4) client1 releases the lock

...at that point the server's lockd will try to queue up a GRANT_MSG
callback for client2, but first it requeues the block with a timeout of
30s. nlm_async_call will attempt to bind the RPC client to client2 and
will call rpc_ping. rpc_ping entails a sync RPC call and if client2 is
unresponsive it will take around 60s for that to time out. Once it times
out, it's already time to retry the block and the whole process repeats.

Once in this situation, nlmsvc_retry_blocked will never return until
the host starts responding again. lockd won't service new calls.

Fix this by skipping the RPC ping on NLM RPC clients. This makes
nlm_async_call return quickly when called.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index ca6b16f..00063ee 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -244,6 +244,7 @@ nlm_bind_host(struct nlm_host *host)
 			.version	= host->h_version,
 			.authflavor	= RPC_AUTH_UNIX,
 			.flags		= (RPC_CLNT_CREATE_HARDRTRY |
+					   RPC_CLNT_CREATE_NOPING |
 					   RPC_CLNT_CREATE_AUTOBIND),
 		};
 
-- 
1.5.3.8

