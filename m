Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-fx0-f46.google.com ([209.85.161.46]:40529 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754362Ab1J0SnI (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Oct 2011 14:43:08 -0400
Received: by faan17 with SMTP id n17so2949164faa.19
        for <linux-nfs@vger.kernel.org>; Thu, 27 Oct 2011 11:43:06 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: bfields@netapp.com
Cc: linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@tonian.com>
Subject: [PATCH] nfsd4: typo logical vs bitwise negate in nfsd4_decode_share_access
Date: Thu, 27 Oct 2011 20:43:01 +0200
Message-Id: <1319740981-3338-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Benny Halevy <bhalevy@tonian.com>

Signed-off-by: Benny Halevy <bhalevy@tonian.com>
---
 fs/nfsd/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 66d095d..b6fa792 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -655,7 +655,7 @@ static __be32 nfsd4_decode_share_access(struct nfsd4_compoundargs *argp, u32 *x)
 	default:
 		return nfserr_bad_xdr;
 	}
-	w &= !NFS4_SHARE_ACCESS_MASK;
+	w &= ~NFS4_SHARE_ACCESS_MASK;
 	if (!w)
 		return nfs_ok;
 	if (!argp->minorversion)
-- 
1.7.6

