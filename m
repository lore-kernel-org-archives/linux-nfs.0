Return-Path: <SRS0=NEh4=OI=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-10.6 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0C323C43441
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:00:36 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C044E2133F
	for <linux-nfs@archiver.kernel.org>; Thu, 29 Nov 2018 06:00:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (1024-bit key) header.d=kernel.org header.i=@kernel.org header.b="hvn6e7Kw"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C044E2133F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=kernel.org
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729155AbeK2REp (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 29 Nov 2018 12:04:45 -0500
Received: from mail.kernel.org ([198.145.29.99]:39530 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728072AbeK2REo (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 29 Nov 2018 12:04:44 -0500
Received: from sasha-vm.mshome.net (unknown [37.142.5.207])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id E895421019;
        Thu, 29 Nov 2018 06:00:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1543471233;
        bh=c/ChE8yBtEBDkCxyt7xjnK8SV6zhay9ljoeMMWtQV7U=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=hvn6e7KwZj/X0eNBHPr85+NLD565FNRHiymp23PQ56uZj8eSdHWfYNwMJRPmx15Qq
         bLJzmh+QbKO9v6WIenepIFf9Ag/TvxVQABtn4cZD40FlLGOitPBDaPTGWK+PoABuGb
         l2s6z1zey/Vwerp4dnshqCqJKxiKbs4NN5Vxsu8Y=
From:   Sasha Levin <sashal@kernel.org>
To:     stable@vger.kernel.org, linux-kernel@vger.kernel.org
Cc:     Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        Rick Macklem <rmacklem@uoguelph.ca>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 4.19 58/68] flexfiles: use per-mirror specified stateid for IO
Date:   Thu, 29 Nov 2018 00:55:49 -0500
Message-Id: <20181129055559.159228-58-sashal@kernel.org>
X-Mailer: git-send-email 2.17.1
In-Reply-To: <20181129055559.159228-1-sashal@kernel.org>
References: <20181129055559.159228-1-sashal@kernel.org>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>

[ Upstream commit bb21ce0ad227b69ec0f83279297ee44232105d96 ]

rfc8435 says:

  For tight coupling, ffds_stateid provides the stateid to be used by
  the client to access the file.

However current implementation replaces per-mirror provided stateid with
by open or lock stateid.

Ensure that per-mirror stateid is used by ff_layout_write_prepare_v4 and
nfs4_ff_layout_prepare_ds.

Signed-off-by: Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>
Signed-off-by: Rick Macklem <rmacklem@uoguelph.ca>
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/flexfilelayout/flexfilelayout.c    | 21 +++++++++------------
 fs/nfs/flexfilelayout/flexfilelayout.h    |  4 ++++
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 19 +++++++++++++++++++
 3 files changed, 32 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index cae43333ef16..86ac2c5b93fe 100644
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
index 59aa04976331..a8df2f496898 100644
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
2.17.1

