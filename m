From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] nfsd: do_probe_callback should not clear rpc stats
Date: Fri, 26 Sep 2008 15:14:13 +0300
Message-ID: <48DCD215.8050508@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([66.104.249.162]:20925 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750969AbYIZMOX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 26 Sep 2008 08:14:23 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that cb_stats are static (since commit
ff7d9756b501744540be65e172d27ee321d86103)
there's no need to clear them.

Initially I thought it might make sense to do
that every callback probing but since the stats
are per-program and they are shared between possibly
several client callback instances, zeroing them out
seems like the wrong thing to do.

Note that that commit also introduced a bug
since stats.program is also being cleared in the process
and it is not restored after the memset as it used to be.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4callback.c |    3 ---
 1 files changed, 0 insertions(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 5e95909..7b94701 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -399,9 +399,6 @@ static int do_probe_callback(void *data)
 		__func__, args.program->name, args.program->number,
 		args.program->nrvers, args.version);
 
-	/* Initialize rpc_stat */
-	memset(args.program->stats, 0, sizeof(struct rpc_stat));
-
 	/* Create RPC client */
 	client = rpc_create(&args);
 	if (IS_ERR(client)) {

