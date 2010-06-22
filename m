From: andros@netapp.com
Subject: [PATCH 3/8] SQUASHME pnfs-submit: tell commit to use the MDS
Date: Tue, 22 Jun 2010 17:56:33 -0400
Message-ID: <1277243798-8181-4-git-send-email-andros@netapp.com>
References: <1277243798-8181-1-git-send-email-andros@netapp.com>
 <1277243798-8181-2-git-send-email-andros@netapp.com>
 <1277243798-8181-3-git-send-email-andros@netapp.com>
Cc: linux-nfs@vger.kernel.org, Andy Adamson <andros@netapp.com>
To: bhalevy@panasas.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:36643 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751811Ab0FVV4f (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 22 Jun 2010 17:56:35 -0400
In-Reply-To: <1277243798-8181-3-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 fs/nfs/pnfs.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
index 9a295cf..c1a8066 100644
--- a/fs/nfs/pnfs.c
+++ b/fs/nfs/pnfs.c
@@ -1454,6 +1454,7 @@ pnfs_writepages(struct nfs_write_data *wdata, int how)
 							wdata);
 
 	if (trypnfs == PNFS_NOT_ATTEMPTED) {
+		wdata->req->wb_lseg = NULL;
 		wdata->pdata.lseg = NULL;
 		put_lseg(lseg);
 	}
-- 
1.6.6

