From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 1/3] SQUASHME: get callback minorversion from fore channel's
Date: Sun, 29 Mar 2009 22:11:05 +0300
Message-ID: <1238353865-3778-1-git-send-email-bhalevy@panasas.com>
References: <49CFC758.6030808@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:27809 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751425AbZC2TLO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 Mar 2009 15:11:14 -0400
In-Reply-To: <49CFC758.6030808@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently we assign a constant 1.
Squash into "nfsd41: callback infrastructure"

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index e5c7ddb..b7c4ed0 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1418,7 +1418,8 @@ nfsd4_create_session(struct svc_rqst *rqstp,
 		if (cr_ses->flags & SESSION4_BACK_CHAN) {
 			unconf->cl_cb_xprt = rqstp->rq_xprt;
 			svc_xprt_get(unconf->cl_cb_xprt);
-			unconf->cl_callback.cb_minorversion = 1;
+			unconf->cl_callback.cb_minorversion =
+				cstate->minorversion;
 			unconf->cl_cb_seq_nr = 0;
 			unconf->cl_callback.cb_prog = cr_ses->callback_prog;
 			nfsd4_probe_callback(unconf);
-- 
1.6.2.1

