Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60987 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab1BEXNH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 5 Feb 2011 18:13:07 -0500
Received: by fxm20 with SMTP id 20so3673775fxm.19
        for <linux-nfs@vger.kernel.org>; Sat, 05 Feb 2011 15:13:05 -0800 (PST)
Date: Sun, 6 Feb 2011 02:13:01 +0300
From: Stanislav Fomichev <kernel@fomichev.me>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: add kmalloc return value check in decode_and_add_ds
Message-ID: <4d4dd980.114ddf0a.1d17.3cc9@mx.google.com>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

add kmalloc return value check in decode_and_add_ds

Signed-off-by: Stanislav Fomichev <kernel@fomichev.me>
---
 fs/nfs/nfs4filelayoutdev.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index f5c9b12..b73c343 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -219,6 +219,10 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 		goto out_err;
 	}
 	buf = kmalloc(rlen + 1, GFP_KERNEL);
+	if (!buf) {
+		dprintk("%s: Not enough memory\n", __func__);
+		goto out_err;
+	}
 	buf[rlen] = '\0';
 	memcpy(buf, r_addr, rlen);
 
-- 
1.7.1
