From: "J. Bruce Fields" <bfields@citi.umich.edu>
Subject: [PATCH 020/100] nfsd: select CONFIG_PROC_FS in nfsv4 and gss server cases
Date: Fri, 25 Jan 2008 18:16:00 -0500
Message-ID: <1201303040-7779-20-git-send-email-bfields@citi.umich.edu>
References: <20080125231521.GG25141@fieldses.org>
 <1201303040-7779-1-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-2-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-3-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-4-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-5-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-6-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-7-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-8-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-9-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-10-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-11-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-12-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-13-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-14-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-15-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-16-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-17-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-18-git-send-email-bfields@citi.umich.edu>
 <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
Cc: "J. Bruce Fields" <bfields@citi.umich.edu>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:47342 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1762006AbYAYXR1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 18:17:27 -0500
In-Reply-To: <1201303040-7779-19-git-send-email-bfields@citi.umich.edu>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The server depends on upcalls under /proc to support nfsv4 and gss.

Acked-by: NeilBrown <neilb@suse.de>
Signed-off-by: J. Bruce Fields <bfields@citi.umich.edu>
---
 fs/Kconfig |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/Kconfig b/fs/Kconfig
index 487236c..e81fcd6 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -1679,6 +1679,8 @@ config NFSD
 	select CRYPTO_MD5 if NFSD_V4
 	select CRYPTO if NFSD_V4
 	select FS_POSIX_ACL if NFSD_V4
+	select PROC_FS if NFSD_V4
+	select PROC_FS if SUNRPC_GSS
 	help
 	  If you want your Linux box to act as an NFS *server*, so that other
 	  computers on your local network which support NFS can access certain
-- 
1.5.4.rc2.60.gb2e62

