From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/14] text-based mount command: "clientaddr=" option support
	for IPv6 addresses
Date: Wed, 09 Jul 2008 20:37:42 -0400
Message-ID: <20080710003741.6137.48877.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from agminet01.oracle.com ([141.146.126.228]:12525 "EHLO
	agminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751374AbYGJEIL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:11 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the append_clientaddr_option() function to support sending either
IPv4 or IPv6 addresses to the kernel via the "clientaddr=" option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   26 ++++++++++++--------------
 1 files changed, 12 insertions(+), 14 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index f856998..ff51652 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -252,24 +252,21 @@ static int nfs_append_addr_option(const struct sockaddr *sap,
  * Returns 1 if 'clientaddr=' option created successfully or if
  * 'clientaddr=' option is already present; otherwise zero.
  */
-static int append_clientaddr_option(struct sockaddr_in *saddr,
-				    struct mount_options *options)
+static int nfs_append_clientaddr_option(const struct sockaddr *sap,
+					socklen_t salen,
+					struct mount_options *options)
 {
-	struct sockaddr_in my_addr;
-	char new_option[32];
+	struct sockaddr_storage dummy;
+	struct sockaddr *my_addr = (struct sockaddr *)&dummy;
+	socklen_t my_len = sizeof(dummy);
 
-	if (po_contains(options, "clientaddr") == PO_SUCCEEDED)
+	if (po_contains(options, "clientaddr") == PO_FOUND)
 		return 1;
 
-	if (!get_client_address(saddr, &my_addr))
-		return 0;
-
-	snprintf(new_option, sizeof(new_option) - 1,
-			"clientaddr=%s", inet_ntoa(my_addr.sin_addr));
+	nfs_callback_address(sap, salen, my_addr, &my_len);
 
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return nfs_append_generic_address_option(my_addr, my_len,
+							"clientaddr", options);
 }
 
 /*
@@ -339,7 +336,8 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
-		if (!append_clientaddr_option(&saddr, mi->options))
+		if (!nfs_append_clientaddr_option((struct sockaddr *)&saddr,
+						  sizeof(saddr), mi->options))
 			return 0;
 	} else {
 		if (!fix_mounthost_option(mi->options))

