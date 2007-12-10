From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 25/27] NFS: Refactor mount option address parsing into
	separate function
Date: Mon, 10 Dec 2007 14:59:21 -0500
Message-ID: <20071210195921.2823.22100.stgit@manray.1015granger.net>
References: <20071210195106.2823.43884.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi102.sbcis.sbc.com ([207.115.20.71]:39867 "EHLO
	flpi102.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756322AbXLJUE6 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Dec 2007 15:04:58 -0500
In-Reply-To: <20071210195106.2823.43884.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Refactor the logic to parse incoming text-based IP addresses.  Use the
in4_pton() function instead of the older in_aton(), following the lead
of the in-kernel CIFS client.

Later we'll add IPv6 address parsing using the matching in6_pton()
function.  For now we can't allow IPv6 address parsing: we must expand
the size of the address storage fields in the nfs_parsed_mount_options
struct before we can parse and store IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
---

 fs/nfs/super.c |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 4a3a5c0..bf98b8f 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -617,6 +617,26 @@ static int nfs_verify_server_address(struct sockaddr *addr)
 }
 
 /*
+ * Parse string addresses passed in via a mount option,
+ * and construct a sockaddr based on the result.
+ *
+ * If address parsing fails, set the sockaddr's address
+ * family to AF_UNSPEC to force nfs_verify_server_address()
+ * to punt the mount.
+ */
+static void nfs_parse_server_address(char *value,
+				     struct sockaddr *sap)
+{
+	struct sockaddr_in *ap = (void *)sap;
+
+	ap->sin_family = AF_INET;
+	if (in4_pton(value, -1, (u8 *)&ap->sin_addr.s_addr, '\0', NULL))
+		return;
+
+	sap->sa_family = AF_UNSPEC;
+}
+
+/*
  * Error-check and convert a string of mount options from user space into
  * a data structure
  */
@@ -939,9 +959,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->nfs_server.address.sin_family = AF_INET;
-			mnt->nfs_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string, (struct sockaddr *)
+						 &mnt->nfs_server.address);
 			kfree(string);
 			break;
 		case Opt_clientaddr:
@@ -960,9 +979,8 @@ static int nfs_parse_mount_options(char *raw,
 			string = match_strdup(args);
 			if (string == NULL)
 				goto out_nomem;
-			mnt->mount_server.address.sin_family = AF_INET;
-			mnt->mount_server.address.sin_addr.s_addr =
-							in_aton(string);
+			nfs_parse_server_address(string, (struct sockaddr *)
+						 &mnt->mount_server.address);
 			kfree(string);
 			break;
 

