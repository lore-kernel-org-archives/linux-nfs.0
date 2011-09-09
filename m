Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:19240 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933308Ab1IIMI7 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Sep 2011 08:08:59 -0400
Subject: [PATCH v2 2/5] SUNRPC: use rpcbind reference counting helpers
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net
Date: Fri, 09 Sep 2011 16:08:36 +0400
Message-ID: <20110909120836.13697.24968.stgit@localhost6.localdomain6>
In-Reply-To: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
References: <20110909115146.13697.71682.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

All is simple: we just increase users counter if rpcbind clients has been
created already. Otherwise we create them and set users counter to 1.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index c84e6a3..b4cc0f1 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -256,9 +256,7 @@ static int rpcb_create_local_unix(void)
 		clnt4 = NULL;
 	}
 
-	/* Protected by rpcb_create_local_mutex */
-	rpcb_local_clnt = clnt;
-	rpcb_local_clnt4 = clnt4;
+	rpcb_set_local(clnt, clnt4);
 
 out:
 	return result;
@@ -310,9 +308,7 @@ static int rpcb_create_local_net(void)
 		clnt4 = NULL;
 	}
 
-	/* Protected by rpcb_create_local_mutex */
-	rpcb_local_clnt = clnt;
-	rpcb_local_clnt4 = clnt4;
+	rpcb_set_local(clnt, clnt4);
 
 out:
 	return result;
@@ -327,11 +323,11 @@ static int rpcb_create_local(void)
 	static DEFINE_MUTEX(rpcb_create_local_mutex);
 	int result = 0;
 
-	if (rpcb_local_clnt)
+	if (rpcb_get_local())
 		return result;
 
 	mutex_lock(&rpcb_create_local_mutex);
-	if (rpcb_local_clnt)
+	if (rpcb_get_local())
 		goto out;
 
 	if (rpcb_create_local_unix() != 0)

