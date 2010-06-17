Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:46153 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1760007Ab0FQVSC (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 17:18:02 -0400
From: Benny Halevy <bhalevy@panasas.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] SQUASHME: FIXME: pnfsd: do not expire client on cb_layout error.
Date: Thu, 17 Jun 2010 17:18:09 -0400
Message-Id: <1276809489-25700-1-git-send-email-bhalevy@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

This may lead to deadlocks on the nfsd state lock.
Instead, wait for the laundromat to expire the client.

TODO: Regardless, even if the callback succeeded, we need to track
a list of recalled layout and maintain it as they returned by the client
Then, scrub it in the laundromat and expire the client if it hasn't
returned all recalled layouts in a timely manner (e.g. after 2
lease periods after its last return with the respective stateid)

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index c5973c3..f5c24d1 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1043,7 +1043,6 @@ static void nfsd4_cb_layout_done(struct rpc_task *task, void *calldata)
 		 * the client after at-least "lease time" .eg lease-time * 2
 		 * when failing to communicate a recall
 		 */
-		expire_client_lock(clp);
 		break;
 	case -NFS4ERR_DELAY:
 		/* Pole the client until it's done with the layout */
-- 
1.6.4.4

