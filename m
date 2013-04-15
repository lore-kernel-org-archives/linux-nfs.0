Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:49895 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753465Ab3DOTfK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Apr 2013 15:35:10 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] SUNRPC: attempt AF_LOCAL connect on setup
Date: Mon, 15 Apr 2013 15:35:03 -0400
Message-Id: <1366054508-27604-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1366054508-27604-1-git-send-email-bfields@redhat.com>
References: <1366054508-27604-1-git-send-email-bfields@redhat.com>
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
 net/sunrpc/xprtsock.c |    3 +++
 1 file changed, 3 insertions(+)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 3d02130..425a9e9 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -2655,6 +2655,9 @@ static struct rpc_xprt *xs_setup_local(struct xprt_create *args)
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

