Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:7093 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753118Ab2LQPnQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 17 Dec 2012 10:43:16 -0500
From: Steve Dickson <steved@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>
Cc: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 05/13] KConfig: Add KConfig entries for Labeled NFS
Date: Mon, 17 Dec 2012 10:43:03 -0500
Message-Id: <1355758991-30049-6-git-send-email-steved@redhat.com>
In-Reply-To: <1355758991-30049-1-git-send-email-steved@redhat.com>
References: <1355758991-30049-1-git-send-email-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: David Quigley <dpquigl@davequigley.com>

This patch adds two entries into the fs/KConfig file. The first entry
NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
the server side.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: Miguel Rodel Felipe <Rodel_FM@dsi.a-star.edu.sg>
Signed-off-by: Phua Eu Gene <PHUA_Eu_Gene@dsi.a-star.edu.sg>
Signed-off-by: Khin Mi Mi Aung <Mi_Mi_AUNG@dsi.a-star.edu.sg>
---
 fs/nfs/Kconfig  | 16 ++++++++++++++++
 fs/nfsd/Kconfig | 13 +++++++++++++
 2 files changed, 29 insertions(+)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 13ca196..0077197 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -131,6 +131,22 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
 	  If the NFS client is unchanged from the upstream kernel, this
 	  option should be set to the default "kernel.org".
 
+config NFS_V4_SECURITY_LABEL
+	bool "Provide Security Label support for NFSv4 client"
+	depends on NFS_V4 && SECURITY
+	help
+
+	Say Y here if you want enable fine-grained security label attribute
+	support for NFS version 4.  Security labels allow security modules like
+	SELinux and Smack to label files to facilitate enforcement of their policies.
+	Without this an NFSv4 mount will have the same label on each file.
+
+	If you do not wish to enable fine-grained security labels SELinux or
+	Smack policies on NFSv4 files, say N.
+
+
+	  If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 8df1ea4..75ba894 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -81,6 +81,19 @@ config NFSD_V4
 
 	  If unsure, say N.
 
+config NFSD_V4_SECURITY_LABEL
+	bool "Provide Security Label support for NFSv4 server"
+	depends on NFSD_V4 && SECURITY
+	help
+
+	Say Y here if you want enable fine-grained security label attribute
+	support for NFS version 4.  Security labels allow security modules like
+	SELinux and Smack to label files to facilitate enforcement of their policies.
+	Without this an NFSv4 mount will have the same label on each file.
+
+	If you do not wish to enable fine-grained security labels SELinux or
+	Smack policies on NFSv4 files, say N.
+
 config NFSD_FAULT_INJECTION
 	bool "NFS server manual fault injection"
 	depends on NFSD_V4 && DEBUG_KERNEL
-- 
1.7.11.7

