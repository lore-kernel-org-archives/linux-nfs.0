Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:1570 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756742Ab1CATZy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 1 Mar 2011 14:25:54 -0500
From: andros@netapp.com
To: bhalevy@panasas.com
Cc: linux-nfs@vger.kernel.org, Fred Isaman <iisaman@netapp.com>
Subject: [PATCH pnfs-submit-wave3 update 4/5] wave3: clean up lseg after pg_doio function
Date: Tue,  1 Mar 2011 14:25:33 -0500
Message-Id: <1299007534-4105-5-git-send-email-andros@netapp.com>
In-Reply-To: <1299007534-4105-4-git-send-email-andros@netapp.com>
References: <1299007534-4105-1-git-send-email-andros@netapp.com>
 <1299007534-4105-2-git-send-email-andros@netapp.com>
 <1299007534-4105-3-git-send-email-andros@netapp.com>
 <1299007534-4105-4-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Fred Isaman <iisaman@netapp.com>

nfs_pageio_doio can be repeatedly triggered, in which case
it is possible for an lseg which has already been put to be
used and put again without matching gets.

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/pagelist.c |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/pagelist.c b/fs/nfs/pagelist.c
index b49cb4b..45b0fb8 100644
--- a/fs/nfs/pagelist.c
+++ b/fs/nfs/pagelist.c
@@ -318,6 +318,7 @@ static void nfs_pageio_doio(struct nfs_pageio_descriptor *desc)
 					  desc->pg_count,
 					  desc->pg_ioflags,
 					  desc->pg_lseg);
+		desc->pg_lseg = NULL;
 		if (error < 0)
 			desc->pg_error = error;
 		else
-- 
1.6.2.5

