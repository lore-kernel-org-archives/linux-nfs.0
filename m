From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 7/8] NFSD: Remove NFSv4 dependency on NFSv3
Date: Thu, 14 Feb 2008 15:58:47 -0500
Message-ID: <20080214205847.11765.45486.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from flpi185.sbcis.sbc.com ([207.115.20.187]:20451 "EHLO
	flpi185.prodigy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764607AbYBNU7v (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Feb 2008 15:59:51 -0500
Received: from manray.1015granger.net (adsl-76-241-169-38.dsl.sfldmi.sbcglobal.net [76.241.169.38])
	by flpi185.prodigy.net (8.13.8 out.dk.spool/8.13.8) with ESMTP id m1EKxoo0014889
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 12:59:51 -0800
Received: from manray.1015granger.net (manray.1015granger.net [127.0.0.1])
	by manray.1015granger.net (8.14.1/8.14.1) with ESMTP id m1EKwlID011829
	for <linux-nfs@vger.kernel.org>; Thu, 14 Feb 2008 15:58:47 -0500
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
index fcd8d10..c7ad5b7 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1718,7 +1718,8 @@ config NFSD_V3_ACL
 
 config NFSD_V4
 	bool "NFS server support for NFS version 4 (EXPERIMENTAL)"
-	depends on NFSD && NFSD_V3 && PROC_FS && EXPERIMENTAL
+	depends on NFSD && PROC_FS && EXPERIMENTAL
+	select NFSD_V3
 	select RPCSEC_GSS_KRB5
 	help
 	  This option enables support in your system's NFS server for

