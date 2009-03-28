From: Benny Halevy <bhalevy@panasas.com>
Subject: [PATCH v2 31/47] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
Date: Sat, 28 Mar 2009 11:33:48 +0300
Message-ID: <1238229228-11236-1-git-send-email-bhalevy@panasas.com>
References: <49CDDFC2.4070402@panasas.com>
Cc: linux-nfs@vger.kernel.org, pnfs@linux-nfs.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:18266 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756375AbZC1Idy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 28 Mar 2009 04:33:54 -0400
In-Reply-To: <49CDDFC2.4070402@panasas.com>
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

