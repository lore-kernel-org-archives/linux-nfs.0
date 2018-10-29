Return-Path: <SRS0=jHeB=NJ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 70B5FC2BC61
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:05 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 3830D2082D
	for <linux-nfs@archiver.kernel.org>; Mon, 29 Oct 2018 19:04:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="dYcgJmoW"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3830D2082D
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=none smtp.mailfrom=linux-nfs-owner@vger.kernel.org
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728488AbeJ3DyC (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 29 Oct 2018 23:54:02 -0400
Received: from mail-qt1-f196.google.com ([209.85.160.196]:40561 "EHLO
        mail-qt1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725923AbeJ3DyB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Oct 2018 23:54:01 -0400
Received: by mail-qt1-f196.google.com with SMTP id k12so4705707qtf.7;
        Mon, 29 Oct 2018 12:04:02 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references;
        bh=v5fKmkh8T+Ommp9W6hAHXoyDi5Y6lfOuGF2pswJXawE=;
        b=dYcgJmoWwDdjoLjnA7Swb+gssWTUz1sTHDHEafSYmQTSNHqoL0pX4/vKBLARLm0AuI
         P5jonfKSPwMMF/tbi6/Dv+b9+A/MHOTmXjRR1zXlCKnZHvtg5dwkmc9z1e8ZblyuRt42
         xv3Pcbo9vCqI+fMVVmchtylCuUHVh4wgnJphmyBS87VbDlsANr/X7Df0O03eFsg0hQsr
         zG0UtUCVhrDFvvjDkMmUlWVuJWda6TOl7pUp5KXFLWcPd9D+LniuhPInP+2beYZytNKu
         HSxp8NpYr+V21bKney3sbMeSTclkRmPb/NGQJykygxz4ZDNx5YlCV+VPrWstyeKWe9HR
         R5Lg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:in-reply-to
         :references;
        bh=v5fKmkh8T+Ommp9W6hAHXoyDi5Y6lfOuGF2pswJXawE=;
        b=B65iCO+ZC5que3UTaX495ftGZBxdvGI0I5sIRx12AhhfIVzQcBJt7bFaisLRuelYGS
         cBiYyPINS3D8/3aBERuWw2hCv+SLnjUgV+6hSmXHCsXALOlOIyIq49ZGy4mkaWG5evBV
         VxYTXDs07WfQ1OpPNVXkYT0A7micu1e77Ps2ZG19tT2PPDcV6EY8pDCmWb4uplaqPyg2
         EDGFXhAXGvwrdTZ5+Podn5jCIKdb8CW8Lk78aJk3stAtPEG6ckKILW/1KR9OUgvvhXNZ
         aKvxpKbgL42ISh+P77skKDtX4KwESZ5PzN8q2DvfblgwvjLrrrI33zw7IJxJ52o9SggU
         UwPg==
X-Gm-Message-State: AGRZ1gKCm0ZmG/8witA+ZB8ynEMWzf4J3uho1+Gi/DF/RT7fmq19jkgR
        UOLsIHGCwzNx7KhLSVqtofs=
X-Google-Smtp-Source: AJdET5efjAP78uWV5E7TZTR6aVNAtidRd/VoPiRIGSwHj6fjHvwgFkje73zkwjj7gicvmlC9FleYGA==
X-Received: by 2002:aed:3a82:: with SMTP id o2-v6mr14003624qte.240.1540839842108;
        Mon, 29 Oct 2018 12:04:02 -0700 (PDT)
Received: from Olgas-MBP-195.attlocal.net (172-10-226-31.lightspeed.livnmi.sbcglobal.net. [172.10.226.31])
        by smtp.gmail.com with ESMTPSA id c5-v6sm2714373qtj.55.2018.10.29.12.04.00
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 29 Oct 2018 12:04:01 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com,
        viro@zeniv.linux.org.uk, smfrench@gmail.com, miklos@szeredi.hu
Cc:     linux-nfs@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-unionfs@vger.kernel.org,
        linux-man@vger.kernel.org
Subject: [PATCH v6 01/12] VFS: generic cross-device copy_file_range() support for all filesystems
Date:   Mon, 29 Oct 2018 15:03:45 -0400
Message-Id: <20181029190357.38439-2-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
In-Reply-To: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
References: <20181029190357.38439-1-olga.kornievskaia@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

In preparation for enabling cross-device offloading of
copy_file_range() functionality, first enable generic cross-device
support by allowing copy_file_range() to fall back to a page cache
based physical data copy. This means the copy_file_range() syscall
will never fail with EXDEV, and so in future userspace will not need
to detect or provide a fallback for failed cross-device copies
anymore.

This requires pushing the cross device support checks down into the
filesystem ->copy_file_range methods and falling back to the page
cache copy if they return EXDEV. This will come in the following
patch. Now enforcing same superblock check for copy_file_range().

Further, clone_file_range() is only supported within a filesystem,
so we must also check that the files belong to the same superblock
before calling ->clone_file_range(). If they are on different
superblocks, skip the attempt to clone the file and instead try to
copy the file.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/read_write.c | 10 ++++------
 1 file changed, 4 insertions(+), 6 deletions(-)

diff --git a/fs/read_write.c b/fs/read_write.c
index 39b4a21..70f6939 100644
--- a/fs/read_write.c
+++ b/fs/read_write.c
@@ -1575,10 +1575,6 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	    (file_out->f_flags & O_APPEND))
 		return -EBADF;
 
-	/* this could be relaxed once a method supports cross-fs copies */
-	if (inode_in->i_sb != inode_out->i_sb)
-		return -EXDEV;
-
 	if (len == 0)
 		return 0;
 
@@ -1588,7 +1584,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 	 * Try cloning first, this is supported by more file systems, and
 	 * more efficient if both clone and copy are supported (e.g. NFS).
 	 */
-	if (file_in->f_op->clone_file_range) {
+	if (inode_in->i_sb == inode_out->i_sb &&
+	    file_in->f_op->clone_file_range) {
 		ret = file_in->f_op->clone_file_range(file_in, pos_in,
 				file_out, pos_out, len);
 		if (ret == 0) {
@@ -1597,7 +1594,8 @@ ssize_t vfs_copy_file_range(struct file *file_in, loff_t pos_in,
 		}
 	}
 
-	if (file_out->f_op->copy_file_range) {
+	if (inode_in->i_sb == inode_out->i_sb &&
+	    file_out->f_op->copy_file_range) {
 		ret = file_out->f_op->copy_file_range(file_in, pos_in, file_out,
 						      pos_out, len, flags);
 		if (ret != -EOPNOTSUPP)
-- 
1.8.3.1

