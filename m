Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:50779 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756949AbcBXR4X (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Feb 2016 12:56:23 -0500
From: <andros@netapp.com>
To: <steved@redhat.com>
CC: <linux-nfs@vger.kernel.org>, Andy Adamson <andros@netapp.com>
Subject: [PATCH 1/2] NFS parse NFSv4 multiple hostnames
Date: Wed, 24 Feb 2016 12:55:58 -0500
Message-ID: <1456336559-17334-2-git-send-email-andros@netapp.com>
In-Reply-To: <1456336559-17334-1-git-send-email-andros@netapp.com>
References: <1456336559-17334-1-git-send-email-andros@netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Andy Adamson <andros@netapp.com>

For NFSv4.x mounts

Signed-off-by: Andy Adamson <andros@netapp.com>
---
 utils/mount/parse_dev.c | 30 ++++++++++++++++++++----------
 utils/mount/parse_dev.h |  2 +-
 utils/mount/stropts.c   |  3 ++-
 utils/mount/utils.c     |  2 +-
 4 files changed, 24 insertions(+), 13 deletions(-)

diff --git a/utils/mount/parse_dev.c b/utils/mount/parse_dev.c
index 0d3bcb9..c5d2215 100644
--- a/utils/mount/parse_dev.c
+++ b/utils/mount/parse_dev.c
@@ -79,10 +79,10 @@ static int nfs_pdn_missing_brace_err(void)
 /*
  * Standard hostname:path format
  */
-static int nfs_parse_simple_hostname(const char *dev,
-				     char **hostname, char **pathname)
+static int nfs_parse_simple_hostname(const char *dev, char **hostname,
+				     char **multinames, char **pathname)
 {
-	size_t host_len, path_len;
+	size_t host_len, multi_len = 0, path_len;
 	char *colon, *comma;
 
 	/* Must have a colon */
@@ -96,13 +96,15 @@ static int nfs_parse_simple_hostname(const char *dev,
 		return nfs_pdn_hostname_too_long_err();
 
 	/* If there's a comma before the colon, take only the
-	 * first name in list */
+	 * first name in list as the hostname, the rest get stored in
+	 * the multinames. Note that NFS_MAXHOSTNAME limits the number
+	 * of multinames */
 	comma = strchr(dev, ',');
 	if (comma != NULL) {
 		*comma = '\0';
 		host_len = comma - dev;
-		nfs_error(_("%s: warning: multiple hostnames not supported"),
-				progname);
+		comma++;
+		multi_len = colon - comma;
 	} else
 
 	colon++;
@@ -115,6 +117,11 @@ static int nfs_parse_simple_hostname(const char *dev,
 		if (*hostname == NULL)
 			return nfs_pdn_nomem_err();
 	}
+	if (multinames && multi_len != 0) {
+		*multinames = strndup(comma, multi_len);
+		if (*multinames == NULL)
+			return nfs_pdn_nomem_err();
+	}
 	if (pathname) {
 		*pathname = strndup(colon, path_len);
 		if (*pathname == NULL) {
@@ -196,11 +203,13 @@ static int nfs_parse_nfs_url(__attribute__((unused)) const char *dev,
  * nfs_parse_devname - Determine the server's hostname by looking at "devname".
  * @devname: pointer to mounted device name (first argument of mount command)
  * @hostname: OUT: pointer to server's hostname
+ * @multinames: OUT: pointer to comma separated multiple server interface names
  * @pathname: OUT: pointer to export path on server
  *
  * Returns 1 if succesful, or zero if some error occurred.  On success,
- * @hostname and @pathname point to dynamically allocated buffers containing
- * the hostname of the server and the export pathname (both '\0'-terminated).
+ * @hostname, @multinames, and @pathname point to dynamically allocated
+ * buffers containing the hostname of the server, other multiple server
+ * interfaces, and the export pathname (all '\0'-terminated).
  *
  * @hostname or @pathname may be NULL if caller doesn't want a copy of those
  * parts of @devname.
@@ -208,7 +217,7 @@ static int nfs_parse_nfs_url(__attribute__((unused)) const char *dev,
  * Note that this will not work if @devname is a wide-character string.
  */
 int nfs_parse_devname(const char *devname,
-		      char **hostname, char **pathname)
+		      char **hostname, char **multinames, char **pathname)
 {
 	char *dev;
 	int result;
@@ -225,7 +234,8 @@ int nfs_parse_devname(const char *devname,
 	else if (strncmp(dev, "nfs://", 6) == 0)
 		result = nfs_parse_nfs_url(dev, hostname, pathname);
 	else
-		result = nfs_parse_simple_hostname(dev, hostname, pathname);
+		result = nfs_parse_simple_hostname(dev, hostname, multinames,
+						   pathname);
 
 	free(dev);
 	return result;
diff --git a/utils/mount/parse_dev.h b/utils/mount/parse_dev.h
index f9857bc..ef663f8 100644
--- a/utils/mount/parse_dev.h
+++ b/utils/mount/parse_dev.h
@@ -23,6 +23,6 @@
 #ifndef __NFS_UTILS_PARSE_DEV_HEADER
 #define __NFS_UTILS_PARSE_DEV_HEADER
 
-extern int	nfs_parse_devname(const char *, char **, char **);
+extern int	nfs_parse_devname(const char *, char **, char **, char **);
 
 #endif	/* __NFS_UTILS_PARSE_DEV */
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 86829a9..75646f6 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -83,6 +83,7 @@ struct nfsmount_info {
 				*node,		/* mounted-on dir */
 				*type;		/* "nfs" or "nfs4" */
 	char			*hostname;	/* server's hostname */
+	char			*multinames;	/* more server interfaces */
 	struct addrinfo		*address;	/* server's addresses */
 
 	struct mount_options	*options;	/* parsed mount options */
@@ -377,7 +378,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	sa_family_t family;
 	int error;
 
-	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
+	if (!nfs_parse_devname(mi->spec, &mi->hostname, &mi->multinames,  NULL))
 		return 0;
 
 	if (!nfs_nfs_proto_family(mi->options, &family))
diff --git a/utils/mount/utils.c b/utils/mount/utils.c
index 92662ed..2b6ee74 100644
--- a/utils/mount/utils.c
+++ b/utils/mount/utils.c
@@ -159,7 +159,7 @@ int nfs_umount23(const char *devname, char *string)
 	struct mount_options *options;
 	int result = EX_FAIL;
 
-	if (!nfs_parse_devname(devname, &hostname, &dirname))
+	if (!nfs_parse_devname(devname, &hostname, NULL, &dirname))
 		return EX_USAGE;
 
 	options = po_split(string);
-- 
1.8.3.1

