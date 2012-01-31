Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:25902 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753152Ab2AaKJZ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 31 Jan 2012 05:09:25 -0500
Subject: [PATCH v2 2/4] SUNRPC: clear svc transports lists helper introduced
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        jbottomley@parallels.com, bfields@fieldses.org, davem@davemloft.net,
        devel@openvz.org
Date: Tue, 31 Jan 2012 14:09:08 +0400
Message-ID: <20120131100908.4342.86129.stgit@localhost6.localdomain6>
In-Reply-To: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
References: <20120131100625.4342.34539.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch moves service transports deletion from service sockets lists to
separated function.
This is a precursor patch, which would be usefull with service shutdown in
network namespace context, introduced later in the series.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/svc_xprt.c |   19 +++++++++++--------
 1 files changed, 11 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index 50bf7c1..493e70b 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -950,11 +950,19 @@ static void svc_clear_pools(struct svc_serv *serv)
 	}
 }
 
-void svc_close_all(struct svc_serv *serv)
+static void svc_clear_list(struct list_head *xprt_list)
 {
 	struct svc_xprt *xprt;
 	struct svc_xprt *tmp;
 
+	list_for_each_entry_safe(xprt, tmp, xprt_list, xpt_list) {
+		svc_delete_xprt(xprt);
+	}
+	BUG_ON(!list_empty(xprt_list));
+}
+
+void svc_close_all(struct svc_serv *serv)
+{
 	svc_close_list(&serv->sv_tempsocks);
 	svc_close_list(&serv->sv_permsocks);
 
@@ -964,13 +972,8 @@ void svc_close_all(struct svc_serv *serv)
 	 * svc_enqueue will not add new entries without taking the
 	 * sp_lock and checking XPT_BUSY.
 	 */
-	list_for_each_entry_safe(xprt, tmp, &serv->sv_tempsocks, xpt_list)
-		svc_delete_xprt(xprt);
-	list_for_each_entry_safe(xprt, tmp, &serv->sv_permsocks, xpt_list)
-		svc_delete_xprt(xprt);
-
-	BUG_ON(!list_empty(&serv->sv_permsocks));
-	BUG_ON(!list_empty(&serv->sv_tempsocks));
+	svc_clear_list(&serv->sv_tempsocks);
+	svc_clear_list(&serv->sv_permsocks);
 }
 
 /*

