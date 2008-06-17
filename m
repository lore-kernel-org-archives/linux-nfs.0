From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Use common device name parsing logic for NFSv4 and
	NFSv2/v3
Date: Tue, 17 Jun 2008 14:17:19 -0400
Message-ID: <20080617181719.3215.5824.stgit@ellison.1015granger.net>
References: <20080617181622.3215.61295.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:55980 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756178AbYFQSUb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Jun 2008 14:20:31 -0400
In-Reply-To: <20080617181622.3215.61295.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

To support passing a raw IPv6 address as a server hostname, we need to
expand the logic that handles splitting the passed-in device name into
a server hostname and export path

Start by pulling device name parsing out of the mount option validation
functions and into separate helper functions.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |  124 ++++++++++++++++++++++++++++++++++++--------------------
 1 files changed, 79 insertions(+), 45 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index d884f52..5e0eefa 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1216,6 +1216,67 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 }
 
 /*
+ * Split "dev_name" into "hostname:export_path".
+ *
+ * Note: caller frees hostname and export path, even on error.
+ */
+static int nfs_parse_devname(const char *dev_name,
+			     char **hostname, size_t maxnamlen,
+			     char **export_path, size_t maxpathlen)
+{
+	size_t len;
+	char *colon, *comma;
+
+	colon = strchr(dev_name, ':');
+	if (colon == NULL)
+		goto out_bad_devname;
+
+	len = colon - dev_name;
+	if (len > maxnamlen)
+		goto out_hostname;
+
+	/* N.B. caller will free nfs_server.hostname in all cases */
+	*hostname = kstrndup(dev_name, len, GFP_KERNEL);
+	if (!*hostname)
+		goto out_nomem;
+
+	/* kill possible hostname list: not supported */
+	comma = strchr(*hostname, ',');
+	if (comma != NULL) {
+		if (comma == *hostname)
+			goto out_bad_devname;
+		*comma = '\0';
+	}
+
+	colon++;
+	len = strlen(colon);
+	if (len > maxpathlen)
+		goto out_path;
+	*export_path = kstrndup(colon, len, GFP_KERNEL);
+	if (!*export_path)
+		goto out_nomem;
+
+	dfprintk(MOUNT, "NFS: MNTPATH: '%s'\n", *export_path);
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
  * Validate the NFS2/NFS3 mount data
  * - fills in the mount root filehandle
  *
@@ -1341,8 +1402,6 @@ static int nfs_validate_mount_data(void *options,
 
 		break;
 	default: {
-		unsigned int len;
-		char *c;
 		int status;
 
 		if (nfs_parse_mount_options((char *)options, args) == 0)
@@ -1357,21 +1416,17 @@ static int nfs_validate_mount_data(void *options,
 
 		nfs_set_transport_defaults(args);
 
-		c = strchr(dev_name, ':');
-		if (c == NULL)
-			return -EINVAL;
-		len = c - dev_name;
-		/* N.B. caller will free nfs_server.hostname in all cases */
-		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
-		if (!args->nfs_server.hostname)
-			goto out_nomem;
+		status = nfs_parse_devname(dev_name,
+					   &args->nfs_server.hostname,
+					   PAGE_SIZE,
+					   &args->nfs_server.export_path,
+					   NFS_MAXPATHLEN);
+		if (!status)
+			status = nfs_try_mount(args, mntfh);
 
-		c++;
-		if (strlen(c) > NFS_MAXPATHLEN)
-			return -ENAMETOOLONG;
-		args->nfs_server.export_path = c;
+		kfree(args->nfs_server.export_path);
+		args->nfs_server.export_path = NULL;
 
-		status = nfs_try_mount(args, mntfh);
 		if (status)
 			return status;
 
@@ -1898,7 +1953,7 @@ static int nfs4_validate_mount_data(void *options,
 
 		break;
 	default: {
-		unsigned int len;
+		int status;
 
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
@@ -1922,34 +1977,17 @@ static int nfs4_validate_mount_data(void *options,
 			goto out_inval_auth;
 		}
 
-		/*
-		 * Split "dev_name" into "hostname:mntpath".
-		 */
-		c = strchr(dev_name, ':');
-		if (c == NULL)
-			return -EINVAL;
-		/* while calculating len, pretend ':' is '\0' */
-		len = c - dev_name;
-		if (len > NFS4_MAXNAMLEN)
-			return -ENAMETOOLONG;
-		/* N.B. caller will free nfs_server.hostname in all cases */
-		args->nfs_server.hostname = kstrndup(dev_name, len, GFP_KERNEL);
-		if (!args->nfs_server.hostname)
-			goto out_nomem;
-
-		c++;			/* step over the ':' */
-		len = strlen(c);
-		if (len > NFS4_MAXPATHLEN)
-			return -ENAMETOOLONG;
-		args->nfs_server.export_path = kstrndup(c, len, GFP_KERNEL);
-		if (!args->nfs_server.export_path)
-			goto out_nomem;
-
-		dprintk("NFS: MNTPATH: '%s'\n", args->nfs_server.export_path);
-
 		if (args->client_address == NULL)
 			goto out_no_client_address;
 
+		status = nfs_parse_devname(dev_name,
+					   &args->nfs_server.hostname,
+					   NFS4_MAXNAMLEN,
+					   &args->nfs_server.export_path,
+					   NFS4_MAXPATHLEN);
+		if (status < 0)
+			return status;
+
 		break;
 		}
 	}
@@ -1965,10 +2003,6 @@ out_inval_auth:
 		 data->auth_flavourlen);
 	return -EINVAL;
 
-out_nomem:
-	dfprintk(MOUNT, "NFS4: not enough memory to handle mount options\n");
-	return -ENOMEM;
-
 out_no_address:
 	dfprintk(MOUNT, "NFS4: mount program didn't pass remote address\n");
 	return -EINVAL;

