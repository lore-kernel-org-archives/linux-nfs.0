Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gx0-f174.google.com ([209.85.161.174]:44985 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab1JTCNd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 19 Oct 2011 22:13:33 -0400
Received: by ggnb1 with SMTP id b1so2306912ggn.19
        for <linux-nfs@vger.kernel.org>; Wed, 19 Oct 2011 19:13:32 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH 6/7] nfsd4: typo logical vs bitwise negate for want_mask
Date: Wed, 19 Oct 2011 19:13:29 -0700
Message-Id: <1319076809-13512-1-git-send-email-benny@tonian.com>
In-Reply-To: <4E9F82FC.2000904@tonian.com>
References: <4E9F82FC.2000904@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1a419c0..1a5cb7e 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -671,7 +671,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	default:
 		return nfserr_bad_xdr;
 	}
-	w &= !NFS4_SHARE_WANT_MASK;
+	w &= ~NFS4_SHARE_WANT_MASK;
 	if (!w)
 		return nfs_ok;
 	switch (w) {
-- 
1.7.6

