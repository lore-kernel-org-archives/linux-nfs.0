From: andros@netapp.com
Subject: [PATCH 08/16] SQUASHME pnfs-submit: don't reference the layout in init_lseg
Date: Wed,  7 Jul 2010 18:34:15 -0400
Message-ID: <1278542063-4009-9-git-send-email-andros@netapp.com>
References: <1278542063-4009-1-git-send-email-andros@netapp.com>
 <1278542063-4009-2-git-send-email-andros@netapp.com>
 <1278542063-4009-3-git-send-email-andros@netapp.com>
 <1278542063-4009-4-git-send-email-andros@netapp.com>
 <1278542063-4009-5-git-send-email-andros@netapp.com>
 <1278542063-4009-6-git-send-email-andros@netapp.com>
 <1278542063-4009-7-git-send-email-andros@netapp.com>
 <1278542063-4009-8-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:43252 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754820Ab0GGWe2 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 7 Jul 2010 18:34:28 -0400
In-Reply-To: <1278542063-4009-8-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

The layout is referenced when the layout segment is inserted into the cache.

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 18ebde9..118d34c 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -402,7 +402,6 @@ init_lseg(struct pnfs_layout_type *lo, struct pnfs_layout_segment *lseg)
 	kref_init(&lseg->kref);
 	lseg->valid = true;
 	lseg->layout = lo;
-	get_layout(lo);
 }
 
 static void
-- 
1.6.6

