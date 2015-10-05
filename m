Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx143.netapp.com ([216.240.21.24]:41493 "EHLO mx143.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751303AbbJEUnc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 5 Oct 2015 16:43:32 -0400
From: Anna Schumaker <Anna.Schumaker@netapp.com>
To: <Trond.Myklebust@primarydata.com>, <linux-nfs@vger.kernel.org>
CC: <Anna.Schumaker@netapp.com>, <Olga.Kornievskaia@netapp.com>
Subject: [PATCH] NFS: Fix a tracepoint NULL-pointer dereference
Date: Mon, 5 Oct 2015 16:43:26 -0400
Message-ID: <1444077806-29155-1-git-send-email-Anna.Schumaker@Netapp.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Running xfstest generic/013 with the tracepoint nfs:nfs4_open_file
enabled produces a NULL-pointer dereference when calculating fileid and
filehandle of the opened file.  Fix this by checking if state is NULL
before trying to use the inode pointer.

Reported-by: Olga Kornievskaia <aglo@umich.edu>
Signed-off-by: Anna Schumaker <Anna.Schumaker@Netapp.com>
---
 fs/nfs/nfs4trace.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 28df12e..671cf68 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -409,7 +409,7 @@ DECLARE_EVENT_CLASS(nfs4_open_event,
 			__entry->flags = flags;
 			__entry->fmode = (__force unsigned int)ctx->mode;
 			__entry->dev = ctx->dentry->d_sb->s_dev;
-			if (!IS_ERR(state))
+			if (!IS_ERR_OR_NULL(state))
 				inode = state->inode;
 			if (inode != NULL) {
 				__entry->fileid = NFS_FILEID(inode);
-- 
2.6.0

