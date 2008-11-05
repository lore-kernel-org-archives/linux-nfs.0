From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 12/12] lockd: remove redundant rpc_shutdown_client()
Date: Wed,  5 Nov 2008 15:06:51 -0500
Message-ID: <1225915611-2401-12-git-send-email-bfields@citi.umich.edu>
References: <20081105172351.7330.50739.stgit@ingres.1015granger.net>
 <1225915611-2401-1-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-2-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-3-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-4-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-5-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-6-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-7-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-8-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-9-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-10-git-send-email-bfields@citi.umich.edu>
 <1225915611-2401-11-git-send-email-bfields@citi.umich.edu>
Cc: linux-nfs@vger.kernel.org,
	"J. Bruce Fields" <bfields@citi.umich.edu>
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:39507 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757576AbYKEUG4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 5 Nov 2008 15:06:56 -0500
In-Reply-To: <1225915611-2401-11-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

These clients will all be shut down by nlm_destroy_host() when we do
garbage collection a little later, so this is redundant.

XXX: Ask Jeff Layton why he added this again?

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/lockd/host.c |    8 +-------
 1 files changed, 1 insertions(+), 7 deletions(-)

diff --git a/fs/lockd/host.c b/fs/lockd/host.c
index 73c2be2..0387c6b 100644
--- a/fs/lockd/host.c
+++ b/fs/lockd/host.c
@@ -602,14 +602,8 @@ static void expire_hosts(struct host_table *table)
 	struct hlist_node *pos;
 	struct nlm_host	*host;
 
-	dprintk("lockd: nuking all hosts...\n");
-	for_each_host(host, pos, chain, table) {
+	for_each_host(host, pos, chain, table)
 		host->h_expires = jiffies - 1;
-		if (host->h_rpcclnt) {
-			rpc_shutdown_client(host->h_rpcclnt);
-			host->h_rpcclnt = NULL;
-		}
-	}
 }
 
 /*
-- 
1.5.5.rc1

