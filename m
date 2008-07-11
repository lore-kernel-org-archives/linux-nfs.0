From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 09/14] text-based mount command: Add IPv6 support to
	set_mandatory_options
Date: Fri, 11 Jul 2008 16:35:01 -0400
Message-ID: <20080711203501.478.17875.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39614 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757473AbYGKUfw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:52 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   12 ++++++------
 1 files changed, 6 insertions(+), 6 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index e2e72a7..caa2c25 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -334,14 +334,15 @@ static int nfs_append_sloppy_option(struct mount_options *options)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
-	struct sockaddr_in saddr;
+	struct sockaddr_storage dummy;
+	struct sockaddr *sap = (struct sockaddr *)&dummy;
+	socklen_t salen = sizeof(dummy);
 
-	if (!fill_ipv4_sockaddr(mi->hostname, &saddr))
+	if (!nfs_name_to_address(mi->hostname, mi->family, sap, &salen))
 		return 0;
 
 	if (strncmp(mi->type, "nfs4", 4) == 0) {
-		if (!nfs_append_clientaddr_option((struct sockaddr *)&saddr,
-						  sizeof(saddr), mi->options))
+		if (!nfs_append_clientaddr_option(sap, salen, mi->options))
 			return 0;
 	} else {
 		if (!nfs_fix_mounthost_option(mi->family, mi->options))
@@ -353,8 +354,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_append_sloppy_option(mi->options))
 		return 0;
 
-	return nfs_append_addr_option((struct sockaddr *)&saddr,
-					sizeof(saddr), mi->options);
+	return nfs_append_addr_option(sap, salen, mi->options);
 }
 
 /*

