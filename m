Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:28644 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752045Ab1FMULv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 13 Jun 2011 16:11:51 -0400
From: andros@netapp.com
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH Bakeathon 2/2] NFSv4.1: File layout only supports whole file layouts
Date: Mon, 13 Jun 2011 16:11:46 -0400
Message-Id: <1307995906-4177-2-git-send-email-andros@netapp.com>
In-Reply-To: <1307995906-4177-1-git-send-email-andros@netapp.com>
References: <1307995906-4177-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    6 ++++++
 1 files changed, 6 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index 3a8bd92..ada6ce1 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -427,6 +427,12 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 
 	dprintk("--> %s\n", __func__);
 
+	if (fl->generic_hdr.pls_range.offset != 0 ||
+	    fl->generic_hdr.pls_range.length != NFS4_MAX_UINT64) {
+		dprintk("%s Only whole file layouts supported. Use MDS.\n",
+			__func__);
+		goto out;
+	}
 	if (fl->pattern_offset > lgr->range.offset) {
 		dprintk("%s pattern_offset %lld too large\n",
 				__func__, fl->pattern_offset);
-- 
1.7.3.1

