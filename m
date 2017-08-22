Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-it0-f48.google.com ([209.85.214.48]:35973 "EHLO
        mail-it0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932989AbdHVPTh (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Aug 2017 11:19:37 -0400
Received: by mail-it0-f48.google.com with SMTP id x187so1079027ite.1
        for <linux-nfs@vger.kernel.org>; Tue, 22 Aug 2017 08:19:37 -0700 (PDT)
Subject: [PATCH v1] xprtrdma: Re-arrange struct rx_stats
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Tue, 22 Aug 2017 11:19:35 -0400
Message-ID: <20170822150754.12455.14201.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To reduce false cacheline sharing, separate counters that are likely
to be accessed in the Call path from those accessed in the Reply
path.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
Hi Anna-

This was the final xprtrdma change I've prepared for v4.14. There
might be one more, on top of Trond's recent lock contention patches.

I don't know if Trond intends to merge those changes into v4.14, but
they are going to conflict with the xprtrdma changes I've sent you
so far. A possible strategy for resolving the conflict is to apply
my changes, which restructure rpcrdma_reply_handler, first. Then
apply Trond's changes, which should be straightforward to adapt to
the restructured code. Then I can send you the extra patch I
mentioned above, respun to apply on all of those, either to
accompany the initial submission, or as an -rc fix.

Another way to do this would be for you and Trond to provide a
for-v4.14 branch with the lock contention changes applied. Then I
would rework all the xprtrdma patches to apply on that, and add the
extra patch on top of the xprtrdma patches I've sent so far, and
send them to you to be reviewed and applied to for-4.14.


 net/sunrpc/xprtrdma/xprt_rdma.h |   13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/net/sunrpc/xprtrdma/xprt_rdma.h b/net/sunrpc/xprtrdma/xprt_rdma.h
index 546c264..45dab24 100644
--- a/net/sunrpc/xprtrdma/xprt_rdma.h
+++ b/net/sunrpc/xprtrdma/xprt_rdma.h
@@ -441,24 +441,27 @@ struct rpcrdma_create_data_internal {
  * Statistics for RPCRDMA
  */
 struct rpcrdma_stats {
+	/* accessed when sending a call */
 	unsigned long		read_chunk_count;
 	unsigned long		write_chunk_count;
 	unsigned long		reply_chunk_count;
-
 	unsigned long long	total_rdma_request;
-	unsigned long long	total_rdma_reply;
 
+	/* rarely accessed error counters */
 	unsigned long long	pullup_copy_count;
-	unsigned long long	fixup_copy_count;
 	unsigned long		hardway_register_count;
 	unsigned long		failed_marshal_count;
 	unsigned long		bad_reply_count;
-	unsigned long		nomsg_call_count;
-	unsigned long		bcall_count;
 	unsigned long		mrs_recovered;
 	unsigned long		mrs_orphaned;
 	unsigned long		mrs_allocated;
+
+	/* accessed when receiving a reply */
+	unsigned long long	total_rdma_reply;
+	unsigned long long	fixup_copy_count;
 	unsigned long		local_inv_needed;
+	unsigned long		nomsg_call_count;
+	unsigned long		bcall_count;
 };
 
 /*

