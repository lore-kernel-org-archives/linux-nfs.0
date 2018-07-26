Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:58259 "EHLO mx143.netapp.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1730827AbeGZVXF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 26 Jul 2018 17:23:05 -0400
From: Olga Kornievskaia <kolga@netapp.com>
To: <Trond.Myklebust@hammerspace.com>, <anna.schumaker@netapp.com>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/1] NFSv4.0 fix client reference leak in callback
Date: Thu, 26 Jul 2018 16:04:47 -0400
Message-ID: <20180726200447.52345-1-kolga@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If there is an error during processing of a callback message, it leads
to refrence leak on the client structure and eventually an unclean
superblock.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/callback_xdr.c | 11 ++++++++---
 1 file changed, 8 insertions(+), 3 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index a813979..cb905c0 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -883,16 +883,21 @@ static __be32 nfs4_callback_compound(struct svc_rqst *rqstp)
 
 	if (hdr_arg.minorversion == 0) {
 		cps.clp = nfs4_find_client_ident(SVC_NET(rqstp), hdr_arg.cb_ident);
-		if (!cps.clp || !check_gss_callback_principal(cps.clp, rqstp))
+		if (!cps.clp || !check_gss_callback_principal(cps.clp, rqstp)) {
+			if (cps.clp)
+				nfs_put_client(cps.clp);
 			goto out_invalidcred;
+		}
 	}
 
 	cps.minorversion = hdr_arg.minorversion;
 	hdr_res.taglen = hdr_arg.taglen;
 	hdr_res.tag = hdr_arg.tag;
-	if (encode_compound_hdr_res(&xdr_out, &hdr_res) != 0)
+	if (encode_compound_hdr_res(&xdr_out, &hdr_res) != 0) {
+		if (cps.clp)
+			nfs_put_client(cps.clp);
 		return rpc_system_err;
-
+	}
 	while (status == 0 && nops != hdr_arg.nops) {
 		status = process_op(nops, rqstp, &xdr_in,
 				    rqstp->rq_argp, &xdr_out, rqstp->rq_resp,
-- 
1.8.3.1

