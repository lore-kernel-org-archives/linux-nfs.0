Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:33311 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbbGMJcL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:32:11 -0400
Received: by padck2 with SMTP id ck2so39965894pad.0
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:32:10 -0700 (PDT)
Message-ID: <55A38595.70801@gmail.com>
Date: Mon, 13 Jul 2015 17:32:05 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 07/14] nfsd: Remove unneeded values in nfsd4_open()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4proc.c | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 90cfda7..5d99111 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -362,7 +362,6 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	__be32 status;
 	struct svc_fh *resfh = NULL;
-	struct nfsd4_compoundres *resp;
 	struct net *net = SVC_NET(rqstp);
 	struct nfsd_net *nn = net_generic(net, nfsd_net_id);
 
@@ -389,8 +388,7 @@ nfsd4_open(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 		copy_clientid(&open->op_clientid, cstate->session);
 
 	/* check seqid for replay. set nfs4_owner */
-	resp = rqstp->rq_resp;
-	status = nfsd4_process_open1(&resp->cstate, open, nn);
+	status = nfsd4_process_open1(cstate, open, nn);
 	if (status == nfserr_replay_me) {
 		struct nfs4_replay *rp = &open->op_openowner->oo_owner.so_replay;
 		fh_put(&cstate->current_fh);
-- 
2.4.3

