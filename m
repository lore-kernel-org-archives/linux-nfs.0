From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 06/10] mount.nfs: Fix sockaddr pointer aliasing in stropts.c
Date: Tue, 08 Dec 2009 13:00:16 -0500
Message-ID: <20091208180015.2544.89381.stgit@localhost.localdomain>
References: <20091208175128.2544.457.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:62201 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965739AbZLHSAt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Dec 2009 13:00:49 -0500
In-Reply-To: <20091208175128.2544.457.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Using a sockaddr_storage and casting a sockaddr pointer to it breaks
C's aliasing rules.

See:

  https://bugzilla.redhat.com/show_bug.cgi?id=448743

Replacing sockaddr_storage makes this code less likely to break when
optimized by gcc.  It also saves a significant amount of stack space
by replacing a 130 byte structure with a union that is less than 32
bytes.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   32 +++++++++++++++++++-------------
 1 files changed, 19 insertions(+), 13 deletions(-)

diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index 40f8bd9..c4fccbc 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -77,12 +77,18 @@ extern char *progname;
 extern int verbose;
 extern int sloppy;
 
+union nfs_sockaddr {
+	struct sockaddr		sa;
+	struct sockaddr_in	s4;
+	struct sockaddr_in6	s6;
+};
+
 struct nfsmount_info {
 	const char		*spec,		/* server:/path */
 				*node,		/* mounted-on dir */
 				*type;		/* "nfs" or "nfs4" */
 	char			*hostname;	/* server's hostname */
-	struct sockaddr_storage	address;	/* server's address */
+	union nfs_sockaddr	address;
 	socklen_t		salen;		/* size of server's address */
 
 	struct mount_options	*options;	/* parsed mount options */
@@ -205,9 +211,9 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
 					socklen_t salen,
 					struct mount_options *options)
 {
-	struct sockaddr_storage dummy;
-	struct sockaddr *my_addr = (struct sockaddr *)&dummy;
-	socklen_t my_len = sizeof(dummy);
+	union nfs_sockaddr address;
+	struct sockaddr *my_addr = &address.sa;
+	socklen_t my_len = sizeof(address);
 
 	if (po_contains(options, "clientaddr") == PO_FOUND)
 		return 1;
@@ -224,9 +230,9 @@ static int nfs_append_clientaddr_option(const struct sockaddr *sap,
  */
 static int nfs_fix_mounthost_option(struct mount_options *options)
 {
-	struct sockaddr_storage dummy;
-	struct sockaddr *sap = (struct sockaddr *)&dummy;
-	socklen_t salen = sizeof(dummy);
+	union nfs_sockaddr address;
+	struct sockaddr *sap = &address.sa;
+	socklen_t salen = sizeof(address);
 	char *mounthost;
 
 	mounthost = po_get(options, "mounthost");
@@ -320,7 +326,7 @@ static int nfs_set_version(struct nfsmount_info *mi)
  */
 static int nfs_validate_options(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = (struct sockaddr *)&mi->address;
+	struct sockaddr *sap = &mi->address.sa;
 
 	if (!nfs_parse_devname(mi->spec, &mi->hostname, NULL))
 		return 0;
@@ -453,12 +459,12 @@ static int nfs_construct_new_options(struct mount_options *options,
 static int
 nfs_rewrite_pmap_mount_options(struct mount_options *options)
 {
-	struct sockaddr_storage nfs_address;
-	struct sockaddr *nfs_saddr = (struct sockaddr *)&nfs_address;
+	union nfs_sockaddr nfs_address;
+	struct sockaddr *nfs_saddr = &nfs_address.sa;
 	socklen_t nfs_salen = sizeof(nfs_address);
 	struct pmap nfs_pmap;
-	struct sockaddr_storage mnt_address;
-	struct sockaddr *mnt_saddr = (struct sockaddr *)&mnt_address;
+	union nfs_sockaddr mnt_address;
+	struct sockaddr *mnt_saddr = &mnt_address.sa;
 	socklen_t mnt_salen = sizeof(mnt_address);
 	struct pmap mnt_pmap;
 	char *option;
@@ -594,7 +600,7 @@ out_fail:
  */
 static int nfs_try_mount_v4(struct nfsmount_info *mi)
 {
-	struct sockaddr *sap = (struct sockaddr *)&mi->address;
+	struct sockaddr *sap = &mi->address.sa;
 	struct mount_options *options = po_dup(mi->options);
 	int result = 0;
 

