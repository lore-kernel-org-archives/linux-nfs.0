Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:35813 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751042AbbHQSD0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 17 Aug 2015 14:03:26 -0400
Received: by pacgr6 with SMTP id gr6so113278318pac.2
        for <linux-nfs@vger.kernel.org>; Mon, 17 Aug 2015 11:03:26 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFS: nfs_set_pgio_error sometimes misses errors
Date: Mon, 17 Aug 2015 13:03:23 -0500
Message-Id: <1439834603-6897-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We should ensure that we always set the pgio_header's error field
if a READ or WRITE RPC call returns an error. The current code depends
on 'hdr->good_bytes' always being initialised to a large value, which
is not always done correctly by callers.
When this happens, applications may end up missing important errors.

Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/pagelist.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index 4984bbe55ff1..7c5718ba625e 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -77,8 +77,8 @@ EXPORT_SYMBOL_GPL(nfs_pgheader_init);
 void nfs_set_pgio_error(struct nfs_pgio_header *hdr, int error, loff_t pos)
 {
 	spin_lock(&hdr->lock);
-	if (pos < hdr->io_start + hdr->good_bytes) {
-		set_bit(NFS_IOHDR_ERROR, &hdr->flags);
+	if (!test_and_set_bit(NFS_IOHDR_ERROR, &hdr->flags)
+	    || pos < hdr->io_start + hdr->good_bytes) {
 		clear_bit(NFS_IOHDR_EOF, &hdr->flags);
 		hdr->good_bytes = pos - hdr->io_start;
 		hdr->error = error;
-- 
2.4.3

