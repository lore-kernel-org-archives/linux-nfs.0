Return-Path: <SRS0=umLH=R7=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08B05C43381
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id CE4DD21850
	for <linux-nfs@archiver.kernel.org>; Thu, 28 Mar 2019 20:56:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="cghYCZzJ"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727563AbfC1U41 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 28 Mar 2019 16:56:27 -0400
Received: from mail-it1-f193.google.com ([209.85.166.193]:56103 "EHLO
        mail-it1-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727538AbfC1U40 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Mar 2019 16:56:26 -0400
Received: by mail-it1-f193.google.com with SMTP id z126so437070itd.5
        for <linux-nfs@vger.kernel.org>; Thu, 28 Mar 2019 13:56:25 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=cghYCZzJ0YaS4u39r/G03F4V9dfkwiLYVNcXMI0d+OyaxakjFyX28bJidnSuD2NX2y
         YVheVNOX67yXQZ6Y7li7x+8xiScHaImVlt/XEdME/Xei6Av7VCNHH4akEnMrwePuAG1I
         xt53zz5AeDEYcAUtBd+mDF2IPa/eUnZZZgTcz5c1q5b0OupESfJ32It1rgVleSrz862R
         3RMZ8bFtavkwLMam4J60ZoDk9ebLjL1TQHs4DL8VIi9TVSL/qgKe/jO4WJ8UJBVTzMqT
         dtO9stBnRONvA5yrsTLqmUWm8hVp8jAznma5jqX32MTcHjEh87JSKKnja3sBgv9kWjO+
         1oVw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=pb9VQIlipxvtv1VrZyk8nRS1A8ept6UJSKvPOMd5LmBr1Pg7jEALuHt6W/geDlziVV
         JvoHgY+5ptjBC9z246jw13Y1bsFQ/45QhvEAn81fTekiHlrJ2zpzKfnwMII4Bcuh9UjP
         IsdHW53pNtgJHIXUc3bdQgQLnr8rn43RL+xaUIdWoKd4ZDZDV77MoTGG/EkSzZ5V10YX
         MFzBOqUur1KldeTRLlroUrUcJjxVOAoJlEE3xB42CXMRTYBkqJzwlYLHvb2Qb5aapT1A
         wevsH0ZmdyTAyD5oTWfvdkmtDsAIQoSEkUGAo1A3IXzJuBTzXyj3u1HNIyjtYiR/YOc+
         DGtQ==
X-Gm-Message-State: APjAAAWykNMGSc13dyUNSkaf1KhE04S6o4zUk0NJk1kstxZ3op/3LPwo
        oqGNUa88uHRGo5iggdAEYrgjZMg=
X-Google-Smtp-Source: APXvYqz7PjTG/VddjqJbR568N2P5qxW7p8Ef2UChj5WBO6HaI5JY6Jm4XKeDt3QMNXV0r4dvcTSTOg==
X-Received: by 2002:a02:88b9:: with SMTP id n54mr34644563jaj.110.1553806584792;
        Thu, 28 Mar 2019 13:56:24 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id t67sm1084750ita.35.2019.03.28.13.56.24
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 28 Mar 2019 13:56:24 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH 18/25] NFS: Don't inadvertently clear writeback errors
Date:   Thu, 28 Mar 2019 16:52:32 -0400
Message-Id: <20190328205239.29674-19-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328205239.29674-18-trond.myklebust@hammerspace.com>
References: <20190328205239.29674-1-trond.myklebust@hammerspace.com>
 <20190328205239.29674-2-trond.myklebust@hammerspace.com>
 <20190328205239.29674-3-trond.myklebust@hammerspace.com>
 <20190328205239.29674-4-trond.myklebust@hammerspace.com>
 <20190328205239.29674-5-trond.myklebust@hammerspace.com>
 <20190328205239.29674-6-trond.myklebust@hammerspace.com>
 <20190328205239.29674-7-trond.myklebust@hammerspace.com>
 <20190328205239.29674-8-trond.myklebust@hammerspace.com>
 <20190328205239.29674-9-trond.myklebust@hammerspace.com>
 <20190328205239.29674-10-trond.myklebust@hammerspace.com>
 <20190328205239.29674-11-trond.myklebust@hammerspace.com>
 <20190328205239.29674-12-trond.myklebust@hammerspace.com>
 <20190328205239.29674-13-trond.myklebust@hammerspace.com>
 <20190328205239.29674-14-trond.myklebust@hammerspace.com>
 <20190328205239.29674-15-trond.myklebust@hammerspace.com>
 <20190328205239.29674-16-trond.myklebust@hammerspace.com>
 <20190328205239.29674-17-trond.myklebust@hammerspace.com>
 <20190328205239.29674-18-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

vfs_fsync() has the side effect of clearing unreported writeback errors,
so we need to make sure that we do not abuse it in situations where
applications might not normally expect us to report those errors.

The solution is to replace calls to vfs_fsync() with calls to nfs_wb_all().

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/file.c     | 6 +++---
 fs/nfs/nfs4file.c | 2 +-
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/file.c b/fs/nfs/file.c
index 4899b85f9b3c..f807e8643ae6 100644
--- a/fs/nfs/file.c
+++ b/fs/nfs/file.c
@@ -147,7 +147,7 @@ nfs_file_flush(struct file *file, fl_owner_t id)
 		return 0;
 
 	/* Flush writes to the server and return any errors */
-	return vfs_fsync(file, 0);
+	return nfs_wb_all(inode);
 }
 
 ssize_t
@@ -655,7 +655,7 @@ ssize_t nfs_file_write(struct kiocb *iocb, struct iov_iter *from)
 
 	/* Return error values */
 	if (nfs_need_check_write(file, inode)) {
-		int err = vfs_fsync(file, 0);
+		int err = nfs_wb_all(inode);
 		if (err < 0)
 			result = err;
 	}
@@ -709,7 +709,7 @@ do_unlk(struct file *filp, int cmd, struct file_lock *fl, int is_local)
 	 * Flush all pending writes before doing anything
 	 * with locks..
 	 */
-	vfs_fsync(filp, 0);
+	nfs_wb_all(inode);
 
 	l_ctx = nfs_get_lock_context(nfs_file_open_context(filp));
 	if (!IS_ERR(l_ctx)) {
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 45b2322e092d..90bf5ab6d579 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -125,7 +125,7 @@ nfs4_file_flush(struct file *file, fl_owner_t id)
 		return filemap_fdatawrite(file->f_mapping);
 
 	/* Flush writes to the server and return any errors */
-	return vfs_fsync(file, 0);
+	return nfs_wb_all(inode);
 }
 
 #ifdef CONFIG_NFS_V4_2
-- 
2.20.1

