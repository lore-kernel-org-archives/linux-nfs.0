Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35652 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752443AbbGAD55 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Jun 2015 23:57:57 -0400
Received: by pactm7 with SMTP id tm7so15862231pac.2
        for <linux-nfs@vger.kernel.org>; Tue, 30 Jun 2015 20:57:57 -0700 (PDT)
Message-ID: <5593653D.3030101@gmail.com>
Date: Wed, 01 Jul 2015 11:57:49 +0800
From: Kinglong Mee <kinglongmee@gmail.com>
MIME-Version: 1.0
To: Trond Myklebust <trond.myklebust@primarydata.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        kinglongmee@gmail.com, Al Viro <viro@zeniv.linux.org.uk>
Subject: [PATCH 4/8] nfs: Don't setting FILE_CREATED flags always
References: <5593648D.7020804@gmail.com>
In-Reply-To: <5593648D.7020804@gmail.com>
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 5bc2afc2b5 "NFSv4: Honour the 'opened' parameter in the atomic_open()
 filesystem method" have support the opened arguments now.

Also,
Commit 03da633aa7 "atomic_open: take care of EEXIST in no-open case with
 O_CREAT|O_EXCL in fs/namei.c" have change vfs's logical.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/dir.c | 3 ---
 1 file changed, 3 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index b2c8b31..21457bb 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1470,9 +1470,6 @@ static int nfs_finish_open(struct nfs_open_context *ctx,
 {
 	int err;
 
-	if ((open_flags & (O_CREAT | O_EXCL)) == (O_CREAT | O_EXCL))
-		*opened |= FILE_CREATED;
-
 	err = finish_open(file, dentry, do_open, opened);
 	if (err)
 		goto out;
-- 
2.4.3

