Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:15866 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751779Ab1FOScF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 15 Jun 2011 14:32:05 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] nfs4.1: mark layout as bad on error path in _pnfs_return_layout
Date: Wed, 15 Jun 2011 14:32:02 -0400
Message-Id: <1308162722-16248-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index ebac718..dec239f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -658,6 +658,8 @@ _pnfs_return_layout(struct inode *ino)
 	lrp = kzalloc(sizeof(*lrp), GFP_KERNEL);
 	if (unlikely(lrp == NULL)) {
 		status = -ENOMEM;
+		set_bit(NFS_LAYOUT_RW_FAILED, &lo->plh_flags);
+		set_bit(NFS_LAYOUT_RO_FAILED, &lo->plh_flags);
 		put_layout_hdr(lo);
 		goto out;
 	}
-- 
1.7.2.1

