Return-Path: <SRS0=UxWt=P5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 34903C37123
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Jan 2019 20:59:48 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 01E4B20861
	for <linux-nfs@archiver.kernel.org>; Mon, 21 Jan 2019 20:59:48 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="Vxkx+fil"
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726694AbfAUU7r (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Mon, 21 Jan 2019 15:59:47 -0500
Received: from mail-io1-f68.google.com ([209.85.166.68]:43776 "EHLO
        mail-io1-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1726004AbfAUU7r (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Jan 2019 15:59:47 -0500
Received: by mail-io1-f68.google.com with SMTP id b23so17430029ios.10
        for <linux-nfs@vger.kernel.org>; Mon, 21 Jan 2019 12:59:46 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=o3GeiTl2AzSQmrhBTRhVuV+20q5/mNdyo8+r+77r7Yw=;
        b=Vxkx+fil/qWVWcGV6qe8AoJWE00TwmiA0fm4PFCxlIrX0zZw6IbGZ5CfgPCp9Dq/EN
         IYixYGxB23qrT22rZDzN5Ng17b65sxjC4vFsifEhBSoMyzACU5F8IDntnmDOUhQY2Guj
         55ODYO3E7LS5O0vJhePr47wpbInTIaXhZqNxvobupSZKgg53lHw6LnxdgYesKXFGz8L4
         MGU8OPK/pzoSjH0ejKMZLt9UUMwW2LY0iQUOHSug/mMDYYcDFzr2Gn4DGhuuzZB8N0tR
         R7rQns9uaSN12lGVnUIEA43ZizD8FEZQ/XA9EFhlOm50c8hlG3pOf5vwBkSnr4565qbB
         AHNQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:from:to:cc:subject:date:message-id:mime-version
         :content-transfer-encoding;
        bh=o3GeiTl2AzSQmrhBTRhVuV+20q5/mNdyo8+r+77r7Yw=;
        b=tC0cnDiku+81eBp68hKtr+UwA6jPvstr0q21A9BxtzDNnOJCgphVurEbtcVYgDiSuV
         kpsV5UaL2bgz9MiHOlym0jEbbPn7a9w7HGbn9AdNDXXaXa3YL7nsTL6HX5yIPzmwwgLh
         DPol9k/S5jhRepZMmZ3kBohc/CPpVWATYmjXCSA5X+4Lj9e5yfjV7ZmprfrE2hAjS8Ue
         ejnGlOybMj5TOTXIBgeTlccyLo2Pbnm4CPAjjYfKdkcu23RPz2lwxyyATALiYXXNmvCk
         f0qjJO5Og78wtM/auaQQlCc74cSaSsmBQ/EsLYZePdUGw+XfLVx+2pP47T7PNO4BUIDn
         koeQ==
X-Gm-Message-State: AJcUukcT75muzGTPZ7E6Pvpx1xplpqtIxYzhgLGcoAMXX06f+1CWnoB4
        H0BzplHuEj86jf7xu8HBbA==
X-Google-Smtp-Source: ALg8bN6+TjEcs5H1izrQySMGrdBXIIQjaKwjGF28yCotRa3aoTI8pO16Ju/5zvHGAnhLhrUDz00E0w==
X-Received: by 2002:a5d:8889:: with SMTP id d9mr18846180ioo.68.1548104386271;
        Mon, 21 Jan 2019 12:59:46 -0800 (PST)
Received: from localhost.localdomain (c-68-40-189-247.hsd1.mi.comcast.net. [68.40.189.247])
        by smtp.gmail.com with ESMTPSA id j7sm5391958iom.80.2019.01.21.12.59.45
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 21 Jan 2019 12:59:45 -0800 (PST)
From:   Trond Myklebust <trondmy@gmail.com>
X-Google-Original-From: Trond Myklebust <trond.myklebust@hammerspace.com>
To:     "J. Bruce Fields" <bfields@redhat.com>
Cc:     "Darrick J. Wong" <darrick.wong@oracle.com>,
        linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd: Fix error return values for nfsd4_clone_file_range()
Date:   Mon, 21 Jan 2019 15:58:38 -0500
Message-Id: <20190121205838.18680-1-trond.myklebust@hammerspace.com>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

If the parameter 'count' is non-zero, nfsd4_clone_file_range() will
currently clobber all errors returned by vfs_clone_file_range() and
replace them with EINVAL.

Fixes: 42ec3d4c0218 ("vfs: make remap_file_range functions take and...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Cc: stable@vger.kernel.org # v4.20+
---
 fs/nfsd/vfs.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
index 9824e32b2f23..7dc98e14655d 100644
--- a/fs/nfsd/vfs.c
+++ b/fs/nfsd/vfs.c
@@ -557,9 +557,11 @@ __be32 nfsd4_clone_file_range(struct file *src, u64 src_pos, struct file *dst,
 	loff_t cloned;
 
 	cloned = vfs_clone_file_range(src, src_pos, dst, dst_pos, count, 0);
+	if (cloned < 0)
+		return nfserrno(cloned);
 	if (count && cloned != count)
-		cloned = -EINVAL;
-	return nfserrno(cloned < 0 ? cloned : 0);
+		return nfserrno(-EINVAL);
+	return 0;
 }
 
 ssize_t nfsd_copy_file_range(struct file *src, u64 src_pos, struct file *dst,
-- 
2.20.1

