From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 19/51] nfsd41: add OPEN4_SHARE_ACCESS_WANT nfs4_stateid bmap
Date: Mon, 10 Nov 2008 22:47:09 +0200
Message-ID: <1226350029-10810-1-git-send-email-bhalevy@panasas.com>
References: <491895A0.3040809@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: " J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:44747 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751484AbYKJUrV (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:47:21 -0500
In-Reply-To: <491895A0.3040809@panasas.com>
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
index b772469..db79c0c 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -1186,7 +1186,8 @@ init_stateid(struct nfs4_stateid *stp, struct nfs4_file *fp, struct nfsd4_open *
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
1.6.0.2

