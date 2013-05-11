Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f180.google.com ([209.85.212.180]:59626 "EHLO
	mail-wi0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754337Ab3EKCmx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:42:53 -0400
Received: by mail-wi0-f180.google.com with SMTP id h11so1205879wiv.13
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:51 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id u17sm1176053wiv.8.2013.05.10.19.42.50
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:51 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 05/38] Revert "FIXME pnfsd: gfs2 temp turn off DS stateid processing."
Date: Sat, 11 May 2013 05:42:46 +0300
Message-Id: <1368240166-31910-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 9f47c0b97353c433f6c83a1bc665ea76eb12e25f.
---
 fs/nfsd/nfs4state.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index d2256d8..84fa1af 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3556,15 +3556,8 @@ __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 		if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 			status = nfserr_bad_stateid;
 		else
-#ifdef CONFIG_GFS2_FS_LOCKING_DLM
-		{
-			dprintk("%s Don't check DS stateid\n", __func__);
-			return 0;
-		}
-#else /* CONFIG_GFS2_FS_LOCKING_DLM */
 			status = nfs4_preprocess_pnfs_ds_stateid(current_fh,
 								 stateid);
-#endif /* CONFIG_GFS2_FS_LOCKING_DLM */
 		goto out;
 	}
 #endif /* CONFIG_PNFSD */
-- 
1.7.11.7

