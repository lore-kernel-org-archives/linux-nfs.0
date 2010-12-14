Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:11394 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758041Ab0LNWDF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Dec 2010 17:03:05 -0500
Received: from localhost.localdomain (vpn2ntap-71744.hq.netapp.com [10.58.57.236])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBEM32oe010255
	for <linux-nfs@vger.kernel.org>; Tue, 14 Dec 2010 14:03:04 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 2/3] pnfs-submit: wave2: Remove smp barrier in get_layout_hdr
Date: Tue, 14 Dec 2010 17:02:59 -0500
Message-Id: <1292364180-28512-3-git-send-email-iisaman@netapp.com>
In-Reply-To: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
References: <1292364180-28512-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Trond points out that, since this is always called inside some
spinlock, the barrier is not necessay.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index c22e439..b815e3e 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -237,7 +237,6 @@ void
 get_layout_hdr(struct pnfs_layout_hdr *lo)
 {
 	atomic_inc(&lo->plh_refcount);
-	smp_mb__after_atomic_inc();
 }
 
 static void
-- 
1.7.2.1

