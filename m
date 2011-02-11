Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:51329 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757855Ab1BKSAp (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Feb 2011 13:00:45 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 17/17] SQUASHME put_layout_hdr can remove nfsi->layout
Date: Thu, 10 Feb 2011 20:52:50 -0500
Message-Id: <1297389170-26702-18-git-send-email-andros@netapp.com>
In-Reply-To: <1297389170-26702-17-git-send-email-andros@netapp.com>
References: <1297389170-26702-1-git-send-email-andros@netapp.com>
 <1297389170-26702-2-git-send-email-andros@netapp.com>
 <1297389170-26702-3-git-send-email-andros@netapp.com>
 <1297389170-26702-4-git-send-email-andros@netapp.com>
 <1297389170-26702-5-git-send-email-andros@netapp.com>
 <1297389170-26702-6-git-send-email-andros@netapp.com>
 <1297389170-26702-7-git-send-email-andros@netapp.com>
 <1297389170-26702-8-git-send-email-andros@netapp.com>
 <1297389170-26702-9-git-send-email-andros@netapp.com>
 <1297389170-26702-10-git-send-email-andros@netapp.com>
 <1297389170-26702-11-git-send-email-andros@netapp.com>
 <1297389170-26702-12-git-send-email-andros@netapp.com>
 <1297389170-26702-13-git-send-email-andros@netapp.com>
 <1297389170-26702-14-git-send-email-andros@netapp.com>
 <1297389170-26702-15-git-send-email-andros@netapp.com>
 <1297389170-26702-16-git-send-email-andros@netapp.com>
 <1297389170-26702-17-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index dc15a76..912b1ff 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -799,7 +799,7 @@ pnfs_update_layout(struct inode *ino,
 	put_layout_hdr(lo);
 out:
 	dprintk("%s end, state 0x%lx lseg %p\n", __func__,
-		nfsi->layout->plh_flags, lseg);
+		nfsi->layout ? nfsi->layout->plh_flags : -1, lseg);
 	return lseg;
 out_unlock:
 	spin_unlock(&ino->i_lock);
-- 
1.6.6

