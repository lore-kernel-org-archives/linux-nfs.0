Return-Path: <SRS0=Psyw=RE=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 273BFC4360F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:08 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E8A472084F
	for <linux-nfs@archiver.kernel.org>; Fri,  1 Mar 2019 19:27:07 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="IcnxP9/Z"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1725905AbfCAT1H (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 1 Mar 2019 14:27:07 -0500
Received: from mail-yw1-f65.google.com ([209.85.161.65]:38428 "EHLO
        mail-yw1-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726042AbfCAT1G (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 1 Mar 2019 14:27:06 -0500
Received: by mail-yw1-f65.google.com with SMTP id o184so14923779ywo.5
        for <linux-nfs@vger.kernel.org>; Fri, 01 Mar 2019 11:27:06 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=YN3L/E7k+5YM5PC0HJXk+0h3eD43DsFTXy9tfol5FFY=;
        b=IcnxP9/ZiQfgdbrkpiT+ekKmznjLq9bdv7FeqntUDiObXUfhV3c177rnQn2+ZtZXl0
         nBFeWkf9Gr6lu0gJpYvD+JK4Juh157NjsOJn0k/F+qFRuB5hVmgBZKXz3kuNJP4GhzMJ
         an4rK+ev4qK+ZltozbCKC3A8V/vW+zjo2vu41h6Yv4qbC5JrYC9r0b9QQadKFTLc8QUl
         Gtrj/bTyyBrf6h4r21lLaKnSdYbIwe/Di0olx+MjFv3DzAG0VDltqf8FrSVafKUGG5uQ
         u4LTAkEKEooTq9OVukV1roWruY/8QyQ4GIfs1CmpWO9JzDJOs3t7V1yUA54pCLsFHtiM
         G9og==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=YN3L/E7k+5YM5PC0HJXk+0h3eD43DsFTXy9tfol5FFY=;
        b=t15uTslfCkB9FvgWWodGMrbsMMdLfYFB76IEpqFhV7Sy+MitvViI5VGM0xiuo8/Y87
         ulAFv+ve62nv44ORwiQOWTBiCCyYb1A/Xg5xMlJseXW4sQgM33/dAHoZhy+BZes3KdpT
         vclChkkVvJGtqdipkdMdTMCg/G/xgvFpgY+gvLu3QP/KKKwVF8AGwfVj9p2cpkkcWozV
         WGEZux5Kq/n9Q+T99rd+RBk4TUCJXDXk8kFqm8jaDWir9g0vKLueY7POy8z/o79/6yf2
         ixvDQWg7c1ZUdO0YA2YPTXrMwSsgglQF5WA0SAy2u0xvOH71mTbXsIsy7WAl3oTg7fjc
         T1Yg==
X-Gm-Message-State: APjAAAW3mKIX9guzY0xr5zRzJiOVS7eRMY2d2pBdDCQ84mS3hkpnm/df
        A//gqUySNRFgW9pPRsoqDE2bviQ=
X-Google-Smtp-Source: APXvYqyyoXSXtDQ2JN7GUbZ23kg26Anu7sCizJmxVrs9j3xehFJsaL05ovpqUooib9eg4JLULHc+bQ==
X-Received: by 2002:a81:c87:: with SMTP id 129mr4971341ywm.137.1551468425248;
        Fri, 01 Mar 2019 11:27:05 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l71sm7509193ywl.65.2019.03.01.11.27.04
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 01 Mar 2019 11:27:04 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 14/19] NFS/flexfiles: Simplify nfs4_ff_find_or_create_ds_client()
Date:   Fri,  1 Mar 2019 14:24:50 -0500
Message-Id: <20190301192455.104943-15-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190301192455.104943-14-trond.myklebust@hammerspace.com>
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
 fs/nfs/flexfilelayout/flexfilelayout.h    | 3 +--
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 ++-----
 3 files changed, 6 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 95afde994723..54e4a1dabf68 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -1778,7 +1778,7 @@ ff_layout_read_pagelist(struct nfs_pgio_header *hdr)
 	if (!ds)
 		goto out_failed;
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
 						   hdr->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
@@ -1843,7 +1843,7 @@ ff_layout_write_pagelist(struct nfs_pgio_header *hdr, int sync)
 	if (!ds)
 		goto out_failed;
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
 						   hdr->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_failed;
@@ -1928,7 +1928,7 @@ static int ff_layout_initiate_commit(struct nfs_commit_data *data, int how)
 	if (!ds)
 		goto out_err;
 
-	ds_clnt = nfs4_ff_find_or_create_ds_client(lseg, idx, ds->ds_clp,
+	ds_clnt = nfs4_ff_find_or_create_ds_client(mirror, ds->ds_clp,
 						   data->inode);
 	if (IS_ERR(ds_clnt))
 		goto out_err;
diff --git a/fs/nfs/flexfilelayout/flexfilelayout.h b/fs/nfs/flexfilelayout/flexfilelayout.h
index 935cba942834..2bda4baa655a 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.h
+++ b/fs/nfs/flexfilelayout/flexfilelayout.h
@@ -215,8 +215,7 @@ nfs4_ff_layout_prepare_ds(struct pnfs_layout_segment *lseg,
 			  bool fail_return);
 
 struct rpc_clnt *
-nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg,
-				 u32 ds_idx,
+nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
 				 struct nfs_client *ds_clp,
 				 struct inode *inode);
 const struct cred *ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg,
diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index 631976f2bd8e..0651fd1e52c3 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -465,8 +465,7 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
 
 /**
  * nfs4_ff_find_or_create_ds_client - Find or create a DS rpc client
- * @lseg: pointer to layout segment
- * @ds_idx: mirror index
+ * @mirror: pointer to the mirror
  * @ds_clp: nfs_client for the DS
  * @inode: pointer to inode
  *
@@ -474,11 +473,9 @@ ff_layout_get_ds_cred(struct pnfs_layout_segment *lseg, u32 ds_idx,
  * in the nfs_client cl_ds_clients list.
  */
 struct rpc_clnt *
-nfs4_ff_find_or_create_ds_client(struct pnfs_layout_segment *lseg, u32 ds_idx,
+nfs4_ff_find_or_create_ds_client(struct nfs4_ff_layout_mirror *mirror,
 				 struct nfs_client *ds_clp, struct inode *inode)
 {
-	struct nfs4_ff_layout_mirror *mirror = FF_LAYOUT_COMP(lseg, ds_idx);
-
 	switch (mirror->mirror_ds->ds_versions[0].version) {
 	case 3:
 		/* For NFSv3 DS, flavor is set when creating DS connections */
-- 
2.20.1

