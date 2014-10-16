Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35891 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbaJPTib (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Oct 2014 15:38:31 -0400
Received: by mail-ig0-f173.google.com with SMTP id h18so262502igc.12
        for <linux-nfs@vger.kernel.org>; Thu, 16 Oct 2014 12:38:31 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id ro6sm14833175igb.3.2014.10.16.12.38.30
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Oct 2014 12:38:30 -0700 (PDT)
Subject: [PATCH v1 02/16] xprtrdma: Cap req_cqinit
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Thu, 16 Oct 2014 15:38:29 -0400
Message-ID: <20141016193829.13414.57075.stgit@manet.1015granger.net>
In-Reply-To: <20141016192919.13414.3151.stgit@manet.1015granger.net>
References: <20141016192919.13414.3151.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent work made FRMR registration and invalidation completions
unsignaled. This greatly reduces the adapter interrupt rate.

Every so often, however, a posted send Work Request is allowed to
signal. Otherwise, the provider's Work Queue will wrap and the
workload will hang.

The number of Work Requests that are allowed to remain unsignaled is
determined by the value of req_cqinit. Currently, this is set to the
size of the send Work Queue divided by two, minus 1.

For FRMR, the send Work Queue is the maximum number of concurrent
RPCs (currently 32) times the maximum number of Work Requests an
RPC might use (currently 7, though some adapters may need more).

For mlx4, this is 224 entries. This leaves completion signaling
disabled for 111 send Work Requests.

Some providers hold back dispatching Work Requests until a CQE is
generated.  If completions are disabled, then no CQEs are generated
for quite some time, and that can stall the Work Queue.

I've seen this occur running xfstests generic/113 over NFSv4, where
eventually, posting a FAST_REG_MR Work Request fails with -ENOMEM
because the Work Queue has overflowed. The connection is dropped
and re-established.

Cap the rep_cqinit setting so completions are not left turned off
for too long.

BugLink: https://bugzilla.linux-nfs.org/show_bug.cgi?id=269
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/verbs.c |    2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 6ea2942..5c0c7a5 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -733,6 +733,8 @@ rpcrdma_ep_create(struct rpcrdma_ep *ep, struct rpcrdma_ia *ia,
 
 	/* set trigger for requesting send completion */
 	ep->rep_cqinit = ep->rep_attr.cap.max_send_wr/2 - 1;
+	if (ep->rep_cqinit > 20)
+		ep->rep_cqinit = 20;
 	if (ep->rep_cqinit <= 2)
 		ep->rep_cqinit = 0;
 	INIT_CQCOUNT(ep);

