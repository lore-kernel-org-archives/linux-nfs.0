Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 48179C10F03
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:11 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 151242070B
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:11 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="lqNMx42x"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726104AbfCAT1K (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:10 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:38950 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726080AbfCAT1K (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:10 -0500
Received: by mail-yw1-f68.google.com with SMTP id z191so14308419ywa.6
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:09 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Hdgsy3TrI7HfoT2JCZUr3HGrmkiPKxRrDPzuRRUiuWU=;
        b=lqNMx42xT/fI1jR5THCPhDZArsnGs7L7RygXBW/O1LzT4fs2jJ5DDlLBowsIZXChVJ
         GLLP+qaxVlP/I7CTlWzvos8Pbsy2HPxdqWAX4pjQCpctM8PbAKY9ou/NT/YrWD4aFlSN
         ENB1Lsj4nX9L0UKNCZkDGuIN0XcNjUnpDsVSzUjSkrCWkD7beJwW9/TFQvr+m5URXNDV
         IJS8vulLBYjr9hcUD/xsaLxO+nH7689Hszq6b5TNqfXxbeYJ/+EVhKUHVwD451Z2kz5Y
         T0kd8EYT2rtgU+brJf9pIKP+BKPvAL2ZyZdN+kh9sr98v0gnKSX1jyoVgS+7Vm1t1wuq
         pkMg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=Hdgsy3TrI7HfoT2JCZUr3HGrmkiPKxRrDPzuRRUiuWU=;
        b=FmIrc1Zl0cz4+iVKHY1YZRCPNUM9tEQx0IxGlo9PgoPF1T8lVzYkqMjy1t2OWpLMD+
         iIZJz3/+Up/7ln6OEJZdlSi/UBkQeuMvMK/5X0E3cSDluoeS1Gup3JH2qR7m0TIu8IWG
         0ziZnAlMBYCg/Yku58fsY0lUQuV544FqRXLdlVumzMUvxoPKZcWlM7CHrefq7C9lMgHt
         rTkCpfR5R0/JFmkagyt/UCBRxF8U64PYOLVUrnFO33csljOiNRRyWVfQZBvPip3Nhyx4
         q9DXktjmuVutEWMWgGkyIWB5QUy6Dc1MkAitXblZVF7R/giUEnCX9+3v6wXUg15Q+BMJ
         istQ==
X-Gm-Message-State: APjAAAWsGXCVEe8GXzVCc69eXNaKEXt7oTHAQW6PZjmxdPqDOBImi7cx
        tEanbC66l1SHANrVfB7BvURh0Jw=
X-Google-Smtp-Source: APXvYqyDATiCPBEPzWyApm0wh5Q7JilAiwrWN0EqiaSenUZJGCX4Q9TM3J9K3Iz1fJ9d8Ueml4VsMA==
X-Received: by 2002:a25:c0cc:: with SMTP id c195mr5530735ybf.166.1551468428408;
        Fri, 01 Mar 2019 11:27:08 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.07
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:07 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 17/19] NFS/flexfile: Simplify nfs4_ff_layout_select_ds_stateid()
Date:   Fri,  1 Mar 2019 14:24:53 -0500
Message-Id: <20190301192455.104943-18-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-17-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
 <20190301192455.104943-9-trond.myklebust@hammerspace.com>
 <20190301192455.104943-10-trond.myklebust@hammerspace.com>
 <20190301192455.104943-11-trond.myklebust@hammerspace.com>
 <20190301192455.104943-12-trond.myklebust@hammerspace.com>
 <20190301192455.104943-13-trond.myklebust@hammerspace.com>
 <20190301192455.104943-14-trond.myklebust@hammerspace.com>
 <20190301192455.104943-15-trond.myklebust@hammerspace.com>
 <20190301192455.104943-16-trond.myklebust@hammerspace.com>
 <20190301192455.104943-17-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Pass in a pointer to the mirror rather than forcing another
array access.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  8 ++------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  7 +++----
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 21 +++++----------------
 3 files changed, 10 insertions(+), 26 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 94515856b357..5db768924fba 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1799,9 +1799,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (fh)
 		hdr->args.fh = fh;
 
-	if (vers == 4 &&
-		!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
-		goto out_failed;
+	nfs4_ff_layout_select_ds_stateid(mirror, &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
@@ -1867,9 +1865,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
-	if (vers == 4 &&
-		!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
-		goto out_failed;
+	nfs4_ff_layout_select_ds_stateid(mirror, &hdr->args.stateid);
 
 	/*
 	 * Note that if we ever decide to split across DSes,
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 99cfe2e8f32a..2f369966abf7 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -204,10 +204,9 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
 		unsigned int maxnum);
 struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror);
-int
-nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
-				u32 mirror_idx,
-				nfs4_stateid *stateid);
+void
+nfs4_ff_layout_select_ds_stateid(const struct nfs4_ff_layout_mirror *mirror,
+		nfs4_stateid *stateid);
 
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 691e8b87032b..9348a4588f55 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -357,23 +357,12 @@ nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror)
 	return &mirror->fh_versions[0];
 }
 
-int
-nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
-				u32 mirror_idx,
-				nfs4_stateid *stateid)
+void
+nfs4_ff_layout_select_ds_stateid(const struct nfs4_ff_layout_mirror *mirror,
+		nfs4_stateid *stateid)
 {
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
-
-	if (!ff_layout_mirror_valid(lseg, mirror, false)) {
-		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
-			__func__, mirror_idx);
-		goto out;
-	}
-
-	nfs4_stateid_copy(stateid, &mirror->stateid);
-	return 1;
-out:
-	return 0;
+	if (nfs4_ff_layout_ds_version(mirror) == 4)
+		nfs4_stateid_copy(stateid, &mirror->stateid);
 }
 
 /**
-- 
2.20.1

