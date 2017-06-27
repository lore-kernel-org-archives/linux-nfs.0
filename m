Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([65.50.211.133]:53180 "EHLO
        bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751483AbdF0PoI (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Tue, 27 Jun 2017 11:44:08 -0400
From: Christoph Hellwig <hch@lst.de>
To: trond.myklebust@primarydata.com
Cc: jlayton@poochiereds.net, linux-nfs@vger.kernel.org
Subject: [PATCH 1/4] nfs: replace d_add with d_splice_alias in atomic_open
Date: Tue, 27 Jun 2017 08:44:00 -0700
Message-Id: <20170627154403.20944-2-hch@lst.de>
In-Reply-To: <20170627154403.20944-1-hch@lst.de>
References: <20170627154403.20944-1-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Peng Tao <tao.peng@primarydata.com>

It's a trival change but follows knfsd export document that asks
for d_splice_alias during lookup.

Signed-off-by: Peng Tao <tao.peng@primarydata.com>
---
 fs/nfs/dir.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 32ccd7754f8a..0296c06dcdc5 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1512,7 +1512,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
 		d_drop(dentry);
 		switch (err) {
 		case -ENOENT:
-			d_add(dentry, NULL);
+			d_splice_alias(NULL, dentry);
 			nfs_set_verifier(dentry, nfs_save_change_attribute(dir));
 			break;
 		case -EISDIR:
-- 
2.11.0

