From: "David P. Quigley" <dpquigl@tycho.nsa.gov>
Subject: [PATCH 05/10] KConfig: Add KConfig entries for Labeled NFS
Date: Wed,  7 Jul 2010 10:31:21 -0400
Message-ID: <1278513086-23964-6-git-send-email-dpquigl@tycho.nsa.gov>
References: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	linux-security-module@vger.kernel.org, selinux@tycho.nsa.gov,
	linux-nfs@vger.kernel.org,
	"David P. Quigley" <dpquigl@tycho.nsa.gov>,
	"Matthew N. Dodd" <Matthew.Dodd@sparta.com>
To: hch@infradead.org, viro@zeniv.linux.org.uk, casey@schaufler-ca.com,
	sds@tycho.nsa.gov, matthew.dodd@sparta.com,
	trond.myklebust@fys.uio.no, bfields@fieldses.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1278513086-23964-1-git-send-email-dpquigl@tycho.nsa.gov>
Sender: linux-kernel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

This patch adds two entries into the fs/KConfig file. The first entry
NFS_V4_SECURITY_LABEL enables security label support for the NFSv4 client while
the second entry NFSD_V4_SECURITY_LABEL enables security labeling support on
the server side.

Signed-off-by: Matthew N. Dodd <Matthew.Dodd@sparta.com>
Signed-off-by: David P. Quigley <dpquigl@tycho.nsa.gov>
---
 fs/nfs/Kconfig  |   16 ++++++++++++++++
 fs/nfsd/Kconfig |   13 +++++++++++++
 2 files changed, 29 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index a43d07e..67b158c 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -83,6 +83,22 @@ config NFS_V4_1
 
 	  Unless you're an NFS developer, say N.
 
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
index 503b9da..3a282f8 100644
--- a/fs/nfsd/Kconfig
+++ b/fs/nfsd/Kconfig
@@ -79,3 +79,16 @@ config NFSD_V4
 	  available from http://linux-nfs.org/.
 
 	  If unsure, say N.
+
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
-- 
1.6.2.5
