From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 11/11] NFSD: Remove NFSv4 dependency on NFSv3
Date: Mon, 11 Feb 2008 17:12:46 -0500
Message-ID: <20080211221246.1047.96665.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@fieldses.org, trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi195.sbcis.sbc.com ([207.115.20.197]:2509 "EHLO
	flpi195.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758126AbYBKWNA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 11 Feb 2008 17:13:00 -0500
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up: Because NFSD_V4 "depends on" NFSD_V3, it appears as a child of
the NFSD_V3 menu entry, and is not visible if NFSD_V3 is unselected.

Replace the dependency on NFSD_V3 with a "select NFSD_V3".  This makes
NFSD_V4 look and work just like NFS_V3, while ensuring that NFSD_V3 is
enabled if NFSD_V4 is.

Sam Ravnborg adds:

"This use of select is questionable. In general it is bad to select
a symbol with dependencies.

In this case the dependencies of NFSD_V3 are duplicated for NFSD_V4
so we will not se erratic configurations but do you remember to
update NFSD_V4 when you add a depends on NFSD_V3?

But I see no other clean way to do it right now."

Later he said:

"My comment was more to say we have things to address in kconfig.
This is abuse in the acceptable range."

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/Kconfig |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 267ff73..a5bd7ff 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1718,7 +1718,8 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
+	depends on NFSD && PROC_FS && EXPERIMENTAL
+	select NFSD_V3
 	select FS_POSIX_ACL
 	select RPCSEC_GSS_KRB5
 	help

