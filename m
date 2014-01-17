Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ig0-f175.google.com ([209.85.213.175]:51024 "EHLO
	mail-ig0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753293AbaAQTiS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 17 Jan 2014 14:38:18 -0500
Received: by mail-ig0-f175.google.com with SMTP id uq10so2469160igb.2
        for <linux-nfs@vger.kernel.org>; Fri, 17 Jan 2014 11:38:18 -0800 (PST)
Received: from manet.1015granger.net (c-68-40-85-241.hsd1.mi.comcast.net. [68.40.85.241])
        by mx.google.com with ESMTPSA id kb10sm4937103igb.6.2014.01.17.11.38.17
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 17 Jan 2014 11:38:17 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Fix large reads on NFS/RDMA
To: linux-nfs@vger.kernel.org
Date: Fri, 17 Jan 2014 14:38:16 -0500
Message-ID: <20140117193816.3452.45059.stgit@manet.1015granger.net>
In-Reply-To: <20140117193555.3452.31437.stgit@manet.1015granger.net>
References: <20140117193555.3452.31437.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

After commit a11a2bf4, "SUNRPC: Optimise away unnecessary data
moves in xdr_align_pages", Thu Aug 2 13:21:43 2012, READs larger
than a few hundred bytes via NFS/RDMA stopped working.  This
commit exposed a long-standing bug in rpcrdma_inline_fixup().

I reproduce this with an rsize=4096 mount using the cthon04
basic tests.  Test 5 fails with an EIO error.

For my reproducer, kernel log shows:

  NFS: server cheating in read reply: count 4096 > recvd 0

rpcrdma_inline_fixup() is zeroing the xdr_stream::page_len
field, and xdr_align_pages() is now returning that value to
the READ XDR decoder function.

That field is set up by xdr_inline_pages() by the READ XDR
encoder function.  As far as I can tell, it is supposed to
be left alone after that, as it describes the dimensions of
the reply xdr_stream, not the contents of that stream.

Bugzilla: https://bugzilla.kernel.org/show_bug.cgi?id=68391
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: <stable@vger.kernel.org> # 3.7+
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

