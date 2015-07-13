Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:36541 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbbGMJdD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Jul 2015 05:33:03 -0400
Received: by pdjr16 with SMTP id r16so60035546pdj.3
        for <linux-nfs@vger.kernel.org>; Mon, 13 Jul 2015 02:33:02 -0700 (PDT)
Message-ID: <55A385CB.2040608@gmail.com>
Date: Mon, 13 Jul 2015 17:32:59 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: "J. Bruce Fields" <bfields@fieldses.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
CC: kinglongmee@gmail.com
Subject: [PATCH 09/14] nfsd: Remove nfs4_set_claim_prev()
References: <55A384B1.8030207@gmail.com>
In-Reply-To: <55A384B1.8030207@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/nfs4state.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index c94d1ef..f3c38e3 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3887,12 +3887,6 @@ nfs4_upgrade_open(struct svc_rqst *rqstp, struct nfs4_file *fp, struct svc_fh *c
 	return status;
 }
 
-static void
-nfs4_set_claim_prev(struct nfsd4_open *open, bool has_session)
-{
-	open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
-}
-
 /* Should we give out recallable state?: */
 static bool nfsd4_cb_channel_good(struct nfs4_client *clp)
 {
@@ -4212,7 +4206,7 @@ out:
 	if (fp)
 		put_nfs4_file(fp);
 	if (status == 0 && open->op_claim_type == NFS4_OPEN_CLAIM_PREVIOUS)
-		nfs4_set_claim_prev(open, nfsd4_has_session(&resp->cstate));
+		open->op_openowner->oo_flags |= NFS4_OO_CONFIRMED;
 	/*
 	* To finish the open response, we just need to set the rflags.
 	*/
-- 
2.4.3

