Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:57922 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754059Ab1CKUbL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 11 Mar 2011 15:31:11 -0500
Received: by iwn34 with SMTP id 34so2995873iwn.19
        for <linux-nfs@vger.kernel.org>; Fri, 11 Mar 2011 12:31:10 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH] NFS: NFSROOT should default to "proto=udp"
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Fri, 11 Mar 2011 15:31:06 -0500
Message-ID: <20110311202750.12680.13402.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

There have been a number of recent reports that NFSROOT is no longer
working with default mount options, but fails only with certain NICs.

Brian Downing <bdowning@lavos.net> bisected to commit 56463e50 "NFS:
Use super.c for NFSROOT mount option parsing".  Among other things,
this commit changes the default mount options for NFSROOT to use TCP
instead of UDP as the underlying transport.

TCP seems less able to deal with NICs that are slow to initialize.
The system logs that have accompanied reports of problems all show
that NFSROOT attempts to establish a TCP connection before the NIC is
fully initialized, and thus the TCP connection attempt fails.

When a TCP connection attempt fails during a mount operation, the
NFS stack needs to fail the operation.  Usually user space knows how
and when to retry it.  The network layer does not report a distinct
error code for this particular failure mode.  Thus, there isn't a
clean way for the RPC client to see that it needs to retry in this
case, but not in others.

Because NFSROOT is used in some environments where it is not possible
to update the kernel command line to specify "udp", the proper thing
to do is change NFSROOT to use UDP by default, as it did before commit
56463e50.

To make it easier to see how to change default mount options for
NFSROOT and to distinguish default settings from mandatory settings,
I've adjusted a couple of areas to document the specifics.

root_nfs_cat() is also modified to deal with commas properly when
concatenating strings containing mount option lists.  This keeps
root_nfs_cat() call sites simpler, now that we may be concatenating
multiple mount option strings.

Tested-by: Brian Downing <bdowning@lavos.net>
Tested-by: Mark Brown <broonie@opensource.wolfsonmicro.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: <stable@kernel.org> # 2.6.37
---

Hi Trond-

This should work better than the old version.

 fs/nfs/nfsroot.c |   29 ++++++++++++++---------------
 1 files changed, 14 insertions(+), 15 deletions(-)

diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
index 903908a..c541093 100644
--- a/fs/nfs/nfsroot.c
+++ b/fs/nfs/nfsroot.c
@@ -86,11 +86,14 @@
 /* Default path we try to mount. "%s" gets replaced by our IP address */
 #define NFS_ROOT		"/tftpboot/%s"
 
+/* Default NFSROOT mount options. */
+#define NFS_DEF_OPTIONS		"udp"
+
 /* Parameters passed from the kernel command line */
 static char nfs_root_parms[256] __initdata = "";
 
 /* Text-based mount options passed to super.c */
-static char nfs_root_options[256] __initdata = "";
+static char nfs_root_options[256] __initdata = NFS_DEF_OPTIONS;
 
 /* Address of NFS server */
 static __be32 servaddr __initdata = htonl(INADDR_NONE);
@@ -160,8 +163,14 @@ static int __init root_nfs_copy(char *dest, const char *src,
 }
 
 static int __init root_nfs_cat(char *dest, const char *src,
-				  const size_t destlen)
+			       const size_t destlen)
 {
+	size_t len = strlen(dest);
+
+	if (len && dest[len - 1] != ',')
+		if (strlcat(dest, ",", destlen) > destlen)
+			return -1;
+
 	if (strlcat(dest, src, destlen) > destlen)
 		return -1;
 	return 0;
@@ -194,16 +203,6 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
 		if (root_nfs_cat(nfs_root_options, incoming,
 						sizeof(nfs_root_options)))
 			return -1;
-
-	/*
-	 * Possibly prepare for more options to be appended
-	 */
-	if (nfs_root_options[0] != '\0' &&
-	    nfs_root_options[strlen(nfs_root_options)] != ',')
-		if (root_nfs_cat(nfs_root_options, ",",
-						sizeof(nfs_root_options)))
-			return -1;
-
 	return 0;
 }
 
@@ -217,7 +216,7 @@ static int __init root_nfs_parse_options(char *incoming, char *exppath,
  */
 static int __init root_nfs_data(char *cmdline)
 {
-	char addr_option[sizeof("nolock,addr=") + INET_ADDRSTRLEN + 1];
+	char mand_options[sizeof("nolock,addr=") + INET_ADDRSTRLEN + 1];
 	int len, retval = -1;
 	char *tmp = NULL;
 	const size_t tmplen = sizeof(nfs_export_path);
@@ -244,9 +243,9 @@ static int __init root_nfs_data(char *cmdline)
 	 * Append mandatory options for nfsroot so they override
 	 * what has come before
 	 */
-	snprintf(addr_option, sizeof(addr_option), "nolock,addr=%pI4",
+	snprintf(mand_options, sizeof(mand_options), "nolock,addr=%pI4",
 			&servaddr);
-	if (root_nfs_cat(nfs_root_options, addr_option,
+	if (root_nfs_cat(nfs_root_options, mand_options,
 						sizeof(nfs_root_options)))
 		goto out_optionstoolong;
 

