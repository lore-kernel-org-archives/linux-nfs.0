Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3895EC43381
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 066002084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:09 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="ko7SmrIL"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726087AbfCAT1I (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:08 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:40610 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726080AbfCAT1I (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:08 -0500
Received: by mail-yw1-f68.google.com with SMTP id c67so14912550ywa.7
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=rNo/gAWru6n9VrbYqblgw5CRH3GCCY+DGVXNC57VZlw=;
        b=ko7SmrILrTLME/JvMeDOB9wS14T+UVFqlflNai0Y3G7UEKooP97YgXkMpbr4/cKpjS
         hehwfJMIp6jKiP7wIM/gQxchKb7Aef/jDzK2IjlnRJ0FlcnUh/Vl901a8Dt+6OmeKIqk
         HU+oqXAT/JHzWcc0hqYRQYV0lzdWbd5mlo1Rd2y3dnKrYtcfNELdsF3xrz6W3njT253A
         5MTYY3W44LvWajGRjcMpsnLdXsSQ3fK01j/o47tPZ9qS/KesE3KCD7MvaaRWKec/1bGA
         2UZI9DXSnAflvIhazpylktMEzRSK23N5upYhRHyEEUJqJEXoYdHW20wrHCv9izr/dR3+
         P2Ow==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=rNo/gAWru6n9VrbYqblgw5CRH3GCCY+DGVXNC57VZlw=;
        b=AISNMXoYSxU/H866wxUIdjAE3il2FctLQxhsvntl5GJ02E6/e/QIYj7Cs0a/LhP8x0
         zmO+8TmDgKKANuJJYU4124rIWlzZcQwvwJ2EDQBWD+WWlFOpFEX7fCli2Bd8yFhe5VXm
         TlsiKJa5Yxtb8iBFq+XjsPcQlYrAXXR0LNLS8jfbVAnoemRmZX+6xjS1vkPfgRKujQOs
         W7zhSZrbTlAcIJoUTRRCAYgRayYWk32q9pe94geFlQvJFY9xCygjW/nKN1kNubs0CoOt
         kGtotbLAvcrn+sRvZrnrzNJOaBHRkF3fVhPHjL5mpTCGX0oPsPl9Btx1HC3BO0EoAC3h
         QZAw==
X-Gm-Message-State: APjAAAVje2dWnAhVqOa6/JLJqs1XXy0+cZ6Xk6UC4mvx+/OCwOprNA7k
        SCYr1fMlwLdL++fLoaqhHL7QEJE=
X-Google-Smtp-Source: APXvYqyjTJHYXk3hnDvu5g8ecUIepTBtYpD78K4nZn081Zcpa95ITEHK7qSLBZQNObip8/5RzYkRIw==
X-Received: by 2002:a81:4ed6:: with SMTP id c205mr4987025ywb.13.1551468426361;
        Fri, 01 Mar 2019 11:27:06 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.05
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:05 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 15/19] NFS/flexfiles: Simplify ff_layout_get_ds_cred()
Date:   Fri,  1 Mar 2019 14:24:51 -0500
Message-Id: <20190301192455.104943-16-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-15-trond.myklebust@hammerspace.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.c    | 6 +++---
 fs/nfs/flexfilelayout/flexfilelayout.h    | 5 +++--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 6 +++---
 3 files changed, 9 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 54e4a1dabf68..57776de619b5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1783,7 +1783,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
 
-	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred);
 	if (!ds_cred)
 		goto out_failed;
 
@@ -1848,7 +1848,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
 
-	ds_cred = ff_layout_get_ds_cred(lseg, idx, hdr->cred);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, hdr->cred);
 	if (!ds_cred)
 		goto out_failed;
 
@@ -1933,7 +1933,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	if (IS_ERR(ds_clnt))
 		goto out_err;
 
-	ds_cred = ff_layout_get_ds_cred(lseg, idx, data->cred);
+	ds_cred = ff_layout_get_ds_cred(mirror, &lseg->pls_range, data->cred);
 	if (!ds_cred)
 		goto out_err;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 2bda4baa655a..e0b2c3deae5a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -218,8 +218,9 @@ struct rpc_clnt *
 nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
 				 struct nfs_client *ds_clp,
 				 struct inode *inode);
-const struct cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
-				       u32 ds_idx, const struct cred *mdscred);
+const struct cred *ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
+					 const struct pnfs_layout_range *range,
+					 const struct cred *mdscred);
 bool ff_layout_avoid_mds_available_ds(struct pnfs_layout_segment *lseg);
 bool ff_layout_avoid_read_on_rw(struct pnfs_layout_segment *lseg);
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 0651fd1e52c3..691e8b87032b 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -447,14 +447,14 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 }
 
 const struct cred *
-ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
+ff_layout_get_ds_cred(struct nfs4_ff_layout_mirror *mirror,
+		      const struct pnfs_layout_range *range,
 		      const struct cred *mdscred)
 {
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
 	const struct cred *cred;
 
 	if (mirror && !mirror->mirror_ds->ds_versions[0].tightly_coupled) {
-		cred = ff_layout_get_mirror_cred(mirror, lseg->pls_range.iomode);
+		cred = ff_layout_get_mirror_cred(mirror, range->iomode);
 		if (!cred)
 			cred = get_cred(mdscred);
 	} else {
-- 
2.20.1

