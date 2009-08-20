From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH RFC 06/10] nfsd41: Backchannel: Server backchannel RPC wait queue
Date: Thu, 20 Aug 2009 03:34:38 +0300
Message-ID: <1250728478-28643-1-git-send-email-bhalevy@panasas.com>
References: <4A8C9992.2000505@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@fieldses.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ip67-152-220-67.z220-152-67.customer.algx.net ([67.152.220.67]:15755
	"EHLO daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753485AbZHTAs0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Aug 2009 20:48:26 -0400
In-Reply-To: <4A8C9992.2000505@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

RPC callback requests will wait on this wait queue if the backchannel
is out of slots.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    2 ++
 include/linux/nfsd/state.h |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index a420197..ffedc50 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -726,6 +726,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
+	clear_bit(0, &clp->cl_cb_slot_busy);
+	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	return clp;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index 50c515f..637f67c 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -213,7 +213,11 @@ struct nfs4_client {
 	struct nfs4_sessionid	cl_sessionid;
 
 	/* for nfs41 callbacks */
+	/* We currently support a single back channel with a single slot */
+	unsigned long		cl_cb_slot_busy;
 	struct svc_xprt		*cl_cb_xprt;	/* 4.1 callback transport */
+	struct rpc_wait_queue	cl_cb_waitq;	/* backchannel callers may */
+						/* wait here for slots */
 };
 
 /* struct nfs4_client_reset
-- 
1.6.4

