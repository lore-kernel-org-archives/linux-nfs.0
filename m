Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50750 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab1E2SRD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:17:03 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Cc: Jim Rees <rees@umich.edu>
Subject: [PATCH 01/32] NFSv4.1: fix typo in filelayout_check_layout
Date: Sun, 29 May 2011 21:16:51 +0300
Message-Id: <1306693011-7731-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DE28CFB.4060608@panasas.com>
References: <4DE28CFB.4060608@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Jim Rees <rees@umich.edu>

Signed-off-by: Jim Rees <rees@umich.edu>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/nfs4filelayout.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4filelayout.c b/fs/nfs/nfs4filelayout.c
index be79dc9..dd6ccf0 100644
--- a/fs/nfs/nfs4filelayout.c
+++ b/fs/nfs/nfs4filelayout.c
@@ -428,7 +428,7 @@ filelayout_check_layout(struct pnfs_layout_hdr *lo,
 	dprintk("--> %s\n", __func__);
 
 	if (fl->pattern_offset > lgr->range.offset) {
-		dprintk("%s pattern_offset %lld to large\n",
+		dprintk("%s pattern_offset %lld too large\n",
 				__func__, fl->pattern_offset);
 		goto out;
 	}
-- 
1.7.2.3

