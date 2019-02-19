Return-Path: <SRS0=cCtV=Q2=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.9 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 47A11C43381
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:20 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 1A7832147A
	for <linux-nfs@archiver.kernel.org>; Tue, 19 Feb 2019 13:55:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="rVPIr01P"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728589AbfBSNzT (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 19 Feb 2019 08:55:19 -0500
Received: from mail-it1-f195.google.com ([209.85.166.195]:54316 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725767AbfBSNzT (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 19 Feb 2019 08:55:19 -0500
Received: by mail-it1-f195.google.com with SMTP id f10so6112460ita.4
        for <linux-nfs@vger.kernel.org>; Tue, 19 Feb 2019 05:55:18 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=KvAVOpySW+nJNSDgsb4o9kSovq91vPpOtg04Xafg4Jg=;
        b=rVPIr01P1ND8LWrP1wJ9MFsv/jOZzduEJfuZJwRCp8qcL1YnEwobgdlTCTX/ZVhd4c
         0KPF6jnEGSgBFQ+tEeBpxY3k/H3PusImxdSP+8bR6BXQ+HG+cuHq1GL3SNxZ5AVLsUJd
         T/tDVWJWy/qjZGyz/hGdk/5G4beUYz3bkppV16XZKEg+lfNqEbEN3E+nckr9KSrmigWc
         pzqWbP+4BKRi/b+zIUlAUCkVkIvsQzE6QvY75dg04BDrBiqmOKj0PkHvSaP4Gid1ltD1
         HuBkXlWx4FbA+t8+vvxu/e/MsXlwHk6FP5a78NQb4ak1i25q+86AJxXusHLKNt9Lp+H3
         If3g==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=KvAVOpySW+nJNSDgsb4o9kSovq91vPpOtg04Xafg4Jg=;
        b=UATjs43q3fM/BiNdcs0APnnBXquV9nZQpE/itFbto0cv279FA+YJ3CUyrRYuetWM8f
         eraz9x3sagqjgEVMP7LTSCvBHL5RaU5URwbAwQNGfE+v0EhJiTJrd3HeaHitMiEuNz/+
         k1QYZPtZb5gV/ZCI1smXhh+27a84q8Iw1NETWWBuc39zzbfDBhT8A8CuAWxO5W3uRJCR
         Xxr4ygXPzShm39/TdQhawaT4FmU38mF+ItSN9cV6aF1tF9GLhv7Iuug7eNgVt9oLbwbM
         J0sEg4wQFmek/6yF8XVUK3dCxx+ASXf3UY8iDqxENzxBIR9SCxSeQzptI000PPlA1V5f
         neag==
X-Gm-Message-State: AHQUAubyaqTQYhzpl7oRpw5EQVvURfMYqS2EvDHIJPqQaN/COEmZ5o8/
        0jlylSTPY4tb3PwS3nk1XrCfvWo=
X-Google-Smtp-Source: AHgI3IYXYA3T54gtl40qyIKLuJHWR+L+B4lF0x0MY22erIIC+5SOkqd2zyplTzaD4NFrN0TEPTab/Q==
X-Received: by 2002:a5e:a607:: with SMTP id q7mr16757708ioi.15.1550584517725;
        Tue, 19 Feb 2019 05:55:17 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id c133sm1196313itc.24.2019.02.19.05.55.16
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 05:55:17 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 4/8] NFS: Clean up list moves of struct nfs_page
Date:   Tue, 19 Feb 2019 08:53:07 -0500
Message-Id: <20190219135311.119300-5-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190219135311.119300-4-trond.myklebust@hammerspace.com>
References: <20190219135311.119300-1-trond.myklebust@hammerspace.com>
 <20190219135311.119300-2-trond.myklebust@hammerspace.com>
 <20190219135311.119300-3-trond.myklebust@hammerspace.com>
 <20190219135311.119300-4-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

In several places we're just moving the struct nfs_page from one list to
another by first removing from the existing list, then adding to the new
one.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/direct.c          |  3 +--
 fs/nfs/pagelist.c        | 12 ++++--------
 include/linux/nfs_page.h | 10 ++++++++++
 3 files changed, 15 insertions(+), 10 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 33824a0a57bf..1377ee20ecf9 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -664,8 +664,7 @@ static void nfs_direct_write_reschedule(struct nfs_direct_req *dreq)
 
 	list_for_each_entry_safe(req, tmp, &reqs, wb_list) {
 		if (!nfs_pageio_add_request(&desc, req)) {
-			nfs_list_remove_request(req);
-			nfs_list_add_request(req, &failed);
+			nfs_list_move_request(req, &failed);
 			spin_lock(&cinfo.inode->i_lock);
 			dreq->flags = 0;
 			if (desc.pg_error < 0)
diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index a8951f1f7b4e..9cbfdb979992 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -768,8 +768,7 @@ int nfs_generic_pgio(struct nfs_pageio_descriptor *desc,
 	pageused = 0;
 	while (!list_empty(head)) {
 		req = nfs_list_entry(head->next);
-		nfs_list_remove_request(req);
-		nfs_list_add_request(req, &hdr->pages);
+		nfs_list_move_request(req, &hdr->pages);
 
 		if (!last_page || last_page != req->wb_page) {
 			pageused++;
@@ -961,8 +960,7 @@ static int nfs_pageio_do_add_request(struct nfs_pageio_descriptor *desc,
 	}
 	if (!nfs_can_coalesce_requests(prev, req, desc))
 		return 0;
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &mirror->pg_list);
+	nfs_list_move_request(req, &mirror->pg_list);
 	mirror->pg_count += req->wb_bytes;
 	return 1;
 }
@@ -994,8 +992,7 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 {
 	LIST_HEAD(head);
 
-	nfs_list_remove_request(req);
-	nfs_list_add_request(req, &head);
+	nfs_list_move_request(req, &head);
 	desc->pg_completion_ops->error_cleanup(&head);
 }
 
@@ -1237,9 +1234,8 @@ int nfs_pageio_resend(struct nfs_pageio_descriptor *desc,
 	while (!list_empty(&hdr->pages)) {
 		struct nfs_page *req = nfs_list_entry(hdr->pages.next);
 
-		nfs_list_remove_request(req);
 		if (!nfs_pageio_add_request(desc, req))
-			nfs_list_add_request(req, &failed);
+			nfs_list_move_request(req, &failed);
 	}
 	nfs_pageio_complete(desc);
 	if (!list_empty(&failed)) {
diff --git a/include/linux/nfs_page.h b/include/linux/nfs_page.h
index e27572d30d97..ad69430fd0eb 100644
--- a/include/linux/nfs_page.h
+++ b/include/linux/nfs_page.h
@@ -164,6 +164,16 @@ nfs_list_add_request(struct nfs_page *req, struct list_head *head)
 	list_add_tail(&req->wb_list, head);
 }
 
+/**
+ * nfs_list_move_request - Move a request to a new list
+ * @req: request
+ * @head: head of list into which to insert the request.
+ */
+static inline void
+nfs_list_move_request(struct nfs_page *req, struct list_head *head)
+{
+	list_move_tail(&req->wb_list, head);
+}
 
 /**
  * nfs_list_remove_request - Remove a request from its wb_list
-- 
2.20.1

