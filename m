Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:28028 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756817Ab3KLWpU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Nov 2013 17:45:20 -0500
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 1/3] NFSD: Update error codes
Date: Tue, 12 Nov 2013 14:04:06 -0500
Message-ID: <1384283048-7699-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
References: <1384283048-7699-1-git-send-email-bjschuma@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recent NFS v4.2 drafts have removed NFS4ERR_METADATA_NOTSUPP and
reassigned the error code to NFS4ERR_UNION_NOTSUPP.

Signed-off-by: Anna Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfsd.h       | 2 +-
 include/linux/nfs4.h | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 30f34ab..4fe49e9 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -244,7 +244,7 @@ void		nfsd_lockd_shutdown(void);
 #define nfserr_deleg_revoked		cpu_to_be32(NFS4ERR_DELEG_REVOKED)
 #define nfserr_partner_notsupp		cpu_to_be32(NFS4ERR_PARTNER_NOTSUPP)
 #define nfserr_partner_no_auth		cpu_to_be32(NFS4ERR_PARTNER_NO_AUTH)
-#define nfserr_metadata_notsupp		cpu_to_be32(NFS4ERR_METADATA_NOTSUPP)
+#define nfserr_union_notsupp		cpu_to_be32(NFS4ERR_UNION_NOTSUPP)
 #define nfserr_offload_denied		cpu_to_be32(NFS4ERR_OFFLOAD_DENIED)
 #define nfserr_wrong_lfs		cpu_to_be32(NFS4ERR_WRONG_LFS)
 #define nfserr_badlabel		cpu_to_be32(NFS4ERR_BADLABEL)
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 9577769..6d79deb 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -235,7 +235,7 @@ enum nfsstat4 {
 	/* nfs42 */
 	NFS4ERR_PARTNER_NOTSUPP	= 10088,
 	NFS4ERR_PARTNER_NO_AUTH	= 10089,
-	NFS4ERR_METADATA_NOTSUPP = 10090,
+	NFS4ERR_UNION_NOTSUPP = 10090,
 	NFS4ERR_OFFLOAD_DENIED = 10091,
 	NFS4ERR_WRONG_LFS = 10092,
 	NFS4ERR_BADLABEL = 10093,
-- 
1.8.4.2

