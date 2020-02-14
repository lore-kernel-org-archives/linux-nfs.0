Return-Path: <SRS0=JHN1=4C=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BF6D4C2BA83
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:58:24 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 9477C2082F
	for <linux-nfs@archiver.kernel.org>; Fri, 14 Feb 2020 16:58:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1581699504;
	bh=P++HCTpxiCRIcTWNZG9ayqctJBsLbth8OUnjd8D3TW0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=SixPQj7dpw0Ea68KZiUI9iUmnurK6DWs09Tkz/A62K/jO3qFQYBVz5U3blIUw2J6m
	 ynwzwpyt7s/kEZ5AcXm7YKdYXPqI0Z9htuGSF5kXg5cLibEreLHl23O/cSszDxifW0
	 5hFSQkg0Zlbrupdekhvb2j6A0dFF52W1TWi1w6c8=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2404435AbgBNQRV (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 14 Feb 2020 11:17:21 -0500
Received: from mail.kernel.org ([198.145.29.99]:48536 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S2404431AbgBNQRU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 14 Feb 2020 11:17:20 -0500
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id 69B522469A;
        Fri, 14 Feb 2020 16:17:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1581697040;
        bh=P++HCTpxiCRIcTWNZG9ayqctJBsLbth8OUnjd8D3TW0=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=LyU1RboRyRSM21GPRp++AC3fiMY6EtVMfaZ3HwaSbFmBe3eBkK1H0Fpjb7UaAX3RT
         kSy1L6Udr+vpzW1Pn0ObtCLoNDOUEFKe/yQbXG+w98DFw9dyY+Yj4u96sepmn5Cbcr
         3fRybk8hRtfOw5A2vtxQXJ49Xf5bqAKaDZwjpzK8=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     "J. Bruce Fields" <bfields@redhat.com>,
        Dan Carpenter <dan.carpenter@oracle.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.14 003/186] nfsd4: avoid NULL deference on strange COPY compounds
Date:   Fri, 14 Feb 2020 11:14:12 -0500
Message-Id: <20200214161715.18113-3-sashal@kernel.org>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20200214161715.18113-1-sashal@kernel.org>
References: <20200214161715.18113-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: "J. Bruce Fields" <bfields@redhat.com>

[ Upstream commit d781e3df710745fbbaee4eb07fd5b64331a1b175 ]

With cross-server COPY we've introduced the possibility that the current
or saved filehandle might not have fh_dentry/fh_export filled in, but we
missed a place that assumed it was.  I think this could be triggered by
a compound like:

	PUTFH(foreign filehandle)
	GETATTR
	SAVEFH
	COPY

First, check_if_stalefh_allowed sets no_verify on the first (PUTFH) op.
Then op_func = nfsd4_putfh runs and leaves current_fh->fh_export NULL.
need_wrongsec_check returns true, since this PUTFH has OP_IS_PUTFH_LIKE
set and GETATTR does not have OP_HANDLES_WRONGSEC set.

We should probably also consider tightening the checks in
check_if_stalefh_allowed and double-checking that we don't assume the
filehandle is verified elsewhere in the compound.  But I think this
fixes the immediate issue.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Fixes: 4e48f1cccab3 "NFSD: allow inter server COPY to have... "
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfsd/nfs4proc.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index ee765abad2efb..be42ea2603683 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1798,7 +1798,8 @@ nfsd4_proc_compound(struct svc_rqst *rqstp)
 			if (op->opdesc->op_flags & OP_CLEAR_STATEID)
 				clear_current_stateid(cstate);
 
-			if (need_wrongsec_check(rqstp))
+			if (current_fh->fh_export &&
+					need_wrongsec_check(rqstp))
 				op->status = check_nfsd_access(current_fh->fh_export, rqstp);
 		}
 encode_op:
-- 
2.20.1

