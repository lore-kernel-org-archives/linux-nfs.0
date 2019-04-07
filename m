Return-Path: <SRS0=hGI+=SJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7F6D6C282DD
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:44 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 5509720896
	for <linux-nfs@archiver.kernel.org>; Sun,  7 Apr 2019 18:01:44 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qdyCacg9"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726475AbfDGSBn (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Sun, 7 Apr 2019 14:01:43 -0400
Received: from mail-it1-f195.google.com ([209.85.166.195]:38985 "EHLO
        mail-it1-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726466AbfDGSBn (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sun, 7 Apr 2019 14:01:43 -0400
Received: by mail-it1-f195.google.com with SMTP id 139so17333810ita.4
        for <linux-nfs@vger.kernel.org>; Sun, 07 Apr 2019 11:01:42 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=qdyCacg9PKPZiD31bg+/n3XiNvQ6ylXIhpTsm48qahQhBFLZMfcA0SWS1HZF+qDxD5
         Yz+IGtIo8e7pWRjekukaLnCcMZ/m5/8zpxNmIxqSK9D8bu+g9Pwgx+0e1GJDSALUw/Yy
         yq+XG/jeKXeHjLHyEHDI7D5z/gYKNH+g/MTsLPeD8UEamsKQmrfESCtzDfsvSBqZ5/vB
         rfDWr1qD96gwvlR8SKQRzZR03qwytTgtT0bMGcH0f7sgbLnZguK4i4tDWTSHRvbRXsyy
         sGyOVVKIBFf5abD0KEPwOgBRU+j4ZHiJOcoTg1CrrfJ1GtkbV4mAsEatHbbIGYaiz7n4
         PzSQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references:mime-version:content-transfer-encoding;
        bh=aMgttM/nk4zUqEnDG3rhSTJALWClACiu42cy+odVt+w=;
        b=Fi3t6u1GdYsMp4vhp5glWgBnvQjlu3dn0gUxTZEx/4uwaZ2sN/aNtvQ6nfQwhwpnCo
         LxBjBjkFu6o6uu1coBXxglAMQLwvlLQamp0+uOm6q/9uMEWAJ8Y9buRR0aQYcacBAUlU
         +hFjeRODeETThj+YBBCXgNWD9hsMUgtQ6dc/peEYehwCVONzzoAKyL6xmd92oskdr58Z
         +JCzF1nTNLlFmZ4ICvG3AsSzqW/0ziJ0akMJQQtIE6dwU233pW5K3NVhrAw6NTpqhza0
         l2Xx2ktVRnbQ+Yk+YSd2941af6yNXXF5oBHfrX/m6IDqwG5rEyO3+hrlKoVycSsf9SDe
         hpzg==
X-Gm-Message-State: APjAAAUOuFwTL9oLWd/qqTUXSw0sarGpfwe8BY8Pvdl2qHB5eB5tsfs2
        atptpcamLbS7JcaTj90A8w==
X-Google-Smtp-Source: APXvYqxzfq0UrwE3H7oZItG50p+c7FHfYD4if83TQKn1qLT3yE27RraYMaaUbBLhvj8AxzWFz8M51w==
X-Received: by 2002:a24:6cc5:: with SMTP id w188mr18204295itb.38.1554660101997;
        Sun, 07 Apr 2019 11:01:41 -0700 (PDT)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id m6sm10807362ioj.36.2019.04.07.11.01.41
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 07 Apr 2019 11:01:41 -0700 (PDT)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     Anna Schumaker <Anna.Schumaker@netapp.com>
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v3 21/29] NFS: Don't inadvertently clear writeback errors
Date:   Sun,  7 Apr 2019 13:59:04 -0400
Message-Id: <20190407175912.23528-22-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190407175912.23528-21-trond.myklebust@hammerspace.com>
References: <20190407175912.23528-1-trond.myklebust@hammerspace.com>
 <20190407175912.23528-2-trond.myklebust@hammerspace.com>
 <20190407175912.23528-3-trond.myklebust@hammerspace.com>
 <20190407175912.23528-4-trond.myklebust@hammerspace.com>
 <20190407175912.23528-5-trond.myklebust@hammerspace.com>
 <20190407175912.23528-6-trond.myklebust@hammerspace.com>
 <20190407175912.23528-7-trond.myklebust@hammerspace.com>
 <20190407175912.23528-8-trond.myklebust@hammerspace.com>
 <20190407175912.23528-9-trond.myklebust@hammerspace.com>
 <20190407175912.23528-10-trond.myklebust@hammerspace.com>
 <20190407175912.23528-11-trond.myklebust@hammerspace.com>
 <20190407175912.23528-12-trond.myklebust@hammerspace.com>
 <20190407175912.23528-13-trond.myklebust@hammerspace.com>
 <20190407175912.23528-14-trond.myklebust@hammerspace.com>
 <20190407175912.23528-15-trond.myklebust@hammerspace.com>
 <20190407175912.23528-16-trond.myklebust@hammerspace.com>
 <20190407175912.23528-17-trond.myklebust@hammerspace.com>
 <20190407175912.23528-18-trond.myklebust@hammerspace.com>
 <20190407175912.23528-19-trond.myklebust@hammerspace.com>
 <20190407175912.23528-20-trond.myklebust@hammerspace.com>
 <20190407175912.23528-21-trond.myklebust@hammerspace.com>
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

