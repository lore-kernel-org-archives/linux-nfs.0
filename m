Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:31227 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756964Ab1LNKqK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:46:10 -0500
Subject: [PATCH 09/11] SUNRPC: remove xs_tcp_fin_timeout variable
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:45:54 +0300
Message-ID: <20111214104554.3991.56903.stgit@localhost6.localdomain6>
In-Reply-To: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This is a cleanup patch. Static xs_tcp_fin_timeout is not needed anymore.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/xprtsock.c |    5 ++---
 1 files changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sunrpc/xprtsock.c b/net/sunrpc/xprtsock.c
index 49219d2..610a74a 100644
--- a/net/sunrpc/xprtsock.c
+++ b/net/sunrpc/xprtsock.c
@@ -61,7 +61,6 @@ unsigned int xprt_min_resvport = RPC_DEF_MIN_RESVPORT;
 unsigned int xprt_max_resvport = RPC_DEF_MAX_RESVPORT;
 
 #define XS_TCP_LINGER_TO	(15U * HZ)
-static unsigned int xs_tcp_fin_timeout __read_mostly = XS_TCP_LINGER_TO;
 
 /*
  * We can register our own files under /proc/sys/sunrpc by
@@ -129,7 +128,7 @@ static ctl_table xs_tunables_table[] = {
 	},
 	{
 		.procname	= "tcp_fin_timeout",
-		.maxlen		= sizeof(xs_tcp_fin_timeout),
+		.maxlen		= sizeof(unsigned int),
 		.mode		= 0644,
 		.proc_handler	= proc_dointvec_jiffies,
 	},
@@ -2930,7 +2929,7 @@ int socket_sysctl_init(struct net *net)
 	sn->xprt_max_tcp_slot_table_entries = xprt_max_tcp_slot_table_entries;
 	sn->xprt_min_resvport = xprt_min_resvport;
 	sn->xprt_max_resvport = xprt_max_resvport;
-	sn->xs_tcp_fin_timeout = xs_tcp_fin_timeout;
+	sn->xs_tcp_fin_timeout = XS_TCP_LINGER_TO;
 #ifdef RPC_DEBUG
 	return create_xs_tunables_table(net);
 #else

