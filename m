Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:24471 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757494Ab3D2M7T (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 29 Apr 2013 08:59:19 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 15/17] Kconfig: Add Kconfig entry for Labeled NFS V4 client
Date: Mon, 29 Apr 2013 08:57:17 -0400
Message-Id: <1367240239-19326-16-git-send-email-SteveD@redhat.com>
In-Reply-To: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
References: <1367240239-19326-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This patch adds the NFS_V4_SECURITY_LABEL entry which
enables security label support for the NFSv4 client

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig | 19 +++++++++++++++++++
 1 file changed, 19 insertions(+)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 79c500e..771831d3 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -107,6 +107,7 @@ config NFS_V4_1
 config NFS_V4_2
 	bool "NFS client support for NFSv4.2"
 	depends on NFS_V4_1
+	select NFS_V4_SECURITY_LABEL
 	help
 	  This option enables support for minor version 1 of the NFSv4 protocol
 	  in the kernel's NFS client.
@@ -140,6 +141,24 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
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
+	WARNING: there is still a chance of backwards-incompatible protocol changes.  
+	For now we recommend "Y" only for developers and testers."
+
+	If unsure, say N.
+
 config ROOT_NFS
 	bool "Root file system on NFS"
 	depends on NFS_FS=y && IP_PNP
-- 
1.8.1.4

