Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-gg0-f169.google.com ([209.85.161.169]:38607 "EHLO
	mail-gg0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752274Ab3JUNwj (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 21 Oct 2013 09:52:39 -0400
Received: by mail-gg0-f169.google.com with SMTP id 21so1617338ggh.28
        for <linux-nfs@vger.kernel.org>; Mon, 21 Oct 2013 06:52:39 -0700 (PDT)
From: Jeff Layton <jlayton@redhat.com>
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] nfs: return -EBUSY on remount when new options can't be applied
Date: Mon, 21 Oct 2013 09:52:34 -0400
Message-Id: <1382363554-6587-1-git-send-email-jlayton@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Currently the kernel returns -EINVAL, which makes it hard to
distinguish this situation from the case where an invalid mount option
was specified.

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index 3f5a7a8..cebdb26 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -2156,7 +2156,7 @@ nfs_compare_remount_data(struct nfs_server *nfss,
 	    data->nfs_server.addrlen != nfss->nfs_client->cl_addrlen ||
 	    !rpc_cmp_addr((struct sockaddr *)&data->nfs_server.address,
 			  (struct sockaddr *)&nfss->nfs_client->cl_addr))
-		return -EINVAL;
+		return -EBUSY;
 
 	return 0;
 }
-- 
1.8.3.1

