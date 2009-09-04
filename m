From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 06/10] nfsd41: Backchannel: Server backchannel RPC wait queue
Date: Fri,  4 Sep 2009 19:32:26 +0300
Message-ID: <1252081946-19631-1-git-send-email-bhalevy@panasas.com>
References: <4AA13DE3.8020800@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from dip-colo-pa.panasas.com ([67.152.220.67]:8969 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S933755AbZIDQc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 4 Sep 2009 12:32:26 -0400
In-Reply-To: <4AA13DE3.8020800@panasas.com>
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
index e4c3223..957f6e5 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -779,6 +779,8 @@ static struct nfs4_client *create_client(struct xdr_netobj name, char *recdir)
 	INIT_LIST_HEAD(&clp->cl_delegations);
 	INIT_LIST_HEAD(&clp->cl_sessions);
 	INIT_LIST_HEAD(&clp->cl_lru);
+	clear_bit(0, &clp->cl_cb_slot_busy);
+	rpc_init_wait_queue(&clp->cl_cb_waitq, "Backchannel slot table");
 	return clp;
 }
 
diff --git a/include/linux/nfsd/state.h b/include/linux/nfsd/state.h
index f69ea48..234e9af 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -220,7 +220,11 @@ struct nfs4_client {
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

