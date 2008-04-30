From: Chuck Lever <chucklever@gmail.com>
Subject: [PATCH 3/6] NFS: missing newline in NFS mount debugging message
Date: Wed, 30 Apr 2008 11:59:56 -0400
Message-ID: <20080430155956.32402.88172.stgit@manray.1015granger.net>
References: <20080430154011.32402.42101.stgit@manray.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: jlayton@redhat.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.242]:59334 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758242AbYD3QAA (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 30 Apr 2008 12:00:00 -0400
Received: by an-out-0708.google.com with SMTP id d40so120817and.103
        for <linux-nfs@vger.kernel.org>; Wed, 30 Apr 2008 08:59:59 -0700 (PDT)
In-Reply-To: <20080430154011.32402.42101.stgit-meopP2rzCrTwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Clean up.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/super.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b69e3ec..cfe8d4c 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1186,7 +1186,7 @@ static int nfs_try_mount(struct nfs_parsed_mount_data *args,
 	if (status == 0)
 		return 0;
 
-	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d",
+	dfprintk(MOUNT, "NFS: unable to mount server %s, error %d\n",
 			hostname, status);
 	return status;
 }

