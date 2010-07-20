From: Steve Dickson <steved@redhat.com>
Subject: [PATCH 14/24] Removed warnings from idmapd.c
Date: Tue, 20 Jul 2010 19:37:27 -0400
Message-ID: <1279669057-17509-15-git-send-email-steved@redhat.com>
References: <1279669057-17509-1-git-send-email-steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from 4dicksons.org ([207.22.49.45]:60368 "EHLO
	Dobby.Home.4dicksons.org" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1761879Ab0GUAmy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 20 Jul 2010 20:42:54 -0400
Received: from tophat.home.4dicksons.org ([192.168.62.20] helo=localhost.localdomain)
	by Dobby.Home.4dicksons.org with esmtp (Exim 4.63)
	(envelope-from <steved@redhat.com>)
	id 1ObMNY-0004K5-J4
	for linux-nfs@vger.kernel.org; Tue, 20 Jul 2010 19:37:40 -0400
In-Reply-To: <1279669057-17509-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

idmapd.c:120: warning: missing initializer
idmapd.c:120: warning: (near initialization for 'nfsd_ic[0].ic_event')
idmapd.c:121: warning: missing initializer
idmapd.c:121: warning: (near initialization for 'nfsd_ic[1].ic_event')
idmapd.c: In function 'flush_nfsd_cache':
idmapd.c:173: warning: comparison between signed and unsigned integer expressions
idmapd.c: In function 'dirscancb':
idmapd.c:384: warning: unused parameter 'fd'
idmapd.c:384: warning: unused parameter 'which'
idmapd.c: In function 'svrreopen':
idmapd.c:468: warning: unused parameter 'fd'
idmapd.c:468: warning: unused parameter 'which'
idmapd.c:468: warning: unused parameter 'data'
idmapd.c: In function 'clntscancb':
idmapd.c:474: warning: unused parameter 'fd'
idmapd.c:474: warning: unused parameter 'which'
idmapd.c: In function 'nfsdcb':
idmapd.c:488: warning: unused parameter 'fd'
idmapd.c: In function 'nfscb':
idmapd.c:663: warning: unused parameter 'fd'
idmapd.c: In function 'validateascii':
idmapd.c:850: warning: comparison between signed and unsigned integer expressions
idmapd.c:858: warning: comparison between signed and unsigned integer expressions
idmapd.c: In function 'getfield':
idmapd.c:916: warning: comparison between signed and unsigned integer expressions

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/idmapd/idmapd.c |   36 +++++++++++++++++++++++++++++++-----
 1 files changed, 31 insertions(+), 5 deletions(-)

diff --git a/utils/idmapd/idmapd.c b/utils/idmapd/idmapd.c
index 573abaa..45b458b 100644
--- a/utils/idmapd/idmapd.c
+++ b/utils/idmapd/idmapd.c
@@ -117,8 +117,24 @@ struct idmap_client {
 	TAILQ_ENTRY(idmap_client)  ic_next;
 };
 static struct idmap_client nfsd_ic[2] = {
-{IC_IDNAME, "Server", "", IC_IDNAME_CHAN, -1, -1, 0},
-{IC_NAMEID, "Server", "", IC_NAMEID_CHAN, -1, -1, 0},
+{
+	.ic_which = IC_IDNAME, 
+	.ic_clid = "Server", 
+	.ic_id = "", 
+	.ic_path = IC_IDNAME_CHAN, 
+	.ic_fd = -1, 
+	.ic_dirfd = -1, 
+	.ic_scanned = 0
+},
+{
+	.ic_which = IC_NAMEID, 
+	.ic_clid = "Server", 
+	.ic_id = "", 
+	.ic_path = IC_NAMEID_CHAN, 
+	.ic_fd = -1, 
+	.ic_dirfd = -1, 
+	.ic_scanned = 0
+},
 };
 
 TAILQ_HEAD(idmap_clientq, idmap_client);
@@ -170,7 +186,7 @@ flush_nfsd_cache(char *path, time_t now)
 	fd = open(path, O_RDWR);
 	if (fd == -1)
 		return -1;
-	if (write(fd, stime, strlen(stime)) != strlen(stime)) {
+	if (write(fd, stime, strlen(stime)) != (ssize_t)strlen(stime)) {
 		errx(1, "Flushing nfsd cache failed: errno %d (%s)",
 			errno, strerror(errno));
 	}
@@ -389,6 +405,8 @@ dirscancb(int fd, short which, void *data)
 	char path[PATH_MAX];
 	struct idmap_clientq *icq = data;
 
+	xlog(D_GENERAL, "dirscancb: fd %d which %d data %p", fd, which, data);
+
 	nent = scandir(pipefsdir, &ents, NULL, alphasort);
 	if (nent == -1) {
 		xlog_warn("dirscancb: scandir(%s): %s", pipefsdir, strerror(errno));
@@ -467,6 +485,8 @@ out:
 static void
 svrreopen(int fd, short which, void *data)
 {
+	xlog(D_GENERAL, "svrreopen: fd %d which %d data %p", fd, which, data);
+
 	nfsdreopen();
 }
 
@@ -476,6 +496,8 @@ clntscancb(int fd, short which, void *data)
 	struct idmap_clientq *icq = data;
 	struct idmap_client *ic;
 
+	xlog(D_GENERAL, "clntscancb: fd %d which %d data %p", fd, which, data);
+
 	TAILQ_FOREACH(ic, icq, ic_next)
 		if (ic->ic_fd == -1 && nfsopen(ic) == -1) {
 			close(ic->ic_dirfd);
@@ -496,6 +518,8 @@ nfsdcb(int fd, short which, void *data)
 		buf1[IDMAP_MAXMSGSZ], authbuf[IDMAP_MAXMSGSZ], *p;
 	unsigned long tmp;
 
+	xlog(D_GENERAL, "nfsdcb: fd %d which %d data %p", fd, which, data);
+
 	if (which != EV_READ)
 		goto out;
 
@@ -665,6 +689,8 @@ nfscb(int fd, short which, void *data)
 	struct idmap_client *ic = data;
 	struct idmap_msg im;
 
+	xlog(D_GENERAL, "nfscb: fd %d which %d data %p", fd, which, data);
+
 	if (which != EV_READ)
 		goto out;
 
@@ -845,7 +871,7 @@ nametoidres(struct idmap_msg *im)
 static int
 validateascii(char *string, u_int32_t len)
 {
-	int i;
+	u_int32_t i;
 
 	for (i = 0; i < len; i++) {
 		if (string[i] == '\0')
@@ -901,7 +927,7 @@ static int
 getfield(char **bpp, char *fld, size_t fldsz)
 {
 	char *bp;
-	u_int val, n;
+	int val, n;
 
 	while ((bp = strsep(bpp, " ")) != NULL && bp[0] == '\0')
 		;
-- 
1.7.0.1

