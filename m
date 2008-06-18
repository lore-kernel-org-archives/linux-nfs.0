From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/4] NFS: Support raw IPv6 address hostnames during NFS mount
	operation
Date: Wed, 18 Jun 2008 18:32:04 -0400
Message-ID: <20080618223203.16006.61765.stgit@ellison.1015granger.net>
References: <20080618222951.16006.3679.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29734 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757219AbYFRWc0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2008 18:32:26 -0400
In-Reply-To: <20080618222951.16006.3679.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Traditionally the mount command has looked for a ":" to separate the
server's hostname from the export path in the mounted on device name,
like this:

	mount server:/export /mounted/on/dir

The server's hostname is "server" and the export path is "/export".

You can also substitute a specific IPv4 network address for the server
hostname, like this:

	mount 192.168.0.55:/export /mounted/on/dir

Raw IPv6 addresses present a problem, however, because they look
something like this:

	fe80::200:5aff:fe00:30b

Note the use of colons.

To get around the presence of colons, copy the Solaris convention used for
mounting IPv6 servers by address: wrap a raw IPv6 address with square
brackets.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   90 +++++++++++++++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 82 insertions(+), 8 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 5e0eefa..98c8110 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1215,14 +1215,9 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	return status;
 }
 
-/*
- * Split "dev_name" into "hostname:export_path".
- *
- * Note: caller frees hostname and export path, even on error.
- */
-static int nfs_parse_devname(const char *dev_name,
-			     char **hostname, size_t maxnamlen,
-			     char **export_path, size_t maxpathlen)
+static int nfs_parse_simple_hostname(const char *dev_name,
+				     char **hostname, size_t maxnamlen,
+				     char **export_path, size_t maxpathlen)
 {
 	size_t len;
 	char *colon, *comma;
@@ -1277,6 +1272,85 @@ out_path:
 }
 
 /*
+ * Hostname has square brackets around it because it contains one or
+ * more colons.  We look for the first closing square bracket, and a
+ * colon must follow it.
+ */
+static int nfs_parse_protected_hostname(const char *dev_name,
+					char **hostname, size_t maxnamlen,
+					char **export_path, size_t maxpathlen)
+{
+	size_t len;
+	char *start, *end;
+
+	start = (char *)(dev_name + 1);
+
+	end = strchr(start, ']');
+	if (end == NULL)
+		goto out_bad_devname;
+	if (*(end + 1) != ':')
+		goto out_bad_devname;
+
+	len = end - start;
+	if (len > maxnamlen)
+		goto out_hostname;
+
+	/* N.B. caller will free nfs_server.hostname in all cases */
+	*hostname = kstrndup(start, len, GFP_KERNEL);
+	if (*hostname == NULL)
+		goto out_nomem;
+
+	end += 2;
+	len = strlen(end);
+	if (len > maxpathlen)
+		goto out_path;
+	*export_path = kstrndup(end, len, GFP_KERNEL);
+	if (!*export_path)
+		goto out_nomem;
+
+	return 0;
+
+out_bad_devname:
+	dfprintk(MOUNT, "NFS: device name not in host:path format\n");
+	return -EINVAL;
+
+out_nomem:
+	dfprintk(MOUNT, "NFS: not enough memory to parse device name\n");
+	return -ENOMEM;
+
+out_hostname:
+	dfprintk(MOUNT, "NFS: server hostname too long\n");
+	return -ENAMETOOLONG;
+
+out_path:
+	dfprintk(MOUNT, "NFS: export pathname too long\n");
+	return -ENAMETOOLONG;
+}
+
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
+{
+	if (*dev_name == '[')
+		return nfs_parse_protected_hostname(dev_name,
+						    hostname, maxnamlen,
+						    export_path, maxpathlen);
+
+	return nfs_parse_simple_hostname(dev_name,
+					 hostname, maxnamlen,
+					 export_path, maxpathlen);
+}
+
+/*
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  *

