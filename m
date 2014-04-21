Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-yk0-f173.google.com ([209.85.160.173]:49692 "EHLO
	mail-yk0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752896AbaDUWBO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Apr 2014 18:01:14 -0400
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH V2 03/17] xprtrdma: Enable RDMA pad optimization by default
To: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Date: Mon, 21 Apr 2014 18:01:11 -0400
Message-ID: <20140421220111.12569.77783.stgit@manet.1015granger.net>
In-Reply-To: <20140421214442.12569.8950.stgit@manet.1015granger.net>
References: <20140421214442.12569.8950.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Section 4 of RFC 5667 (NFS/RDMA) says:

> The server MUST ignore any Read list for other NFS procedures,
> as well as additional Read list entries beyond the first in the
> list.

Our XDR code adds a zero pad at the end of NFS WRITEs and SYMLINKs
whose content is not a multiple of 4 octets long.  xprtrdma treats
the tail buffer containing the zero pad as a separate read chunk,
which the server ignores.

Enable the pad optimization so our NFS client avoids sending zeroes
the server is just going to ignore.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 net/sunrpc/xprtrdma/transport.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/xprtrdma/transport.c b/net/sunrpc/xprtrdma/transport.c
index 1eb9c46..f94a6c4 100644
--- a/net/sunrpc/xprtrdma/transport.c
+++ b/net/sunrpc/xprtrdma/transport.c
@@ -73,7 +73,7 @@ static unsigned int xprt_rdma_max_inline_read = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_max_inline_write = RPCRDMA_DEF_INLINE;
 static unsigned int xprt_rdma_inline_write_padding;
 static unsigned int xprt_rdma_memreg_strategy = RPCRDMA_FRMR;
-                int xprt_rdma_pad_optimize = 0;
+int		    xprt_rdma_pad_optimize = 1;
 
 #ifdef RPC_DEBUG
 

