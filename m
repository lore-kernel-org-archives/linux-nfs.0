Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wi0-f169.google.com ([209.85.212.169]:41099 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754407Ab3EKCm4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 10 May 2013 22:42:56 -0400
Received: by mail-wi0-f169.google.com with SMTP id h11so1324596wiv.2
        for <linux-nfs@vger.kernel.org>; Fri, 10 May 2013 19:42:55 -0700 (PDT)
Received: from bhalevy-lt.il.tonian.com (bzq-79-180-144-28.red.bezeqint.net. [79.180.144.28])
        by mx.google.com with ESMTPSA id cw8sm1187470wib.7.2013.05.10.19.42.54
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 10 May 2013 19:42:55 -0700 (PDT)
From: Benny Halevy <bhalevy@tonian.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 06/38] Revert "pnfsd: nfs4_preprocess_pnfs_ds_stateid"
Date: Sat, 11 May 2013 05:42:50 +0300
Message-Id: <1368240170-31954-1-git-send-email-bhalevy@tonian.com>
In-Reply-To: <518B6377.3000207@tonian.com>
References: <518B6377.3000207@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This reverts commit 83d662282b879bc018b8a48229d67218d45b16fa.

Conflicts:
	fs/nfsd/state.h
---
 fs/nfsd/nfs4state.c | 12 ++----------
 fs/nfsd/state.h     |  2 --
 2 files changed, 2 insertions(+), 12 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 84fa1af..b404d33 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -3551,16 +3551,8 @@ __be32 nfsd4_lookup_stateid(stateid_t *stateid, unsigned char typemask,
 	if (grace_disallows_io(net, ino))
 		return nfserr_grace;
 
-#if defined(CONFIG_PNFSD)
-	if (pnfs_fh_is_ds(&current_fh->fh_handle)) {
-		if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
-			status = nfserr_bad_stateid;
-		else
-			status = nfs4_preprocess_pnfs_ds_stateid(current_fh,
-								 stateid);
-		goto out;
-	}
-#endif /* CONFIG_PNFSD */
+	if (pnfs_fh_is_ds(&current_fh->fh_handle))
+		return 0;
 
 	if (ZERO_STATEID(stateid) || ONE_STATEID(stateid))
 		return check_special_stateids(net, current_fh, stateid, flags);
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 31d5d0f..788e5e8 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -531,8 +531,6 @@ extern struct nfs4_client_reclaim *nfs4_client_to_reclaim(const char *name,
 extern void pnfs_expire_client(struct nfs4_client *);
 extern void release_pnfs_ds_dev_list(struct nfs4_ol_stateid *);
 extern void nfs4_pnfs_state_init(void);
-extern void nfs4_ds_get_verifier(stateid_t *, struct super_block *, u32 *);
-extern int nfs4_preprocess_pnfs_ds_stateid(struct svc_fh *, stateid_t *);
 extern void pnfsd_roc(struct nfs4_client *clp, struct nfs4_file *fp);
 #else /* CONFIG_PNFSD */
 static inline void nfsd4_free_pnfs_slabs(void) {}
-- 
1.7.11.7

