Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:49930 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752123AbdEEK06 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 May 2017 06:26:58 -0400
From: "Jianhong.Yin" <jiyin@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: trond.myklebust@primarydata.com, bfields@redhat.com,
        steved@redhat.com, "Jianhong.Yin" <yin-jianhong@163.com>
Subject: [PATCH] fs/nfs: fix covscan error: FORWARD_NULL
Date: Fri,  5 May 2017 18:26:51 +0800
Message-Id: <1493980011-24395-1-git-send-email-jiyin@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "Jianhong.Yin" <yin-jianhong@163.com>

fs/nfs/nfs4xdr.c: encode_attrs()
'''
Error: FORWARD_NULL (CWE-476): [#def3702]
.../fs/nfs/nfs4xdr.c:1085: var_compare_op: Comparing "label" to null implies that "label" might be null.
.../fs/nfs/nfs4xdr.c:1129: var_deref_op: Dereferencing null pointer "label".
 1127|   	}
 1128|   	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
 1129|-> 		*p++ = cpu_to_be32(label->lfs);
 1130|   		*p++ = cpu_to_be32(label->pi);
 1131|   		*p++ = cpu_to_be32(label->len);

Error: FORWARD_NULL (CWE-476): [#def3703]
.../fs/nfs/nfs4xdr.c:1027: var_compare_op: Comparing "umask" to null implies that "umask" might be null.
.../fs/nfs/nfs4xdr.c:1136: var_deref_op: Dereferencing null pointer "umask".
 1134|   	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
 1135|   		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
 1136|-> 		*p++ = cpu_to_be32(*umask);
 1137|   	}
'''

Signed-off-by: Jianhong Yin <yin-jianhong@163.com>
---
 fs/nfs/nfs4xdr.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 80ce289..a86ed66 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1124,7 +1124,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 		} else
 			*p++ = cpu_to_be32(NFS4_SET_TO_SERVER_TIME);
 	}
-	if (bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
+	if (label && bmval[2] & FATTR4_WORD2_SECURITY_LABEL) {
 		*p++ = cpu_to_be32(label->lfs);
 		*p++ = cpu_to_be32(label->pi);
 		*p++ = cpu_to_be32(label->len);
@@ -1132,7 +1132,8 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
 	}
 	if (bmval[2] & FATTR4_WORD2_MODE_UMASK) {
 		*p++ = cpu_to_be32(iap->ia_mode & S_IALLUGO);
-		*p++ = cpu_to_be32(*umask);
+		if (umask != NULL)
+			*p++ = cpu_to_be32(*umask);
 	}
 
 /* out: */
-- 
1.8.3.1

