From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/7] text-based mount command: pass "sloppy" when -s is set
Date: Mon, 30 Jun 2008 13:10:47 -0400
Message-ID: <20080630171046.9905.32473.stgit@ellison.1015granger.net>
References: <20080630170420.9905.90111.stgit@ellison.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: steved@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:29818 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753552AbYF3RLP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 30 Jun 2008 13:11:15 -0400
In-Reply-To: <20080630170420.9905.90111.stgit-ewv44WTpT0t9HhUboXbp9zCvJB+x5qRC@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the "-s" option is ignored by the text-based mount interface.  To
notify the kernel that sloppy mount option parsing is needed, add "sloppy"
to the string of mount options passed to the kernel.

The 2.6.23 - 2.6.26 kernels will fail the mount if "sloppy" is present, as
they won't recognize it.  To prevent them from ever seeing this option,
have the mount command check the kernel version before appending the option.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 utils/mount/stropts.c |   15 +++++++++++++++
 1 files changed, 15 insertions(+), 0 deletions(-)


diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
index c8148c4..34b4134 100644
--- a/utils/mount/stropts.c
+++ b/utils/mount/stropts.c
@@ -45,6 +45,7 @@
 #include "error.h"
 #include "network.h"
 #include "parse_opt.h"
+#include "version.h"
 
 #ifdef HAVE_RPCSVC_NFS_PROT_H
 #include <rpcsvc/nfs_prot.h>
@@ -76,6 +77,7 @@
 extern int nfs_mount_data_version;
 extern char *progname;
 extern int verbose;
+extern int sloppy;
 
 struct nfsmount_info {
 	const char		*spec,		/* server:/path */
@@ -287,6 +289,16 @@ static int verify_lock_option(struct mount_options *options)
 	return 1;
 }
 
+static int nfs_append_sloppy_option(struct mount_options *options)
+{
+	if (!sloppy || linux_version_code() < MAKE_VERSION(2, 6, 27))
+		return 1;
+
+	if (po_append(options, "sloppy") == PO_FAILED)
+		return 0;
+	return 1;
+}
+
 /*
  * Set up mandatory NFS mount options.
  *
@@ -309,6 +321,9 @@ static int nfs_validate_options(struct nfsmount_info *mi)
 			return 0;
 	}
 
+	if (!nfs_append_sloppy_option(mi->options))
+		return 0;
+
 	if (!append_addr_option(&saddr, mi->options))
 		return 0;
 

