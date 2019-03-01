Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 98628C4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:06 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 598A92084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:06 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="eiFgwA3B"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726060AbfCAT1F (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:05 -0500
Received: from mail-yw1-f52.google.com ([209.85.161.52]:38209 "EHLO
        mail-yw1-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbfCAT1F (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:05 -0500
Received: by mail-yw1-f52.google.com with SMTP id o184so14923708ywo.5
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:04 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=lPqR62dyufqTiPT/jgz/UvuDnZtMhQ54p2fSnxv6jKs=;
        b=eiFgwA3B6EiOrtdtV6K/ZGSOi5LxTNYIKhbb/T7A0fLaAdV0n3YMGlWWkx8CnkOnRN
         QY/AULSZbdCGsGqCqYz4ZDiTHVPBdCF2lXGfEU4+alrVEpEAcOpWZwKXJfwrDrUZP8oJ
         xzfgoTj4zKFYnjoD8TExjhpdGhHLF/qqw6hGZiYaJNrDxczXiKJrQHwMzwZdJ8NM2BMK
         UXkS6YG3AmXwYJ/Y+lXErO+aOfMLQuBH2FHWGytAOu7L6tbyTC42tQ/Qc1paRl46/fXq
         zFda9+ecT6QNQwZ+CTeMB0T6QgxKitVN2LWRS9IIUksxJoFRyDnqaUPtctq8wvo38CQR
         HgIQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=lPqR62dyufqTiPT/jgz/UvuDnZtMhQ54p2fSnxv6jKs=;
        b=JzBxJtCfvN3c/5+nnvKuRu3+R4yuJ3t7yZ7b3gejeZaZ0i3a4JiC4qhV27KhcifYDC
         hBEW5Im1ziVK3tatrN5s1tWrU63KfNPNrHqOVtOOU8f+we6wRKDTk/IxLdOLBwYN7M7Z
         pSHD6eTAaFaVnhdM1eDLOS5ZtheL/+Mrzem95DYv3w61KDcgBtoo2RPo7vQ5HSeAjx9K
         oEf106IeyAbLJ1MvF3lIrNsU8kc2xh0K+dkESyZj3f5FS5A/AApHu5A2RYayJ/GECgOm
         R/lOFSc2Ipj7+c/YSVnwkHlQ11YaQ1nRfJXTB7+8zLKeHwywcGeuJDZ9Dh5b0DXdlNhe
         tjvQ==
X-Gm-Message-State: APjAAAV2ULdZqhGPZEzz3oW5j3x14aWBnaqhZN11Y7O5ipFI9OQa7V37
        YFVf3oRiCxPONWH2z5JTHb8GWTo=
X-Google-Smtp-Source: APXvYqx87LwooGbcRbXFXi+EUC+adKaBN5+fbJfDfOhWO7PiwEkPCtfpxUoWojhH4buMc/NkskEzVA==
X-Received: by 2002:a81:3c14:: with SMTP id j20mr4770526ywa.324.1551468423622;
        Fri, 01 Mar 2019 11:27:03 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.02
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:03 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 12/19] NFS/flexfiles: Speed up read failover when DSes are down
Date:   Fri,  1 Mar 2019 14:24:48 -0500
Message-Id: <20190301192455.104943-13-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-12-trond.myklebust@hammerspace.com>
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
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If we notice that a DS may be down, we should attempt to read from the
other mirrors first before we go back to retry the dead DS.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 74 +++++++++++++++++++++-----
 fs/nfs/pnfs.h                          |  1 +
 fs/nfs/pnfs_dev.c                      | 10 ++++
 3 files changed, 73 insertions(+), 12 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index c4a9f7f2f0e4..ba5ed07eac92 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -788,10 +788,28 @@ ff_layout_alloc_commit_info(struct pnfs_layout_segment *lseg,
 	}
 }
 
+static void
+ff_layout_mark_ds_unreachable(struct pnfs_layout_segment *lseg, int idx)
+{
+	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
+
+	if (devid)
+		nfs4_mark_deviceid_unavailable(devid);
+}
+
+static void
+ff_layout_mark_ds_reachable(struct pnfs_layout_segment *lseg, int idx)
+{
+	struct nfs4_deviceid_node *devid = FF_LAYOUT_DEVID_NODE(lseg, idx);
+
+	if (devid)
+		nfs4_mark_deviceid_available(devid);
+}
+
 static struct nfs4_pnfs_ds *
-ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
-				  int start_idx,
-				  int *best_idx)
+ff_layout_choose_ds_for_read(struct pnfs_layout_segment *lseg,
+			     int start_idx, int *best_idx,
+			     bool check_device)
 {
 	struct nfs4_ff_layout_segment *fls = FF_LAYOUT_LSEG(lseg);
 	struct nfs4_ff_layout_mirror *mirror;
@@ -799,25 +817,53 @@ ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
 	bool fail_return = false;
 	int idx;
 
-	/* mirrors are sorted by efficiency */
+	/* mirrors are initially sorted by efficiency */
 	for (idx = start_idx; idx < fls->mirror_array_cnt; idx++) {
 		if (idx+1 == fls->mirror_array_cnt)
-			fail_return = true;
+			fail_return = !check_device;
 
 		mirror = FF_LAYOUT_COMP(lseg, idx);
-		if (ff_layout_test_devid_unavailable(&mirror->mirror_ds->id_node))
+		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, fail_return);
+		if (!ds)
 			continue;
 
-		ds = nfs4_ff_layout_prepare_ds(lseg, mirror, fail_return);
-		if (ds) {
-			*best_idx = idx;
-			return ds;
-		}
+		if (check_device &&
+		    nfs4_test_deviceid_unavailable(&mirror->mirror_ds->id_node))
+			continue;
+
+		*best_idx = idx;
+		return ds;
 	}
 
 	return NULL;
 }
 
+static struct nfs4_pnfs_ds *
+ff_layout_choose_any_ds_for_read(struct pnfs_layout_segment *lseg,
+				 int start_idx, int *best_idx)
+{
+	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx, false);
+}
+
+static struct nfs4_pnfs_ds *
+ff_layout_choose_valid_ds_for_read(struct pnfs_layout_segment *lseg,
+				   int start_idx, int *best_idx)
+{
+	return ff_layout_choose_ds_for_read(lseg, start_idx, best_idx, true);
+}
+
+static struct nfs4_pnfs_ds *
+ff_layout_choose_best_ds_for_read(struct pnfs_layout_segment *lseg,
+				  int start_idx, int *best_idx)
+{
+	struct nfs4_pnfs_ds *ds;
+
+	ds = ff_layout_choose_valid_ds_for_read(lseg, start_idx, best_idx);
+	if (ds)
+		return ds;
+	return ff_layout_choose_any_ds_for_read(lseg, start_idx, best_idx);
+}
+
 static void
 ff_layout_pg_get_read(struct nfs_pageio_descriptor *pgio,
 		      struct nfs_page *req,
@@ -1167,8 +1213,10 @@ static int ff_layout_async_handle_error(struct rpc_task *task,
 {
 	int vers = clp->cl_nfs_mod->rpc_vers->number;
 
-	if (task->tk_status >= 0)
+	if (task->tk_status >= 0) {
+		ff_layout_mark_ds_reachable(lseg, idx);
 		return 0;
+	}
 
 	/* Handle the case of an invalid layout segment */
 	if (!pnfs_is_valid_lseg(lseg))
@@ -1231,6 +1279,8 @@ static void ff_layout_io_track_ds_error(struct pnfs_layout_segment *lseg,
 	err = ff_layout_track_ds_error(FF_LAYOUT_FROM_HDR(lseg->pls_layout),
 				       mirror, offset, length, status, opnum,
 				       GFP_NOIO);
+	if (status == NFS4ERR_NXIO)
+		ff_layout_mark_ds_unreachable(lseg, idx);
 	pnfs_error_mark_layout_for_return(lseg->pls_layout->plh_inode, lseg);
 	dprintk("%s: err %d op %d status %u\n", __func__, err, opnum, status);
 }
diff --git a/fs/nfs/pnfs.h b/fs/nfs/pnfs.h
index 56659ccce1d8..c0420b979d88 100644
--- a/fs/nfs/pnfs.h
+++ b/fs/nfs/pnfs.h
@@ -350,6 +350,7 @@ void nfs4_delete_deviceid(const struct pnfs_layoutdriver_type *, const struct nf
 void nfs4_init_deviceid_node(struct nfs4_deviceid_node *, struct nfs_server *,
 			     const struct nfs4_deviceid *);
 bool nfs4_put_deviceid_node(struct nfs4_deviceid_node *);
+void nfs4_mark_deviceid_available(struct nfs4_deviceid_node *node);
 void nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node);
 bool nfs4_test_deviceid_unavailable(struct nfs4_deviceid_node *node);
 void nfs4_deviceid_purge_client(const struct nfs_client *);
diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
index ec6b607ff1d7..537b80d693f1 100644
--- a/fs/nfs/pnfs_dev.c
+++ b/fs/nfs/pnfs_dev.c
@@ -283,6 +283,16 @@ nfs4_put_deviceid_node(struct nfs4_deviceid_node *d)
 }
 EXPORT_SYMBOL_GPL(nfs4_put_deviceid_node);
 
+void
+nfs4_mark_deviceid_available(struct nfs4_deviceid_node *node)
+{
+	if (test_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags)) {
+		clear_bit(NFS_DEVICEID_UNAVAILABLE, &node->flags);
+		smp_mb__after_atomic();
+	}
+}
+EXPORT_SYMBOL_GPL(nfs4_mark_deviceid_available);
+
 void
 nfs4_mark_deviceid_unavailable(struct nfs4_deviceid_node *node)
 {
-- 
2.20.1

