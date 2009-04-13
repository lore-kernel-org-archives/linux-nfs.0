From: "Serge E. Hallyn" <serue@us.ibm.com>
Subject: [PATCH] add some long-missing capabilities to fs_mask
Date: Mon, 13 Apr 2009 09:56:14 -0500
Message-ID: <20090413145614.GA15342@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mtk.manpages@gmail.com, Stephen Smalley <sds-FVV4AS6k8l2W8mdqIt43Ew@public.gmane.org>,
	Andrew Morgan <morgan@kernel.org>,
	linux-security-module@vger.kernel.org,
	lkml <linux-kernel@vger.kernel.org>, linux-nfs@vger.kernel.org,
	Igor Zhbanov <izh1979@gmail.com>,
	"J. Bruce Fields" <bfields@citi.umich.edu>, stable@kernel.org,
	linux-api@vger.kernel.org, Chris Wright <chrisw-69jw2NvuJkxg9hUCZPvPmw@public.gmane.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:58630 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751731AbZDMO4d (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Apr 2009 10:56:33 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

When POSIX capabilities were introduced during the 2.1 Linux
cycle, the fs mask, which represents the capabilities which having
fsuid==0 is supposed to grant, did not include CAP_MKNOD and
CAP_LINUX_IMMUTABLE.  However, before capabilities the privilege
to call these did in fact depend upon fsuid==0.

This patch introduces those capabilities into the fsmask,
restoring the old behavior.

See the thread starting at http://lkml.org/lkml/2009/3/11/157 for
reference.

Note that if this fix is deemed valid, then earlier kernel versions (2.4
and 2.2) ought to be fixed too.

Changelog:
	[Mar 23] Actually delete old CAP_FS_SET definition...
	[Mar 20] Updated against J. Bruce Fields's patch

Reported-by: Igor Zhbanov <izh1979@gmail.com>
Signed-off-by: Serge E. Hallyn <serue@us.ibm.com>
Cc: stable@kernel.org
Cc: J. Bruce Fields <bfields@citi.umich.edu>
---
 include/linux/capability.h |   23 +++++++++++++++++++----
 1 files changed, 19 insertions(+), 4 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index 4864a43..c302110 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -377,7 +377,21 @@ struct cpu_vfs_cap_data {
 #define CAP_FOR_EACH_U32(__capi)  \
 	for (__capi = 0; __capi < _KERNEL_CAPABILITY_U32S; ++__capi)
 
+/*
+ * CAP_FS_MASK and CAP_NFSD_MASKS:
+ *
+ * The fs mask is all the privileges that fsuid==0 historically meant.
+ * At one time in the past, that included CAP_MKNOD and CAP_LINUX_IMMUTABLE.
+ *
+ * It has never meant setting security.* and trusted.* xattrs.
+ *
+ * We could also define fsmask as follows:
+ *   1. CAP_FS_MASK is the privilege to bypass all fs-related DAC permissions
+ *   2. The security.* and trusted.* xattrs are fs-related MAC permissions
+ */
+
 # define CAP_FS_MASK_B0     (CAP_TO_MASK(CAP_CHOWN)		\
+			    | CAP_TO_MASK(CAP_MKNOD)		\
 			    | CAP_TO_MASK(CAP_DAC_OVERRIDE)	\
 			    | CAP_TO_MASK(CAP_DAC_READ_SEARCH)	\
 			    | CAP_TO_MASK(CAP_FOWNER)		\
@@ -392,11 +406,12 @@ struct cpu_vfs_cap_data {
 # define CAP_EMPTY_SET    ((kernel_cap_t){{ 0, 0 }})
 # define CAP_FULL_SET     ((kernel_cap_t){{ ~0, ~0 }})
 # define CAP_INIT_EFF_SET ((kernel_cap_t){{ ~CAP_TO_MASK(CAP_SETPCAP), ~0 }})
-# define CAP_FS_SET       ((kernel_cap_t){{ CAP_FS_MASK_B0, CAP_FS_MASK_B1 } })
+# define CAP_FS_SET       ((kernel_cap_t){{ CAP_FS_MASK_B0 \
+				    | CAP_TO_MASK(CAP_LINUX_IMMUTABLE), \
+				    CAP_FS_MASK_B1 } })
 # define CAP_NFSD_SET     ((kernel_cap_t){{ CAP_FS_MASK_B0 \
-					    | CAP_TO_MASK(CAP_SYS_RESOURCE) \
-					    | CAP_TO_MASK(CAP_MKNOD), \
-					    CAP_FS_MASK_B1 } })
+				    | CAP_TO_MASK(CAP_SYS_RESOURCE), \
+				    CAP_FS_MASK_B1 } })
 
 #endif /* _KERNEL_CAPABILITY_U32S != 2 */
 
-- 
1.5.4.3


----- End forwarded message -----
