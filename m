Return-Path: <SRS0=lcGf=NX=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE771C43441
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 13:59:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 28DDC223D0
	for <linux-nfs@archiver.kernel.org>; Mon, 12 Nov 2018 13:59:36 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="qGieO4m6"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 28DDC223D0
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728120AbeKLXw6 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 12 Nov 2018 18:52:58 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:53109 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727530AbeKLXw6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Mon, 12 Nov 2018 18:52:58 -0500
Received: from smtp-buf-2.desy.de (smtp-buf-2.desy.de [131.169.56.165])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id C327B2808D1
        for <linux-nfs@vger.kernel.org>; Mon, 12 Nov 2018 14:59:31 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de C327B2808D1
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1542031171; bh=FcjHSwcedUkHT5lqnbzSPhT2JDk3pKnVVHDKpCm2G5E=;
        h=From:To:Cc:Subject:Date:From;
        b=qGieO4m6uITVXMY8UKu/dsRWFYxTcgQNmjYkgQ6xzryUslo9JGy3PLjz9+d6V6Blg
         WipWiJBc0hwt3wnx8a8O5mx5wmk8XisNN7cM+CneWiq2qD2m6Hi7tiiWtDK/OaeY0w
         cxQXyB2GpTSgJLBVqBaxwErvh7cO795k/6pygaxQ=
Received: from smtp-m-2.desy.de (smtp-m-2.desy.de [131.169.56.130])
        by smtp-buf-2.desy.de (Postfix) with ESMTP id BB9691A00E9;
        Mon, 12 Nov 2018 14:59:31 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from anahit.desy.de (anahit.desy.de [131.169.185.68])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 79CE91029;
        Mon, 12 Nov 2018 14:59:31 +0100 (MET)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     trondmy@hammerspace.com, Anna.Schumaker@Netapp.com
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Rick Macklem <rmacklem@uoguelph.ca>
Subject: [PATCH] flexfiles: use per-mirror specified stateid for IO
Date:   Mon, 12 Nov 2018 14:59:18 +0100
Message-Id: <20181112135918.12011-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.17.2
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

rfc8435 says:

  For tight coupling, ffds_stateid provides the stateid to be used by
  the client to access the file.

However current implementation replaces per-mirror provided stateid with
by open or lock stateid.

Ensure that per-mirror stateid is used by ff_layout_write_prepare_v4 and
nfs4_ff_layout_prepare_ds.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Rick Macklem <rmacklem@uoguelph.ca>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 21 +++++++++++++--------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  2 ++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 17 +++++++++++++++++
 3 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 86bcba40ca61..4c7f042db9c4 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1363,10 +1363,6 @@ static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
 
 	if (ff_layout_read_prepare_common(task, hdr))
 		return;
-
-	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
-			hdr->args.lock_context, FMODE_READ) == -EIO)
-		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
 }
 
 static void ff_layout_read_call_done(struct rpc_task *task, void *data)
@@ -1544,10 +1540,6 @@ static void ff_layout_write_prepare_v4(struct rpc_task *task, void *data)
 
 	if (ff_layout_write_prepare_common(task, hdr))
 		return;
-
-	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
-			hdr->args.lock_context, FMODE_WRITE) == -EIO)
-		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
 }
 
 static void ff_layout_write_call_done(struct rpc_task *task, void *data)
@@ -1713,6 +1705,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	u32 idx = hdr->pgio_mirror_idx;
 	int vers;
 	struct nfs_fh *fh;
+	nfs4_stateid *stateid;
 
 	dprintk("--> %s ino %lu pgbase %u req %zu@%llu\n",
 		__func__, hdr->inode->i_ino,
@@ -1742,6 +1735,12 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
 	if (fh)
 		hdr->args.fh = fh;
+
+	stateid = nfs4_ff_layout_select_ds_stateid(lseg, idx);
+	if (!stateid)
+		goto out_failed;
+	nfs4_stateid_copy(&hdr->args.stateid, stateid);
+
 	/*
 	 * Note that if we ever decide to split across DSes,
 	 * then we may need to handle dense-like offsets.
@@ -1774,6 +1773,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	loff_t offset = hdr->args.offset;
 	int vers;
 	struct nfs_fh *fh;
+	nfs4_stateid *stateid;
 	int idx = hdr->pgio_mirror_idx;
 
 	ds = nfs4_ff_layout_prepare_ds(lseg, idx, true);
@@ -1804,6 +1804,11 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
+	stateid = nfs4_ff_layout_select_ds_stateid(lseg, idx);
+	if (!stateid)
+		goto out_failed;
+	nfs4_stateid_copy(&hdr->args.stateid, stateid);
+
 	/*
 	 * Note that if we ever decide to split across DSes,
 	 * then we may need to handle dense-like offsets.
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 411798346e48..fdfbcb471999 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -215,6 +215,8 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
 		unsigned int maxnum);
 struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx);
+nfs4_stateid *
+nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg, u32 mirror_idx);
 
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 74d8d5352438..91787cf68057 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -370,6 +370,23 @@ nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 	return fh;
 }
 
+nfs4_stateid *
+nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg, u32 mirror_idx)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
+	nfs4_stateid *stateid = NULL;
+
+	if (!ff_layout_mirror_valid(lseg, mirror, false)) {
+		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
+			__func__, mirror_idx);
+		goto out;
+	}
+
+	stateid = &mirror->stateid;
+out:
+	return stateid;
+}
+
 /**
  * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
  * @lseg: the layout segment we're operating on
-- 
2.17.2

