From: akpm@linux-foundation.org
Subject: [patch 1/1] sunrpc: fix RDMA dependency
Date: Fri, 09 Jan 2009 12:25:14 -0800
Message-ID: <200901092025.n09KPEKR022026@imap1.linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, akpm@linux-foundation.org,
	randy.dunlap@oracle.com, Trond.Myklebust@netapp.com,
	bfields@fieldses.org, rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37619 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754262AbZAIUZg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 9 Jan 2009 15:25:36 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

SUNRPC_XPRT_RDMA uses Infiniband RDMA support, so make it depend on that
kconfig symbol for clean builds.

net/built-in.o: In function `rpcrdma_ep_disconnect':
(.text+0x9c2a8): undefined reference to `rdma_disconnect'
net/built-in.o: In function `rpcrdma_create_id':
verbs.c:(.text+0x9c39f): undefined reference to `rdma_create_id'
verbs.c:(.text+0x9c3e3): undefined reference to `rdma_resolve_addr'
verbs.c:(.text+0x9c439): undefined reference to `rdma_resolve_route'
verbs.c:(.text+0x9c482): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `rpcrdma_ep_destroy':
(.text+0x9c84d): undefined reference to `rdma_destroy_qp'
net/built-in.o: In function `rpcrdma_ia_close':
(.text+0x9cb44): undefined reference to `rdma_destroy_qp'
net/built-in.o: In function `rpcrdma_ia_close':
(.text+0x9cb4b): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `rpcrdma_ia_open':
(.text+0x9cdb4): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `rpcrdma_ep_connect':
(.text+0x9d2dd): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `rpcrdma_ep_connect':
(.text+0x9d2eb): undefined reference to `rdma_destroy_qp'
net/built-in.o: In function `rpcrdma_ep_connect':
(.text+0x9d2f8): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `rpcrdma_ep_connect':
(.text+0x9d319): undefined reference to `rdma_create_qp'
net/built-in.o: In function `rpcrdma_ep_connect':
(.text+0x9d3e0): undefined reference to `rdma_connect'
net/built-in.o: In function `svc_rdma_detach':
svc_rdma_transport.c:(.text+0x9ddbb): undefined reference to `rdma_disconnect'
net/built-in.o: In function `__svc_rdma_free':
svc_rdma_transport.c:(.text+0x9f041): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `svc_rdma_accept':
svc_rdma_transport.c:(.text+0x9f362): undefined reference to `rdma_create_qp'
svc_rdma_transport.c:(.text+0x9f388): undefined reference to `rdma_create_qp'
svc_rdma_transport.c:(.text+0x9f553): undefined reference to `rdma_accept'
svc_rdma_transport.c:(.text+0x9f682): undefined reference to `rdma_destroy_id'
net/built-in.o: In function `svc_rdma_create':
svc_rdma_transport.c:(.text+0x9f70e): undefined reference to `rdma_create_id'
svc_rdma_transport.c:(.text+0x9f739): undefined reference to `rdma_bind_addr'
svc_rdma_transport.c:(.text+0x9f762): undefined reference to `rdma_listen'
svc_rdma_transport.c:(.text+0x9f79e): undefined reference to `rdma_destroy_id'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: J. Bruce Fields <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 fs/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff -puN fs/Kconfig~sunrpc-fix-rdma-dependency fs/Kconfig
--- a/fs/Kconfig~sunrpc-fix-rdma-dependency
+++ a/fs/Kconfig
@@ -1370,7 +1370,7 @@ config SUNRPC_GSS
 
 config SUNRPC_XPRT_RDMA
 	tristate
-	depends on SUNRPC && INFINIBAND && EXPERIMENTAL
+	depends on SUNRPC && INFINIBAND_ADDR_TRANS && EXPERIMENTAL
 	default SUNRPC && INFINIBAND
 	help
 	  This option enables an RPC client transport capability that
_
