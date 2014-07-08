Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f173.google.com ([209.85.216.173]:50919 "EHLO
	mail-qc0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754474AbaGHSEx (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Jul 2014 14:04:53 -0400
Received: by mail-qc0-f173.google.com with SMTP id l6so5542057qcy.4
        for <linux-nfs@vger.kernel.org>; Tue, 08 Jul 2014 11:04:53 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v4 013/100] nfsd: shrink st_access_bmap and st_deny_bmap
Date: Tue,  8 Jul 2014 14:03:01 -0400
Message-Id: <1404842668-22521-14-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
References: <1404842668-22521-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

We never use anything above bit #3, so an unsigned long for each is
wasteful. Shrink them to a char each, and add some WARN_ON_ONCE calls if
we try to set or clear bits that would go outside those sizes.

Note too that because atomic bitops work on unsigned longs, we have to
abandon their use here. That shouldn't be a problem though since we
don't really care about the atomicity in this code anyway. Using them
was just a convenient way to flip bits.

Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfs4state.c | 38 +++++++++++++++++++++++++++-----------
 fs/nfsd/state.h     |  4 ++--
 2 files changed, 29 insertions(+), 13 deletions(-)

diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
index 478f8f6d797e..c6fac2de7c95 100644
--- a/fs/nfsd/nfs4state.c
+++ b/fs/nfsd/nfs4state.c
@@ -729,42 +729,58 @@ test_share(struct nfs4_ol_stateid *stp, struct nfsd4_open *open) {
 static inline void
 set_access(u32 access, struct nfs4_ol_stateid *stp)
 {
-	__set_bit(access, &stp->st_access_bmap);
+	unsigned char mask = 1 << access;
+
+	WARN_ON_ONCE(access > NFS4_SHARE_ACCESS_BOTH);
+	stp->st_access_bmap |= mask;
 }
 
 /* clear share access for a given stateid */
 static inline void
 clear_access(u32 access, struct nfs4_ol_stateid *stp)
 {
-	__clear_bit(access, &stp->st_access_bmap);
+	unsigned char mask = 1 << access;
+
+	WARN_ON_ONCE(access > NFS4_SHARE_ACCESS_BOTH);
+	stp->st_access_bmap &= ~mask;
 }
 
 /* test whether a given stateid has access */
 static inline bool
 test_access(u32 access, struct nfs4_ol_stateid *stp)
 {
-	return test_bit(access, &stp->st_access_bmap);
+	unsigned char mask = 1 << access;
+
+	return (bool)(stp->st_access_bmap & mask);
 }
 
 /* set share deny for a given stateid */
 static inline void
-set_deny(u32 access, struct nfs4_ol_stateid *stp)
+set_deny(u32 deny, struct nfs4_ol_stateid *stp)
 {
-	__set_bit(access, &stp->st_deny_bmap);
+	unsigned char mask = 1 << deny;
+
+	WARN_ON_ONCE(deny > NFS4_SHARE_DENY_BOTH);
+	stp->st_deny_bmap |= mask;
 }
 
 /* clear share deny for a given stateid */
 static inline void
-clear_deny(u32 access, struct nfs4_ol_stateid *stp)
+clear_deny(u32 deny, struct nfs4_ol_stateid *stp)
 {
-	__clear_bit(access, &stp->st_deny_bmap);
+	unsigned char mask = 1 << deny;
+
+	WARN_ON_ONCE(deny > NFS4_SHARE_DENY_BOTH);
+	stp->st_deny_bmap &= ~mask;
 }
 
 /* test whether a given stateid is denying specific access */
 static inline bool
-test_deny(u32 access, struct nfs4_ol_stateid *stp)
+test_deny(u32 deny, struct nfs4_ol_stateid *stp)
 {
-	return test_bit(access, &stp->st_deny_bmap);
+	unsigned char mask = 1 << deny;
+
+	return (bool)(stp->st_deny_bmap & mask);
 }
 
 /* release all access and file references for a given stateid */
@@ -4284,12 +4300,12 @@ nfsd4_open_downgrade(struct svc_rqst *rqstp,
 		goto out; 
 	status = nfserr_inval;
 	if (!test_access(od->od_share_access, stp)) {
-		dprintk("NFSD: access not a subset current bitmap: 0x%lx, input access=%08x\n",
+		dprintk("NFSD: access not a subset of current bitmap: 0x%hhx, input access=%08x\n",
 			stp->st_access_bmap, od->od_share_access);
 		goto out;
 	}
 	if (!test_deny(od->od_share_deny, stp)) {
-		dprintk("NFSD:deny not a subset current bitmap: 0x%lx, input deny=%08x\n",
+		dprintk("NFSD: deny not a subset of current bitmap: 0x%hhx, input deny=%08x\n",
 			stp->st_deny_bmap, od->od_share_deny);
 		goto out;
 	}
diff --git a/fs/nfsd/state.h b/fs/nfsd/state.h
index 2ce1d8f583e1..fa6d28329c8a 100644
--- a/fs/nfsd/state.h
+++ b/fs/nfsd/state.h
@@ -408,8 +408,8 @@ struct nfs4_ol_stateid {
 	struct list_head              st_locks;
 	struct nfs4_stateowner      * st_stateowner;
 	struct nfs4_file            * st_file;
-	unsigned long                 st_access_bmap;
-	unsigned long                 st_deny_bmap;
+	unsigned char                 st_access_bmap;
+	unsigned char                 st_deny_bmap;
 	struct nfs4_ol_stateid         * st_openstp;
 };
 
-- 
1.9.3

