From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 20/25] NFS: Set default port for NFSv4,
	with support for AF_INET6
Date: Tue, 13 Nov 2007 13:32:46 -0500
Message-ID: <20071113183246.5087.36926.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: netdev@vger.kernel.org
To: nfs@lists.sourceforge.net
Return-path: <nfs-bounces@lists.sourceforge.net>
Received: from sc8-sf-mx1-b.sourceforge.net ([10.3.1.91]
	helo=mail.sourceforge.net)
	by sc8-sf-list2-new.sourceforge.net with esmtp (Exim 4.43)
	id 1Is0Z5-0000X4-3U
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:49 -0800
Received: from flpi101.sbcis.sbc.com ([207.115.20.70] helo=flpi101.prodigy.net)
	by mail.sourceforge.net with esmtp (Exim 4.44) id 1Is0ZA-0000Iu-JY
	for nfs@lists.sourceforge.net; Tue, 13 Nov 2007 10:32:52 -0800
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

Move more address family dependencies to a helper function.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |   40 ++++++++++++++++++++++++++++++++--------
 1 files changed, 32 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 7dc56ce..1831394 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1573,6 +1573,31 @@ static void nfs4_fill_super(struct super_block *sb)
 }
 
 /*
+ * If the user didn't specify a port, set the port number to
+ * the NFS version 4 default port.
+ */
+static int nfs4_default_port(struct sockaddr *sap)
+{
+	switch (sap->sa_family) {
+	case AF_INET: {
+		struct sockaddr_in *ap = (struct sockaddr_in *)sap;
+		if (ap->sin_port == 0)
+			ap->sin_port = htons(NFS_PORT);
+		return 0;
+	}
+	case AF_INET6: {
+		struct sockaddr_in6 *ap = (struct sockaddr_in6 *)sap;
+		if (ap->sin6_port == 0)
+			ap->sin6_port = htons(NFS_PORT);
+		return 0;
+	}
+	default:
+		dfprintk(MOUNT, "NFS: unrecognized address family\n");
+		return -EAFNOSUPPORT;
+	}
+}
+
+/*
  * Validate NFSv4 mount options
  */
 static int nfs4_validate_mount_data(void *options,
@@ -1580,6 +1605,7 @@ static int nfs4_validate_mount_data(void *options,
 				    const char *dev_name)
 {
 	struct nfs4_mount_data *data = (struct nfs4_mount_data *)options;
+	struct sockaddr *sap = (struct sockaddr *)&args->nfs_server.address;
 	char *c;
 
 	if (data == NULL)
@@ -1604,10 +1630,9 @@ static int nfs4_validate_mount_data(void *options,
 				   data->host_addr,
 				   sizeof(args->nfs_server.address)))
 			return -EFAULT;
-		if (args->nfs_server.address.sin_port == 0)
-			args->nfs_server.address.sin_port = htons(NFS_PORT);
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (nfs4_default_port(sap))
+			goto out_no_address;
+		if (!nfs_verify_server_address(sap))
 			goto out_no_address;
 
 		switch (data->auth_flavourlen) {
@@ -1663,10 +1688,9 @@ static int nfs4_validate_mount_data(void *options,
 		if (nfs_parse_mount_options((char *)options, args) == 0)
 			return -EINVAL;
 
-		if (args->nfs_server.address.sin_port == 0)
-			args->nfs_server.address.sin_port = htons(NFS_PORT);
-		if (!nfs_verify_server_address((struct sockaddr *)
-						&args->nfs_server.address))
+		if (nfs4_default_port(sap))
+			return -EINVAL;
+		if (!nfs_verify_server_address(sap))
 			return -EINVAL;
 
 		switch (args->auth_flavor_len) {


-------------------------------------------------------------------------
This SF.net email is sponsored by: Splunk Inc.
Still grepping through log files to find problems?  Stop.
Now Search log events and configuration files using AJAX and a browser.
Download your FREE copy of Splunk now >> http://get.splunk.com/
_______________________________________________
NFS maillist  -  NFS@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/nfs
