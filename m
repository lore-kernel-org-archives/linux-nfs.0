Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.parallels.com ([64.131.90.16]:57423 "EHLO mx2.parallels.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751897Ab1BCWNV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Feb 2011 17:13:21 -0500
Received: from [96.31.168.206] (helo=mail.parallels.com)
	by mx2.parallels.com with esmtps (TLSv1:AES128-SHA:128)
	(Exim 4.72)
	(envelope-from <rlandley@parallels.com>)
	id 1Pl7QW-0002To-Oq
	for linux-nfs@vger.kernel.org; Thu, 03 Feb 2011 17:13:20 -0500
Message-ID: <4D4B287E.70206@parallels.com>
Date: Thu, 3 Feb 2011 16:13:18 -0600
From: Rob Landley <rlandley@parallels.com>
To: <linux-nfs@vger.kernel.org>
Subject: [PATCH] Ensure user-supplied string null terminated before kstrdup()
Content-Type: text/plain; charset="ISO-8859-1"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

From: Rob Landley <rlandley@parallels.com>

Make sure user string is null terminated before copying it.

Signed-off-by: Rob Landley <rlandley@parallels.com>
---

 fs/nfs/super.c |    5 ++++-
 1 file changed, 4 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index b68c860..0ad1255 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1881,9 +1881,12 @@ static int nfs_validate_mount_data(void *options,
 
 		if (!(data->flags & NFS_MOUNT_TCP))
 			args->nfs_server.protocol = XPRT_TRANSPORT_UDP;
+		/* Force null termination of data->hostname no matter what
+		   user passed in. */
+		args->namlen		= data->namlen;
+		data->namlen = 0;
 		/* N.B. caller will free nfs_server.hostname in all cases */
 		args->nfs_server.hostname = kstrdup(data->hostname, GFP_KERNEL);
-		args->namlen		= data->namlen;
 		args->bsize		= data->bsize;
 
 		if (data->flags & NFS_MOUNT_SECFLAVOUR)
