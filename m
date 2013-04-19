Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx12.netapp.com ([216.240.18.77]:57430 "EHLO mx12.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753536Ab3DSSwb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 19 Apr 2013 14:52:31 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com, bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] nfs: Send atime and mtime as a 64bit value
Date: Fri, 19 Apr 2013 14:52:26 -0400
Message-Id: <1366397547-14639-2-git-send-email-bjschuma@netapp.com>
In-Reply-To: <1366397547-14639-1-git-send-email-bjschuma@netapp.com>
References: <1366397547-14639-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

RFC 3530 says that the seconds value of a nfstime4 structure is a 64bit
value, but we are instead sending a 32-bit 0 and then a 32bit conversion
of the 64bit Linux value.  This means that if we try to set atime to a
value before the epoch (touch -t 196001010101) the client will only send
part of the new value due to lost precision.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4xdr.c | 6 ++----
 1 file changed, 2 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 325eddc..b06dcaf 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -1054,8 +1054,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	if (iap->ia_valid & ATTR_ATIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_ACCESS_SET;
 		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-		*p++ = cpu_to_be32(0);
-		*p++ = cpu_to_be32(iap->ia_atime.tv_sec);
+		p = xdr_encode_hyper(p, (long)iap->ia_atime.tv_sec);
 		*p++ = cpu_to_be32(iap->ia_atime.tv_nsec);
 	}
 	else if (iap->ia_valid & ATTR_ATIME) {
@@ -1065,8 +1064,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap, const
 	if (iap->ia_valid & ATTR_MTIME_SET) {
 		bmval1 |= FATTR4_WORD1_TIME_MODIFY_SET;
 		*p++ = cpu_to_be32(NFS4_SET_TO_CLIENT_TIME);
-		*p++ = cpu_to_be32(0);
-		*p++ = cpu_to_be32(iap->ia_mtime.tv_sec);
+		p = xdr_encode_hyper(p, (long)iap->ia_mtime.tv_sec);
 		*p++ = cpu_to_be32(iap->ia_mtime.tv_nsec);
 	}
 	else if (iap->ia_valid & ATTR_MTIME) {
-- 
1.8.2.1

