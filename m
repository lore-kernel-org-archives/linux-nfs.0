Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:53149 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752764Ab0CBUsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 2 Mar 2010 15:48:20 -0500
Date: Tue, 2 Mar 2010 15:49:30 -0500
To: Steve Dickson <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] mountd: fix --manage-gids hang due to int/uint bug
Message-ID: <20100302204930.GA8609@fieldses.org>
Content-Type: text/plain; charset=us-ascii
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: J. Bruce Fields <bfields@citi.umich.edu>

A uid or gid should be represented as unsigned, not signed.

The conversion to signed here could cause a hang on access by an unknown
user to a server running mountd with --manage-gids; such a user is
likely to be mapped to 2^32-1, which may be converted to 2^31-1 when
represented as an int, resulting in a downcall for uid 2^31-1, hence the
original rpc hanging forever waiting for a cache downcall for 2^32-1.

Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 support/nfs/cacheio.c |   19 +++++++++++++++++++
 utils/mountd/cache.c  |   14 +++++++-------
 2 files changed, 26 insertions(+), 7 deletions(-)

diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index bdf5d84..0587ecb 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -148,6 +148,11 @@ void qword_printint(FILE *f, int num)
 	fprintf(f, "%d ", num);
 }
 
+void qword_printuint(FILE *f, unsigned int num)
+{
+	fprintf(f, "%u ", num);
+}
+
 int qword_eol(FILE *f)
 {
 	int err;
@@ -236,6 +241,20 @@ int qword_get_int(char **bpp, int *anint)
 	return 0;
 }
 
+int qword_get_uint(char *bpp, unsigned int *anint)
+{
+	char buf[50];
+	char *ep;
+	unsigned int rv;
+	int len = qword_get(bpp, buf, 50);
+	if (len < 0) return -1;
+	if (len ==0) return -1;
+	rv = strtoul(buf, &ep, 0);
+	if (*ep) return -1;
+	*anint = rv;
+	return 0;
+}
+
 #define READLINE_BUFFER_INCREMENT 2048
 
 int readline(int fd, char **buf, int *lenp)
diff --git a/utils/mountd/cache.c b/utils/mountd/cache.c
index 200e179..a6e0832 100644
--- a/utils/mountd/cache.c
+++ b/utils/mountd/cache.c
@@ -125,7 +125,7 @@ void auth_unix_gid(FILE *f)
 	 * reply is
 	 *  uid expiry count list of group ids
 	 */
-	int uid;
+	uid_t uid;
 	struct passwd *pw;
 	gid_t glist[100], *groups = glist;
 	int ngroups = 100;
@@ -136,7 +136,7 @@ void auth_unix_gid(FILE *f)
 		return;
 
 	cp = lbuf;
-	if (qword_get_int(&cp, &uid) != 0)
+	if (qword_get_uint(&cp, &uid) != 0)
 		return;
 
 	pw = getpwuid(uid);
@@ -153,14 +153,14 @@ void auth_unix_gid(FILE *f)
 						  groups, &ngroups);
 		}
 	}
-	qword_printint(f, uid);
-	qword_printint(f, time(0)+30*60);
+	qword_printuint(f, uid);
+	qword_printuint(f, time(0)+30*60);
 	if (rv >= 0) {
-		qword_printint(f, ngroups);
+		qword_printuint(f, ngroups);
 		for (i=0; i<ngroups; i++)
-			qword_printint(f, groups[i]);
+			qword_printuint(f, groups[i]);
 	} else
-		qword_printint(f, 0);
+		qword_printuint(f, 0);
 	qword_eol(f);
 
 	if (groups != glist)
-- 
1.6.3.3

