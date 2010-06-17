From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH] SQUASHME: pnfsd: setup backchannel in create_session also in session reestablishment
Date: Thu, 17 Jun 2010 19:01:36 -0400
Message-ID: <1276815696-19281-1-git-send-email-bhalevy@panasas.com>
Cc: bfields@citi.umich.edu, linux-nfs@vger.kernel.org
To: bharrosh@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:58948 "EHLO
	daytona.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755714Ab0FQXBa (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 17 Jun 2010 19:01:30 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The client may send an EXCHANGE_ID and a following CREATE_SESSION for an
existing clientid.  In this case we'll find the nfs4_client in the confirmed
list.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |   24 +++++++++++-------------
 1 files changed, 11 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 3e012d4..0df5483 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1405,25 +1405,23 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (is_ds_only_session(unconf->cl_exchange_flags))
 			cr_ses->flags &= ~SESSION4_BACK_CHAN;
 
-		if (cr_ses->flags & SESSION4_BACK_CHAN) {
-			unconf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
-			svc_xprt_get(rqstp->rq_xprt);
-			rpc_copy_addr(
-				(struct sockaddr *)&unconf->cl_cb_conn.cb_addr,
-				sa);
-			unconf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
-			unconf->cl_cb_conn.cb_minorversion =
-				cstate->minorversion;
-			unconf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
-			unconf->cl_cb_seq_nr = 1;
-			nfsd4_probe_callback(unconf, &unconf->cl_cb_conn);
-		}
 		conf = unconf;
 	} else {
 		status = nfserr_stale_clientid;
 		goto out;
 	}
 
+	if (cr_ses->flags & SESSION4_BACK_CHAN) {
+		conf->cl_cb_conn.cb_xprt = rqstp->rq_xprt;
+		svc_xprt_get(rqstp->rq_xprt);
+		rpc_copy_addr((struct sockaddr *)&conf->cl_cb_conn.cb_addr, sa);
+		conf->cl_cb_conn.cb_addrlen = svc_addr_len(sa);
+		conf->cl_cb_conn.cb_minorversion = cstate->minorversion;
+		conf->cl_cb_conn.cb_prog = cr_ses->callback_prog;
+		conf->cl_cb_seq_nr = 1;
+		nfsd4_probe_callback(conf, &conf->cl_cb_conn);
+	}
+
 	/*
 	 * We do not support RDMA or persistent sessions
 	 */
-- 
1.6.4.4

