Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qg0-f41.google.com ([209.85.192.41]:33531 "EHLO
	mail-qg0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752570AbbHESew (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 5 Aug 2015 14:34:52 -0400
Received: by qged69 with SMTP id d69so36489946qge.0
        for <linux-nfs@vger.kernel.org>; Wed, 05 Aug 2015 11:34:52 -0700 (PDT)
Received: from manet.1015granger.net ([2604:8800:100:81fc:82ee:73ff:fe43:d64f])
        by smtp.gmail.com with ESMTPSA id 71sm1787419qhg.37.2015.08.05.11.34.50
        for <linux-nfs@vger.kernel.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Aug 2015 11:34:51 -0700 (PDT)
Subject: [PATCH] NFS: Add OTW write barrier before may-open test
From: Chuck Lever <chuck.lever@oracle.com>
To: linux-nfs@vger.kernel.org
Date: Wed, 05 Aug 2015 14:34:49 -0400
Message-ID: <20150805182305.11796.75476.stgit@manet.1015granger.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 14546c337588 ("NFS: Don't do a full flush to disk on close()
if we hold a delegation") added an optimization. When an NFSv4 write
delegation is present, close(2) does not wait while a file's dirty
data is flushed to the NFS server.

However, if the application workload immediately re-opens that file,
nfs_may_open() can perform an ACCESS and GETATTR which runs
concurrently with the flushing WRITE. If the flushing WRITE and
GETATTR complete out of order on the server, the file size cached on
the client will go backwards, possibly resulting in new writes going
to the wrong file offset.

Add a write barrier before the access check to ensure the server's
idea of the file's size is properly up to date.

The downside of this approach is that each fresh open(2) of a dirty
file results in an extra flush. It seems to me that _any_ open(2)
done while there is dirty data waiting on the client could result in
a file size roll back. However, I see bad behavior only when the
client holds a write delegation.

Fixes: 14546c337588 ("NFS: Don't do a full flush to disk on . . .")
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---
 fs/nfs/dir.c |    9 +++++++++
 1 file changed, 9 insertions(+)

I'm not certain this is a good long term fix. Some other possible
solutions include:

 - Not performing the access check if the client holds a delegation
 - Not performing a GETATTR as part of the ACCESS check
 - Simply marking the file attributes stale instead of using the
   returned file size
 - Reverting commit 14546c337588

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 547308a..7b36993 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -2439,6 +2439,15 @@ static int nfs_open_permission_mask(int openflags)
 
 int nfs_may_open(struct inode *inode, struct rpc_cred *cred, int openflags)
 {
+	/*
+	 * If a write delegation is present, close(2) does not wait after
+	 * flushing dirty data. Wait for write completion here to ensure
+	 * the file size on the server is up to date. Otherwise this
+	 * access check will roll back the cached file size.
+	 */
+	if (NFS_PROTO(inode)->have_delegation(inode, FMODE_WRITE))
+		nfs_sync_inode(inode);
+
 	return nfs_do_access(inode, cred, nfs_open_permission_mask(openflags));
 }
 EXPORT_SYMBOL_GPL(nfs_may_open);

