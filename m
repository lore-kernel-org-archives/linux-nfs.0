From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 4/9] mount.nfs: Use dynamically allocated character
	buffers
Date: Fri, 24 Aug 2007 13:11:27 -0400
Message-ID: <20070824171127.10418.30384.stgit@monet.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: nfs@lists.sourceforge.net
To: neilb@suse.de
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx2-b.sourceforge.net ([10.3.1.92]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1IOci7-00044v-QL
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:12:39 -0700
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1IOciB-0006tv-V2
	for nfs@lists.sourceforge.net; Fri, 24 Aug 2007 10:12:44 -0700
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

Replace the use of static character arrays with buffers allocated via
xstrdup() in stropts.c.

I added a couple of extra length checks; not sure if these are really
necessary.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   85 +++++++++++++++++++++++++++++++++----------------
 1 files changed, 58 insertions(+), 27 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index cc13325..bd6e60d 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -52,6 +52,14 @@
 #define NFS_PORT 2049
 #endif
 
+#ifndef NFS_MAXHOSTNAME
+#define NFS_MAXHOSTNAME		(255)
+#endif
+
+#ifndef NFS_MAXPATHNAME
+#define NFS_MAXPATHNAME		(1024)
+#endif
+
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
@@ -61,26 +69,55 @@ static int bg_opt = 0;
 static int addr_opt = 0;
 static int ca_opt = 0;
 
-static int parse_devname(char *hostdir, char **hostname, char **dirname)
+static int parse_devname(const char *spec, char **hostname)
 {
-	char *s;
+	int ret = 0;
+	char *dev, *pathname, *s;
+
+	dev = xstrdup(spec);
 
-	if (!(s = strchr(hostdir, ':'))) {
-		nfs_error(_("%s: directory to mount not in host:dir format"),
+	if (!(pathname = strchr(dev, ':'))) {
+		nfs_error(_("%s: remote share not in 'host:dir' format"),
 				progname);
-		return -1;
+		goto out;
 	}
-	*hostname = hostdir;
-	*dirname = s + 1;
-	*s = '\0';
-	/* Ignore all but first hostname in replicated mounts
-	   until they can be fully supported. (mack@sgi.com) */
-	if ((s = strchr(hostdir, ','))) {
+	*pathname = '\0';
+	pathname++;
+
+	/*
+	 * We don't need a copy of the pathname, but let's
+	 * sanity check it anyway.
+	 */
+	if (strlen(pathname) > NFS_MAXPATHNAME) {
+		nfs_error(_("%s: export pathname is too long"),
+				progname);
+		goto out;
+	}
+
+	/*
+	 * Ignore all but first hostname in replicated mounts
+	 * until they can be fully supported. (mack@sgi.com)
+	 */
+	if ((s = strchr(dev, ','))) {
 		*s = '\0';
 		nfs_error(_("%s: warning: multiple hostnames not supported"),
 				progname);
+		nfs_error(_("%s: ignoring hostnames that follow the first one"),
+				progname);
 	}
-	return 0;
+	*hostname = xstrdup(dev);
+	if (strlen(*hostname) > NFS_MAXHOSTNAME) {
+		nfs_error(_("%s: server hostname is too long"),
+				progname);
+		free(*hostname);
+		goto out;
+	}
+
+	ret = 1;
+
+out:
+	free(dev);
+	return ret;
 }
 
 static int fill_ipv4_sockaddr(const char *hostname, struct sockaddr_in *addr)
@@ -161,33 +198,27 @@ static void extract_interesting_options(char *opts)
 }
 
 /*
- * Append the 'addr=' option to the options string.
+ * Append the 'addr=' option to the options string.  The server
+ * address is added to /etc/mtab for use when unmounting.
  *
  * Returns 1 if 'addr=' option created successfully;
  * otherwise zero.
  */
 static int append_addr_opt(const char *spec, char **extra_opts)
 {
-	static char hostdir[1024], new_opts[1024];
-	char *hostname, *dirname, *s, *old_opts;
+	static char new_opts[1024];
+	char *hostname, *s, *old_opts;
 	struct sockaddr_in addr;
+	int err;
 
-	if (strlen(spec) >= sizeof(hostdir)) {
-		nfs_error(_("%s: excessively long host:dir argument\n"),
-				progname);
+	if (!parse_devname(spec, &hostname))
 		return 0;
-	}
-	strcpy(hostdir, spec);
-	if (parse_devname(hostdir, &hostname, &dirname)) {
-		nfs_error(_("%s: parsing host:dir argument failed\n"),
-				progname);
-		return 0;
-	}
 
-	if (!fill_ipv4_sockaddr(hostname, &addr))
+	err = fill_ipv4_sockaddr(hostname, &addr);
+	free(hostname);
+	if (!err)
 		return 0;
 
-	/* add IP address to mtab options for use when unmounting */
 	s = inet_ntoa(addr.sin_addr);
 	old_opts = *extra_opts;
 	if (!old_opts)


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >>  http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
