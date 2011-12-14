Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:37567 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756987Ab1LNKqS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 14 Dec 2011 05:46:18 -0500
Subject: [PATCH 10/11] SUNRPC: allow debug flags modifications only from
 init_net
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Wed, 14 Dec 2011 14:46:02 +0300
Message-ID: <20111214104602.3991.91169.stgit@localhost6.localdomain6>
In-Reply-To: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
References: <20111214103602.3991.20990.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Debug flags are global (i.e. fo all namespaces). So probably, it is better to
restrict write access and allow it only to processes with "init_net" network
namespace.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/sysctl.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/sunrpc/sysctl.c b/net/sunrpc/sysctl.c
index eda80cf..224b075 100644
--- a/net/sunrpc/sysctl.c
+++ b/net/sunrpc/sysctl.c
@@ -156,7 +156,8 @@ proc_dodebug(ctl_table *table, int write,
 			return -EINVAL;
 		while (left && isspace(*s))
 			left--, s++;
-		*(unsigned int *) table->data = value;
+		if (net_eq(current->nsproxy->net_ns, &init_net))
+			*(unsigned int *) table->data = value;
 		/* Display the RPC tasks on writing to rpc_debug */
 		if (strcmp(table->procname, "rpc_debug") == 0)
 			rpc_show_tasks(&init_net);

