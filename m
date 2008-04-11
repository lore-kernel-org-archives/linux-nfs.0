From: Jeff Layton <jlayton@redhat.com>
Subject: [PATCH] NFS: remove duplicate flags assignment from nfs_validate_mount_data
Date: Fri, 11 Apr 2008 11:50:58 -0400
Message-ID: <1207929058-15098-1-git-send-email-jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:56505 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760086AbYDKPvR (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 11 Apr 2008 11:51:17 -0400
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Signed-off-by: Jeff Layton <jlayton@redhat.com>
---
 fs/nfs/super.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/super.c b/fs/nfs/super.c
index f921902..f4ee9d9 100644
--- a/fs/nfs/super.c
+++ b/fs/nfs/super.c
@@ -1208,7 +1208,6 @@ static int nfs_validate_mount_data(void *options,
 		args->flags		= data->flags;
 		args->rsize		= data->rsize;
 		args->wsize		= data->wsize;
-		args->flags		= data->flags;
 		args->timeo		= data->timeo;
 		args->retrans		= data->retrans;
 		args->acregmin		= data->acregmin;
-- 
1.5.3.6

