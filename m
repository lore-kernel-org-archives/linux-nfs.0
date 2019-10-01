Return-Path: <SRS0=EkhZ=X2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9316EECE587
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 17:03:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5EAFE2054F
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 17:03:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569949386;
	bh=sYY95Hr5Vx7uYLpkaAUKFT7rsKYr+ZKBrBYfbzCeno0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=dNydrMFdrcDbuq4jtDlke9y1PYt6neHxz3CcfF1CoCSklM1unq8El4y/55sxXa262
	 QG2YawfCRp2UYXYsBAR++bfAGMpP/iriWdoc2RabNG6pughwm07WApNQjr66NxViLz
	 r94vSljgh6qHWXogDj1A6nMsWd9pH6r01MGpX8xI=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728701AbfJAQj5 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Oct 2019 12:39:57 -0400
Received: from mail.kernel.org ([198.145.29.99]:51058 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728521AbfJAQj4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Oct 2019 12:39:56 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 5E6C62190F;
        Tue,  1 Oct 2019 16:39:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569947996;
        bh=sYY95Hr5Vx7uYLpkaAUKFT7rsKYr+ZKBrBYfbzCeno0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=nNajo/9/AtRBIt5z2NxJmrX/Ot9ufPNXCJMndxQO8Y7YE0CSXEUOaGmqlaIlU0CP4
         AWNFw0gd+iOyN/fmGe2DI/gjY4Dkj8kVGqqrdCjrySbr2q7UkbORa0FVGP9qXl9Aui
         /B32Haas3/LSBF1wGnHyMIb7gmkXoMJ1xGKYl6aM=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.3 22/71] pNFS: Ensure we do clear the return-on-close layout stateid on fatal errors
Date:   Tue,  1 Oct 2019 12:38:32 -0400
Message-Id: <20191001163922.14735-22-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191001163922.14735-1-sashal@kernel.org>
References: <20191001163922.14735-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Trond Myklebust <trondmy@gmail.com>

[ Upstream commit 9c47b18cf722184f32148784189fca945a7d0561 ]

IF the server rejected our layout return with a state error such as
NFS4ERR_BAD_STATEID, or even a stale inode error, then we do want
to clear out all the remaining layout segments and mark that stateid
as invalid.

Fixes: 1c5bd76d17cca ("pNFS: Enable layoutreturn operation for...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/pnfs.c | 9 +++++++--
 1 file changed, 7 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 4525d5acae386..0418b198edd3e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1449,10 +1449,15 @@ void pnfs_roc_release(struct nfs4_layoutreturn_args *args,
 	const nfs4_stateid *res_stateid = NULL;
 	struct nfs4_xdr_opaque_data *ld_private = args->ld_private;
 
-	if (ret == 0) {
-		arg_stateid = &args->stateid;
+	switch (ret) {
+	case -NFS4ERR_NOMATCHING_LAYOUT:
+		break;
+	case 0:
 		if (res->lrs_present)
 			res_stateid = &res->stateid;
+		/* Fallthrough */
+	default:
+		arg_stateid = &args->stateid;
 	}
 	pnfs_layoutreturn_free_lsegs(lo, arg_stateid, &args->range,
 			res_stateid);
-- 
2.20.1

