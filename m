Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:35216 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbeEDTej (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 4 May 2018 15:34:39 -0400
Subject: [PATCH v1 02/19] xprtrdma: Try to fail quickly if proto=rdma
From: Chuck Lever <chuck.lever@oracle.com>
To: anna.schumaker@netapp.com
Cc: linux-rdma@vger.kernel.org, linux-nfs@vger.kernel.org
Date: Fri, 04 May 2018 15:34:37 -0400
Message-ID: <20180504193437.31688.66116.stgit@manet.1015granger.net>
In-Reply-To: <20180504192748.31688.3678.stgit@manet.1015granger.net>
References: <20180504192748.31688.3678.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

rdma_resolve_addr(3) says:

> This call is used to map a given destination IP address to a
> usable RDMA address. The IP to RDMA address mapping is done
> using the local routing tables, or via ARP.

If this can't be done, there's no local device that can be used
to establish an RDMA-capable network path to the remote. In this
case, the RDMA CM very quickly posts an RDMA_CM_EVENT_ADDR_ERROR
upcall.

Currently rpcrdma_conn_upcall() converts RDMA_CM_EVENT_ADDR_ERROR
to EHOSTUNREACH. mount.nfs seems to want to retry EHOSTUNREACH
forever, thinking that this is a temporary situation. This makes
mount.nfs appear to hang if I try to mount with proto=rdma through,
say, a conventional Ethernet device.

If the admin has specified proto=rdma along with a server IP address
that requires a network path that does not support RDMA, instead
let's fail with a permanent error. -EPROTONOSUPPORT is returned when
NFSv4 or one of its minor versions is not supported.

-EPROTO is not (currently) retried by mount.nfs.

There are potentially other similar cases where -EPROTO is an
appropriate return code.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Tested-by: Olga Kornievskaia <kolga@netapp.com>
Tested-by: Anna Schumaker <Anna.Schumaker@netapp.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 10f5032..331d372 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -232,7 +232,7 @@
 		complete(&ia->ri_done);
 		break;
 	case RDMA_CM_EVENT_ADDR_ERROR:
-		ia->ri_async_rc = -EHOSTUNREACH;
+		ia->ri_async_rc = -EPROTO;
 		complete(&ia->ri_done);
 		break;
 	case RDMA_CM_EVENT_ROUTE_ERROR:
@@ -263,7 +263,7 @@
 		connstate = -ENOTCONN;
 		goto connected;
 	case RDMA_CM_EVENT_UNREACHABLE:
-		connstate = -ENETDOWN;
+		connstate = -ENETUNREACH;
 		goto connected;
 	case RDMA_CM_EVENT_REJECTED:
 		dprintk("rpcrdma: connection to %s:%s rejected: %s\n",

