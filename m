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
	by smtp.lore.kernel.org (Postfix) with ESMTP id E4E10C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:03 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B2FDE2084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:03 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="GmEOIM78"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726034AbfCAT1D (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:03 -0500
Received: from mail-yw1-f68.google.com ([209.85.161.68]:42829 "EHLO
        mail-yw1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725905AbfCAT1C (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:02 -0500
Received: by mail-yw1-f68.google.com with SMTP id v201so14922396ywa.9
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:01 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=K8etNovwHr89mpTVuxAGsyAfNo4BZg1qah5bA8zhZQo=;
        b=GmEOIM78jfDJFhru+mvP7EVDP6pFlBZn3hFx7jPegWk7V1yJEzdMKsr18CxBpsZYC3
         DsZvvI7YOXlDei7aGKHAs9V8x42dm0u+WxFThL2cz9hRt8sUsdD0c1UFJT5Eqzf7GAW+
         o/QjoRG3f9yYlzUULXAVtYeijFGgkFoMC0OgMLBhgA42IWf5j5gb8yRaZWaerSexkyAD
         MnClhlNuTrIRzjJNL4Fs7fg4TdQwmjg8Erwmb9Ll/dQkbBpOtGM0AbSLL2kMZbiIQh9h
         lGdvjxgeBXQjlYul886oPlCYgoU/y1KJpyCt8PMis3FPecEvvKU42QWd9kZ5lsqKff+S
         Rhkw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=K8etNovwHr89mpTVuxAGsyAfNo4BZg1qah5bA8zhZQo=;
        b=BXSgWoGmPKQx/+6KBxjB59owz9Qkmfcz8KIBvAptjgW5Zf9/jRQcmsKorr56fI/UB7
         6iW9LiW6tPG0FcH//bjw/JN55O42E9IIf25tIdgYR7l6kl6LbIjUjUmf/3SyneNfiYLt
         XLCJPDyKY4vqBmoJNJIvcwtOBvTHrOLkQFJY3xXkSIf4XXGnYyv1rkREZCoNVw3teWed
         AKne5HkV+X6Jg5zdszlw0CC96G8oAgUS+ee19mkzpBv3+pkLK1PfPqLLZcUeZT7IYHJn
         BH5c4F/5E29CMoHZ0odbZh+8u8MuSLSDHsUwKV9BSJp27McQAPKM6fBbH3kmBO9BFBok
         sTCQ==
X-Gm-Message-State: APjAAAUn344lwX6XwCc42o1t+lrRyYTBROXS5sYh7ne4AOE4upISp02J
        Dk+1hpXaHH3yrGUndGTwtQwUB+E=
X-Google-Smtp-Source: APXvYqxult5bzO04FNAVoga+8WduOee/v/y4JfInYVJyvl88l7dIWidRa2VIlnTDmFvSCgkYgKWavg==
X-Received: by 2002:a81:5e89:: with SMTP id s131mr4961242ywb.482.1551468420247;
        Fri, 01 Mar 2019 11:27:00 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.26.59
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:26:59 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 08/19] NFS/flexfiles: refactor calls to fs4_ff_layout_prepare_ds()
Date:   Fri,  1 Mar 2019 14:24:44 -0500
Message-Id: <20190301192455.104943-9-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-8-trond.myklebust@hammerspace.com>
References: <20190301192455.104943-1-trond.myklebust@hammerspace.com>
 <20190301192455.104943-2-trond.myklebust@hammerspace.com>
 <20190301192455.104943-3-trond.myklebust@hammerspace.com>
 <20190301192455.104943-4-trond.myklebust@hammerspace.com>
 <20190301192455.104943-5-trond.myklebust@hammerspace.com>
 <20190301192455.104943-6-trond.myklebust@hammerspace.com>
 <20190301192455.104943-7-trond.myklebust@hammerspace.com>
 <20190301192455.104943-8-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

While we may want to skip attempting to connect to a downed mirror
when we're deciding which mirror to select for a read, we do not
want to do so once we've committed to attempting the I/O in
ff_layout_read/write_pagelist(), or ff_layout_initiate_commit()

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 26 +++++++++++++++++------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  3 ++-
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 18 +++++-----------
 3 files changed, 27 insertions(+), 20 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 5ba30084f248..4cf6fb5df3c8 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -794,6 +794,7 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 				  int *best_idx)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
+	struct nfs4_ff_layout_mirror *mirror;
 	struct nfs4_pnfs_ds *ds;
 	bool fail_return = false;
 	int idx;
@@ -802,7 +803,12 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 	for (idx = start_idx; idx < fls->mirror_array_cnt; idx++) {
 		if (idx+1 == fls->mirror_array_cnt)
 			fail_return = true;
-		ds = nfs4_ff_layout_prepare_ds(lseg, idx, fail_return);
+
+		mirror = FF_LAYOUT_COMP(lseg, idx);
+		if (ff_layout_test_devid_unavailable(&mirror->mirror_ds->id_node))
+			continue;
+
+		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, fail_return);
 		if (ds) {
 			*best_idx = idx;
 			return ds;
@@ -925,7 +931,10 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 		goto out_mds;
 
 	for (i = 0; i < pgio->pg_mirror_count; i++) {
-		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, i, true);
+		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
+		if (ff_layout_test_devid_unavailable(&mirror->mirror_ds->id_node))
+			continue;
+		ds = nfs4_ff_layout_prepare_ds(pgio->pg_lseg, mirror, true);
 		if (!ds) {
 			if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
 				goto out_mds;
@@ -936,7 +945,6 @@ ff_layout_pg_init_write(struct nfs_pageio_descriptor *pgio,
 			goto retry;
 		}
 		pgm = &pgio->pg_mirrors[i];
-		mirror = FF_LAYOUT_COMP(pgio->pg_lseg, i);
 		pgm->pg_bsize = mirror->mirror_ds->ds_versions[0].wsize;
 	}
 
@@ -1724,6 +1732,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
+	struct nfs4_ff_layout_mirror *mirror;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	u32 idx = hdr->pgio_mirror_idx;
@@ -1734,7 +1743,8 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 		__func__, hdr->inode->i_ino,
 		hdr->args.pgbase, (size_t)hdr->args.count, offset);
 
-	ds = nfs4_ff_layout_prepare_ds(lseg, idx, false);
+	mirror = FF_LAYOUT_COMP(lseg, idx);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, false);
 	if (!ds)
 		goto out_failed;
 
@@ -1791,13 +1801,15 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	struct pnfs_layout_segment *lseg = hdr->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
+	struct nfs4_ff_layout_mirror *mirror;
 	const struct cred *ds_cred;
 	loff_t offset = hdr->args.offset;
 	int vers;
 	struct nfs_fh *fh;
 	int idx = hdr->pgio_mirror_idx;
 
-	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
+	mirror = FF_LAYOUT_COMP(lseg, idx);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, true);
 	if (!ds)
 		goto out_failed;
 
@@ -1870,6 +1882,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	struct pnfs_layout_segment *lseg = data->lseg;
 	struct nfs4_pnfs_ds *ds;
 	struct rpc_clnt *ds_clnt;
+	struct nfs4_ff_layout_mirror *mirror;
 	const struct cred *ds_cred;
 	u32 idx;
 	int vers, ret;
@@ -1880,7 +1893,8 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 		goto out_err;
 
 	idx = calc_ds_index_from_commit(lseg, data->ds_commit_index);
-	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
+	mirror = FF_LAYOUT_COMP(lseg, idx);
+	ds = nfs4_ff_layout_prepare_ds(lseg, mirror, true);
 	if (!ds)
 		goto out_err;
 
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 31a62820a5c6..93508112486a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -228,7 +228,8 @@ nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
 				nfs4_stateid *stateid);
 
 struct nfs4_pnfs_ds *
-nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
+nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
+			  struct nfs4_ff_layout_mirror *mirror,
 			  bool fail_return);
 
 struct rpc_clnt *
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index c174f23afc6d..e16ddf2d4768 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -391,7 +391,7 @@ nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
 /**
  * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
  * @lseg: the layout segment we're operating on
- * @ds_idx: index of the DS to use
+ * @mirror: layout mirror describing the DS to use
  * @fail_return: return layout on connect failure?
  *
  * Try to prepare a DS connection to accept an RPC call. This involves
@@ -406,26 +406,19 @@ nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
  * Returns a pointer to a connected DS object on success or NULL on failure.
  */
 struct nfs4_pnfs_ds *
-nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
+nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
+			  struct nfs4_ff_layout_mirror *mirror,
 			  bool fail_return)
 {
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
 	struct nfs4_pnfs_ds *ds = NULL;
-	struct nfs4_deviceid_node *devid;
+	struct nfs4_deviceid_node *devid = &mirror->mirror_ds->id_node;
 	struct inode *ino = lseg->pls_layout->plh_inode;
 	struct nfs_server *s = NFS_SERVER(ino);
 	unsigned int max_payload;
 	int status;
 
-	if (!ff_layout_mirror_valid(lseg, mirror, true)) {
-		pr_err_ratelimited("NFS: %s: No data server for offset index %d\n",
-			__func__, ds_idx);
+	if (!ff_layout_mirror_valid(lseg, mirror, true))
 		goto out;
-	}
-
-	devid = &mirror->mirror_ds->id_node;
-	if (ff_layout_test_devid_unavailable(devid))
-		goto out_fail;
 
 	ds = mirror->mirror_ds->ds;
 	/* matching smp_wmb() in _nfs4_pnfs_v3/4_ds_connect */
@@ -452,7 +445,6 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
 			mirror->mirror_ds->ds_versions[0].wsize = max_payload;
 		goto out;
 	}
-out_fail:
 	ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				 mirror, lseg->pls_range.offset,
 				 lseg->pls_range.length, NFS4ERR_NXIO,
-- 
2.20.1

