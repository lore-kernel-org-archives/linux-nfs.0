Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ie0-f182.google.com ([209.85.223.182]:64228 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752110AbaCLQvc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 12 Mar 2014 12:51:32 -0400
Received: by mail-ie0-f182.google.com with SMTP id y20so10868868ier.27
        for <linux-nfs@vger.kernel.org>; Wed, 12 Mar 2014 09:51:32 -0700 (PDT)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/6] SUNRPC: Fix large reads on NFS/RDMA
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org
Date: Wed, 12 Mar 2014 12:51:30 -0400
Message-ID: <20140312165130.15349.22853.stgit@manet.1015granger.net>
In-Reply-To: <20140312164620.15349.22643.stgit@manet.1015granger.net>
References: <20140312164620.15349.22643.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit a11a2bf4, "SUNRPC: Optimise away unnecessary data moves
in xdr_align_pages", Thu Aug 2 13:21:43 2012, READs larger than a
few hundred bytes via NFS/RDMA no longer work.  This commit exposed
a long-standing bug in rpcrdma_inline_fixup().

I reproduce this with an rsize=4096 mount using the cthon04 basic
tests.  Test 5 fails with an EIO error.

For my reproducer, kernel log shows:

  NFS: server cheating in read reply: count 4096 > recvd 0

rpcrdma_inline_fixup() is zeroing the xdr_stream::page_len field,
and xdr_align_pages() is now returning that value to the READ XDR
decoder function.

That field is set up by xdr_inline_pages() by the READ XDR encoder
function.  As far as I can tell, it is supposed to be left alone
after that, as it describes the dimensions of the reply xdr_stream,
not the contents of that stream.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=68391
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/rpc_rdma.c |    4 +---
 1 files changed, 1 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtrdma/rpc_rdma.c b/net/sunrpc/xprtrdma/rpc_rdma.c
index e03725b..96ead52 100644
--- a/net/sunrpc/xprtrdma/rpc_rdma.c
+++ b/net/sunrpc/xprtrdma/rpc_rdma.c
@@ -649,9 +649,7 @@ rpcrdma_inline_fixup(struct rpc_rqst *rqst, char *srcp, int copy_len, int pad)
 				break;
 			page_base = 0;
 		}
-		rqst->rq_rcv_buf.page_len = olen - copy_len;
-	} else
-		rqst->rq_rcv_buf.page_len = 0;
+	}
 
 	if (copy_len && rqst->rq_rcv_buf.tail[0].iov_len) {
 		curlen = copy_len;

