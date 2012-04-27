Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:20489 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849Ab2D0VpL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Apr 2012 17:45:11 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Version 4 01/13] NFSv4.1 do not send LAYOUTRETURN when there are no layout segments
Date: Fri, 27 Apr 2012 17:53:41 -0400
Message-Id: <1335563633-7191-2-git-send-email-andros@netapp.com>
In-Reply-To: <1335563633-7191-1-git-send-email-andros@netapp.com>
References: <1335563633-7191-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 5e11557..463eb2f 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -657,7 +657,7 @@ _pnfs_return_layout(struct inode *ino)
 
 	spin_lock(&ino->i_lock);
 	lo = nfsi->layout;
-	if (!lo) {
+	if (!lo || list_empty(&lo->plh_segs)) {
 		spin_unlock(&ino->i_lock);
 		dprintk("%s: no layout to return\n", __func__);
 		return status;
-- 
1.7.6.4

