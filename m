Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:17532 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932934Ab2GYM7C (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 25 Jul 2012 08:59:02 -0400
Subject: [PATCH v2 14/15] NFSd: make grace end flag per network namespace
To: bfields@fieldses.org
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, Trond.Myklebust@netapp.com,
        linux-kernel@vger.kernel.org, devel@openvz.org
Date: Wed, 25 Jul 2012 16:57:37 +0400
Message-ID: <20120725125737.24376.62359.stgit@localhost.localdomain>
In-Reply-To: <20120725125258.24376.82525.stgit@localhost.localdomain>
References: <20120725125258.24376.82525.stgit@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>
---
 fs/nfsd/netns.h     |    1 +
 fs/nfsd/nfs4state.c |    8 +++-----
 2 files changed, 4 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
index e99767d..b6deebd 100644
--- a/fs/nfsd/netns.h
+++ b/fs/nfsd/netns.h
@@ -36,6 +36,7 @@ struct nfsd_net {
 	struct cache_detail *nametoid_cache;
 
 	struct lock_manager nfsd4_manager;
+	bool grace_ended;
 };
 
 extern int nfsd_net_id;
diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index b926e00..2c53447 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3118,19 +3118,17 @@ out:
 	return status;
 }
 
-static bool grace_ended;
-
 static void
 nfsd4_end_grace(struct net *net)
 {
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
 	/* do nothing if grace period already ended */
-	if (grace_ended)
+	if (nn->grace_ended)
 		return;
 
 	dprintk("NFSD: end of grace period\n");
-	grace_ended = true;
+	nn->grace_ended = true;
 	nfsd4_record_grace_done(net, boot_time);
 	locks_end_grace(&nn->nfsd4_manager);
 	/*
@@ -4704,7 +4702,7 @@ nfs4_state_start(void)
 	nfsd4_client_tracking_init(net);
 	boot_time = get_seconds();
 	locks_start_grace(net, &nn->nfsd4_manager);
-	grace_ended = false;
+	nn->grace_ended = false;
 	printk(KERN_INFO "NFSD: starting %ld-second grace period\n",
 	       nfsd4_grace);
 	ret = set_callback_cred();

