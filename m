From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/3] NFSD: Remove NFSv4 dependency on NFSv3
Date: Fri, 14 Mar 2008 14:06:10 -0400
Message-ID: <20080314180610.29775.14401.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: bfields@citi.umich.edu, Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi101.sbcis.sbc.com ([207.115.20.70]:64073 "EHLO
	flpi101.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756062AbYCNSGd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 14 Mar 2008 14:06:33 -0400
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
index 373ee37..151808b 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1728,7 +1728,8 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
+	depends on NFSD && PROC_FS && EXPERIMENTAL
+	select NFSD_V3
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

