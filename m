Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:36308 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752219AbdBMQ4r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Feb 2017 11:56:47 -0500
Subject: [PATCH v4 3/9] xprtrdma: Disable pad optimization by default
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Mon, 13 Feb 2017 11:56:44 -0500
Message-ID: <20170213165644.15801.8847.stgit@manet.1015granger.net>
In-Reply-To: <20170213163936.15801.31225.stgit@manet.1015granger.net>
References: <20170213163936.15801.31225.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit d5440e27d3e5 ("xprtrdma: Enable pad optimization") made the
Linux client omit XDR round-up padding in normal Read and Write
chunks so that the client doesn't have to register and invalidate
3-byte memory regions that contain no real data.

Unfortunately, my cheery 2014 assessment that this optimization "is
supported now by both Linux and Solaris servers" was premature.
We've found bugs in Solaris in this area since commit d5440e27d3e5
("xprtrdma: Enable pad optimization") was merged (SYMLINK is the
main offender).

So for maximum interoperability, I'm disabling this optimization
again. If a CM private message is exchanged when connecting, the
client recognizes that the server is Linux, and enables the
optimization for that connection.

Until now the Solaris server bugs did not impact common operations,
and were thus largely benign. Soon, less capable devices on Linux
NFS/RDMA clients will make use of Read chunks more often, and these
Solaris bugs will prevent interoperation in more cases.

Fixes: 677eb17e94ed ("xprtrdma: Fix XDR tail buffer marshalling")
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
index 2a6a367..23f4da4 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -216,6 +216,7 @@
 	    pmsg->cp_magic == rpcrdma_cmp_magic &&
 	    pmsg->cp_version == RPCRDMA_CMP_VERSION) {
 		r_xprt->rx_ia.ri_reminv_expected = true;
+		r_xprt->rx_ia.ri_implicit_roundup = true;
 		rsize = rpcrdma_decode_buffer_size(pmsg->cp_send_size);
 		wsize = rpcrdma_decode_buffer_size(pmsg->cp_recv_size);
 	}

