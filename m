From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH 4/4] NLM: have nlm_shutdown_hosts kill off all NLM RPC tasks
Date: Mon, 14 Jan 2008 09:05:18 -0500
Message-ID: <1200319518-22422-5-git-send-email-jlayton@redhat.com>
References: <1200319518-22422-1-git-send-email-jlayton@redhat.com>
 <1200319518-22422-2-git-send-email-jlayton@redhat.com>
 <1200319518-22422-3-git-send-email-jlayton@redhat.com>
 <1200319518-22422-4-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
To: neilb@suse.de
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:57409 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751228AbYANOFV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Jan 2008 09:05:21 -0500
In-Reply-To: <1200319518-22422-4-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If we're shutting down all the nlm_hosts anyway, then it doesn't make
sense to allow RPC calls to linger. Allowing them to do so can mean
that the RPC calls can outlive the currently running lockd and can lead
to a use after free situation.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/lockd/host.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 572601e..8771484 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -377,8 +377,10 @@ nlm_shutdown_hosts(void)
 	/* First, make all hosts eligible for gc */
 	dprintk("lockd: nuking all hosts...\n");
 	for (chain = nlm_hosts; chain < nlm_hosts + NLM_HOST_NRHASH; ++chain) {
-		hlist_for_each_entry(host, pos, chain, h_hash)
+		hlist_for_each_entry(host, pos, chain, h_hash) {
 			host->h_expires = jiffies - 1;
+			rpc_killall_tasks(host->h_rpcclnt);
+		}
 	}
 
 	/* Then, perform a garbage collection pass */
-- 
1.5.3.7

