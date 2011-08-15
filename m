Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:43956 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750790Ab1HOWaf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Aug 2011 18:30:35 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: linux-nfs@vger.kernel.org
Cc: "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 1/5] nfsd4: clean up S_IS -> NF4 file type mapping
Date: Mon, 15 Aug 2011 18:30:28 -0400
Message-Id: <1313447432-1537-1-git-send-email-bfields@redhat.com>
In-Reply-To: <20110815222859.GD32181@fieldses.org>
References: <20110815222859.GD32181@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A slightly unconventional approach to make the code more compact I could
live with, but let's give the poor reader *some* chance.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c |   21 ++++++++++++++-------
 1 files changed, 14 insertions(+), 7 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index c8bf405..42ef8ff 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1760,12 +1760,19 @@ static __be32 nfsd4_encode_fs_locations(struct svc_rqst *rqstp,
 	return 0;
 }
 
-static u32 nfs4_ftypes[16] = {
-        NF4BAD,  NF4FIFO, NF4CHR, NF4BAD,
-        NF4DIR,  NF4BAD,  NF4BLK, NF4BAD,
-        NF4REG,  NF4BAD,  NF4LNK, NF4BAD,
-        NF4SOCK, NF4BAD,  NF4LNK, NF4BAD,
-};
+static u32 nfs4_file_type(umode_t mode)
+{
+	switch (mode & S_IFMT) {
+	case S_IFIFO:	return NF4FIFO;
+	case S_IFCHR:	return NF4CHR;
+	case S_IFDIR:	return NF4DIR;
+	case S_IFBLK:	return NF4BLK;
+	case S_IFLNK:	return NF4LNK;
+	case S_IFREG:	return NF4REG;
+	case S_IFSOCK:	return NF4SOCK;
+	default:	return NF4BAD;
+	};
+}
 
 static __be32
 nfsd4_encode_name(struct svc_rqst *rqstp, int whotype, uid_t id, int group,
@@ -1954,7 +1961,7 @@ nfsd4_encode_fattr(struct svc_fh *fhp, struct svc_export *exp,
 	if (bmval0 & FATTR4_WORD0_TYPE) {
 		if ((buflen -= 4) < 0)
 			goto out_resource;
-		dummy = nfs4_ftypes[(stat.mode & S_IFMT) >> 12];
+		dummy = nfs4_file_type(stat.mode);
 		if (dummy == NF4BAD)
 			goto out_serverfault;
 		WRITE32(dummy);
-- 
1.7.4.1

