Return-Path: <SRS0=Mjai=QW=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2307BC4360F
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 00:00:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E424D2070C
	for <linux-nfs@archiver.kernel.org>; Fri, 15 Feb 2019 00:00:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="OkwtJ1Nh"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729121AbfBOAAT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 14 Feb 2019 19:00:19 -0500
Received: from mail-it1-f196.google.com ([209.85.166.196]:39272 "EHLO
        mail-it1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727348AbfBOAAS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2019 19:00:18 -0500
Received: by mail-it1-f196.google.com with SMTP id l15so6330360iti.4
        for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2019 16:00:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=rJZ5u1ChTs+i9no7garSIJS4ZB9wjTiiXnLrKYSr/eQ=;
        b=OkwtJ1Nh33mzXuXm5Vn9QpDmu3DvQ2GK8eXSD6oi+hrsVFYr2M4qg7pMdmBdY3zQra
         KkGQH0QymwzG6KTgrV4Mb8q9v9DUroPj/ynkcyfR8R8qrPMT8Scslmh8+W8GBBj0E6hg
         tmDxpqlCAFERxNSqircXhrDjroOomCW7OJ5wi4QNi291XBCeyplbMT19yc2FJS4vN3+n
         FUV+UYazM1mlXpBRB6OPdj4g/W/9IWc8znS5IUougeSJufiQ5SAzAAn4zFm8ZY+zEmXO
         h/ECqfoPHevEBideHyGDoKG5UUuud8JnRrmpMiJXpCShcdKLNybPlLniPAXQ2BeGJx7u
         KYtg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=rJZ5u1ChTs+i9no7garSIJS4ZB9wjTiiXnLrKYSr/eQ=;
        b=linKgSesbw+WWHQO+FbJ6vIh4egh4BP8TXsuFnAuGTyJRn6PEsP1C7CxBafCFzS2Zq
         X7mznv5+Vy67uReiW+ZYEdMCh5kuaVASiLneH++ypqWlcP10Vd0LYiplRQxstuMAlNQf
         4SebCpR42TDwVuEio4LB7yfO9f0LSZv9jlVrlGS/apWb0LtMyxbEihbrllPlBT8rqniU
         szqGVvx1OejAm1mQqfKdKj/wmUprvo+V0rh19TEL3bnn4ViUW06PxW06uTED4MyrcIEp
         Vwz0wZEWAVHazdrOTN1Br3j5DPqm/8mVtcCQQR/M/w71O7sjLmcQyGQr+TYoP0BM72DQ
         8U6Q==
X-Gm-Message-State: AHQUAualzU+BsdoqzCG8w4CyZcU+yo7Kd45YXHThoXUGphcHaGrWSYVh
        Hp+2jenBXQjaw17t4TyBxXW78CM=
X-Google-Smtp-Source: AHgI3IaBpOSw7VAq+Lhu6xdlXdQw7U5Ieb2izxMGUstezxdrPx3IU8tQWWQrwo3C3nFUfsh3C+spPA==
X-Received: by 2002:a24:19d5:: with SMTP id b204mr3390671itb.6.1550188817402;
        Thu, 14 Feb 2019 16:00:17 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id l186sm1862840itl.22.2019.02.14.16.00.16
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 14 Feb 2019 16:00:16 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 2/2] NFS: Pass error information to the pgio error cleanup routine
Date:   Thu, 14 Feb 2019 18:59:07 -0500
Message-Id: <20190214235907.85519-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190214235907.85519-1-trond.myklebust@hammerspace.com>
References: <20190214235907.85519-1-trond.myklebust@hammerspace.com>
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
index 33824a0a57bf..aa24a2e10dd7 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -428,7 +428,7 @@ static void nfs_direct_read_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_read_sync_pgio_error(struct list_head *head)
+static void nfs_read_sync_pgio_error(struct list_head *head, int error)
 {
 	struct nfs_page *req;
 
@@ -821,7 +821,7 @@ static void nfs_direct_write_completion(struct nfs_pgio_header *hdr)
 	hdr->release(hdr);
 }
 
-static void nfs_write_sync_pgio_error(struct list_head *head)
+static void nfs_write_sync_pgio_error(struct list_head *head, int error)
 {
 	struct nfs_page *req;
 
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 301880a3ad8e..2d973b70d96a 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -996,7 +996,7 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &head);
-	desc->pg_completion_ops->error_cleanup(&head);
+	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error);
 }
 
 /**
@@ -1133,7 +1133,8 @@ static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
 
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
index f12cb31a41e5..480ccad94b9a 100644
--- a/fs/nfs/write.c
+++ b/fs/nfs/write.c
@@ -1411,20 +1411,27 @@ static void nfs_redirty_request(struct nfs_page *req)
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
index c39a29ab0dfd..9b8324ec08f3 100644
--- a/include/linux/nfs_xdr.h
+++ b/include/linux/nfs_xdr.h
@@ -1584,7 +1584,7 @@ struct nfs_commit_data {
 };
 
 struct nfs_pgio_completion_ops {
-	void	(*error_cleanup)(struct list_head *head);
+	void	(*error_cleanup)(struct list_head *head, int);
 	void	(*init_hdr)(struct nfs_pgio_header *hdr);
 	void	(*completion)(struct nfs_pgio_header *hdr);
 	void	(*reschedule_io)(struct nfs_pgio_header *hdr);
-- 
2.20.1

