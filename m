Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:23188 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751646Ab1FNN5B (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 09:57:01 -0400
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Fred Isaman <iisaman@netapp.com>
Subject: [PATCH 1/1] nfs4.1: pnfs_find_lseg only looks at first element in list
Date: Tue, 14 Jun 2011 09:56:28 -0400
Message-Id: <1308059788-17381-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

The break condition to skip out of the loop if we've gone too far was
reversed, causing the function to abort after looking at the first
list entry.

Reported-by: Peng Tao <peng_tao@emc.com>
Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pnfs.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 1abb300..c640f91 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -895,7 +895,7 @@ pnfs_find_lseg(struct pnfs_layout_hdr *lo,
 			ret = get_lseg(lseg);
 			break;
 		}
-		if (cmp_layout(range, &lseg->pls_range) > 0)
+		if (cmp_layout(range, &lseg->pls_range) < 0)
 			break;
 	}
 
-- 
1.7.2.1

