Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf1-f196.google.com ([209.85.210.196]:44400 "EHLO
        mail-pf1-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1727307AbeI1AeR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Sep 2018 20:34:17 -0400
Received: by mail-pf1-f196.google.com with SMTP id k21-v6so2450788pff.11
        for <linux-nfs@vger.kernel.org>; Thu, 27 Sep 2018 11:14:47 -0700 (PDT)
From: Stan Hu <stanhu@gmail.com>
To: linux-nfs@vger.kernel.org
Cc: Stan Hu <stanhu@gmail.com>
Subject: [PATCH] NFSv4: Revalidate inode if any of its cache flags are dirty
Date: Thu, 27 Sep 2018 18:14:37 +0000
Message-Id: <20180927181437.26284-1-stanhu@gmail.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a file is opened on one host before it is renamed or unlinked on another,
an NFS 4.0 client will continue to use the original file handle. On some NFS
servers (e.g. Isilon), this can cause "Stale file errors" until the original
file is closed or the directory cache is refreshed.

Note that this problem does not occur with an NFS 4.1 client since the
revalidation will always occur because the NFS_CAP_ATOMIC_OPEN_V1 flag is
enabled.
---
 fs/nfs/dir.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 8bfaa658b2c1..25259b0b41f9 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1626,6 +1626,9 @@ static int nfs4_lookup_revalidate(struct dentry *dentry, unsigned int flags)
 	/* We cannot do exclusive creation on a positive dentry */
 	if (flags & LOOKUP_EXCL)
 		goto no_open;
+	/* Revalidate if any cache flags are dirty */
+	if (NFS_I(inode)->cache_validity)
+		goto no_open;
 
 	/* Let f_op->open() actually open (and revalidate) the file */
 	ret = 1;
-- 
2.16.2
