Return-Path: <linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
Received: from vger.kernel.org (vger.kernel.org [23.128.96.18])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CA4A1C19F28
	for <linux-nfs@archiver.kernel.org>; Wed,  3 Aug 2022 14:37:50 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S232747AbiHCOht (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 3 Aug 2022 10:37:49 -0400
Received: from lindbergh.monkeyblade.net ([23.128.96.19]:55766 "EHLO
        lindbergh.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S232079AbiHCOht (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2022 10:37:49 -0400
Received: from dfw.source.kernel.org (dfw.source.kernel.org [139.178.84.217])
        by lindbergh.monkeyblade.net (Postfix) with ESMTPS id 8269019C1D
        for <linux-nfs@vger.kernel.org>; Wed,  3 Aug 2022 07:37:48 -0700 (PDT)
Received: from smtp.kernel.org (relay.kernel.org [52.25.139.140])
        (using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
        (No client certificate requested)
        by dfw.source.kernel.org (Postfix) with ESMTPS id 1DCA06164A
        for <linux-nfs@vger.kernel.org>; Wed,  3 Aug 2022 14:37:48 +0000 (UTC)
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 58AA3C433C1;
        Wed,  3 Aug 2022 14:37:47 +0000 (UTC)
Subject: [PATCH v2 3/3] NFSD: Make nfsd4_rename() wait before returning
 NFS4ERR_DELAY
From:   Chuck Lever <chuck.lever@oracle.com>
To:     linux-nfs@vger.kernel.org
Cc:     imammedo@redhat.com
Date:   Wed, 03 Aug 2022 10:37:46 -0400
Message-ID: <165953746619.1658.12640644653566498600.stgit@manet.1015granger.net>
In-Reply-To: <165953688893.1658.15242150042289528147.stgit@manet.1015granger.net>
References: <165953688893.1658.15242150042289528147.stgit@manet.1015granger.net>
User-Agent: StGit/1.5.dev2+g9ce680a5
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

nfsd_rename() can kick off a CB_RECALL (via
vfs_rename() -> leases_conflict()) if a delegation is present.
Before returning NFS4ERR_DELAY, give the client holding that
delegation a chance to return it and then retry the nfsd_rename()
again, once.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfsd/nfs4proc.c |   31 +++++++++++++++++++++++--------
 1 file changed, 23 insertions(+), 8 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 62a267bb2ce5..2e484aafc41c 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1056,17 +1056,32 @@ nfsd4_rename(struct svc_rqst *rqstp, struct nfsd4_compound_state *cstate,
 {
 	struct nfsd4_rename *rename = &u->rename;
 	__be32 status;
+	int retries;
 
 	if (opens_in_grace(SVC_NET(rqstp)))
 		return nfserr_grace;
-	status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
-			     rename->rn_snamelen, &cstate->current_fh,
-			     rename->rn_tname, rename->rn_tnamelen);
-	if (status)
-		return status;
-	set_change_info(&rename->rn_sinfo, &cstate->current_fh);
-	set_change_info(&rename->rn_tinfo, &cstate->save_fh);
-	return nfs_ok;
+
+	retries = 1;
+	do {
+		status = nfsd_rename(rqstp, &cstate->save_fh, rename->rn_sname,
+				     rename->rn_snamelen, &cstate->current_fh,
+				     rename->rn_tname, rename->rn_tnamelen);
+		if (status == nfs_ok) {
+			set_change_info(&rename->rn_sinfo, &cstate->current_fh);
+			set_change_info(&rename->rn_tinfo, &cstate->save_fh);
+			break;
+		}
+		if (status != nfserr_jukebox)
+			break;
+		if (!retries--)
+			break;
+
+		fh_clear_pre_post_attrs(&cstate->save_fh);
+		fh_clear_pre_post_attrs(&cstate->current_fh);
+		nfsd4_wait_for_delegreturn(rqstp, &cstate->current_fh);
+	} while (1);
+
+	return status;
 }
 
 static __be32


