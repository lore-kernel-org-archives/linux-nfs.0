From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/14] text-based mount command: "addr=" option support for
	IPv6 addresses
Date: Wed, 09 Jul 2008 20:37:36 -0400
Message-ID: <20080710003735.6137.55651.stgit@tarkus.1015granger.net>
References: <20080710001725.6137.83845.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:61680 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751325AbYGJEIM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jul 2008 00:08:12 -0400
In-Reply-To: <20080710001725.6137.83845.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the append_addr_option() function to support sending either IPv4
or IPv6 addresses to the kernel via the "addr=" option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   21 ++++++---------------
 1 files changed, 6 insertions(+), 15 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a1ffca2..f856998 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -237,19 +237,12 @@ out_err:
  * Returns 1 if 'addr=' option appended successfully;
  * otherwise zero.
  */
-static int append_addr_option(struct sockaddr_in *saddr,
-			   struct mount_options *options)
+static int nfs_append_addr_option(const struct sockaddr *sap,
+				  socklen_t salen,
+				  struct mount_options *options)
 {
-	char new_option[24];
-
 	po_remove_all(options, "addr");
-
-	snprintf(new_option, sizeof(new_option) - 1,
-			"addr=%s", inet_ntoa(saddr->sin_addr));
-
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return nfs_append_generic_address_option(sap, salen, "addr", options);
 }
 
 /*
@@ -358,10 +351,8 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	if (!append_addr_option(&saddr, mi->options))
-		return 0;
-
-	return 1;
+	return nfs_append_addr_option((struct sockaddr *)&saddr,
+					sizeof(saddr), mi->options);
 }
 
 /*

