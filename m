Return-Path: <SRS0=4uXo=PQ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B9545C43387
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 17:55:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 88A5E2064C
	for <linux-nfs@archiver.kernel.org>; Tue,  8 Jan 2019 17:55:41 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Dc2P+cX7"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728723AbfAHRzk (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 8 Jan 2019 12:55:40 -0500
Received: from mail-yw1-f67.google.com ([209.85.161.67]:36671 "EHLO
        mail-yw1-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727484AbfAHRzk (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jan 2019 12:55:40 -0500
Received: by mail-yw1-f67.google.com with SMTP id i73so1892201ywg.3
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jan 2019 09:55:40 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=nYaBVAPOnLORUyuMxUqkLRYvhXMmmN0J85/a/P7UxsU=;
        b=Dc2P+cX7KGzIhC3FtS1pY049ZTWzQEcrrITKS4A3N/i+TQb916hpTpu2tuap0AjiVb
         buCFXRwuvBtigpedYCews4ieYTjollV+n7xOE7CYH4fsUPYhsEDIp7jUd3GNPlZtG82I
         CwAJKhJ2bgFoHWekaMGKkdXSGWQ1JEwPPqJIV1OuCrN5x9r8+Kh9UpSTnbYEhAwyDw7D
         RBkxJ34BK078FDXY1gKshsZi8+YTYktc0dVN1mrSbB4//ScXHDrDZY3Bnp32ZapHjAUc
         JHc9izaAdMn0BM4tH0lgUZWT2F/Ad0S8WxKvRgX72hQ+MmlW3JN4vaqNBgx6E+//utLe
         Kzjg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=nYaBVAPOnLORUyuMxUqkLRYvhXMmmN0J85/a/P7UxsU=;
        b=EQqlN/pkpb+7pzSxQXkpuIj1n2GL1VwlCKxWbDc5ezhCMlsox8dHXNkVw6lXVMWPOF
         89eVsCEJx6MA/50FlhXRjp3jKcPMzLdMT1d2wtj1pudZqBbfvBV6oUkzvgvbNU1Ooja6
         GX+TOiFvZv6iaboT+/0JbIA4g33crg2UTodJMSK9JtRRB/ICn5J6TyP/06aGJ56KWoke
         zBMsGVq52uj6oqPR0vABtMmjbudofepT0JCIkZrbV9Wya5OjUO7LXW+KJEWNSAbRHoIr
         uHVBcG+rOCAcyOUN63uNF1hORMXmqbwyffOVbVviDk8iZFzP/RpGOQjmdgxQClYnTrok
         R/DQ==
X-Gm-Message-State: AJcUukehwO8FjrQXrbfMdmoJ6e2M3kiLTMIyVa2WMOXdEWvJs5KRdm9T
        drb+0Ezht6v4DnnAZxZR6YY=
X-Google-Smtp-Source: ALg8bN6hxbfpXiza8+ClcgvMZzT8BEvpKGS+IMxgXwq9eUMWlViU6gN4X12LPHSusOCJpWJ0YTJfOQ==
X-Received: by 2002:a81:1c42:: with SMTP id c63mr2450269ywc.89.1546970139802;
        Tue, 08 Jan 2019 09:55:39 -0800 (PST)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id x9sm26153899ywc.8.2019.01.08.09.55.38
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 08 Jan 2019 09:55:39 -0800 (PST)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH 1/1] NFSv4.2 fix unnecessary retry in nfs4_copy_file_range
Date:   Tue,  8 Jan 2019 12:55:32 -0500
Message-Id: <20190108175532.2348-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

Currently nfs42_proc_copy_file_range() can not return EAGAIN.

Fixes: e4648aa4f98a ("NFS recover from destination server reboot for copies")
Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs4file.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 46d691b..81554af 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -137,11 +137,7 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 
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

