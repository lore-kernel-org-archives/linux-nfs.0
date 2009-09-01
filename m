From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] mount.nfs: Detect "-t nfs -o vers=4" mounts
Date: Tue, 01 Sep 2009 10:29:17 -0400
Message-ID: <20090901142916.3886.67534.stgit@matisse.1015granger.net>
References: <20090901142357.3886.21465.stgit@matisse.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:58333 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754970AbZIAO3c (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 1 Sep 2009 10:29:32 -0400
In-Reply-To: <20090901142357.3886.21465.stgit-RytpoXr2tKZ9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

For "-t nfs -o vers=4" mounts, we want to skip v2/v3 version/transport
negotiation, and be sure to append the "clientaddr" option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/network.c |    2 +-
 utils/mount/network.h |    1 +
 utils/mount/stropts.c |   10 ++++++++--
 3 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/utils/mount/network.c b/utils/mount/network.c
index 420e15a..bd621be 100644
--- a/utils/mount/network.c
+++ b/utils/mount/network.c
@@ -1204,7 +1204,7 @@ nfs_nfs_program(struct mount_options *options, unsigned long *program)
  * Returns TRUE if @version contains a valid value for this option,
  * or FALSE if the option was specified with an invalid value.
  */
-static int
+int
 nfs_nfs_version(struct mount_options *options, unsigned long *version)
 {
 	long tmp;
diff --git a/utils/mount/network.h b/utils/mount/network.h
index db5134c..402e0a5 100644
--- a/utils/mount/network.h
+++ b/utils/mount/network.h
@@ -56,6 +56,7 @@ int clnt_ping(struct sockaddr_in *, const unsigned long,
 
 struct mount_options;
 
+int nfs_nfs_version(struct mount_options *options, unsigned long *version);
 int nfs_options2pmap(struct mount_options *,
 		      struct pmap *, struct pmap *);
 
diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index a12ace7..9113824 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -86,6 +86,7 @@ struct nfsmount_info {
 
 	int			flags,		/* MS_ flags */
 				fake,		/* actually do the mount? */
+				version,	/* NFS version */
 				child;		/* forked bg child? */
 };
 
@@ -272,7 +273,12 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 	if (!nfs_name_to_address(mi->hostname, sap, &salen))
 		return 0;
 
-	if (strncmp(mi->type, "nfs4", 4) == 0) {
+	if (!nfs_nfs_version(mi->options, &mi->version))
+		return 0;
+	if (strncmp(mi->type, "nfs4", 4) == 0)
+		mi->version = 4;
+
+	if (mi->version == 4) {
 		if (!nfs_append_clientaddr_option(sap, salen, mi->options))
 			return 0;
 	} else {
@@ -488,7 +494,7 @@ static int nfs_try_mount(struct nfsmount_info *mi)
 	char *options = NULL;
 	int result;
 
-	if (strncmp(mi->type, "nfs4", 4) != 0) {
+	if (mi->version != 4) {
 		if (!nfs_rewrite_pmap_mount_options(mi->options))
 			return 0;
 	}

