From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Subject: [RFC 07/11] nfsd41: Backchannel: Server backchannel RPC wait queue
Date: Fri,  5 Jun 2009 19:50:02 -0700
Message-ID: <1244256606-12905-7-git-send-email-Ricardo.Labiaga@netapp.com>
References: <273FE88A07F5D445824060902F7003440612BB9D@SACMVEXC1-PRD.hq.netapp.com>
 <1244256606-12905-1-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-2-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-3-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-4-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-5-git-send-email-Ricardo.Labiaga@netapp.com>
 <1244256606-12905-6-git-send-email-Ricardo.Labiaga@netapp.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org,
	Ricardo Labiaga <Ricardo.Labiaga@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: bfields@fieldses.org, trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57617 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753310AbZFFCw4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 22:52:56 -0400
In-Reply-To: <1244256606-12905-6-git-send-email-Ricardo.Labiaga@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

RPC callback requests will wait on this wait queue if the backchannel
is out of slots.

Signed-off-by: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c        |    2 ++
 include/linux/nfsd/state.h |    4 ++++
 2 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 7d89bd0..45cbbbc 100644
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
index 931aaa6..261cd73 100644
--- a/include/linux/nfsd/state.h
+++ b/include/linux/nfsd/state.h
@@ -196,7 +196,11 @@ struct nfs4_client {
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
1.5.4.3

