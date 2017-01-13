Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:35377 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750947AbdAMRnQ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 13 Jan 2017 12:43:16 -0500
Subject: [PATCH v1 3/5] xprtrdma: Disable pad optimization by default
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 13 Jan 2017 12:43:14 -0500
Message-ID: <20170113174314.32692.96554.stgit@manet.1015granger.net>
In-Reply-To: <20170113173023.32692.30661.stgit@manet.1015granger.net>
References: <20170113173023.32692.30661.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d5440e27d3e5 ('xprtrdma: Enable pad optimization') made the
Linux client omit XDR padding in normal Read and Write chunks so
that the client doesn't have to register and invalidate 3-byte
memory regions that contain no real data.

Unfortunately, my cheery 2014 assessment that this optimization "is
supported now by both Linux and Solaris servers" was premature.
We've found bugs in Solaris in this area since commit d5440e27d3e5
was merged (SYMLINK is the main culprit).

So for maximum interoperability, I'm disabling this optimization
again. If a CM private message is exchanged when connecting, the
client recognizes that the server is Linux, and enables the
optimization for that connection.

Until now the Solaris server bugs did not impact common operations,
and were thus largely unnoticed. Soon, less capable devices on Linux
NFS/RDMA clients will make use of Read chunks more often, and these
Solaris bugs will prevent interoperation in more cases.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 net/sunrpc/xprtrdma/transport.c |    2 +-
 net/sunrpc/xprtrdma/verbs.c     |    1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 534c178..6990581 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -67,7 +67,7 @@
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
-		int xprt_rdma_pad_optimize = 1;
+		int xprt_rdma_pad_optimize = 0;
 
 #if IS_ENABLED(CONFIG_SUNRPC_DEBUG)
 
diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 890cb3a..12e8242 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -216,6 +216,7 @@
 	    pmsg->cp_magic == rpcrdma_cmp_magic &&
 	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
 		r_xprt->rx_ia.ri_reminv_expected = true;
+		r_xprt->rx_ia.ri_implicit_padding = true;
 		rsize = rpcrdma_decode_buffer_size(pmsg->cp_send_size);
 		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
 	}

