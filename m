Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:39532 "EHLO
        mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725879AbeIEBdH (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Sep 2018 21:33:07 -0400
Received: by mail-it0-f67.google.com with SMTP id h1-v6so6697380itj.4
        for <linux-nfs@vger.kernel.org>; Tue, 04 Sep 2018 14:06:15 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain (c-68-40-195-73.hsd1.mi.comcast.net. [68.40.195.73])
        by smtp.gmail.com with ESMTPSA id t64-v6sm172860ita.13.2018.09.04.14.06.14
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 04 Sep 2018 14:06:14 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH v2 05/34] SUNRPC: Avoid holding locks across the XDR encoding of the RPC message
Date: Tue,  4 Sep 2018 17:05:20 -0400
Message-Id: <20180904210549.81673-6-trond.myklebust@hammerspace.com>
In-Reply-To: <20180904210549.81673-5-trond.myklebust@hammerspace.com>
References: <20180904210549.81673-1-trond.myklebust@hammerspace.com>
 <20180904210549.81673-2-trond.myklebust@hammerspace.com>
 <20180904210549.81673-3-trond.myklebust@hammerspace.com>
 <20180904210549.81673-4-trond.myklebust@hammerspace.com>
 <20180904210549.81673-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently, we grab the socket bit lock before we allow the message
to be XDR encoded. That significantly slows down the transmission
rate, since we serialise on a potentially blocking operation.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 net/sunrpc/clnt.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/clnt.c b/net/sunrpc/clnt.c
index e5ac35e803ad..a858366cd15d 100644
--- a/net/sunrpc/clnt.c
+++ b/net/sunrpc/clnt.c
@@ -1949,9 +1949,6 @@ call_transmit(struct rpc_task *task)
 	task->tk_action = call_status;
 	if (task->tk_status < 0)
 		return;
-	if (!xprt_prepare_transmit(task))
-		return;
-	task->tk_action = call_transmit_status;
 	/* Encode here so that rpcsec_gss can use correct sequence number. */
 	if (rpc_task_need_encode(task)) {
 		rpc_xdr_encode(task);
@@ -1965,6 +1962,9 @@ call_transmit(struct rpc_task *task)
 			return;
 		}
 	}
+	if (!xprt_prepare_transmit(task))
+		return;
+	task->tk_action = call_transmit_status;
 	xprt_transmit(task);
 	if (task->tk_status < 0)
 		return;
-- 
2.17.1
