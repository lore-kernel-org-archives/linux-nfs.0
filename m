From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 075/112] NFS: Refactor mount option address parsing into
	separate function
Date: Fri, 25 Jan 2008 11:37:50 -0500
Message-ID: <20080125163749.31887.35676.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:14355 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755542AbYAYRAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:00:01 -0500
Received: from svlexrs02.hq.netapp.com (svlexrs02.corp.netapp.com [10.57.156.154])
	by smtp2.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PGxsei010226
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:00:00 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

Refactor the logic to parse incoming text-based IP addresses.  Use the
in4_pton() function instead of the older in_aton(), following the lead
of the in-kernel CIFS client.

Later we'll add IPv6 address parsing using the matching in6_pton()
function.  For now we can't allow IPv6 address parsing: we must expand
the size of the address storage fields in the nfs_parsed_mount_options
struct before we can parse and store IPv6 addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Aurelien Charbon <aurelien.charbon-Z51IpKcfGtLk1uMJSBkQmQ@public.gmane.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/super.c |   30 ++++++++++++++++++++++++------
 1 files changed, 24 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f120be4..041fe9e 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -641,6 +641,26 @@ static int nfs_verify_server_address(struct sockaddr *addr)
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
@@ -963,9 +983,8 @@ static int nfs_parse_mount_options(char *raw,
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
@@ -984,9 +1003,8 @@ static int nfs_parse_mount_options(char *raw,
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
 
