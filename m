Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f193.google.com ([209.85.223.193]:44965 "EHLO
        mail-io0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965557AbeF0SSx (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 27 Jun 2018 14:18:53 -0400
Received: by mail-io0-f193.google.com with SMTP id g7-v6so2758592ioh.11
        for <linux-nfs@vger.kernel.org>; Wed, 27 Jun 2018 11:18:53 -0700 (PDT)
Received: from leira.trondhjem.org.localdomain ([50.105.87.45])
        by smtp.gmail.com with ESMTPSA id x5-v6sm2105233ioa.65.2018.06.27.11.18.51
        for <linux-nfs@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 27 Jun 2018 11:18:52 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 3/5] pNFS: Ignore non-recalled layouts in pnfs_layout_need_return()
Date: Wed, 27 Jun 2018 14:18:26 -0400
Message-Id: <20180627181828.27680-3-trond.myklebust@hammerspace.com>
In-Reply-To: <20180627181828.27680-2-trond.myklebust@hammerspace.com>
References: <20180627181828.27680-1-trond.myklebust@hammerspace.com>
 <20180627181828.27680-2-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

If a layout has been recalled, then we should fire off a layoutreturn as
soon as all the layout segments that match the recall have been retired.

Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/pnfs.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 17776ef734d7..bf7f0b21066d 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1160,12 +1160,21 @@ static bool
 pnfs_layout_need_return(struct pnfs_layout_hdr *lo)
 {
 	struct pnfs_layout_segment *s;
+	enum pnfs_iomode iomode;
+	u32 seq;
 
 	if (!test_bit(NFS_LAYOUT_RETURN_REQUESTED, &lo->plh_flags))
 		return false;
 
-	/* Defer layoutreturn until all lsegs are done */
+	seq = lo->plh_return_seq;
+	iomode = lo->plh_return_iomode;
+
+	/* Defer layoutreturn until all recalled lsegs are done */
 	list_for_each_entry(s, &lo->plh_segs, pls_list) {
+		if (seq && pnfs_seqid_is_newer(s->pls_seq, seq))
+			continue;
+		if (iomode != IOMODE_ANY && s->pls_range.iomode != iomode)
+			continue;
 		if (test_bit(NFS_LSEG_LAYOUTRETURN, &s->pls_flags))
 			return false;
 	}
-- 
2.17.1

