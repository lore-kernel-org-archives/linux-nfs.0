Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:60903 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932285Ab3J1O5d (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 28 Oct 2013 10:57:33 -0400
From: Anna Schumaker <bjschuma@netapp.com>
To: <bfields@fieldses.org>, <linux-nfs@vger.kernel.org>
Subject: [PATCH 1/4] NFSD: Update error codes
Date: Mon, 28 Oct 2013 10:57:23 -0400
Message-ID: <1382972247-1108-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
References: <1382972247-1108-1-git-send-email-bjschuma@netapp.com>
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
index e36dee5..a92e065 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -232,7 +232,7 @@ enum nfsstat4 {
 	/* nfs42 */
 	NFS4ERR_PARTNER_NOTSUPP	= 10088,
 	NFS4ERR_PARTNER_NO_AUTH	= 10089,
-	NFS4ERR_METADATA_NOTSUPP = 10090,
+	NFS4ERR_UNION_NOTSUPP = 10090,
 	NFS4ERR_OFFLOAD_DENIED = 10091,
 	NFS4ERR_WRONG_LFS = 10092,
 	NFS4ERR_BADLABEL = 10093,
-- 
1.8.4.1

