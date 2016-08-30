Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f67.google.com ([209.85.220.67]:33493 "EHLO
        mail-pa0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750859AbcH3Uxx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Aug 2016 16:53:53 -0400
Date: Wed, 31 Aug 2016 02:23:48 +0530
From: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: Tejun Heo <tj@kernel.org>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: [PATCH v2] fs/nfsd/nfs4callback: Remove deprecated
 create_singlethread_workqueue
Message-ID: <20160830205348.GA31915@Karyakshetra>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The workqueue "callback_wq" queues a single work item &cb->cb_work per
nfsd4_callback instance and thus, it doesn't require execution ordering.
Hence, alloc_workqueue has been used to replace the
deprecated create_singlethread_workqueue instance.

The WQ_MEM_RECLAIM flag has not been set since this is an in-kernel nfs
server and isn't involved in memory reclaim operations on the local
host.

Since there are fixed number of work items, explicit concurrency
limit is unnecessary here.

Signed-off-by: Bhaktipriya Shridhar <bhaktipriya96@gmail.com>
---
 Changes in v2:
	- No change. Made this a separate patch (categorised based on
	  directories).

 fs/nfsd/nfs4callback.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 7389cb1..a6611c6 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -1021,7 +1021,7 @@ static const struct rpc_call_ops nfsd4_cb_ops = {

 int nfsd4_create_callback_queue(void)
 {
-	callback_wq = create_singlethread_workqueue("nfsd4_callbacks");
+	callback_wq = alloc_workqueue("nfsd4_callbacks", 0, 0);
 	if (!callback_wq)
 		return -ENOMEM;
 	return 0;
--
2.1.4

