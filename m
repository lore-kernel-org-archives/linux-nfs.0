Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 883DEC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:07 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 568AC2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="iW2s+SdE"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726066AbfCAT1G (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:06 -0500
Received: from mail-yw1-f66.google.com ([209.85.161.66]:40604 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT1G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:06 -0500
Received: by mail-yw1-f66.google.com with SMTP id c67so14912488ywa.7
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:05 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mEk4JxFqISaaaKHq07GPD1V46Lyq2t82EWuia0B5nkc=;
        b=iW2s+SdEqTxed/avLzp6uiiHHH+ZI48Grz6Xj7cpRuuc3FyeJI6nj8Yn2t30ct9jQz
         5GYDsAkmPgApEemyngtV9C8UniFPQvkmmaTjYDKZBqJP15FtdkWV/JB3OZB8d74/Wf/5
         KcsVgPI6m+8Ik7FzYlfFuANUkH0CG+5b3UrJvEj9JOdr7Fsjz3E/L9oYepA1nSkjiUw+
         ZFtyxEMtMrpr1JKC81ufZQ+WSQ2CJvtoFdjaQZa9qlO7j5K/wIA+jbLHds9xigEUqK8I
         qaNwQbplVBWJaxQyg3r3EE4t4t6n6jQsD0PCWZkzjLUPKoIkM9zLZ2k7y1SUjore/piY
         i+mw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=mEk4JxFqISaaaKHq07GPD1V46Lyq2t82EWuia0B5nkc=;
        b=QEZMApKcfs2QlX3xNjBzSDpA9zo7K2RJ+kogzDXrnmbwd/oaT/kngr6rMX4VFimqos
         g36uPrfg9R/tEkPNyAZaRMva5ZnGCZeL2PBkozcIMxP4+VOZ/JEuLjKLx75KXj7DDuy+
         xsjyE9fCZVlgTQ9wP8tXL2HHAsI+WKWMAiHsnlHZamKzqPDuwfG75EG7QmUXIfR+4Qja
         p8K6XV4RyPrpNw0QiCaBQ5+XmPsijC+L/BKkC2cDA9w17ZogAheI4REP8wbZr+bBxRAk
         8pcTdPxzim05dyMNB1LqnIZw5Lq0+b7DcTNWs7U9FW4WzCiLY/TFSaSnd0qdEQeZ1RG9
         Dt1w==
X-Gm-Message-State: APjAAAXiDtBZUAAhxvvtPutg02mzoWWn4h9Di8sO1w/EMYV4O7A3LEwF
        FjrAGmFTq1ARfXFJ6kof6C6JGT4=
X-Google-Smtp-Source: APXvYqwIhVWvjx54DUmcyPOcAd6dGhITc5YtU818j9cgZKVUKfEzIjT94Lbg6T1x8sarskSbas3UmA==
X-Received: by 2002:a0d:edc3:: with SMTP id w186mr5049795ywe.301.1551468424419;
        Fri, 01 Mar 2019 11:27:04 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.03
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:03 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 13/19] NFS/flexfiles: Simplify nfs4_ff_layout_select_ds_fh()
Date:   Fri,  1 Mar 2019 14:24:49 -0500
Message-Id: <20190301192455.104943-14-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-13-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Pass in a pointer to the mirror rather than having to retrieve it from
the array and then verify the resulting pointer.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    |  4 ++--
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 +-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 15 ++-------------
 3 files changed, 5 insertions(+), 16 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index ba5ed07eac92..95afde994723 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1795,7 +1795,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	hdr->pgio_done_cb = ff_layout_read_done_cb;
 	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
-	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
+	fh = nfs4_ff_layout_select_ds_fh(mirror);
 	if (fh)
 		hdr->args.fh = fh;
 
@@ -1863,7 +1863,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	refcount_inc(&ds->ds_clp->cl_count);
 	hdr->ds_clp = ds->ds_clp;
 	hdr->ds_commit_idx = idx;
-	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
+	fh = nfs4_ff_layout_select_ds_fh(mirror);
 	if (fh)
 		hdr->args.fh = fh;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 2e3c606625ef..935cba942834 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -203,7 +203,7 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
 		struct list_head *head,
 		unsigned int maxnum);
 struct nfs_fh *
-nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx);
+nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror);
 int
 nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
 				u32 mirror_idx,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index a52b31417fab..631976f2bd8e 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -351,21 +351,10 @@ ff_layout_get_mirror_cred(struct nfs4_ff_layout_mirror *mirror, u32 iomode)
 }
 
 struct nfs_fh *
-nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
+nfs4_ff_layout_select_ds_fh(struct nfs4_ff_layout_mirror *mirror)
 {
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
-	struct nfs_fh *fh = NULL;
-
-	if (!ff_layout_mirror_valid(lseg, mirror, false)) {
-		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
-			__func__, mirror_idx);
-		goto out;
-	}
-
 	/* FIXME: For now assume there is only 1 version available for the DS */
-	fh = &mirror->fh_versions[0];
-out:
-	return fh;
+	return &mirror->fh_versions[0];
 }
 
 int
-- 
2.20.1

