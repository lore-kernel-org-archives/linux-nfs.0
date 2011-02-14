Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41287 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752333Ab1BNTSn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 14 Feb 2011 14:18:43 -0500
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 02/16] NFS put_layout_hdr can remove nfsi->layout
Date: Mon, 14 Feb 2011 14:18:22 -0500
Message-Id: <1297711116-3139-3-git-send-email-andros@netapp.com>
In-Reply-To: <1297711116-3139-1-git-send-email-andros@netapp.com>
References: <1297711116-3139-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Prevents an Oops triggered by CB_LAYOUTRECALL and LAYOUTGET race on a
pnfs_layout_hdr first pnfs_layout_segment.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 0f5b66f..7d031cd 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -768,7 +768,7 @@ pnfs_update_layout(struct inode *ino,
 	put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->plh_flags, lseg);
+		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
-- 
1.7.2.3

