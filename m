Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:34111 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752703AbcLaNSR (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 31 Dec 2016 08:18:17 -0500
Received: by mail-pg0-f66.google.com with SMTP id b1so25086859pgc.1
        for <linux-nfs@vger.kernel.org>; Sat, 31 Dec 2016 05:18:17 -0800 (PST)
To: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFSD: only support readonly export for !fsync and readonly
 filesystem
Cc: Christoph Hellwig <hch@infradead.org>,
        Steve Dickson <SteveD@redhat.com>, kinglongmee@gmail.com
Message-ID: <960d206f-3cb5-b60e-5245-d7282dabf664@gmail.com>
Date: Sat, 31 Dec 2016 21:18:08 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit fae5096ad217
"nfsd: assume writeable exportabled filesystems have f_sync"
have remove the checking of f_sync.

Christoph Hellwig suggests,
"Warn and refuse the writable export."

I think just covert to a readonly export for !fsync filesystem,
also, for a readonly filesystem is reasonable.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfsd/export.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/fs/nfsd/export.c b/fs/nfsd/export.c
index 43e109c..3ec3b6b 100644
--- a/fs/nfsd/export.c
+++ b/fs/nfsd/export.c
@@ -358,6 +358,18 @@ static int check_export(struct inode *inode, int *flags, unsigned char *uuid)
 	if (*flags & NFSEXP_V4ROOT)
 		*flags |= NFSEXP_READONLY;
 
+	/*
+	 * Convert to a readonly export for that,
+	 * 1. not supported fsync filesystem,
+	 * 2. readonly filesystem.
+	 */
+	if ((!inode->i_fop->fsync || IS_RDONLY(inode))
+	    && !(*flags & NFSEXP_READONLY)) {
+		dprintk("exp_export: Only support readonly export "
+			"for fsync unsupported or readonly filesystem.\n");
+		*flags |= NFSEXP_READONLY;
+	}
+
 	/* There are two requirements on a filesystem to be exportable.
 	 * 1:  We must be able to identify the filesystem from a number.
 	 *       either a device number (so FS_REQUIRES_DEV needed)
-- 
2.9.3

