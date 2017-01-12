Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:58250 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S934883AbdALCSI (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 11 Jan 2017 21:18:08 -0500
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/3] nfsd: constify nfsd_suppatttrs
Date: Wed, 11 Jan 2017 21:18:00 -0500
Message-Id: <1484187481-32723-2-git-send-email-bfields@redhat.com>
In-Reply-To: <1484187481-32723-1-git-send-email-bfields@redhat.com>
References: <1484187481-32723-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

To keep me from making that mistake again.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 2 +-
 fs/nfsd/nfsd.h    | 6 +++---
 2 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 048b06861f94..7a63d442042c 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -58,7 +58,7 @@
 
 #define NFSDDBG_FACILITY		NFSDDBG_XDR
 
-u32 nfsd_suppattrs[3][3] = {
+const u32 nfsd_suppattrs[3][3] = {
 	{NFSD4_SUPPORTED_ATTRS_WORD0,
 	 NFSD4_SUPPORTED_ATTRS_WORD1,
 	 NFSD4_SUPPORTED_ATTRS_WORD2},
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index d74c8c44dc35..d96606801d47 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -362,16 +362,16 @@ void		nfsd_lockd_shutdown(void);
 	FATTR4_WORD2_MODE_UMASK | \
 	NFSD4_2_SECURITY_ATTRS)
 
-extern u32 nfsd_suppattrs[3][3];
+extern const u32 nfsd_suppattrs[3][3];
 
-static inline bool bmval_is_subset(u32 *bm1, u32 *bm2)
+static inline bool bmval_is_subset(const u32 *bm1, const u32 *bm2)
 {
 	return !((bm1[0] & ~bm2[0]) ||
 	         (bm1[1] & ~bm2[1]) ||
 		 (bm1[2] & ~bm2[2]));
 }
 
-static inline bool nfsd_attrs_supported(u32 minorversion, u32 *bmval)
+static inline bool nfsd_attrs_supported(u32 minorversion, const u32 *bmval)
 {
 	return bmval_is_subset(bmval, nfsd_suppattrs[minorversion]);
 }
-- 
2.9.3

