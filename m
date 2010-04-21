From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/9] NFS: rsize and wsize settings ignored on v4 mounts
Date: Wed, 21 Apr 2010 13:43:04 -0400
Message-ID: <20100421174303.2037.86673.stgit@localhost.localdomain>
References: <20100421173628.2037.54635.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:41046 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756056Ab0DURuG (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 21 Apr 2010 13:50:06 -0400
Received: by pxi17 with SMTP id 17so406996pxi.19
        for <linux-nfs@vger.kernel.org>; Wed, 21 Apr 2010 10:50:05 -0700 (PDT)
In-Reply-To: <20100421173628.2037.54635.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

NFSv4 mounts ignore the rsize and wsize mount options, and always use
the default transfer size for both.  This seems to be because all
NFSv4 mounts are now cloned, and the cloning logic doesn't copy the
rsize and wsize settings from the parent nfs_server.

I tested Fedora's 2.6.32.11-99 and it seems to have this problem as
well, so I'm guessing that .33, .32, and perhaps older kernels have
this issue as well.

Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: Stable <stable@kernel.org>
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

