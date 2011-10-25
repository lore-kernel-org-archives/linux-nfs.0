Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mailhub.sw.ru ([195.214.232.25]:1415 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756415Ab1JYKQc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Oct 2011 06:16:32 -0400
Subject: [PATCH v6 2/8] SUNRPC: use rpcbind reference counting helpers
To: Trond.Myklebust@netapp.com
From: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, xemul@parallels.com, neilb@suse.de,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        bfields@fieldses.org, davem@davemloft.net, devel@openvz.org
Date: Tue, 25 Oct 2011 14:16:48 +0300
Message-ID: <20111025101644.12689.45595.stgit@localhost6.localdomain6>
In-Reply-To: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
References: <20111025100826.12689.46944.stgit@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

All is simple: we just increase users counter if rpcbind clients has been
created already. Otherwise we create them and set users counter to 1.

Signed-off-by: Stanislav Kinsbursky <skinsbursky@parallels.com>

---
 net/sunrpc/rpcb_clnt.c |   12 ++++--------
 1 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/net/sunrpc/rpcb_clnt.c b/net/sunrpc/rpcb_clnt.c
index 9fcdb42..7e5a0f8 100644
--- a/net/sunrpc/rpcb_clnt.c
+++ b/net/sunrpc/rpcb_clnt.c
@@ -259,9 +259,7 @@ static int rpcb_create_local_unix(void)
 		clnt4 = NULL;
 	}
 
-	/* Protected by rpcb_create_local_mutex */
-	rpcb_local_clnt = clnt;
-	rpcb_local_clnt4 = clnt4;
+	rpcb_set_local(clnt, clnt4);
 
 out:
 	return result;
@@ -313,9 +311,7 @@ static int rpcb_create_local_net(void)
 		clnt4 = NULL;
 	}
 
-	/* Protected by rpcb_create_local_mutex */
-	rpcb_local_clnt = clnt;
-	rpcb_local_clnt4 = clnt4;
+	rpcb_set_local(clnt, clnt4);
 
 out:
 	return result;
@@ -330,11 +326,11 @@ static int rpcb_create_local(void)
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

