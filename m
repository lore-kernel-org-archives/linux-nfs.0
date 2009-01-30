From: Manish Katiyar <mkatiyar@gmail.com>
Subject: [PATCH 0/1] nfs : Define NFS_FS only when FILE_LOCKING is enabled
Date: Fri, 30 Jan 2009 10:08:11 +0530
Message-ID: <ea11fea30901292038h5810bde4lf83470332b6b72c9@mail.gmail.com>
References: <ea11fea30901290722s5d9fe1b4y8f6142bcd137eb2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "J. Bruce Fields" <bfields@fieldses.org>,
	Trond Myklebust <trond.myklebust@fys.uio.no>,
	linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.191]:59502 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755764AbZA3EiN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 29 Jan 2009 23:38:13 -0500
Received: by ti-out-0910.google.com with SMTP id b6so39964tic.23
        for <linux-nfs@vger.kernel.org>; Thu, 29 Jan 2009 20:38:11 -0800 (PST)
In-Reply-To: <ea11fea30901290722s5d9fe1b4y8f6142bcd137eb2-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Bruce,

I didn't see this one merged in your 2.6.30 tree. Was it missed (since
I had sent it to wrong list by mistake). Please ignore if already
merged.


Below patch enables NFS_FS only when FILE_LOCKING is enabled.

Signed-off-by: Manish Katiyar <mkatiyar@gmail.com>
---
 fs/nfs/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
index 36fe20d..e93151e 100644
--- a/fs/nfs/Kconfig
+++ b/fs/nfs/Kconfig
@@ -1,6 +1,7 @@
 config NFS_FS
       tristate "NFS client support"
       depends on INET
+       depends on FILE_LOCKING
       select LOCKD
       select SUNRPC
       select NFS_ACL_SUPPORT if NFS_V3_ACL
--
1.5.4.3


Thanks -
Manish
