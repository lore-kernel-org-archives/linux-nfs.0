Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58448 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574Ab1FNO6P (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 10:58:15 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 2/4] mountd: gather fsid information into one struct
Date: Tue, 14 Jun 2011 10:58:10 -0400
Message-Id: <1308063492-30103-3-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-1-git-send-email-bfields@redhat.com>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

A large part of nfsd_fh() is concerned with extracting
fsid-type-specific information from the fsid, then matching that
information with information from the export list and the filesystem.

Moving all that information into one struct will allow some further
simplifications.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |   79 ++++++++++++++++++++++++++++---------------------
 1 files changed, 45 insertions(+), 34 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index c3dee13..897d61d 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -352,6 +352,18 @@ static bool subexport(struct exportent *e1, struct exportent *e2)
 	       && p1[l2] == '/';
 }
 
+struct parsed_fsid {
+	int fsidtype;
+	/* We could use a union for this, but it would be more
+	 * complicated; why bother? */
+	unsigned int inode;
+	unsigned int minor;
+	unsigned int major;
+	unsigned int fsidnum;
+	int uuidlen;
+	char *fhuuid;
+};
+
 static void nfsd_fh(FILE *f)
 {
 	/* request are:
@@ -363,19 +375,16 @@ static void nfsd_fh(FILE *f)
 	char *dom;
 	int fsidtype;
 	int fsidlen;
-	unsigned int dev, major=0, minor=0;
-	unsigned int inode=0;
 	unsigned long long inode64;
-	unsigned int fsidnum=0;
+	unsigned int dev;
 	char fsid[32];
+	struct parsed_fsid parsed;
 	struct exportent *found = NULL;
 	struct addrinfo *ai = NULL;
 	char *found_path = NULL;
 	nfs_export *exp;
 	int i;
 	int dev_missing = 0;
-	int uuidlen = 0;
-	char *fhuuid = NULL;
 
 	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
 		return;
@@ -400,15 +409,15 @@ static void nfsd_fh(FILE *f)
 		if (fsidlen != 8)
 			goto out;
 		memcpy(&dev, fsid, 4);
-		memcpy(&inode, fsid+4, 4);
-		major = ntohl(dev)>>16;
-		minor = ntohl(dev) & 0xFFFF;
+		memcpy(&parsed.inode, fsid+4, 4);
+		parsed.major = ntohl(dev)>>16;
+		parsed.minor = ntohl(dev) & 0xFFFF;
 		break;
 
 	case FSID_NUM: /* 4 bytes - fsid */
 		if (fsidlen != 4)
 			goto out;
-		memcpy(&fsidnum, fsid, 4);
+		memcpy(&parsed.fsidnum, fsid, 4);
 		break;
 
 	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode 
@@ -417,9 +426,11 @@ static void nfsd_fh(FILE *f)
 		 */
 		if (fsidlen != 12)
 			goto out;
-		memcpy(&dev, fsid, 4); major = ntohl(dev);
-		memcpy(&dev, fsid+4, 4); minor = ntohl(dev);
-		memcpy(&inode, fsid+8, 4);
+		memcpy(&dev, fsid, 4);
+		parsed.major = ntohl(dev);
+		memcpy(&dev, fsid+4, 4);
+		parsed.minor = ntohl(dev);
+		memcpy(&parsed.inode, fsid+8, 4);
 		break;
 
 	case FSID_ENCODE_DEV: /* 8 bytes: 4 byte packed device number, 4 inode */
@@ -429,37 +440,37 @@ static void nfsd_fh(FILE *f)
 		if (fsidlen != 8)
 			goto out;
 		memcpy(&dev, fsid, 4);
-		memcpy(&inode, fsid+4, 4);
-		major = (dev & 0xfff00) >> 8;
-		minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
+		memcpy(&parsed.inode, fsid+4, 4);
+		parsed.major = (dev & 0xfff00) >> 8;
+		parsed.minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
 		break;
 
 	case FSID_UUID4_INUM: /* 4 byte inode number and 4 byte uuid */
 		if (fsidlen != 8)
 			goto out;
-		memcpy(&inode, fsid, 4);
-		uuidlen = 4;
-		fhuuid = fsid+4;
+		memcpy(&parsed.inode, fsid, 4);
+		parsed.uuidlen = 4;
+		parsed.fhuuid = fsid+4;
 		break;
 	case FSID_UUID8: /* 8 byte uuid */
 		if (fsidlen != 8)
 			goto out;
-		uuidlen = 8;
-		fhuuid = fsid;
+		parsed.uuidlen = 8;
+		parsed.fhuuid = fsid;
 		break;
 	case FSID_UUID16: /* 16 byte uuid */
 		if (fsidlen != 16)
 			goto out;
-		uuidlen = 16;
-		fhuuid = fsid;
+		parsed.uuidlen = 16;
+		parsed.fhuuid = fsid;
 		break;
 	case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
 		if (fsidlen != 24)
 			goto out;
 		memcpy(&inode64, fsid, 8);
-		inode = inode64;
-		uuidlen = 16;
-		fhuuid = fsid+8;
+		parsed.inode = inode64;
+		parsed.uuidlen = 16;
+		parsed.fhuuid = fsid+8;
 		break;
 	}
 
@@ -514,20 +525,20 @@ static void nfsd_fh(FILE *f)
 			case FSID_DEV:
 			case FSID_MAJOR_MINOR:
 			case FSID_ENCODE_DEV:
-				if (stb.st_ino != inode)
+				if (stb.st_ino != parsed.inode)
 					continue;
-				if (major != major(stb.st_dev) ||
-				    minor != minor(stb.st_dev))
+				if (parsed.major != major(stb.st_dev) ||
+				    parsed.minor != minor(stb.st_dev))
 					continue;
 				break;
 			case FSID_NUM:
 				if (((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
-				     exp->m_export.e_fsid != fsidnum))
+				     exp->m_export.e_fsid != parsed.fsidnum))
 					continue;
 				break;
 			case FSID_UUID4_INUM:
 			case FSID_UUID16_INUM:
-				if (stb.st_ino != inode)
+				if (stb.st_ino != parsed.inode)
 					continue;
 				goto check_uuid;
 			case FSID_UUID8:
@@ -537,15 +548,15 @@ static void nfsd_fh(FILE *f)
 			check_uuid:
 				if (exp->m_export.e_uuid)
 					get_uuid(exp->m_export.e_uuid,
-						 uuidlen, u);
+						 parsed.uuidlen, u);
 				else
 					for (type = 0;
-					     uuid_by_path(path, type, uuidlen, u);
+					     uuid_by_path(path, type, parsed.uuidlen, u);
 					     type++)
-						if (memcmp(u, fhuuid, uuidlen) == 0)
+						if (memcmp(u, parsed.fhuuid, parsed.uuidlen) == 0)
 							break;
 
-				if (memcmp(u, fhuuid, uuidlen) != 0)
+				if (memcmp(u, parsed.fhuuid, parsed.uuidlen) != 0)
 					continue;
 				break;
 			}
-- 
1.7.4.1

