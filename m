Return-Path: <SRS0=26It=SA=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 75C34C43381
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:16 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 470762184D
	for <linux-nfs@archiver.kernel.org>; Fri, 29 Mar 2019 22:02:16 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dtgQddu1"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1730362AbfC2WCP (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 29 Mar 2019 18:02:15 -0400
Received: from mail-it1-f194.google.com ([209.85.166.194]:36188 "EHLO
        mail-it1-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1730357AbfC2WCP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 29 Mar 2019 18:02:15 -0400
Received: by mail-it1-f194.google.com with SMTP id y10so4316185itc.1
        for <linux-nfs@vger.kernel.org>; Fri, 29 Mar 2019 15:02:14 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=dtgQddu1ztPwPpdBuUdV4Txtrvp5khtj8ojDixjpONLfSz/Hd6q+fi09ZIoENe+xFO
         yLrKlL4v6KHmPTplwTVj8m3wVCXrT/Uk2yYlFRG6qebEZ0HGmumCIMyGJW303zFMRruV
         ZqRivLOowmjvdf347G4Q33VsvDSgAgSOJR6R6sUSP6Zqv/pmqMzK/vtTDM9+wc+fGo0T
         iHPszA/gpccoS8GyJNm/2fxcFeArUEHIdzbT8JgKQMjLR/5gzRWfjUxQb+o4GGO1geCK
         eUFX4HBY7f2B034cCerLOMtNd+6/KysfgCjPBgz5rF3pxrWTeJ+XIR2CfBSX+CsAndIE
         xWyQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=scNFQkcT48wxG90i2HDvX1SXREfQ/bRZzVEBR2e/yk9oEF3IW1mj6EuWQeqi+BxN/z
         n6pt1L0aHuO4UCkWguGNLy2M3hMQWYUDCVreY+a8RDaOjpPnn12yt77Db/2BDKarWeJi
         hatymf0BSc29dv51UA4ZG2chZ+tk381vrKGnAsrhLyJ6Ph21aJR0fl8O8Y+1NyP/Bs8T
         WSUlLEx9RH6rYrzNAtdZ/I3vFOI92dMGSDyirCxrtPSfLZaYu3+VpxU7mm5pMuel5v12
         ehJ5R+RCeYR/JlNpWW/JKeQLzv7+owibnx4kSt7gDaHk+AZeegPd3U9poH0OO/9cXJZg
         JhmQ==
X-Gm-Message-State: APjAAAUjdNC80QX1rNdxXd9MDy1G5dnlMaJkFekPU6hNnXm4rB9Uk8iF
        kwbbr1P7Z+BxJ3IPZ7A6efheyDo=
X-Google-Smtp-Source: APXvYqy4Sx6yLsemSgXpwZeCK+8OR3Goa09ujQc9v45g1RMEbD96+CFVRCLBTgnRINaqdAueZxv0gw==
X-Received: by 2002:a05:660c:606:: with SMTP id i6mr3798792itk.154.1553896934006;
        Fri, 29 Mar 2019 15:02:14 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id v20sm1376796ioh.17.2019.03.29.15.02.13
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 29 Mar 2019 15:02:13 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 21/28] NFS: Don't inadvertently clear writeback errors
Date:   Fri, 29 Mar 2019 17:59:41 -0400
Message-Id: <20190329215948.107328-22-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190329215948.107328-21-trond.myklebust@hammerspace.com>
References: <20190329215948.107328-1-trond.myklebust@hammerspace.com>
 <20190329215948.107328-2-trond.myklebust@hammerspace.com>
 <20190329215948.107328-3-trond.myklebust@hammerspace.com>
 <20190329215948.107328-4-trond.myklebust@hammerspace.com>
 <20190329215948.107328-5-trond.myklebust@hammerspace.com>
 <20190329215948.107328-6-trond.myklebust@hammerspace.com>
 <20190329215948.107328-7-trond.myklebust@hammerspace.com>
 <20190329215948.107328-8-trond.myklebust@hammerspace.com>
 <20190329215948.107328-9-trond.myklebust@hammerspace.com>
 <20190329215948.107328-10-trond.myklebust@hammerspace.com>
 <20190329215948.107328-11-trond.myklebust@hammerspace.com>
 <20190329215948.107328-12-trond.myklebust@hammerspace.com>
 <20190329215948.107328-13-trond.myklebust@hammerspace.com>
 <20190329215948.107328-14-trond.myklebust@hammerspace.com>
 <20190329215948.107328-15-trond.myklebust@hammerspace.com>
 <20190329215948.107328-16-trond.myklebust@hammerspace.com>
 <20190329215948.107328-17-trond.myklebust@hammerspace.com>
 <20190329215948.107328-18-trond.myklebust@hammerspace.com>
 <20190329215948.107328-19-trond.myklebust@hammerspace.com>
 <20190329215948.107328-20-trond.myklebust@hammerspace.com>
 <20190329215948.107328-21-trond.myklebust@hammerspace.com>
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

