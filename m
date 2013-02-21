Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:34328 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755026Ab3BUQi2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 21 Feb 2013 11:38:28 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: Trond.Myklebust@netapp.com, chuck.lever@oracle.com, simo@redhat.com,
        "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/6] SUNRPC: attempt AF_LOCAL connect on setup
Date: Thu, 21 Feb 2013 11:38:21 -0500
Message-Id: <1361464705-12340-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1361464705-12340-1-git-send-email-bfields@redhat.com>
References: <1361464705-12340-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

In the gss-proxy case, setup time is when I know I'll have the right
namespace for the connect.

In other cases, it might be useful to get any connection errors
earlier--though actually in practice it doesn't make any difference for
rpcbind.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 net/sunrpc/xprtsock.c |    6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index b1df874..f2cf652 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -1867,7 +1867,7 @@ static int xs_local_finish_connecting(struct rpc_xprt *xprt,
  * @transport: socket transport to connect
  * @create_sock: function to create a socket of the correct type
  */
-static void xs_local_setup_socket(struct sock_xprt *transport)
+static int xs_local_setup_socket(struct sock_xprt *transport)
 {
 	struct rpc_xprt *xprt = &transport->xprt;
 	struct socket *sock;
@@ -1913,6 +1913,7 @@ out:
 	xprt_clear_connecting(xprt);
 	xprt_wake_pending_tasks(xprt, status);
 	current->flags &= ~PF_FSTRANS;
+	return status;
 }
 
 static void xs_local_connect(struct rpc_task *task)
@@ -2649,6 +2650,9 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
 		}
 		xprt_set_bound(xprt);
 		xs_format_peer_addresses(xprt, "local", RPCBIND_NETID_LOCAL);
+		ret = ERR_PTR(xs_local_setup_socket(transport));
+		if (ret)
+			goto out_err;
 		break;
 	default:
 		ret = ERR_PTR(-EAFNOSUPPORT);
-- 
1.7.9.5

