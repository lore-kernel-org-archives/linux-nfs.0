Return-Path: <SRS0=kagm=SN=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC2D9C10F13
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 18:34:28 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id B596820693
	for <linux-nfs@archiver.kernel.org>; Thu, 11 Apr 2019 18:34:28 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="YpmiLbE6"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726615AbfDKSe2 (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 11 Apr 2019 14:34:28 -0400
Received: from mail-yw1-f66.google.com ([209.85.161.66]:46445 "EHLO
        mail-yw1-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726595AbfDKSe2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Apr 2019 14:34:28 -0400
Received: by mail-yw1-f66.google.com with SMTP id v127so2412562ywe.13
        for <linux-nfs@vger.kernel.org>; Thu, 11 Apr 2019 11:34:27 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id;
        bh=7WbJ0yaQ727Q4v6B6hty4iWv5saRuC8u/0+3OzQrVQw=;
        b=YpmiLbE6+QCokOhcqfm8259e2y920TQXwd3paiZ8TbopEppvSuIBL/G5+rfoMqdtMr
         y0drwS6uBs1nnl1l8q0Q9CAvX3kMJG5AqZrK9fucdrcSRTthojzL+R6IHRVAd1RLkh2n
         r2fGY2mpmkECDbGw8i/o7k+SBnG2v6Gje0AYGiblCBC/EtpRWePXOyNuz1hnF4CNKrOh
         Tuj8Pou3Gk77Tu3FzG6qvSEG9c+jSlV7bBbfk9sPeGz2wnMtntlxU1IFNJ1uBsSml4T0
         xxrHuVIkZr98BZ2bOThZmXxTz+vPNyLxQPhVxJbW93ws7EscGQgQESxRbEN+pj9axbAV
         5d5A==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id;
        bh=7WbJ0yaQ727Q4v6B6hty4iWv5saRuC8u/0+3OzQrVQw=;
        b=fP72rJTHCqz4hoPNFKs8qQ4xpIIYBaBUVAoefPSJYleKNde+fdlW6E0YfsCQZ3PCEt
         mXbCv8aYJHR2ZyCb4Pk0Zq+7VObsu/0cJCnPI3Jwzr9sjLqt5xV1L+KBC8rGS8by1gkZ
         XZoGCZK4smXvsDuQzNIl3+zB2ty5M3Qp3sQVmDDCs1qCY/qJn5dUPLQ4EFKswcb4lfYw
         U4IA5xSw9gWpOvbY9Wkf4rFezGJVYo2RNXH4iBFYljVFEj9oQKuPntvOdzfwE3P+sim3
         LK3DrZzfRohE+rk5DvTIN0pAsP4Fo2qJlez/lr1wmm69Q+Izz1kuH0P8KbOKLPhitU6H
         50GQ==
X-Gm-Message-State: APjAAAUn5ayZrGjYA50bAB4VmRVK/NCZoh7S2N6trVDY6OL6Pnco+CZY
        SHMy7Fj0A/KrgkNIt7a6bLOnOmBF
X-Google-Smtp-Source: APXvYqwadYqhEik6M12lJ0VyYdRzWsp6XqLSaHZ7GuJcSf8nqidU7deOgWGXiH01v6kQZkVX1mypYQ==
X-Received: by 2002:a81:5189:: with SMTP id f131mr40914816ywb.312.1555007667192;
        Thu, 11 Apr 2019 11:34:27 -0700 (PDT)
Received: from localhost.localdomain ([97.101.44.244])
        by smtp.gmail.com with ESMTPSA id l127sm13670639ywe.35.2019.04.11.11.34.26
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Apr 2019 11:34:26 -0700 (PDT)
From:   Olga Kornievskaia <olga.kornievskaia@gmail.com>
To:     trond.myklebust@hammerspace.com, anna.schumaker@netapp.com
Cc:     linux-nfs@vger.kernel.org
Subject: [PATCH v2 1/1] NFSv4.1 fix incorrect return value in copy_file_range
Date:   Thu, 11 Apr 2019 14:34:18 -0400
Message-Id: <20190411183418.4510-1-olga.kornievskaia@gmail.com>
X-Mailer: git-send-email 2.10.1 (Apple Git-78)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

According to the NFSv4.2 spec if the input and output file is the
same file, operation should fail with EINVAL. However, linux
copy_file_range() system call has no such restrictions. Therefore,
in such case let's return EOPNOTSUPP and allow VFS to fallback
to doing do_splice_direct(). Also when copy_file_range is called
on an NFSv4.0 or 4.1 mount (ie., a server that doesn't support
COPY functionality), we also need to return EOPNOTSUPP and
fallback to a regular copy.

Fixes xfstest generic/075, generic/091, generic/112, generic/263
for all NFSv4.x versions.

Signed-off-by: Olga Kornievskaia <kolga@netapp.com>
---
 fs/nfs/nfs42proc.c | 3 ---
 fs/nfs/nfs4file.c  | 4 +++-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index ff6f85f..5196bfa 100644
--- a/fs/nfs/nfs42proc.c
+++ b/fs/nfs/nfs42proc.c
@@ -329,9 +329,6 @@ ssize_t nfs42_proc_copy(struct file *src, loff_t pos_src,
 	};
 	ssize_t err, err2;
 
-	if (!nfs_server_capable(file_inode(dst), NFS_CAP_COPY))
-		return -EOPNOTSUPP;
-
 	src_lock = nfs_get_lock_context(nfs_file_open_context(src));
 	if (IS_ERR(src_lock))
 		return PTR_ERR(src_lock);
diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
index 45b2322..00d1719 100644
--- a/fs/nfs/nfs4file.c
+++ b/fs/nfs/nfs4file.c
@@ -133,8 +133,10 @@ static ssize_t nfs4_copy_file_range(struct file *file_in, loff_t pos_in,
 				    struct file *file_out, loff_t pos_out,
 				    size_t count, unsigned int flags)
 {
+	if (!nfs_server_capable(file_inode(file_out), NFS_CAP_COPY))
+		return -EOPNOTSUPP;
 	if (file_inode(file_in) == file_inode(file_out))
-		return -EINVAL;
+		return -EOPNOTSUPP;
 	return nfs42_proc_copy(file_in, pos_in, file_out, pos_out, count);
 }
 
-- 
1.8.3.1

