From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH 32/47] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
Date: Fri, 27 Mar 2009 06:18:02 +0300
Message-ID: <1238123882-7928-1-git-send-email-bhalevy@panasas.com>
References: <49CC40E5.2080506@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org,
	Andy Adamson <andros@netapp.com>,
	Benny Halevy <bhalevy@panasas.com>
To: " J. Bruce Fields" <bfields@citi.umich.edu>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:23402 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756156AbZC0DSH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Mar 2009 23:18:07 -0400
In-Reply-To: <49CC40E5.2080506@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

Separate the access bits from the want bits and enable __set_bit to
work correctly with st_access_bmap.

Signed-off-by: Andy Adamson<andros@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfsd/nfs4state.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index dbf0d07..8a64981 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1905,7 +1905,8 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
 	stp->st_stateid.si_generation = 0;
 	stp->st_access_bmap = 0;
 	stp->st_deny_bmap = 0;
-	__set_bit(open->op_share_access, &stp->st_access_bmap);
+	__set_bit(open->op_share_access & ~NFS4_SHARE_WANT_MASK,
+		  &stp->st_access_bmap);
 	__set_bit(open->op_share_deny, &stp->st_deny_bmap);
 	stp->st_openstp = NULL;
 }
-- 
1.6.2.1

