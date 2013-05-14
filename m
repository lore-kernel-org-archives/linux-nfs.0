Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mga02.intel.com ([134.134.136.20]:57864 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932142Ab3ENOtQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 May 2013 10:49:16 -0400
From: Imre Deak <imre.deak@intel.com>
To: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>,
        Daniel Vetter <daniel.vetter@ffwll.ch>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        "David S. Miller" <davem@davemloft.net>,
        Haggai Eran <haggaie@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>,
        Shani Michaeli <shanim@mellanox.com>,
        Roland Dreier <roland@purestorage.com>, linux-nfs@vger.kernel.org,
        netdev@vger.kernel.org
Subject: [PATCH v2 6/8] net/sunrpc: take msecs_to_jiffies_timeout into use
Date: Tue, 14 May 2013 17:48:36 +0300
Message-Id: <1368542918-8861-7-git-send-email-imre.deak@intel.com>
In-Reply-To: <1368542918-8861-1-git-send-email-imre.deak@intel.com>
References: <1368542918-8861-1-git-send-email-imre.deak@intel.com>
In-Reply-To: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
References: <1368188011-23661-1-git-send-email-imre.deak@intel.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use msecs_to_jiffies_timeout instead of open-coding the same.

Signed-off-by: Imre Deak <imre.deak@intel.com>
---
 net/sunrpc/xprtrdma/verbs.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
index 93726560..8a6575d 100644
--- a/net/sunrpc/xprtrdma/verbs.c
+++ b/net/sunrpc/xprtrdma/verbs.c
@@ -404,7 +404,7 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 		goto out;
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+				msecs_to_jiffies_timeout(RDMA_RESOLVE_TIMEOUT));
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
@@ -417,7 +417,7 @@ rpcrdma_create_id(struct rpcrdma_xprt *xprt,
 		goto out;
 	}
 	wait_for_completion_interruptible_timeout(&ia->ri_done,
-				msecs_to_jiffies(RDMA_RESOLVE_TIMEOUT) + 1);
+				msecs_to_jiffies_timeout(RDMA_RESOLVE_TIMEOUT));
 	rc = ia->ri_async_rc;
 	if (rc)
 		goto out;
-- 
1.7.10.4

