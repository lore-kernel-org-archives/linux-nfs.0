Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:34633 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754753Ab3BRSsU (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Feb 2013 13:48:20 -0500
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 12/14] Kconfig: Add Kconfig entry for Labeled NFS V4 client
Date: Mon, 18 Feb 2013 13:47:54 -0500
Message-Id: <1361213276-17962-13-git-send-email-SteveD@redhat.com>
In-Reply-To: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
References: <1361213276-17962-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This patch adds the NFS_V4_SECURITY_LABEL entry which
enables security label support for the NFSv4 client

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfs/Kconfig | 18 ++++++++++++++++++
 1 file changed, 18 insertions(+)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 13ca196..3861a1f 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -131,6 +131,24 @@ config NFS_V4_1_IMPLEMENTATION_ID_DOMAIN
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
1.8.1.2

