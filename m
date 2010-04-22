From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 3/5] NFS: rsize and wsize settings ignored on v4 mounts
Date: Thu, 22 Apr 2010 16:50:19 -0400
Message-ID: <1271969421-7443-4-git-send-email-Trond.Myklebust@netapp.com>
References: <1271969421-7443-1-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-2-git-send-email-Trond.Myklebust@netapp.com>
 <1271969421-7443-3-git-send-email-Trond.Myklebust@netapp.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:57887 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754906Ab0DVUu0 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Apr 2010 16:50:26 -0400
Received: from localhost.localdomain (kmanoj02-lxp.hq.netapp.com [10.58.60.82] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o3MKoMJ8026155
	for <linux-nfs@vger.kernel.org>; Thu, 22 Apr 2010 13:50:24 -0700 (PDT)
In-Reply-To: <1271969421-7443-3-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Chuck Lever <chuck.lever@oracle.com>

NFSv4 mounts ignore the rsize and wsize mount options, and always use
the default transfer size for both.  This seems to be because all
NFSv4 mounts are now cloned, and the cloning logic doesn't copy the
rsize and wsize settings from the parent nfs_server.

I tested Fedora's 2.6.32.11-99 and it seems to have this problem as
well, so I'm guessing that .33, .32, and perhaps older kernels have
this issue as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Stable <stable@kernel.org>
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/client.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/client.c b/fs/nfs/client.c
index a8766c4..acc9c49 100644
--- a/fs/nfs/client.c
+++ b/fs/nfs/client.c
@@ -966,6 +966,8 @@ out_error:
 static void nfs_server_copy_userdata(struct nfs_server *target, struct nfs_server *source)
 {
 	target->flags = source->flags;
+	target->rsize = source->rsize;
+	target->wsize = source->wsize;
 	target->acregmin = source->acregmin;
 	target->acregmax = source->acregmax;
 	target->acdirmin = source->acdirmin;
-- 
1.6.6.1

