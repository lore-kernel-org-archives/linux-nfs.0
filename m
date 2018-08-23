Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-it0-f68.google.com ([209.85.214.68]:35310 "EHLO
        mail-it0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1732062AbeHWSdP (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 23 Aug 2018 14:33:15 -0400
Received: by mail-it0-f68.google.com with SMTP id 139-v6so7976612itf.0
        for <linux-nfs@vger.kernel.org>; Thu, 23 Aug 2018 08:03:11 -0700 (PDT)
From: Trond Myklebust <trondmy@gmail.com>
To: Anna Schumaker <Anna.Schumaker@netapp.com>
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSv4: Fix a tracepoint Oops in initiate_file_draining()
Date: Thu, 23 Aug 2018 11:02:49 -0400
Message-Id: <20180823150249.124919-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Now that the value of 'ino' can be NULL or an ERR_PTR(), we need to
change the test in the tracepoint.

Fixes: ce5624f7e6675 ("NFSv4: Return NFS4ERR_DELAY when a layout fails...")
Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
---
 fs/nfs/nfs4trace.h | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4trace.h b/fs/nfs/nfs4trace.h
index 9bae014544fd..ed5794c0c818 100644
--- a/fs/nfs/nfs4trace.h
+++ b/fs/nfs/nfs4trace.h
@@ -1194,7 +1194,7 @@ DECLARE_EVENT_CLASS(nfs4_inode_stateid_callback_event,
 		TP_fast_assign(
 			__entry->error = error;
 			__entry->fhandle = nfs_fhandle_hash(fhandle);
-			if (inode != NULL) {
+			if (!IS_ERR_OR_NULL(inode)) {
 				__entry->fileid = NFS_FILEID(inode);
 				__entry->dev = inode->i_sb->s_dev;
 			} else {
-- 
2.17.1
