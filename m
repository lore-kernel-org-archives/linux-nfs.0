Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:62926 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758003Ab3DXUXQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 24 Apr 2013 16:23:16 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        "J. Bruce Fields" <bfields@redhat.com>,
        "David P. Quigley" <dpquigl@tycho.nsa.gov>
Cc: Linux NFS list <linux-nfs@vger.kernel.org>,
        Linux FS devel list <linux-fsdevel@vger.kernel.org>,
        Linux Security List <linux-security-module@vger.kernel.org>,
        SELinux List <selinux@tycho.nsa.gov>
Subject: [PATCH 17/17] Kconfig: Add Kconfig entry for Labeled NFS V4 server
Date: Wed, 24 Apr 2013 16:18:03 -0400
Message-Id: <1366834683-29075-18-git-send-email-SteveD@redhat.com>
In-Reply-To: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
References: <1366834683-29075-1-git-send-email-SteveD@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Steve Dickson <steved@redhat.com>

This patch adds the NFSd_V4_SECURITY_LABEL entry which
enables security label support for the NFSv4 server

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 fs/nfsd/Kconfig | 16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/fs/nfsd/Kconfig b/fs/nfsd/Kconfig
index 430b687..c37a046 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -81,6 +81,22 @@ config NFSD_V4
 
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
+	WARNING: there is still a chance of backwards-incompatible protocol changes.  
+	For now we recommend "Y" only for developers and testers."
+
 config NFSD_FAULT_INJECTION
 	bool "NFS server manual fault injection"
 	depends on NFSD_V4 && DEBUG_KERNEL
-- 
1.8.1.4

