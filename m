Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:53257 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757911Ab3DXUXD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 16:23:03 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 03/17] NFSDv4.2: Added NFS v4.2 support to the NFS server
Date: Wed, 24 Apr 2013 16:17:49 -0400
Message-Id: <1366834683-29075-4-git-send-email-SteveD@redhat.com>
In-Reply-To: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This enable NFSv4.2 support for the server. To enable this
code do the following:
  echo "+4.2" >/proc/fs/nfsd/versions

after the nfsd kernel module is loaded.

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 1 +
 fs/nfsd/nfsd.h    | 7 ++++++-
 2 files changed, 7 insertions(+), 1 deletion(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index a272007..b38de7a 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1572,6 +1572,7 @@ struct nfsd4_minorversion_ops {
 static struct nfsd4_minorversion_ops nfsd4_minorversion[] = {
 	[0] = { nfsd4_dec_ops, ARRAY_SIZE(nfsd4_dec_ops) },
 	[1] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
+	[2] = { nfsd41_dec_ops, ARRAY_SIZE(nfsd41_dec_ops) },
 };
 
 static __be32
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 553b230..b5eade7 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -24,7 +24,7 @@
 /*
  * nfsd version
  */
-#define NFSD_SUPPORTED_MINOR_VERSION	1
+#define NFSD_SUPPORTED_MINOR_VERSION	2
 /*
  * Maximum blocksizes supported by daemon under various circumstances.
  */
@@ -328,6 +328,8 @@ void		nfsd_lockd_shutdown(void);
 #define NFSD4_1_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_SUPPORTED_ATTRS_WORD2 | FATTR4_WORD2_SUPPATTR_EXCLCREAT)
 
+#define NFSD4_2_SUPPORTED_ATTRS_WORD2 0
+
 static inline u32 nfsd_suppattrs0(u32 minorversion)
 {
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD0
@@ -342,6 +344,9 @@ static inline u32 nfsd_suppattrs1(u32 minorversion)
 
 static inline u32 nfsd_suppattrs2(u32 minorversion)
 {
+	if (minorversion == 2)
+		return NFSD4_2_SUPPORTED_ATTRS_WORD2;
+
 	return minorversion ? NFSD4_1_SUPPORTED_ATTRS_WORD2
 			    : NFSD4_SUPPORTED_ATTRS_WORD2;
 }
-- 
1.8.1.4

