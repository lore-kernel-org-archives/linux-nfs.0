From: Kevin Coffman <kwc@citi.umich.edu>
Subject: [PATCH 4/9] Copy new cacheio functions used by svcgssd to
	nfslib
Date: Fri, 12 Oct 2007 16:35:00 -0400
Message-ID: <20071012203459.24796.45416.stgit@RoCk.CiTi.UmIcH.EdU>
References: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IgRDk-00089j-DM
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:34:56 -0700
Received: from citi.umich.edu ([141.211.133.111])
	by mail.sourceforge.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.44) id 1IgRDo-0007To-M9
	for nfs@lists.sourceforge.net; Fri, 12 Oct 2007 13:35:01 -0700
In-Reply-To: <20071012202348.24796.29260.stgit@RoCk.CiTi.UmIcH.EdU>
List-Id: "Discussion of NFS under Linux development, interoperability,
	and testing." <nfs.lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=nfs>
List-Post: <mailto:nfs@lists.sourceforge.net>
List-Help: <mailto:nfs-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/nfs>,
	<mailto:nfs-request@lists.sourceforge.net?subject=subscribe>
Sender: nfs-bounces@lists.sourceforge.net
Errors-To: nfs-bounces@lists.sourceforge.net

From: Kevin Coffman <kwc@citi.umich.edu>

Copy private qword_ functions from the svcgssd version into
the general nfslib library.   Add prototypes as needed.
Also, update readline to use a bigger buffer allocation as is
needed in the svcgssd version.

Signed-off-by: Kevin Coffman <kwc@citi.umich.edu>
---

 support/include/nfslib.h |    5 +++++
 support/nfs/cacheio.c    |   47 +++++++++++++++++++++++++++++++++++++++-------
 2 files changed, 45 insertions(+), 7 deletions(-)

diff --git a/support/include/nfslib.h b/support/include/nfslib.h
index ffa2440..422b012 100644
--- a/support/include/nfslib.h
+++ b/support/include/nfslib.h
@@ -144,6 +144,11 @@ int qword_get(char **bpp, char *dest, int bufsize);
 int qword_get_int(char **bpp, int *anint);
 void cache_flush(int force);
 int check_new_cache(void);
+void qword_add(char **bpp, int *lp, char *str);
+void qword_addhex(char **bpp, int *lp, char *buf, int blen);
+void qword_addint(char **bpp, int *lp, int n);
+void qword_adduint(char **bpp, int *lp, unsigned int n);
+void qword_addeol(char **bpp, int *lp);
 
 void closeall(int min);
 
diff --git a/support/nfs/cacheio.c b/support/nfs/cacheio.c
index 9d271cd..48292f8 100644
--- a/support/nfs/cacheio.c
+++ b/support/nfs/cacheio.c
@@ -88,6 +88,37 @@ void qword_addhex(char **bpp, int *lp, char *buf, int blen)
 	*lp = len;
 }
 
+void qword_addint(char **bpp, int *lp, int n)
+{
+	int len;
+
+	len = snprintf(*bpp, *lp, "%d ", n);
+	if (len > *lp)
+		len = *lp;
+	*bpp += len;
+	*lp -= len;
+}
+
+void qword_adduint(char **bpp, int *lp, unsigned int n)
+{
+	int len;
+
+	len = snprintf(*bpp, *lp, "%u ", n);
+	if (len > *lp)
+		len = *lp;
+	*bpp += len;
+	*lp -= len;
+}
+
+void qword_addeol(char **bpp, int *lp)
+{
+	if (*lp <= 0)
+		return;
+	**bpp = '\n';
+	(*bpp)++;
+	(*lp)--;
+}
+
 static char qword_buf[8192];
 void qword_print(FILE *f, char *str)
 {
@@ -192,23 +223,25 @@ int qword_get_int(char **bpp, int *anint)
 	return 0;
 }
 
+#define READLINE_BUFFER_INCREMENT 2048
+
 int readline(int fd, char **buf, int *lenp)
 {
 	/* read a line into *buf, which is malloced *len long
 	 * realloc if needed until we find a \n
 	 * nul out the \n and return
-	 * 0 of eof, 1 of success 
+	 * 0 on eof, 1 on success
 	 */
-	int len = *lenp;
+	int len;
 
-	if (len == 0) {
-		char *b = malloc(128);
+	if (*lenp == 0) {
+		char *b = malloc(READLINE_BUFFER_INCREMENT);
 		if (b == NULL)
 			return 0;
 		*buf = b;
-		*lenp = 128;
+		*lenp = READLINE_BUFFER_INCREMENT;
 	}
-	len = read(fd, *buf, len);
+	len = read(fd, *buf, *lenp);
 	if (len <= 0)
 		return 0;
 	while ((*buf)[len-1] != '\n') {
@@ -217,7 +250,7 @@ int readline(int fd, char **buf, int *lenp)
 	 */
 		char *new;
 		int nl;
-		*lenp *= 2;
+		*lenp += READLINE_BUFFER_INCREMENT;
 		new = realloc(*buf, *lenp);
 		if (new == NULL)
 			return 0;


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
