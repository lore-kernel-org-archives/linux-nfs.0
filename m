Return-Path: <SRS0=rzd8=OA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,HK_RANDOM_FROM,INCLUDES_PATCH,
	MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E26F1C43441
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Nov 2018 11:26:10 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 48D5B2146F
	for <linux-nfs@archiver.kernel.org>; Wed, 21 Nov 2018 11:26:10 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=desy.de header.i=@desy.de header.b="vVmhwnXF"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 48D5B2146F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=desy.de
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728587AbeKUWAK (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 21 Nov 2018 17:00:10 -0500
Received: from smtp-o-3.desy.de ([131.169.56.156]:50972 "EHLO smtp-o-3.desy.de"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727874AbeKUWAK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Nov 2018 17:00:10 -0500
Received: from smtp-buf-3.desy.de (smtp-buf-3.desy.de [131.169.56.166])
        by smtp-o-3.desy.de (DESY-O-3) with ESMTP id A009D280B4A
        for <linux-nfs@vger.kernel.org>; Wed, 21 Nov 2018 12:26:05 +0100 (CET)
DKIM-Filter: OpenDKIM Filter v2.11.0 smtp-o-3.desy.de A009D280B4A
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=desy.de; s=default;
        t=1542799565; bh=+oeFM/pHg/Sfu1jcLXvO1dWoSgTu8v8A0LfuZCzuEdY=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=vVmhwnXFqhRbk9kU1ISTUYaYsSQ2fI3xmcF1hepbtwvL3GGjWuv8I0VrOR0aR4PqJ
         xa3ambV6UPdQqexBkOQfzD5ql2M/KaSm0Q85qGfpVTgItzKM5d6mKt5CxtEFGk/TLt
         Sn/4GcbuclIVlXXqj25NRiwC79aebA3e+JsoT8Cw=
Received: from smtp-m-3.desy.de (smtp-m-3.desy.de [IPv6:2001:638:700:1038::1:83])
        by smtp-buf-3.desy.de (Postfix) with ESMTP id 9676BA0056;
        Wed, 21 Nov 2018 12:26:05 +0100 (CET)
X-Virus-Scanned: amavisd-new at desy.de
Received: from anahit.desy.de (anahit.desy.de [131.169.185.68])
        by smtp-intra-3.desy.de (DESY-INTRA-3) with ESMTP id 57B501029;
        Wed, 21 Nov 2018 12:26:05 +0100 (MET)
From:   Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
To:     trondmy@hammerspace.com, Anna.Schumaker@Netapp.com
Cc:     linux-nfs@vger.kernel.org,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Rick Macklem <rmacklem@uoguelph.ca>
Subject: [PATCH v2] flexfiles: use per-mirror specified stateid for IO
Date:   Wed, 21 Nov 2018 12:25:41 +0100
Message-Id: <20181121112541.14224-1-tigran.mkrtchyan@desy.de>
X-Mailer: git-send-email 2.17.2
In-Reply-To: <20dd91f5c12ce9312e5c955c3a94008c8315d478.camel@hammerspace.com>
References: <20dd91f5c12ce9312e5c955c3a94008c8315d478.camel@hammerspace.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.c    | 21 +++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  4 ++++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 19 +++++++++++++++++++
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 86bcba40ca61..74b36ed883ca 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1361,12 +1361,7 @@ static void ff_layout_read_prepare_v4(struct rpc_task *task, void *data)
 				task))
 		return;
 
-	if (ff_layout_read_prepare_common(task, hdr))
-		return;
-
-	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
-			hdr->args.lock_context, FMODE_READ) == -EIO)
-		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
+	ff_layout_read_prepare_common(task, hdr);
 }
 
 static void ff_layout_read_call_done(struct rpc_task *task, void *data)
@@ -1542,12 +1537,7 @@ static void ff_layout_write_prepare_v4(struct rpc_task *task, void *data)
 				task))
 		return;
 
-	if (ff_layout_write_prepare_common(task, hdr))
-		return;
-
-	if (nfs4_set_rw_stateid(&hdr->args.stateid, hdr->args.context,
-			hdr->args.lock_context, FMODE_WRITE) == -EIO)
-		rpc_exit(task, -EIO); /* lost lock, terminate I/O */
+	ff_layout_write_prepare_common(task, hdr);
 }
 
 static void ff_layout_write_call_done(struct rpc_task *task, void *data)
@@ -1742,6 +1732,10 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	fh = nfs4_ff_layout_select_ds_fh(lseg, idx);
 	if (fh)
 		hdr->args.fh = fh;
+
+	if (!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
+		goto out_failed;
+
 	/*
 	 * Note that if we ever decide to split across DSes,
 	 * then we may need to handle dense-like offsets.
@@ -1804,6 +1798,9 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (fh)
 		hdr->args.fh = fh;
 
+	if (!nfs4_ff_layout_select_ds_stateid(lseg, idx, &hdr->args.stateid))
+		goto out_failed;
+
 	/*
 	 * Note that if we ever decide to split across DSes,
 	 * then we may need to handle dense-like offsets.
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 411798346e48..de50a342d5a5 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -215,6 +215,10 @@ unsigned int ff_layout_fetch_ds_ioerr(struct pnfs_layout_hdr *lo,
 		unsigned int maxnum);
 struct nfs_fh *
 nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx);
+int
+nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
+				u32 mirror_idx,
+				nfs4_stateid *stateid);
 
 struct nfs4_pnfs_ds *
 nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg, u32 ds_idx,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 74d8d5352438..d23347389626 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -370,6 +370,25 @@ nfs4_ff_layout_select_ds_fh(struct pnfs_layout_segment *lseg, u32 mirror_idx)
 	return fh;
 }
 
+int
+nfs4_ff_layout_select_ds_stateid(struct pnfs_layout_segment *lseg,
+				u32 mirror_idx,
+				nfs4_stateid *stateid)
+{
+	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, mirror_idx);
+
+	if (!ff_layout_mirror_valid(lseg, mirror, false)) {
+		pr_err_ratelimited("NFS: %s: No data server for mirror offset index %d\n",
+			__func__, mirror_idx);
+		goto out;
+	}
+
+	nfs4_stateid_copy(stateid, &mirror->stateid);
+	return 1;
+out:
+	return 0;
+}
+
 /**
  * nfs4_ff_layout_prepare_ds - prepare a DS connection for an RPC call
  * @lseg: the layout segment we're operating on
-- 
2.17.2

