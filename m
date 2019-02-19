Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5688DC10F00
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:21 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 2494C2147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:21 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o4ULJbGK"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728627AbfBSNzU (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:20 -0500
Received: from mail-it1-f193.google.com ([209.85.166.193]:55893 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727529AbfBSNzU (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:20 -0500
Received: by mail-it1-f193.google.com with SMTP id z131so6106332itf.5
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:19 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=W/j2mn2PX0yxrHNZqs1uBfz+H/pswwQ3cFDZuA3XLOk=;
        b=o4ULJbGKVUHYbLOV+ph8Fwvdzgc6ikcWfUur5fYSV9iu7zgsIenAR3h/vuF/EYDSdT
         Smlfu8OsvR28OZxQMIWRDbqqPGJEv42KxLWoVaQDc/t8+kwza+CaYXrTRck1cQnGFCUA
         jtHPQ76tRCp05BQyhZwuqfSMNw8Di9bGTGOl8pNeV//8BC8xdg8vLt/DrOQ2/rZYt0UK
         RpMVaAvISAUcf0DyGDj4albN94cnNz5yzFV2vECh2vPqH90dCsc2Gc+L+cW3romhX/WH
         b2DRjJRD37WRuvGHJFu62HIL6Va0/C4VqHMWHrOdQUWeCZRrN10JRovRIQgQgshF7xDy
         Gn6g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=W/j2mn2PX0yxrHNZqs1uBfz+H/pswwQ3cFDZuA3XLOk=;
        b=hdmdFNkjpAkK6C0c+Vpz7vOjUamaykb7BU05PFgtRwrW69+ka3PXv2k1SdFW8uPoAr
         SJ5SY2XiLyB+f9BvQ0KBCyAODpFC2qESlMUnm0Yq9U3jqe5/ytmIIwtycGqbI65/0y3x
         aic6UX23LKDveeg+PbY6hZFfFvJh0bXfsTe2/r/dlijSNmD5TDTIEjpM/cFefR6ff+/n
         zhsoVxBDIDVXyxDM3L1WI+ROBHFYE7XALipofcdOIPkfRg1yShiHy+MV2y1TU7IrEz1m
         lNJ8PzFIjNkaN1naYR31uGCZ3zcOHwPFG1gQkUuO0OMVivGPZdSFwrjNkX1b5YMBs5bR
         tIXQ==
X-Gm-Message-State: AHQUAuahqFwofJNzkuzrWTsV0Gk3fxwiMx5JLf1VsfYz+VG8K4ioPRi1
        pZ0EH0Ren982utQLxOehy5WLFPk=
X-Google-Smtp-Source: AHgI3IbCp+yekUry+QcWjoAh/bc8WBRhxpOnPBc4Si2EjFjNGXhXM0uWK/+/5xnp5za0l0DYCx4crQ==
X-Received: by 2002:a02:e8a:: with SMTP id 132mr772183jae.75.1550584518522;
        Tue, 19 Feb 2019 05:55:18 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.17
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:17 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 5/8] NFS: Pass error information to the pgio error cleanup routine
Date:   Tue, 19 Feb 2019 08:53:08 -0500
Message-Id: <20190219135311.119300-6-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-5-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
 <20190219135311.119300-4-trond.myklebust@hammerspace.com>
 <20190219135311.119300-5-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Allow the caller to pass error information when cleaning up a failed
I/O request so that we can conditionally take action to cancel the
request altogether if the error turned out to be fatal.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/direct.c         |  4 ++--
 fs/nfs/pagelist.c       |  5 +++--
 fs/nfs/read.c           |  2 +-
 fs/nfs/write.c          | 11 +++++++++--
 include/linux/nfs_xdr.h |  2 +-
 5 files changed, 16 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 1377ee20ecf9..0fd811ac08b5 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -428,7 +428,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_read_sync_pgio_error(struct list_head *head)
+static void nfs_read_sync_pgio_error(struct list_head *head, int error)
 {
 	struct nfs_page *req;
 
@@ -820,7 +820,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_write_sync_pgio_error(struct list_head *head)
+static void nfs_write_sync_pgio_error(struct list_head *head, int error)
 {
 	struct nfs_page *req;
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 9cbfdb979992..695afb7de3a7 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -993,7 +993,7 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 	LIST_HEAD(head);
 
 	nfs_list_move_request(req, &head);
-	desc->pg_completion_ops->error_cleanup(&head);
+	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error);
 }
 
 /**
@@ -1129,7 +1129,8 @@ static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
 
 	for (midx = 0; midx < desc->pg_mirror_count; midx++) {
 		mirror = &desc->pg_mirrors[midx];
-		desc->pg_completion_ops->error_cleanup(&mirror->pg_list);
+		desc->pg_completion_ops->error_cleanup(&mirror->pg_list,
+				desc->pg_error);
 	}
 }
 
diff --git a/fs/nfs/read.c b/fs/nfs/read.c
index f9f19784db82..1d95a60b2586 100644
--- a/fs/nfs/read.c
+++ b/fs/nfs/read.c
@@ -205,7 +205,7 @@ static void nfs_initiate_read(struct nfs_pgio_header *hdr,
 }
 
 static void
-nfs_async_read_error(struct list_head *head)
+nfs_async_read_error(struct list_head *head, int error)
 {
 	struct nfs_page	*req;
 
diff --git a/fs/nfs/write.c b/fs/nfs/write.c
index d09c9f878141..11df9f03245f 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1412,20 +1412,27 @@ static void nfs_redirty_request(struct nfs_page *req)
 	nfs_release_request(req);
 }
 
-static void nfs_async_write_error(struct list_head *head)
+static void nfs_async_write_error(struct list_head *head, int error)
 {
 	struct nfs_page	*req;
 
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
 		nfs_list_remove_request(req);
+		if (nfs_error_is_fatal(error)) {
+			nfs_context_set_write_error(req->wb_context, error);
+			if (nfs_error_is_fatal_on_server(error)) {
+				nfs_write_error_remove_page(req);
+				continue;
+			}
+		}
 		nfs_redirty_request(req);
 	}
 }
 
 static void nfs_async_write_reschedule_io(struct nfs_pgio_header *hdr)
 {
-	nfs_async_write_error(&hdr->pages);
+	nfs_async_write_error(&hdr->pages, 0);
 	filemap_fdatawrite_range(hdr->inode->i_mapping, hdr->args.offset,
 			hdr->args.offset + hdr->args.count - 1);
 }
diff --git a/include/linux/nfs_xdr.h b/include/linux/nfs_xdr.h
index 441a93ebcac0..b4bd2bf5f585 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1549,7 +1549,7 @@ struct nfs_commit_data {
 };
 
 struct nfs_pgio_completion_ops {
-	void	(*error_cleanup)(struct list_head *head);
+	void	(*error_cleanup)(struct list_head *head, int);
 	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
 	void	(*reschedule_io)(struct nfs_pgio_header *hdr);
-- 
2.20.1

