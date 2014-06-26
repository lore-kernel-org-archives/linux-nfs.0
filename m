Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f172.google.com ([209.85.216.172]:46316 "EHLO
	mail-qc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750832AbaFZTNz (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 26 Jun 2014 15:13:55 -0400
Received: by mail-qc0-f172.google.com with SMTP id o8so3619778qcw.31
        for <linux-nfs@vger.kernel.org>; Thu, 26 Jun 2014 12:13:55 -0700 (PDT)
From: Jeff Layton <jlayton@primarydata.com>
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH v2 006/117] nfsd: add appropriate __force directives to filehandle generation code
Date: Thu, 26 Jun 2014 15:11:46 -0400
Message-Id: <1403810017-16062-7-git-send-email-jlayton@primarydata.com>
In-Reply-To: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
References: <1403810017-16062-1-git-send-email-jlayton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The filehandle structs all use host-endian values, but will sometimes
stuff big-endian values into those fields. This is OK since these
values are opaque to the client, but it confuses sparse. Add __force to
make it clear that we are doing this intentionally.

Reviewed-by: Christoph Hellwig <hch@lst.de>
Signed-off-by: Jeff Layton <jlayton@primarydata.com>
---
 fs/nfsd/nfsfh.c | 10 +++++++++-
 fs/nfsd/nfsfh.h | 15 +++++++++++----
 2 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfsfh.c b/fs/nfsd/nfsfh.c
index ec8393418154..6ae5219c478e 100644
--- a/fs/nfsd/nfsfh.c
+++ b/fs/nfsd/nfsfh.c
@@ -162,7 +162,15 @@ static __be32 nfsd_set_fh_dentry(struct svc_rqst *rqstp, struct svc_fh *fhp)
 			/* deprecated, convert to type 3 */
 			len = key_len(FSID_ENCODE_DEV)/4;
 			fh->fh_fsid_type = FSID_ENCODE_DEV;
-			fh->fh_fsid[0] = new_encode_dev(MKDEV(ntohl(fh->fh_fsid[0]), ntohl(fh->fh_fsid[1])));
+			/*
+			 * struct knfsd_fh uses host-endian fields, which are
+			 * sometimes used to hold net-endian values. This
+			 * confuses sparse, so we must use __force here to
+			 * keep it from complaining.
+			 */
+			fh->fh_fsid[0] = new_encode_dev(
+				MKDEV(ntohl((__force __be32)fh->fh_fsid[0]),
+				      ntohl((__force __be32)fh->fh_fsid[1])));
 			fh->fh_fsid[1] = fh->fh_fsid[2];
 		}
 		data_left -= len;
diff --git a/fs/nfsd/nfsfh.h b/fs/nfsd/nfsfh.h
index 2e89e70ac15c..08236d70c667 100644
--- a/fs/nfsd/nfsfh.h
+++ b/fs/nfsd/nfsfh.h
@@ -73,8 +73,15 @@ enum fsid_source {
 extern enum fsid_source fsid_source(struct svc_fh *fhp);
 
 
-/* This might look a little large to "inline" but in all calls except
+/*
+ * This might look a little large to "inline" but in all calls except
  * one, 'vers' is constant so moste of the function disappears.
+ *
+ * In some cases the values are considered to be host endian and in
+ * others, net endian. fsidv is always considered to be u32 as the
+ * callers don't know which it will be. So we must use __force to keep
+ * sparse from complaining. Since these values are opaque to the
+ * client, that shouldn't be a problem.
  */
 static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
 			   u32 fsid, unsigned char *uuid)
@@ -82,7 +89,7 @@ static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
 	u32 *up;
 	switch(vers) {
 	case FSID_DEV:
-		fsidv[0] = htonl((MAJOR(dev)<<16) |
+		fsidv[0] = (__force __u32)htonl((MAJOR(dev)<<16) |
 				 MINOR(dev));
 		fsidv[1] = ino_t_to_u32(ino);
 		break;
@@ -90,8 +97,8 @@ static inline void mk_fsid(int vers, u32 *fsidv, dev_t dev, ino_t ino,
 		fsidv[0] = fsid;
 		break;
 	case FSID_MAJOR_MINOR:
-		fsidv[0] = htonl(MAJOR(dev));
-		fsidv[1] = htonl(MINOR(dev));
+		fsidv[0] = (__force __u32)htonl(MAJOR(dev));
+		fsidv[1] = (__force __u32)htonl(MINOR(dev));
 		fsidv[2] = ino_t_to_u32(ino);
 		break;
 
-- 
1.9.3

