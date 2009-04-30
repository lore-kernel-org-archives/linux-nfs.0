From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 07/10] nfsd41: Backchannel: Server backchannel RPC wait queue
Date: Fri,  1 May 2009 02:06:29 +0300
Message-ID: <1241132789-32590-1-git-send-email-bhalevy@panasas.com>
References: <49FA2D86.8060402@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:24719 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753541AbZD3XGg (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:06:36 -0400
In-Reply-To: <49FA2D86.8060402@panasas.com>
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
index 61d5c66..d7b4028 100644
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
index aeb9c40..f204ca8 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -210,7 +210,11 @@ struct nfs4_client {
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
1.6.2.1

