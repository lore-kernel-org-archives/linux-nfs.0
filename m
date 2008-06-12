From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 3/5] NFS: missing newline in NFS mount debugging message
Date: Thu, 12 Jun 2008 12:37:49 -0400
Message-ID: <20080612163748.13197.21446.stgit@manray.1015granger.net>
References: <20080612163416.13197.92911.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.183]:1403 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753016AbYFLQiG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 12 Jun 2008 12:38:06 -0400
Received: by wa-out-1112.google.com with SMTP id j37so2960659waf.23
        for <linux-nfs@vger.kernel.org>; Thu, 12 Jun 2008 09:38:06 -0700 (PDT)
In-Reply-To: <20080612163416.13197.92911.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)


diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index e9dd5b6..d59913b 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1187,7 +1187,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	if (status == 0)
 		return 0;
 
-	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d",
+	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d\n",
 			hostname, status);
 	return status;
 }

