Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:9363 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754243Ab2EaSIv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 31 May 2012 14:08:51 -0400
From: Sachin Prabhu <sprabhu@redhat.com>
To: Linux NFS mailing list <linux-nfs@vger.kernel.org>
Cc: Trond Myklebust <trond.myklebust@netapp.com>
Subject: [PATCH] NFSv2: EOF incorrectly set on short read
Date: Thu, 31 May 2012 17:45:00 +0100
Message-Id: <1338482700-15470-1-git-send-email-sprabhu@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

In cases where the server returns fewer bytes then those requested, we
can incorrectly set the eof flag for the file. Fixing this allows the
request to be retried with updated offset and count arguments.

Signed-off-by: Sachin Prabhu <sprabhu@redhat.com>
---
 fs/nfs/proc.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/proc.c b/fs/nfs/proc.c
index a706b6b..617c741 100644
--- a/fs/nfs/proc.c
+++ b/fs/nfs/proc.c
@@ -651,7 +651,7 @@ static int nfs_read_done(struct rpc_task *task, struct nfs_read_data *data)
 		/* Emulate the eof flag, which isn't normally needed in NFSv2
 		 * as it is guaranteed to always return the file attributes
 		 */
-		if (data->args.offset + data->args.count >= data->res.fattr->size)
+		if (data->args.offset + data->res.count >= data->res.fattr->size)
 			data->res.eof = 1;
 	}
 	return 0;
-- 
1.7.7.6

