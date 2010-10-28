Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:32993 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752521Ab0J1MR4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 28 Oct 2010 08:17:56 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20])
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1PBRQZ-0000nv-1f
	for linux-nfs@vger.kernel.org; Thu, 28 Oct 2010 08:17:55 -0400
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: [PATCH] [bz 192] Fixed Regression in NFS Direct I/O path
Date: Thu, 28 Oct 2010 08:17:54 -0400
Message-Id: <1288268274-9444-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A typo, introduced by commit f11ac8db, in the nfs_direct_write()
routine causes writes with O_DIRECT set to fail with a ENOMEM error.

Found-by: Jeff Layton <jlayton@redhat.com>
Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/direct.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index 064a809..84d3c8b 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -873,7 +873,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	dreq->inode = inode;
 	dreq->ctx = get_nfs_open_context(nfs_file_open_context(iocb->ki_filp));
 	dreq->l_ctx = nfs_get_lock_context(dreq->ctx);
-	if (dreq->l_ctx != NULL)
+	if (dreq->l_ctx == NULL)
 		goto out_release;
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
-- 
1.7.2.3

