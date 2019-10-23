Return-Path: <SRS0=iyIL=YQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1B307CA9EB9
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E6C5B2084C
	for <linux-nfs@archiver.kernel.org>; Wed, 23 Oct 2019 23:58:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="e58ll6Xu"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2408035AbfJWX6V (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 23 Oct 2019 19:58:21 -0400
Received: from mail-io1-f67.google.com ([209.85.166.67]:36246 "EHLO
        mail-io1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2406360AbfJWX6U (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 23 Oct 2019 19:58:20 -0400
Received: by mail-io1-f67.google.com with SMTP id c16so7351021ioc.3
        for <linux-nfs@vger.kernel.org>; Wed, 23 Oct 2019 16:58:19 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=7NGYtoz2hLdsD68NTZu+3+OvCT8wa4PcwXvK18IJXRY=;
        b=e58ll6XuUeBp3TYaARZN9OCtvjikdoUogi7vEaf4taxEPSPA4dK9xfMXMFQBGSVyFY
         jpObzqKzMLRymHU2oG85X0qVUYGtx+h0jlvr1abBRFahrrCX8nEITDz9V+nsILG9dUJv
         Spm7Z78eyvKRWah+BYP9OvJTYAjICSn/BJepbDNqUXNwVbbKbaFQ0QB4UU/RaV286tnu
         VS/xlIKFj0T18vRNuVnsfg3SxY1ULJvNvHgz/imqB9a9/a0PBq+hHFs7sjl+C1bOo113
         r/xd3w2hnkvbyjZ4k4OpFCRP9Dw6s51lJeEAdliTrYs23oxsu4DIqM/u/4JjekUqTfM7
         eDaw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=7NGYtoz2hLdsD68NTZu+3+OvCT8wa4PcwXvK18IJXRY=;
        b=Fgm/52azh7yGE1b2GpGo8TfzhsQSnSy9ZGew3c+XqBthf/Nu2aVN3erU49o6k87HQ2
         k3D9IjtQMNF/DvsRv+9KROgMx1zOcmaqlshPcExAYm8PyK6rPJkImazqpn1a61drUabV
         TTSSQ2UZqX19WIMw92a6oGa2FqIZVYsp0/BSGub47RrCheXjjsCQa21iH1hVmplJbMJy
         FW8B/V3OLP9AaDPDQ7HdzBmfvbR54g2ZAVcWQ6w/TCaOVRQfL6CcATP7vo7KeaTxweWx
         NLrsv0UcYZlE1CnitjL6PQBx6n9JPY33ecSoVm+3qIXXejKSoHQJcBCqFGcm4TrkcHja
         +khw==
X-Gm-Message-State: APjAAAVzXzNkmOx2eU19uBn+YTDFejH9Ix9X8ghkMJ4GwYacUckS8sX0
        4nsCjYFnqHYpgEDPXRA5vBi52mk=
X-Google-Smtp-Source: APXvYqw92/FQkOPpJprRkE3S9YWn03Ceo/jeXf+wqijy2K/b6C1xl0OSCK+Crfgkham1jguaF2WCWQ==
X-Received: by 2002:a02:ac81:: with SMTP id x1mr12046863jan.133.1571875098827;
        Wed, 23 Oct 2019 16:58:18 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id z18sm2405409iob.47.2019.10.23.16.58.18
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Wed, 23 Oct 2019 16:58:18 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 13/14] NFSv4: Don't reclaim delegations that have been returned or revoked
Date:   Wed, 23 Oct 2019 19:55:59 -0400
Message-Id: <20191023235600.10880-14-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20191023235600.10880-13-trond.myklebust@hammerspace.com>
References: <20191023235600.10880-1-trond.myklebust@hammerspace.com>
 <20191023235600.10880-2-trond.myklebust@hammerspace.com>
 <20191023235600.10880-3-trond.myklebust@hammerspace.com>
 <20191023235600.10880-4-trond.myklebust@hammerspace.com>
 <20191023235600.10880-5-trond.myklebust@hammerspace.com>
 <20191023235600.10880-6-trond.myklebust@hammerspace.com>
 <20191023235600.10880-7-trond.myklebust@hammerspace.com>
 <20191023235600.10880-8-trond.myklebust@hammerspace.com>
 <20191023235600.10880-9-trond.myklebust@hammerspace.com>
 <20191023235600.10880-10-trond.myklebust@hammerspace.com>
 <20191023235600.10880-11-trond.myklebust@hammerspace.com>
 <20191023235600.10880-12-trond.myklebust@hammerspace.com>
 <20191023235600.10880-13-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the delegation has already been revoked, we want to avoid reclaiming
it on reboot.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/delegation.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
index 150a3bf7b35c..00c6c343dced 100644
--- a/fs/nfs/delegation.c
+++ b/fs/nfs/delegation.c
@@ -188,7 +188,7 @@ void nfs_inode_reclaim_delegation(struct inode *inode, const struct cred *cred,
 	delegation = rcu_dereference(NFS_I(inode)->delegation);
 	if (delegation != NULL) {
 		spin_lock(&delegation->lock);
-		if (delegation->inode != NULL) {
+		if (nfs4_is_valid_delegation(delegation, FMODE_READ)) {
 			nfs4_stateid_copy(&delegation->stateid, stateid);
 			delegation->type = type;
 			delegation->pagemod_limit = pagemod_limit;
-- 
2.21.0

