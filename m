Return-Path: <SRS0=Ki69=PU=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DFDEFC43387
	for <linux-nfs@archiver.kernel.org>; Sat, 12 Jan 2019 00:04:53 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id ADFD120872
	for <linux-nfs@archiver.kernel.org>; Sat, 12 Jan 2019 00:04:53 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="mZrLktRP"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726227AbfALAEw (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 11 Jan 2019 19:04:52 -0500
Received: from mail-yb1-f196.google.com ([209.85.219.196]:36757 "EHLO
        mail-yb1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1725927AbfALAEw (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jan 2019 19:04:52 -0500
Received: by mail-yb1-f196.google.com with SMTP id a190so6530527ybg.3
        for <linux-nfs@vger.kernel.org>; Fri, 11 Jan 2019 16:04:52 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=Yku0vWIUZMB/mlDOKZzWPjaDyQg9R9SdKjxKptK3bus=;
        b=mZrLktRPUzGK0Tn2QUNrsSo78xrhGnBFAZejXDr2BIx1iLhKik+eMxwIRBvDznLfS4
         cqq7PF11aQ/WbBaWOWiCtg3FJw2Vna5RoHkJkcWiJRPC6/JSYbeGTvHnNnvVjYnEORgQ
         fb5RkelMwHT54wXX8GjhWDvoH1FLz6LxZ5kOJfCv4XnrTjexepfGT5cy0wjVelm65iH5
         nZyy2rk4ihf2hF2HbH02/0U2OnpqMY8gVQ7Vyu+UTDIPvImG6dZCaKzvLbXhU5597rTK
         1yKn90I95yEmHqxCkdP6RZNsHxmedE8w5kAz4NrgCA59/Rq4E8wwvYreKlPwMJxM+Gnt
         kkZQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=Yku0vWIUZMB/mlDOKZzWPjaDyQg9R9SdKjxKptK3bus=;
        b=ciFMooMqrw77CIjZgyIdSMxNztFRrwGSmyVHtcMSxF97Q+BtwQIIdVo5b8wBHZTPRL
         UOjx1WWct9I3mWIIqjj4FXS6hNqtDPSYbjPQ5fKCeIb7MevAWuxZyvLu4ekd4ltPTh/E
         EGJIYVdWhXHXZrTyl2V8ecdDyufVsZiHeUGx1b021CQEu34Pi4kG4jA7BjSRauHRggeB
         A/omYmzenoiBao5XefLZxza5aMebeQmpF4q1UWilRL35Mllgbx3BMYD6JHbEF7Prff5K
         HjatuBMTqaYAvUsa6XdfEqmXvOeGgurvfKDD+JBNQt11O9SbBu/cxrVYsKikm49FUed/
         kEOw==
X-Gm-Message-State: AJcUukfXKhXfcZXECDlHIARAFk9kI9mNqakarRXaM/xcl58Uqxwq3126
        +GW5EN/YLmtzktMo1xYHsOuIIsVW
X-Google-Smtp-Source: ALg8bN7WBrGuCtHnz1v2r/g21pZ+nSrxvnliMIyzaAqKk4BQu4WZTy5G30j9g3MqSPAS0gxv14j70g==
X-Received: by 2002:a25:5144:: with SMTP id f65mr16400344ybb.426.1547251491778;
        Fri, 11 Jan 2019 16:04:51 -0800 (PST)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id d3sm44750404ywh.58.2019.01.11.16.04.50
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 11 Jan 2019 16:04:51 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2] NFSv4.2 fix unnecessary retry in nfs4_copy_file_range
Date:   Fri, 11 Jan 2019 19:04:44 -0500
Message-Id: <20190112000444.3540-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently nfs42_proc_copy_file_range() can not return EAGAIN.

Fixes: e4648aa4f98a ("NFS recover from destination server reboot for copies")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 8 +-------
 1 file changed, 1 insertion(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 46d691b..45b2322 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,15 +133,9 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
-	ssize_t ret;
-
 	if (file_inode(file_in) == file_inode(file_out))
 		return -EINVAL;
-retry:
-	ret = nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
-	if (ret == -EAGAIN)
-		goto retry;
-	return ret;
+	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 }
 
 static loff_t nfs4_file_llseek(struct file *filep, loff_t offset, int whence)
-- 
1.8.3.1

