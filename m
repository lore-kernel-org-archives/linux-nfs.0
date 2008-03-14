From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 2/3] SUNRPC: Remove PROC_FS dependency
Date: Fri, 14 Mar 2008 14:06:03 -0400
Message-ID: <20080314180602.29775.68118.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:63864 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756042AbYCNSG0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:06:26 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Recently, commit 440bcc59 added a reverse dependency to fs/Kconfig to
ensure that PROC_FS was enabled if SUNRPC_GSS was enabled.

Apparently this isn't necessary because the auth_gss components under
net/sunrpc will build correctly even if PROC_FS is disabled, though
RPCSEC_GSS will not work without /proc.

It also violates the guideline in Documentation/kbuild/kconfig-language.txt
that states "In general use select only for non-visible symbols (no prompts
anywhere) and for symbols with no dependencies."

To address these issues, remove the dependency.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index db67512..373ee37 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1668,7 +1668,6 @@ config NFSD
 	select SUNRPC
 	select EXPORTFS
 	select NFS_ACL_SUPPORT if NFSD_V2_ACL
-	select PROC_FS if SUNRPC_GSS
 	help
 	  Choose Y here if you want to allow other computers to access
 	  files residing on this system using Sun's Network File System

