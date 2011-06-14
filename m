Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58445 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751391Ab1FNO6O (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Jun 2011 10:58:14 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org, "J. Bruce Fields" <bfields@redhat.com>
Subject: [PATCH 3/4] mountd: move fsidtype-specific code to helpers
Date: Tue, 14 Jun 2011 10:58:11 -0400
Message-Id: <1308063492-30103-4-git-send-email-bfields@redhat.com>
In-Reply-To: <1308063492-30103-1-git-send-email-bfields@redhat.com>
References: <1308063492-30103-1-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Now we can move these big switch statements into helper functions.

Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 utils/mountd/cache.c |  240 +++++++++++++++++++++++++++-----------------------
 1 files changed, 129 insertions(+), 111 deletions(-)

diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 897d61d..d2ae4563 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -364,60 +364,26 @@ struct parsed_fsid {
 	char *fhuuid;
 };
 
-static void nfsd_fh(FILE *f)
+int parse_fsid(int fsidtype, int fsidlen, char *fsid, struct parsed_fsid *parsed)
 {
-	/* request are:
-	 *  domain fsidtype fsid
-	 * interpret fsid, find export point and options, and write:
-	 *  domain fsidtype fsid expiry path
-	 */
-	char *cp;
-	char *dom;
-	int fsidtype;
-	int fsidlen;
-	unsigned long long inode64;
 	unsigned int dev;
-	char fsid[32];
-	struct parsed_fsid parsed;
-	struct exportent *found = NULL;
-	struct addrinfo *ai = NULL;
-	char *found_path = NULL;
-	nfs_export *exp;
-	int i;
-	int dev_missing = 0;
-
-	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
-		return;
-
-	xlog(D_CALL, "nfsd_fh: inbuf '%s'", lbuf);
+	unsigned long long inode64;
 
-	cp = lbuf;
-	
-	dom = malloc(strlen(cp));
-	if (dom == NULL)
-		return;
-	if (qword_get(&cp, dom, strlen(cp)) <= 0)
-		goto out;
-	if (qword_get_int(&cp, &fsidtype) != 0)
-		goto out;
-	if (fsidtype < 0 || fsidtype > 7)
-		goto out; /* unknown type */
-	if ((fsidlen = qword_get(&cp, fsid, 32)) <= 0)
-		goto out;
+	parsed->fsidtype = fsidtype;
 	switch(fsidtype) {
 	case FSID_DEV: /* 4 bytes: 2 major, 2 minor, 4 inode */
 		if (fsidlen != 8)
-			goto out;
+			return -1;
 		memcpy(&dev, fsid, 4);
-		memcpy(&parsed.inode, fsid+4, 4);
-		parsed.major = ntohl(dev)>>16;
-		parsed.minor = ntohl(dev) & 0xFFFF;
+		memcpy(&parsed->inode, fsid+4, 4);
+		parsed->major = ntohl(dev)>>16;
+		parsed->minor = ntohl(dev) & 0xFFFF;
 		break;
 
 	case FSID_NUM: /* 4 bytes - fsid */
 		if (fsidlen != 4)
-			goto out;
-		memcpy(&parsed.fsidnum, fsid, 4);
+			return -1;
+		memcpy(&parsed->fsidnum, fsid, 4);
 		break;
 
 	case FSID_MAJOR_MINOR: /* 12 bytes: 4 major, 4 minor, 4 inode 
@@ -425,12 +391,12 @@ static void nfsd_fh(FILE *f)
 		 * an historical accident
 		 */
 		if (fsidlen != 12)
-			goto out;
+			return -1;
 		memcpy(&dev, fsid, 4);
-		parsed.major = ntohl(dev);
+		parsed->major = ntohl(dev);
 		memcpy(&dev, fsid+4, 4);
-		parsed.minor = ntohl(dev);
-		memcpy(&parsed.inode, fsid+8, 4);
+		parsed->minor = ntohl(dev);
+		memcpy(&parsed->inode, fsid+8, 4);
 		break;
 
 	case FSID_ENCODE_DEV: /* 8 bytes: 4 byte packed device number, 4 inode */
@@ -438,41 +404,137 @@ static void nfsd_fh(FILE *f)
 		 * no-one outside this host has any business interpreting it
 		 */
 		if (fsidlen != 8)
-			goto out;
+			return -1;
 		memcpy(&dev, fsid, 4);
-		memcpy(&parsed.inode, fsid+4, 4);
-		parsed.major = (dev & 0xfff00) >> 8;
-		parsed.minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
+		memcpy(&parsed->inode, fsid+4, 4);
+		parsed->major = (dev & 0xfff00) >> 8;
+		parsed->minor = (dev & 0xff) | ((dev >> 12) & 0xfff00);
 		break;
 
 	case FSID_UUID4_INUM: /* 4 byte inode number and 4 byte uuid */
 		if (fsidlen != 8)
-			goto out;
-		memcpy(&parsed.inode, fsid, 4);
-		parsed.uuidlen = 4;
-		parsed.fhuuid = fsid+4;
+			return -1;
+		memcpy(&parsed->inode, fsid, 4);
+		parsed->uuidlen = 4;
+		parsed->fhuuid = fsid+4;
 		break;
 	case FSID_UUID8: /* 8 byte uuid */
 		if (fsidlen != 8)
-			goto out;
-		parsed.uuidlen = 8;
-		parsed.fhuuid = fsid;
+			return -1;
+		parsed->uuidlen = 8;
+		parsed->fhuuid = fsid;
 		break;
 	case FSID_UUID16: /* 16 byte uuid */
 		if (fsidlen != 16)
-			goto out;
-		parsed.uuidlen = 16;
-		parsed.fhuuid = fsid;
+			return -1;
+		parsed->uuidlen = 16;
+		parsed->fhuuid = fsid;
 		break;
 	case FSID_UUID16_INUM: /* 8 byte inode number and 16 byte uuid */
 		if (fsidlen != 24)
-			goto out;
+			return -1;
 		memcpy(&inode64, fsid, 8);
-		parsed.inode = inode64;
-		parsed.uuidlen = 16;
-		parsed.fhuuid = fsid+8;
+		parsed->inode = inode64;
+		parsed->uuidlen = 16;
+		parsed->fhuuid = fsid+8;
 		break;
 	}
+	return 0;
+}
+
+static bool match_fsid(struct parsed_fsid *parsed, nfs_export *exp, char *path)
+{
+	struct stat stb;
+	int type;
+	char u[16];
+
+	if (stat(path, &stb) != 0)
+		return false;
+	if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode))
+		return false;
+
+	switch (parsed->fsidtype) {
+	case FSID_DEV:
+	case FSID_MAJOR_MINOR:
+	case FSID_ENCODE_DEV:
+		if (stb.st_ino != parsed->inode)
+			return false;
+		if (parsed->major != major(stb.st_dev) ||
+		    parsed->minor != minor(stb.st_dev))
+			return false;
+		return true;
+	case FSID_NUM:
+		if (((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
+		     exp->m_export.e_fsid != parsed->fsidnum))
+			return false;
+		return true;
+	case FSID_UUID4_INUM:
+	case FSID_UUID16_INUM:
+		if (stb.st_ino != parsed->inode)
+			return false;
+		goto check_uuid;
+	case FSID_UUID8:
+	case FSID_UUID16:
+		if (!is_mountpoint(path))
+			return false;
+	check_uuid:
+		if (exp->m_export.e_uuid)
+			get_uuid(exp->m_export.e_uuid, parsed->uuidlen, u);
+		else
+			for (type = 0;
+			     uuid_by_path(path, type, parsed->uuidlen, u);
+			     type++)
+				if (memcmp(u, parsed->fhuuid, parsed->uuidlen) == 0)
+					return true;
+
+		if (memcmp(u, parsed->fhuuid, parsed->uuidlen) != 0)
+			return false;
+		return true;
+	}
+	/* Well, unreachable, actually: */
+	return false;
+}
+
+static void nfsd_fh(FILE *f)
+{
+	/* request are:
+	 *  domain fsidtype fsid
+	 * interpret fsid, find export point and options, and write:
+	 *  domain fsidtype fsid expiry path
+	 */
+	char *cp;
+	char *dom;
+	int fsidtype;
+	int fsidlen;
+	char fsid[32];
+	struct parsed_fsid parsed;
+	struct exportent *found = NULL;
+	struct addrinfo *ai = NULL;
+	char *found_path = NULL;
+	nfs_export *exp;
+	int i;
+	int dev_missing = 0;
+
+	if (readline(fileno(f), &lbuf, &lbuflen) != 1)
+		return;
+
+	xlog(D_CALL, "nfsd_fh: inbuf '%s'", lbuf);
+
+	cp = lbuf;
+
+	dom = malloc(strlen(cp));
+	if (dom == NULL)
+		return;
+	if (qword_get(&cp, dom, strlen(cp)) <= 0)
+		goto out;
+	if (qword_get_int(&cp, &fsidtype) != 0)
+		goto out;
+	if (fsidtype < 0 || fsidtype > 7)
+		goto out; /* unknown type */
+	if ((fsidlen = qword_get(&cp, fsid, 32)) <= 0)
+		goto out;
+	if (parse_fsid(fsidtype, fsidlen, fsid, &parsed))
+		goto out;
 
 	auth_reload();
 
@@ -480,10 +542,7 @@ static void nfsd_fh(FILE *f)
 	for (i=0 ; i < MCL_MAXTYPES; i++) {
 		nfs_export *next_exp;
 		for (exp = exportlist[i].p_head; exp; exp = next_exp) {
-			struct stat stb;
-			char u[16];
 			char *path;
-			int type;
 
 			if (exp->m_export.e_flags & NFSEXP_CROSSMOUNT) {
 				static nfs_export *prev = NULL;
@@ -516,50 +575,9 @@ static void nfsd_fh(FILE *f)
 					   exp->m_export.e_mountpoint:
 					   exp->m_export.e_path))
 				dev_missing ++;
-			if (stat(path, &stb) != 0)
-				continue;
-			if (!S_ISDIR(stb.st_mode) && !S_ISREG(stb.st_mode)) {
+
+			if (!match_fsid(&parsed, exp, path))
 				continue;
-			}
-			switch(fsidtype){
-			case FSID_DEV:
-			case FSID_MAJOR_MINOR:
-			case FSID_ENCODE_DEV:
-				if (stb.st_ino != parsed.inode)
-					continue;
-				if (parsed.major != major(stb.st_dev) ||
-				    parsed.minor != minor(stb.st_dev))
-					continue;
-				break;
-			case FSID_NUM:
-				if (((exp->m_export.e_flags & NFSEXP_FSID) == 0 ||
-				     exp->m_export.e_fsid != parsed.fsidnum))
-					continue;
-				break;
-			case FSID_UUID4_INUM:
-			case FSID_UUID16_INUM:
-				if (stb.st_ino != parsed.inode)
-					continue;
-				goto check_uuid;
-			case FSID_UUID8:
-			case FSID_UUID16:
-				if (!is_mountpoint(path))
-					continue;
-			check_uuid:
-				if (exp->m_export.e_uuid)
-					get_uuid(exp->m_export.e_uuid,
-						 parsed.uuidlen, u);
-				else
-					for (type = 0;
-					     uuid_by_path(path, type, parsed.uuidlen, u);
-					     type++)
-						if (memcmp(u, parsed.fhuuid, parsed.uuidlen) == 0)
-							break;
-
-				if (memcmp(u, parsed.fhuuid, parsed.uuidlen) != 0)
-					continue;
-				break;
-			}
 			if (use_ipaddr) {
 				if (ai == NULL) {
 					struct addrinfo *tmp;
-- 
1.7.4.1

