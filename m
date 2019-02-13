Return-Path: <SRS0=saDi=QU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2723BC4360F
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 21:55:09 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id E0C6621872
	for <linux-nfs@archiver.kernel.org>; Wed, 13 Feb 2019 21:55:08 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="kvogw94U"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S2388687AbfBMVzI (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Wed, 13 Feb 2019 16:55:08 -0500
Received: from mail-it1-f194.google.com ([209.85.166.194]:39641 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S2392266AbfBMVzI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 13 Feb 2019 16:55:08 -0500
Received: by mail-it1-f194.google.com with SMTP id p4so7651484itc.4
        for <linux-nfs@vger.kernel.org>; Wed, 13 Feb 2019 13:55:07 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=isP+0Pou2hKfs7cLQ0JCQj28Ybr/PWCUNJ5cuZNSLMo=;
        b=kvogw94ULqOA/69mWV316xal2LNaRD6CQwFY3UkLqsTytrX1zawKjWf+FfIN8Q939a
         D7fGTR7hatU8jIebEWAKk0yXDMLV13KiqBxnjXSQowiXOrYsvS1cHnruoO5XPOOIEIBC
         9PN/sQ2/Nezdq8rwJdKHP7kXW46SL0yyYLQZZjSNBZkj+8tf43rrvciX6YCUtWwtBVLh
         a/uCVOZlpchAOdlO14GUQMHKcwO47vtO7pFiLY7OfiWOac8uQn2AZ3xwRhqIUqfcM3y9
         UnG3eXXTP+n+LrU2FEcoPcOeDrxm5uSTexuMRJUjxdt2PwKHKSZcL3r9BdcVkvYK02O+
         vuaQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=isP+0Pou2hKfs7cLQ0JCQj28Ybr/PWCUNJ5cuZNSLMo=;
        b=eJ502T4pFl6spTSuWlI3oj2hSmTw8QZ3ugk4+FOrw6/yhAq2B93b3CSRmZM7AxJoxc
         mMUz/+ogpjxyDeEDVzHv1NqpdL+AQLKzqZJ59p91rRye4lKEThUhzQcGWMGgcjcAIV3p
         fwXZ1UYO7H7Mz+kwhoQ0g085IDo999GYUEUqUsY+dTTr4hDtmAuaF2vl/bEGD4kr7XaI
         DrAr5KiHBFHutL6Ha4Q6iY5SEDIF2jkLzzeTpIzAPun3fY+Cs66g8FMjjdiLIKdM8xJF
         Qf3/g5tT26VOZcozCRlQXd9Jdxn39fk0We/T0yQ0Z0y8KOVHNH6o7OE1HQ9JwtIGtzyP
         ZMSQ==
X-Gm-Message-State: AHQUAuaT57lnnZ/Gn4Cuij5rHFMjj4qknpRA2JkeTAezr6VRdzk7rrxB
        wsDa0eg8VeW2Fcjq4JoozzZGIM8=
X-Google-Smtp-Source: AHgI3IbF0veg8ZMPuxYUxLvUxdr2D8s4xvaBK4iNz6w5Yo7jAdvb/9NGIZjoeabQrgmT1gwYgSSbqQ==
X-Received: by 2002:a24:3595:: with SMTP id k143mr195585ita.37.1550094906570;
        Wed, 13 Feb 2019 13:55:06 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id y184sm322113ity.27.2019.02.13.13.55.05
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 13:55:06 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <anna.schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 2/2] NFS: Pass error information to the pgio error cleanup routine
Date:   Wed, 13 Feb 2019 16:53:57 -0500
Message-Id: <20190213215357.19696-2-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
References: <20190213215357.19696-1-trond.myklebust@hammerspace.com>
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
index 40b90f187eeb..9e512c0ab544 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -996,7 +996,7 @@ nfs_pageio_cleanup_request(struct nfs_pageio_descriptor *desc,
 
 	nfs_list_remove_request(req);
 	nfs_list_add_request(req, &head);
-	desc->pg_completion_ops->error_cleanup(&head);
+	desc->pg_completion_ops->error_cleanup(&head, desc->pg_error);
 }
 
 /**
@@ -1132,7 +1132,8 @@ static void nfs_pageio_error_cleanup(struct nfs_pageio_descriptor *desc)
 
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

