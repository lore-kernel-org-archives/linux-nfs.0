Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:47372 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933913AbaH0PSE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 27 Aug 2014 11:18:04 -0400
From: <bjschuma@netapp.com>
To: <bfields@fieldses.org>
CC: <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/3] NFSD: Update error codes
Date: Wed, 27 Aug 2014 11:17:56 -0400
Message-ID: <1409152678-7806-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
References: <1409152678-7806-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Anna Schumaker <Anna.Schumaker@netapp.com>

Recent NFS v4.2 drafts have removed NFS4ERR_METADATA_NOTSUPP and
reassigned the error code to NFS4ERR_UNION_NOTSUPP.

I also add in the NFS4ERR_OFFLOAD_NO_REQS error code.

Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfsd/nfsd.h       | 2 +-
 include/linux/nfs4.h | 3 ++-
 2 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 847daf3..747f3b95 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -251,7 +251,7 @@ void		nfsd_lockd_shutdown(void);
 #define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
 #define nfserr_partner_notsupp		cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
 #define nfserr_partner_no_auth		cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
-#define nfserr_metadata_notsupp		cpu_to_be32(NFS4ERR_METADATA_NOTSUPP)
+#define nfserr_union_notsupp		cpu_to_be32(NFS4ERR_UNION_NOTSUPP)
 #define nfserr_offload_denied		cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
 #define nfserr_wrong_lfs		cpu_to_be32(NFS4ERR_WRONG_LFS)
 #define nfserr_badlabel		cpu_to_be32(NFS4ERR_BADLABEL)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index a1e3064..79b2a0f 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -235,10 +235,11 @@ enum nfsstat4 {
 	/* nfs42 */
 	NFS4ERR_PARTNER_NOTSUPP	= 10088,
 	NFS4ERR_PARTNER_NO_AUTH	= 10089,
-	NFS4ERR_METADATA_NOTSUPP = 10090,
+	NFS4ERR_UNION_NOTSUPP = 10090,
 	NFS4ERR_OFFLOAD_DENIED = 10091,
 	NFS4ERR_WRONG_LFS = 10092,
 	NFS4ERR_BADLABEL = 10093,
+	NFS4ERR_OFFLOAD_NO_REQS = 10094,
 };
 
 static inline bool seqid_mutating_err(u32 err)
-- 
2.1.0

