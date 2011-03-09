Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:54938 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751456Ab1CIVyV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 9 Mar 2011 16:54:21 -0500
Message-ID: <4D77F705.3020409@parallels.com>
Date: Wed, 9 Mar 2011 15:54:13 -0600
From: Rob Landley <rlandley@parallels.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>, <linux-nfs@vger.kernel.org>
Subject: [PATCH] cleanup: save 60 lines/100 bytes by combining two mostly
 duplicate functions.
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Rob Landley <rlandley@parallels.com>

Eliminate two mostly duplicate functions (nfs_parse_simple_hostname()
and nfs_parse_protected_hostname()) and instead just make the calling
function (nfs_parse_devname()) do everything.

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

 add/remove: 0/0 grow/shrink: 0/1 up/down: 0/-112 (-112)
 function                                     old     new   delta
 nfs_parse_devname                            511     399    -112

 fs/nfs/super.c |  129 ++++++++++++-----------------------------------
 1 file changed, 33 insertions(+), 96 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b68c860..7e13e1a 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1665,99 +1598,59 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	return nfs_walk_authlist(args, &request);
 }
 
-static int nfs_parse_simple_hostname(const char *dev_name,
-				     char **hostname, size_t maxnamlen,
-				     char **export_path, size_t maxpathlen)
+/*
+ * Split "dev_name" into "hostname:export_path".
+ *
+ * The leftmost colon demarks the split between the server's hostname
+ * and the export path.  If the hostname starts with a left square
+ * bracket, then it may contain colons.
+ *
+ * Note: caller frees hostname and export path, even on error.
+ */
+static int nfs_parse_devname(const char *dev_name,
+			     char **hostname, size_t maxnamlen,
+			     char **export_path, size_t maxpathlen)
 {
 	size_t len;
-	char *colon, *comma;
+	char *end;
 
-	colon = strchr(dev_name, ':');
-	if (colon == NULL)
-		goto out_bad_devname;
-
-	len = colon - dev_name;
-	if (len > maxnamlen)
-		goto out_hostname;
-
-	/* N.B. caller will free nfs_server.hostname in all cases */
-	*hostname = kstrndup(dev_name, len, GFP_KERNEL);
-	if (!*hostname)
-		goto out_nomem;
-
-	/* kill possible hostname list: not supported */
-	comma = strchr(*hostname, ',');
-	if (comma != NULL) {
-		if (comma == *hostname)
+	/* Is the host name protected with square brakcets? */
+	if (*dev_name == '[') {
+		end = strchr(++dev_name, ']');
+		if (end == NULL || end[1] != ':')
 			goto out_bad_devname;
-		*comma = '\0';
-	}
-
-	colon++;
-	len = strlen(colon);
-	if (len > maxpathlen)
-		goto out_path;
-	*export_path = kstrndup(colon, len, GFP_KERNEL);
-	if (!*export_path)
-		goto out_nomem;
-
-	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *export_path);
-	return 0;
-
-out_bad_devname:
-	dfprintk(MOUNT, "NFS: device name not in host:path format\n");
-	return -EINVAL;
 
-out_nomem:
-	dfprintk(MOUNT, "NFS: not enough memory to parse device name\n");
-	return -ENOMEM;
-
-out_hostname:
-	dfprintk(MOUNT, "NFS: server hostname too long\n");
-	return -ENAMETOOLONG;
-
-out_path:
-	dfprintk(MOUNT, "NFS: export pathname too long\n");
-	return -ENAMETOOLONG;
-}
-
-/*
- * Hostname has square brackets around it because it contains one or
- * more colons.  We look for the first closing square bracket, and a
- * colon must follow it.
- */
-static int nfs_parse_protected_hostname(const char *dev_name,
-					char **hostname, size_t maxnamlen,
-					char **export_path, size_t maxpathlen)
-{
-	size_t len;
-	char *start, *end;
+		len = end - dev_name;
+		end++;
+	} else {
+		char *comma;
 
-	start = (char *)(dev_name + 1);
+		end = strchr(dev_name, ':');
+		if (end == NULL)
+			goto out_bad_devname;
+		len = end - dev_name;
 
-	end = strchr(start, ']');
-	if (end == NULL)
-		goto out_bad_devname;
-	if (*(end + 1) != ':')
-		goto out_bad_devname;
+		/* kill possible hostname list: not supported */
+		comma = strchr(dev_name, ',');
+		if (comma != NULL && comma < end)
+			*comma = 0;
+	}
 
-	len = end - start;
 	if (len > maxnamlen)
 		goto out_hostname;
 
 	/* N.B. caller will free nfs_server.hostname in all cases */
-	*hostname = kstrndup(start, len, GFP_KERNEL);
+	*hostname = kstrndup(dev_name, len, GFP_KERNEL);
 	if (*hostname == NULL)
 		goto out_nomem;
-
-	end += 2;
-	len = strlen(end);
+	len = strlen(++end);
 	if (len > maxpathlen)
 		goto out_path;
 	*export_path = kstrndup(end, len, GFP_KERNEL);
 	if (!*export_path)
 		goto out_nomem;
 
+	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *export_path);
 	return 0;
 
 out_bad_devname:
@@ -1778,29 +1671,6 @@ out_path:
 }
 
 /*
- * Split "dev_name" into "hostname:export_path".
- *
- * The leftmost colon demarks the split between the server's hostname
- * and the export path.  If the hostname starts with a left square
- * bracket, then it may contain colons.
- *
- * Note: caller frees hostname and export path, even on error.
- */
-static int nfs_parse_devname(const char *dev_name,
-			     char **hostname, size_t maxnamlen,
-			     char **export_path, size_t maxpathlen)
-{
-	if (*dev_name == '[')
-		return nfs_parse_protected_hostname(dev_name,
-						    hostname, maxnamlen,
-						    export_path, maxpathlen);
-
-	return nfs_parse_simple_hostname(dev_name,
-					 hostname, maxnamlen,
-					 export_path, maxpathlen);
-}
-
-/*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  *
