Return-Path: <SRS0=EkhZ=X2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7487AC352AA
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:57:38 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 4CC8921783
	for <linux-nfs@archiver.kernel.org>; Tue,  1 Oct 2019 16:57:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1569949058;
	bh=9M5Nx3H8tNFe5QixqpzD9pf6eQnJZ5bl01NdqAyFi44=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=0oFuKlHFi7UNmRCLBZOJsA8Q59yv+1linQsmE2ZobxP+T/BSZMinBhsj6crmIWSUX
	 UtVxtCfomp07gOQNFPsDe2rLFXoRnhPFovxzVX6kAP1zxnMzRUjD/9QRZyvXIShQtI
	 NgkkGuzyyutU7P+d/k261FTeBGraABJ8/2tPBc1c=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1731394AbfJAQ5f (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 1 Oct 2019 12:57:35 -0400
Received: from mail.kernel.org ([198.145.29.99]:53616 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1731457AbfJAQly (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 1 Oct 2019 12:41:54 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 4482D21906;
        Tue,  1 Oct 2019 16:41:53 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1569948114;
        bh=9M5Nx3H8tNFe5QixqpzD9pf6eQnJZ5bl01NdqAyFi44=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=qZ8+JTvL/a9/wsLrgWCnx3Ja4yEC94Be2WcXUKu27Xx5+XFRXhm7prS6jkaNMMabf
         E7dlAEwbvY/93daErbUOVpIRA+Jm3QwH1M65yes3P5/+mttD18hyvElduAO+1+J/Be
         crTWme18fhgIWXf7c0zrVGsRguwV4sSDkx2rqCyM=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Trond Myklebust <trondmy@gmail.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <Anna.Schumaker@Netapp.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.2 20/63] pNFS: Ensure we do clear the return-on-close layout stateid on fatal errors
Date:   Tue,  1 Oct 2019 12:40:42 -0400
Message-Id: <20191001164125.15398-20-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20191001164125.15398-1-sashal@kernel.org>
References: <20191001164125.15398-1-sashal@kernel.org>
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
index bfe1f4625f603..33c2ef416564a 100644
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

