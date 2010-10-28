Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63362 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751707Ab0J1EoN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 00:44:13 -0400
Date: Thu, 28 Oct 2010 06:44:03 +0200
From: Dan Carpenter <error27@gmail.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org
Subject: [patch] nfs: check kmalloc() return
Message-ID: <20101028044403.GV6062@bicker>
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The decode_and_add_ds() should return NULL on failure.

Signed-off-by: Dan Carpenter <error27@gmail.com>

diff --git a/fs/nfs/nfs4filelayoutdev.c b/fs/nfs/nfs4filelayoutdev.c
index 51fe64a..098113c 100644
--- a/fs/nfs/nfs4filelayoutdev.c
+++ b/fs/nfs/nfs4filelayoutdev.c
@@ -219,6 +219,8 @@ decode_and_add_ds(__be32 **pp, struct inode *inode)
 		goto out_err;
 	}
 	buf = kmalloc(rlen + 1, GFP_KERNEL);
+	if (!buf)
+		goto out_err;
 	buf[rlen] = '\0';
 	memcpy(buf, r_addr, rlen);
 
