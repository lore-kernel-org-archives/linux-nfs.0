Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:18907 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753980Ab2AaKJk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 05:09:40 -0500
Subject: [PATCH v2 1/4] SUNRPC: clear svc pools lists helper introduced
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 31 Jan 2012 14:09:00 +0400
Message-ID: <20120131100900.4342.85712.stgit@localhost6.localdomain6>
In-Reply-To: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
References: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch moves removing of service transport from it's pools ready lists to
separated function. Also this clear is now done with list_for_each_entry_safe()
helper.
This is a precursor patch, which would be usefull with service shutdown in
network namespace context, introduced later in the series.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svc_xprt.c |   19 +++++++++++++------
 1 files changed, 13 insertions(+), 6 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index de1e1a8..50bf7c1 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -932,26 +932,33 @@ static void svc_close_list(struct list_head *xprt_list)
 	}
 }
 
-void svc_close_all(struct svc_serv *serv)
+static void svc_clear_pools(struct svc_serv *serv)
 {
 	struct svc_pool *pool;
 	struct svc_xprt *xprt;
 	struct svc_xprt *tmp;
 	int i;
 
-	svc_close_list(&serv->sv_tempsocks);
-	svc_close_list(&serv->sv_permsocks);
-
 	for (i = 0; i < serv->sv_nrpools; i++) {
 		pool = &serv->sv_pools[i];
 
 		spin_lock_bh(&pool->sp_lock);
-		while (!list_empty(&pool->sp_sockets)) {
-			xprt = list_first_entry(&pool->sp_sockets, struct svc_xprt, xpt_ready);
+		list_for_each_entry_safe(xprt, tmp, &pool->sp_sockets, xpt_ready) {
 			list_del_init(&xprt->xpt_ready);
 		}
 		spin_unlock_bh(&pool->sp_lock);
 	}
+}
+
+void svc_close_all(struct svc_serv *serv)
+{
+	struct svc_xprt *xprt;
+	struct svc_xprt *tmp;
+
+	svc_close_list(&serv->sv_tempsocks);
+	svc_close_list(&serv->sv_permsocks);
+
+	svc_clear_pools(serv);
 	/*
 	 * At this point the sp_sockets lists will stay empty, since
 	 * svc_enqueue will not add new entries without taking the

