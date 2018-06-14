Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:55506 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754695AbeFNTVf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 14 Jun 2018 15:21:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/2] nfsd4: support change_attr_type attribute
Date: Thu, 14 Jun 2018 15:21:33 -0400
Message-Id: <1529004093-5866-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1529004093-5866-1-git-send-email-bfields@redhat.com>
References: <1529004093-5866-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

The change attribute is what is used by clients to revalidate their
caches.  Our server may use i_version or ctime for that purpose.  Those
choices behave slightly differently, and it may be useful to the client
to know which we're using.  This attribute tells the client that.  The
Linux client doesn't yet use this attribute yet, though.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c    | 10 ++++++++++
 fs/nfsd/nfsd.h       |  1 +
 include/linux/nfs4.h |  8 ++++++++
 3 files changed, 19 insertions(+)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 4c5fa0ff2387..eea31ff4a3ff 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -2888,6 +2888,16 @@ nfsd4_encode_fattr(struct xdr_stream *xdr, struct svc_fh *fhp,
 			goto out;
 	}
 
+	if (bmval2 & FATTR4_WORD2_CHANGE_ATTR_TYPE) {
+		p = xdr_reserve_space(xdr, 4);
+		if (!p)
+			goto out_resource;
+		if (IS_I_VERSION(d_inode(dentry)))
+			*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR);
+		else
+			*p++ = cpu_to_be32(NFS4_CHANGE_TYPE_IS_TIME_METADATA);
+	}
+
 	if (bmval2 & FATTR4_WORD2_SECURITY_LABEL) {
 		status = nfsd4_encode_security_label(xdr, rqstp, context,
 								contextlen);
diff --git a/fs/nfsd/nfsd.h b/fs/nfsd/nfsd.h
index 3fce905d0365..066899929863 100644
--- a/fs/nfsd/nfsd.h
+++ b/fs/nfsd/nfsd.h
@@ -360,6 +360,7 @@ void		nfsd_lockd_shutdown(void);
 
 #define NFSD4_2_SUPPORTED_ATTRS_WORD2 \
 	(NFSD4_1_SUPPORTED_ATTRS_WORD2 | \
+	FATTR4_WORD2_CHANGE_ATTR_TYPE | \
 	FATTR4_WORD2_MODE_UMASK | \
 	NFSD4_2_SECURITY_ATTRS)
 
diff --git a/include/linux/nfs4.h b/include/linux/nfs4.h
index 57ffaa20d564..0877ed333733 100644
--- a/include/linux/nfs4.h
+++ b/include/linux/nfs4.h
@@ -374,6 +374,13 @@ enum lock_type4 {
 	NFS4_WRITEW_LT = 4
 };
 
+enum change_attr_type4 {
+	NFS4_CHANGE_TYPE_IS_MONOTONIC_INCR = 0,
+	NFS4_CHANGE_TYPE_IS_VERSION_COUNTER = 1,
+	NFS4_CHANGE_TYPE_IS_VERSION_COUNTER_NOPNFS = 2,
+	NFS4_CHANGE_TYPE_IS_TIME_METADATA = 3,
+	NFS4_CHANGE_TYPE_IS_UNDEFINED = 4
+};
 
 /* Mandatory Attributes */
 #define FATTR4_WORD0_SUPPORTED_ATTRS    (1UL << 0)
@@ -441,6 +448,7 @@ enum lock_type4 {
 #define FATTR4_WORD2_LAYOUT_BLKSIZE     (1UL << 1)
 #define FATTR4_WORD2_MDSTHRESHOLD       (1UL << 4)
 #define FATTR4_WORD2_CLONE_BLKSIZE	(1UL << 13)
+#define FATTR4_WORD2_CHANGE_ATTR_TYPE	(1UL << 15)
 #define FATTR4_WORD2_SECURITY_LABEL     (1UL << 16)
 #define FATTR4_WORD2_MODE_UMASK		(1UL << 17)
 
-- 
2.17.1

