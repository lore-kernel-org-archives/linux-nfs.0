From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 2/2] NLM: tear down RPC clients in nlm_shutdown_hosts
Date: Tue, 29 Jan 2008 10:30:55 -0500
Message-ID: <1201620655-7595-3-git-send-email-jlayton@redhat.com>
References: <1201620655-7595-1-git-send-email-jlayton@redhat.com>
 <1201620655-7595-2-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:58442 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755561AbYA2Pa7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 29 Jan 2008 10:30:59 -0500
In-Reply-To: <1201620655-7595-2-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

It's possible for a RPC to outlive the lockd daemon that created it, so
we need to make sure that all RPC's are killed when lockd is coming
down. When nlm_shutdown_hosts is called, kill off all RPC tasks
associated with the host. Since we need to wait until they have all gone
away, we might as well just shut down the RPC client altogether.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index ebec009..ca6b16f 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -379,8 +379,13 @@ nlm_shutdown_hosts(void)
 	/* First, make all hosts eligible for gc */
 	dprintk("lockd: nuking all hosts...\n");
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash)
+		hlist_for_each_entry(host, pos, chain, h_hash) {
 			host->h_expires = jiffies - 1;
+			if (host->h_rpcclnt) {
+				rpc_shutdown_client(host->h_rpcclnt);
+				host->h_rpcclnt = NULL;
+			}
+		}
 	}
 
 	/* Then, perform a garbage collection pass */
-- 
1.5.3.8

