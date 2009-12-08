From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 07/10] mount.nfs: proto=netid forces address family when
	resolving server names
Date: Tue, 08 Dec 2009 13:00:25 -0500
Message-ID: <20091208180024.2544.78485.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:42141 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965748AbZLHSA7 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:59 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using the netid settings, determine the correct address family to use
for NFS and MNT server name resolution.  Use this family when
resolving the server name for the addr= and mountaddr= options.

This patch assumes the kernel can recognize a netid, instead of a
protocol name, as the value of the proto= options.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   31 +++++++++++++++++++++++--------
 1 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c4fccbc..f2389f5 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -225,21 +225,33 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 }
 
 /*
- * Resolve the 'mounthost=' hostname and append a new option using
- * the resulting address.
+ * Determine whether to append a 'mountaddr=' option.  The option is needed if:
+ *
+ *   1. "mounthost=" was specified, or
+ *   2. The address families for proto= and mountproto= are different.
  */
-static int nfs_fix_mounthost_option(struct mount_options *options)
+static int nfs_fix_mounthost_option(struct mount_options *options,
+		const char *nfs_hostname)
 {
 	union nfs_sockaddr address;
 	struct sockaddr *sap = &address.sa;
 	socklen_t salen = sizeof(address);
+	sa_family_t nfs_family, mnt_family;
 	char *mounthost;
 
+	if (!nfs_nfs_proto_family(options, &nfs_family))
+		return 0;
+	if (!nfs_mount_proto_family(options, &mnt_family))
+		return 0;
+
 	mounthost = po_get(options, "mounthost");
-	if (!mounthost)
-		return 1;
+	if (mounthost == NULL) {
+		if (nfs_family == mnt_family)
+			return 1;
+		mounthost = (char *)nfs_hostname;
+	}
 
-	if (!nfs_name_to_address(mounthost, sap, &salen)) {
+	if (!nfs_lookup(mounthost, mnt_family, sap, &salen)) {
 		nfs_error(_("%s: unable to determine mount server's address"),
 				progname);
 		return 0;
@@ -327,12 +339,15 @@ static int nfs_set_version(struct nfsmount_info *mi)
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
 	struct sockaddr *sap = &mi->address.sa;
+	sa_family_t family;
 
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
 
+	if (!nfs_nfs_proto_family(mi->options, &family))
+		return 0;
 	mi->salen = sizeof(mi->address);
-	if (!nfs_name_to_address(mi->hostname, sap, &mi->salen))
+	if (!nfs_lookup(mi->hostname, family, sap, &mi->salen))
 		return 0;
 
 	if (!nfs_set_version(mi))
@@ -565,7 +580,7 @@ static int nfs_try_mount_v3v2(struct nfsmount_info *mi)
 		return result;
 	}
 
-	if (!nfs_fix_mounthost_option(options)) {
+	if (!nfs_fix_mounthost_option(options, mi->hostname)) {
 		errno = EINVAL;
 		goto out_fail;
 	}

