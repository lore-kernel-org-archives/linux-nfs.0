Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pl0-f65.google.com ([209.85.160.65]:42262 "EHLO
        mail-pl0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1729688AbeGQSgO (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jul 2018 14:36:14 -0400
Received: by mail-pl0-f65.google.com with SMTP id f4-v6so793229plb.9
        for <linux-nfs@vger.kernel.org>; Tue, 17 Jul 2018 11:02:28 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
To: linux-nfs@vger.kernel.org,
        "J . Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@kernel.org>
Cc: Eric Biggers <ebiggers@google.com>
Subject: [PATCH] nfsd: constify write_op[]
Date: Tue, 17 Jul 2018 11:01:25 -0700
Message-Id: <20180717180125.142261-1-ebiggers3@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Eric Biggers <ebiggers@google.com>

write_op[] is never modified, so make it 'const'.

Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 fs/nfsd/nfsctl.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
index 2c46451c7d60..19aa4ded2590 100644
--- a/fs/nfsd/nfsctl.c
+++ b/fs/nfsd/nfsctl.c
@@ -73,7 +73,7 @@ static ssize_t write_recoverydir(struct file *file, char *buf, size_t size);
 static ssize_t write_v4_end_grace(struct file *file, char *buf, size_t size);
 #endif
 
-static ssize_t (*write_op[])(struct file *, char *, size_t) = {
+static ssize_t (*const write_op[])(struct file *, char *, size_t) = {
 	[NFSD_Fh] = write_filehandle,
 	[NFSD_FO_UnlockIP] = write_unlock_ip,
 	[NFSD_FO_UnlockFS] = write_unlock_fs,
-- 
2.18.0.203.gfac676dfb9-goog

