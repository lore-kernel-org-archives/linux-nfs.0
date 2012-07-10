Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:54149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756130Ab2GJQHu (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 12:07:50 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>, stable@kernel.org
Subject: [PATCH 4/7] nfsd4: our filesystems are normally case sensitive
Date: Tue, 10 Jul 2012 12:07:43 -0400
Message-Id: <1341936466-3821-5-git-send-email-bfields@redhat.com>
In-Reply-To: <1341936466-3821-1-git-send-email-bfields@redhat.com>
References: <1341936466-3821-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

Actually, xfs can optionally be case insensitive; we'll handle that case
in later patches.

Cc: stable@kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4949667..6322df3 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2259,7 +2259,7 @@ out_acl:
 	if (bmval0 & FATTR4_WORD0_CASE_INSENSITIVE) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		WRITE32(1);
+		WRITE32(0);
 	}
 	if (bmval0 & FATTR4_WORD0_CASE_PRESERVING) {
 		if ((buflen -= 4) < 0)
-- 
1.7.9.5

