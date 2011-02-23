From: Jim Rees <rees@umich.edu>
Subject: [PATCH] typo
Date: Tue, 22 Feb 2011 19:31:57 -0500
Message-ID: <20110223003157.GA8716@merit.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org, peter honeyman <honey@citi.umich.edu>
To: Benny Halevy <bhalevy@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from int-mailstore01.merit.edu ([207.75.116.232]:34343 "EHLO
	int-mailstore01.merit.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751525Ab1BWAb6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 22 Feb 2011 19:31:58 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jim Rees <rees@umich.edu>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 91fe4d0..e3e69d6 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -281,7 +281,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 
 	if (fl->pattern_offset > lgr->range.offset) {
-		dprintk("%s pattern_offset %lld to large\n",
+		dprintk("%s pattern_offset %lld too large\n",
 				__func__, fl->pattern_offset);
 		goto out;
 	}
-- 
1.7.1
