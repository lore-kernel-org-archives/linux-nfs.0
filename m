Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:35616 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751404Ab1FNUaS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 14 Jun 2011 16:30:18 -0400
Received: by iwn34 with SMTP id 34so4970768iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 14 Jun 2011 13:30:18 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, iisaman@netapp.com,
        Benny Halevy <benny@tonian.com>
Subject: [PATCH] NFSv4.1: fix break condition in pnfs_find_lseg
Date: Tue, 14 Jun 2011 16:30:16 -0400
Message-Id: <1308083416-22126-1-git-send-email-benny@tonian.com>
In-Reply-To: <4DF77254.2090608@gmail.com>
References: <4DF77254.2090608@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The break condition to skip out of the loop got broken when cmp_layout
was change.  Essentially, we want to stop looking once we know no layout
on the remainder of the list can match the first byte of the looked-up
range.

Reported-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 08c115d..b3994e1 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -895,7 +895,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 			ret = get_lseg(lseg);
 			break;
 		}
-		if (cmp_layout(range, &lseg->pls_range) > 0)
+		if (lseg->pls_range.offset > range->offset)
 			break;
 	}
 
-- 
1.7.4.4

