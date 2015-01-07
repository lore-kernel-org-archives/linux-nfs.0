Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f169.google.com ([209.85.213.169]:52600 "EHLO
	mail-ig0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752821AbbAGXMN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 7 Jan 2015 18:12:13 -0500
Received: by mail-ig0-f169.google.com with SMTP id z20so102612igj.0
        for <linux-nfs@vger.kernel.org>; Wed, 07 Jan 2015 15:12:12 -0800 (PST)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by mx.google.com with ESMTPSA id s80sm1434216ioi.26.2015.01.07.15.12.12
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Jan 2015 15:12:12 -0800 (PST)
Subject: [PATCH v1 03/20] xprtrdma: Display XIDs in host byte order
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 07 Jan 2015 18:12:11 -0500
Message-ID: <20150107231211.13466.19627.stgit@manet.1015granger.net>
In-Reply-To: <20150107230859.13466.67723.stgit@manet.1015granger.net>
References: <20150107230859.13466.67723.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

xprtsock.c and the backchannel code display XIDs in host byte order.
Follow suit in xprtrdma.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/rpc_rdma.c |    8 +++++---
 1 file changed, 5 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index a6fb30b..150dd76 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -766,7 +766,8 @@ rpcrdma_reply_handler(struct rpcrdma_rep *rep)
 		spin_unlock(&xprt->transport_lock);
 		dprintk("RPC:       %s: reply 0x%p failed "
 			"to match any request xid 0x%08x len %d\n",
-			__func__, rep, headerp->rm_xid, rep->rr_len);
+			__func__, rep, be32_to_cpu(headerp->rm_xid),
+			rep->rr_len);
 repost:
 		r_xprt->rx_stats.bad_reply_count++;
 		rep->rr_func = rpcrdma_reply_handler;
@@ -782,13 +783,14 @@ repost:
 		spin_unlock(&xprt->transport_lock);
 		dprintk("RPC:       %s: duplicate reply 0x%p to RPC "
 			"request 0x%p: xid 0x%08x\n", __func__, rep, req,
-			headerp->rm_xid);
+			be32_to_cpu(headerp->rm_xid));
 		goto repost;
 	}
 
 	dprintk("RPC:       %s: reply 0x%p completes request 0x%p\n"
 		"                   RPC request 0x%p xid 0x%08x\n",
-			__func__, rep, req, rqst, headerp->rm_xid);
+			__func__, rep, req, rqst,
+			be32_to_cpu(headerp->rm_xid));
 
 	/* from here on, the reply is no longer an orphan */
 	req->rl_reply = rep;

