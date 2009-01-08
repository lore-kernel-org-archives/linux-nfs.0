From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] text-based mount options: Use new pmap stuffer when
	rewriting mount options
Date: Thu, 08 Jan 2009 12:32:53 -0500
Message-ID: <20090108173253.19893.3750.stgit@ingres.1015granger.net>
References: <20090108172526.19893.91621.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:64757 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752197AbZAHRde (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 8 Jan 2009 12:33:34 -0500
In-Reply-To: <20090108172526.19893.91621.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Call nfs_options2pmap() in nfs_rewrite_mount_options() instead of
open-coding the logic to convert mount options to a pmap struct.
The new nfs_options2pmap() function is more careful about avoiding
invalid mount option values, and handles multiply-specified transport
protocol options correctly.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   68 ++++---------------------------------------------
 1 files changed, 5 insertions(+), 63 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index bd127ab..99be0f3 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -322,19 +322,12 @@ static int nfs_is_permanent_error(int error)
  * Returns a new group of mount options if successful; otherwise
  * NULL is returned if some failure occurred.
  */
-static const char *nfs_transport_opttbl[] = {
-	"udp",
-	"tcp",
-	NULL,
-};
-
 static struct mount_options *nfs_rewrite_mount_options(char *str)
 {
 	struct mount_options *options;
 	char *option, new_option[64];
 	clnt_addr_t mnt_server = { };
 	clnt_addr_t nfs_server = { };
-	int p;
 
 	options = po_split(str);
 	if (!options) {
@@ -360,64 +353,13 @@ static struct mount_options *nfs_rewrite_mount_options(char *str)
 		memcpy(&mnt_server.saddr, &nfs_server.saddr,
 				sizeof(mnt_server.saddr));
 
-	option = po_get(options, "mountport");
-	if (option)
-		mnt_server.pmap.pm_port = atoi(option);
-	mnt_server.pmap.pm_prog = MOUNTPROG;
-	option = po_get(options, "mountvers");
-	if (option)
-		mnt_server.pmap.pm_vers = atoi(option);
-	option = po_get(options, "mountproto");
-	if (option) {
-		if (strcmp(option, "tcp") == 0) {
-			mnt_server.pmap.pm_prot = IPPROTO_TCP;
-			po_remove_all(options, "mountproto");
-		}
-		if (strcmp(option, "udp") == 0) {
-			mnt_server.pmap.pm_prot = IPPROTO_UDP;
-			po_remove_all(options, "mountproto");
-		}
-	}
+	nfs_options2pmap(options, &nfs_server.pmap, &mnt_server.pmap);
 
-	option = po_get(options, "port");
-	if (option) {
-		nfs_server.pmap.pm_port = atoi(option);
-		po_remove_all(options, "port");
-	}
+	/* The kernel NFS client doesn't support changing the RPC program
+	 * number for these services, so reset these fields before probing
+	 * the server's ports.  */
 	nfs_server.pmap.pm_prog = NFS_PROGRAM;
-
-	option = po_get(options, "nfsvers");
-	if (option) {
-		nfs_server.pmap.pm_vers = atoi(option);
-		po_remove_all(options, "nfsvers");
-	}
-	option = po_get(options, "vers");
-	if (option) {
-		nfs_server.pmap.pm_vers = atoi(option);
-		po_remove_all(options, "vers");
-	}
-	option = po_get(options, "proto");
-	if (option) {
-		if (strcmp(option, "tcp") == 0) {
-			nfs_server.pmap.pm_prot = IPPROTO_TCP;
-			po_remove_all(options, "proto");
-		}
-		if (strcmp(option, "udp") == 0) {
-			nfs_server.pmap.pm_prot = IPPROTO_UDP;
-			po_remove_all(options, "proto");
-		}
-	}
-	p = po_rightmost(options, nfs_transport_opttbl);
-	switch (p) {
-	case 1:
-		nfs_server.pmap.pm_prot = IPPROTO_UDP;
-		break;
-	case 2:
-		nfs_server.pmap.pm_prot = IPPROTO_TCP;
-		break;
-	}
-	po_remove_all(options, "tcp");
-	po_remove_all(options, "udp");
+	mnt_server.pmap.pm_prog = MOUNTPROG;
 
 	if (!probe_bothports(&mnt_server, &nfs_server)) {
 		errno = ESPIPE;

