Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:37391 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753870Ab0HSPaL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 19 Aug 2010 11:30:11 -0400
From: andros@netpp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
Subject: [PATCH 5/5] SQUASHME pnfs-submit: rename layoutget 4
Date: Thu, 19 Aug 2010 11:27:57 -0400
Message-Id: <1282231677-4412-6-git-send-email-andros@netpp.com>
In-Reply-To: <1282231677-4412-5-git-send-email-andros@netpp.com>
References: <1282231677-4412-1-git-send-email-andros@netpp.com>
 <1282231677-4412-2-git-send-email-andros@netpp.com>
 <1282231677-4412-3-git-send-email-andros@netpp.com>
 <1282231677-4412-4-git-send-email-andros@netpp.com>
 <1282231677-4412-5-git-send-email-andros@netpp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Andy Adamson <andros@netapp.com>

squash into pnfs_submit: filelayout layout segment alloc and free

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/nfs4filelayout.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index eb9c907..0cfa21c 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -385,7 +385,7 @@ static void filelayout_free_fh_array(struct nfs4_filelayout_segment *fl);
 static int
 filelayout_set_layout(struct nfs4_filelayout *flo,
 		      struct nfs4_filelayout_segment *fl,
-		      struct nfs4_pnfs_layoutget_res *lgr)
+		      struct nfs4_layoutget_res *lgr)
 {
 	uint32_t *p = (uint32_t *)lgr->layout.buf;
 	uint32_t nfl_util;
@@ -454,7 +454,7 @@ filelayout_set_layout(struct nfs4_filelayout *flo,
 
 static struct pnfs_layout_segment *
 filelayout_alloc_lseg(struct pnfs_layout_hdr *layoutid,
-		      struct nfs4_pnfs_layoutget_res *lgr)
+		      struct nfs4_layoutget_res *lgr)
 {
 	struct nfs4_filelayout *flo = FILE_LO(layoutid);
 	struct pnfs_layout_segment *lseg;
-- 
1.6.2.5

