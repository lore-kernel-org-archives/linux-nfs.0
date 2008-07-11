From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 08/14] text-based mount command: "mounthost=" option support
	for IPv6 addresses
Date: Fri, 11 Jul 2008 16:34:56 -0400
Message-ID: <20080711203456.478.724.stgit@tarkus.1015granger.net>
References: <20080711203322.478.52095.stgit@tarkus.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:39589 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756297AbYGKUfq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Jul 2008 16:35:46 -0400
In-Reply-To: <20080711203322.478.52095.stgit-lQeC5l55kZ7wdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Change the fix_mounthost_option() function to support resolving IPv6
addresses.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   33 +++++++++++++++++++++------------
 1 files changed, 21 insertions(+), 12 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index ff51652..e2e72a7 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -94,6 +94,8 @@ struct nfsmount_info {
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
 				child;		/* forked bg child? */
+
+	sa_family_t		family;		/* supported address family */
 };
 
 static int nfs_parse_devname(struct nfsmount_info *mi)
@@ -271,26 +273,28 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 
 /*
  * Resolve the 'mounthost=' hostname and append a new option using
- * the resulting IPv4 address.
+ * the resulting address.
  */
-static int fix_mounthost_option(struct mount_options *options)
+static int nfs_fix_mounthost_option(const sa_family_t family,
+				    struct mount_options *options)
 {
-	struct sockaddr_in maddr;
-	char *mounthost, new_option[32];
+	struct sockaddr_storage dummy;
+	struct sockaddr *sap = (struct sockaddr *)&dummy;
+	socklen_t salen = sizeof(dummy);
+	char *mounthost;
 
 	mounthost = po_get(options, "mounthost");
 	if (!mounthost)
 		return 1;
 
-	if (!fill_ipv4_sockaddr(mounthost, &maddr))
+	if (!nfs_name_to_address(mounthost, family, sap, &salen)) {
+		nfs_error(_("%s: unable to determine mount server's address"),
+				progname);
 		return 0;
+	}
 
-	snprintf(new_option, sizeof(new_option) - 1,
-			"mountaddr=%s", inet_ntoa(maddr.sin_addr));
-
-	if (po_append(options, new_option) == PO_SUCCEEDED)
-		return 1;
-	return 0;
+	return nfs_append_generic_address_option(sap, salen,
+							"mountaddr", options);
 }
 
 /*
@@ -340,7 +344,7 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 						  sizeof(saddr), mi->options))
 			return 0;
 	} else {
-		if (!fix_mounthost_option(mi->options))
+		if (!nfs_fix_mounthost_option(mi->family, mi->options))
 			return 0;
 		if (!mi->fake && !verify_lock_option(mi->options))
 			return 0;
@@ -800,6 +804,11 @@ int nfsmount_string(const char *spec, const char *node, const char *type,
 		.flags		= flags,
 		.fake		= fake,
 		.child		= child,
+#ifdef IPV6_SUPPORTED
+		.family		= AF_UNSPEC,	/* either IPv4 or v6 */
+#else
+		.family		= AF_INET,	/* only IPv4 */
+#endif
 	};
 	int retval = EX_FAIL;
 

