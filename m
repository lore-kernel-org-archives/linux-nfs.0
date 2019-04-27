Return-Path: <SRS0=TJwb=S5=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIMWL_WL_HIGH,DKIM_SIGNED,
	DKIM_VALID,DKIM_VALID_AU,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id CDF8CC43218
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 01:52:22 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id A0BD7205F4
	for <linux-nfs@archiver.kernel.org>; Sat, 27 Apr 2019 01:52:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=default; t=1556329942;
	bh=LBPOy+aYm6EozNKiSve1wb8hu6nj+X4x5OXp2mALJmI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:List-ID:From;
	b=EF+4sslrhaIW9u5B7is1q7JHaFHXlRmbYOiyHBvPUNvnLDdZospUtc67E+zl9VjAK
	 sO3PUdbd5MXOcIb0BCN6QHYhbkS90qgi8h/N/ZyK5qUIjNj1wXskS2aGyb7AKY9Jms
	 uFyRjIw8XLnxTp3o1Zv14qbDr1hQRORWo9Jg8yoQ=
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1728034AbfD0Bkh (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 26 Apr 2019 21:40:37 -0400
Received: from mail.kernel.org ([198.145.29.99]:44290 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727463AbfD0Bkh (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 26 Apr 2019 21:40:37 -0400
Received: from sasha-vm.mshome.net (c-73-47-72-35.hsd1.nh.comcast.net [73.47.72.35])
        (using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
        (No client certificate requested)
        by mail.kernel.org (Postfix) with ESMTPSA id A3F5E215EA;
        Sat, 27 Apr 2019 01:40:35 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
        s=default; t=1556329236;
        bh=LBPOy+aYm6EozNKiSve1wb8hu6nj+X4x5OXp2mALJmI=;
        h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
        b=uewF0XUsycI3XNwt6csXkdOdxsWV0b3KNGCZ07c3FnqLODcuKIMfc6x6scSXYluwg
         Eh4BjlzooOh/PJqBjVP5BikEgB2EN2KOuLo/WzZBeeHS21pJvqKjivOJGeWGPXPEM0
         7mc6quDA+jqIg2Dsx2gOUl1VIXrr2NOH5atZ/qsI=
From:   Sasha Levin <sashal@kernel.org>
To:     linux-kernel@vger.kernel.org, stable@vger.kernel.org
Cc:     Olga Kornievskaia <kolga@netapp.com>,
        Trond Myklebust <trond.myklebust@hammerspace.com>,
        Sasha Levin <sashal@kernel.org>, linux-nfs@vger.kernel.org
Subject: [PATCH AUTOSEL 5.0 73/79] NFSv4.1 fix incorrect return value in copy_file_range
Date:   Fri, 26 Apr 2019 21:38:32 -0400
Message-Id: <20190427013838.6596-73-sashal@kernel.org>
X-Mailer: git-send-email 2.19.1
In-Reply-To: <20190427013838.6596-1-sashal@kernel.org>
References: <20190427013838.6596-1-sashal@kernel.org>
MIME-Version: 1.0
X-stable: review
X-Patchwork-Hint: Ignore
Content-Transfer-Encoding: 8bit
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

From: Olga Kornievskaia <kolga@netapp.com>

[ Upstream commit 0769663b4f580566ef6cdf366f3073dbe8022c39 ]

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
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
Signed-off-by: Sasha Levin <sashal@kernel.org>
---
 fs/nfs/nfs42proc.c | 3 ---
 fs/nfs/nfs4file.c  | 4 +++-
 2 files changed, 3 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
index fed06fd9998d..94f98e190e63 100644
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
index 45b2322e092d..00d17198ee12 100644
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
2.19.1

