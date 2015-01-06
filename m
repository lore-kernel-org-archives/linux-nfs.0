Return-Path: linux-nfs-owner@vger.kernel.org
Received: from casper.infradead.org ([85.118.1.10]:55207 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755845AbbAFQ3f (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 6 Jan 2015 11:29:35 -0500
From: Christoph Hellwig <hch@lst.de>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Jeff Layton <jlayton@primarydata.com>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, xfs@oss.sgi.com
Subject: [PATCH 03/18] nfsd: factor out a helper to decode nfstime4 values
Date: Tue,  6 Jan 2015 17:28:26 +0100
Message-Id: <1420561721-9150-4-git-send-email-hch@lst.de>
In-Reply-To: <1420561721-9150-1-git-send-email-hch@lst.de>
References: <1420561721-9150-1-git-send-email-hch@lst.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 fs/nfsd/nfs4xdr.c | 39 ++++++++++++++++++++++-----------------
 1 file changed, 22 insertions(+), 17 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 15f7b73..fe31178 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -235,6 +235,22 @@ static char *savemem(struct nfsd4_compoundargs *argp, __be32 *p, int nbytes)
 }
 
 static __be32
+nfsd4_decode_time(struct nfsd4_compoundargs *argp, struct timespec *tv)
+{
+	DECODE_HEAD;
+	u64 sec;
+
+	READ_BUF(12);
+	p = xdr_decode_hyper(p, &sec);
+	tv->tv_sec = sec;
+	tv->tv_nsec = be32_to_cpup(p++);
+	if (tv->tv_nsec >= (u32)1000000000)
+		return nfserr_inval;
+
+	DECODE_TAIL;
+}
+
+static __be32
 nfsd4_decode_bitmap(struct nfsd4_compoundargs *argp, u32 *bmval)
 {
 	u32 bmlen;
@@ -267,7 +283,6 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 {
 	int expected_len, len = 0;
 	u32 dummy32;
-	u64 sec;
 	char *buf;
 
 	DECODE_HEAD;
@@ -358,15 +373,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		dummy32 = be32_to_cpup(p++);
 		switch (dummy32) {
 		case NFS4_SET_TO_CLIENT_TIME:
-			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
-			   all 32 bits of 'nseconds'. */
-			READ_BUF(12);
 			len += 12;
-			p = xdr_decode_hyper(p, &sec);
-			iattr->ia_atime.tv_sec = (time_t)sec;
-			iattr->ia_atime.tv_nsec = be32_to_cpup(p++);
-			if (iattr->ia_atime.tv_nsec >= (u32)1000000000)
-				return nfserr_inval;
+			status = nfsd4_decode_time(argp, &iattr->ia_atime);
+			if (status)
+				return status;
 			iattr->ia_valid |= (ATTR_ATIME | ATTR_ATIME_SET);
 			break;
 		case NFS4_SET_TO_SERVER_TIME:
@@ -382,15 +392,10 @@ nfsd4_decode_fattr(struct nfsd4_compoundargs *argp, u32 *bmval,
 		dummy32 = be32_to_cpup(p++);
 		switch (dummy32) {
 		case NFS4_SET_TO_CLIENT_TIME:
-			/* We require the high 32 bits of 'seconds' to be 0, and we ignore
-			   all 32 bits of 'nseconds'. */
-			READ_BUF(12);
 			len += 12;
-			p = xdr_decode_hyper(p, &sec);
-			iattr->ia_mtime.tv_sec = sec;
-			iattr->ia_mtime.tv_nsec = be32_to_cpup(p++);
-			if (iattr->ia_mtime.tv_nsec >= (u32)1000000000)
-				return nfserr_inval;
+			status = nfsd4_decode_time(argp, &iattr->ia_mtime);
+			if (status)
+				return status;
 			iattr->ia_valid |= (ATTR_MTIME | ATTR_MTIME_SET);
 			break;
 		case NFS4_SET_TO_SERVER_TIME:
-- 
1.9.1

