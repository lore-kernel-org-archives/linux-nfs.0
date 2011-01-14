Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:63204 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751046Ab1ANGjz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 Jan 2011 01:39:55 -0500
Received: from tang.cn.fujitsu.com (tang.cn.fujitsu.com [10.167.250.3])
	by song.cn.fujitsu.com (Postfix) with ESMTP id 8E10017012E
	for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 14:39:52 +0800 (CST)
Received: from mailserver.fnst.cn.fujitus.com (tang.cn.fujitsu.com [127.0.0.1])
	by tang.cn.fujitsu.com (8.14.3/8.13.1) with ESMTP id p0E6UdVf014537
	for <linux-nfs@vger.kernel.org>; Fri, 14 Jan 2011 14:34:37 +0800
Message-ID: <4D2FF124.7020500@cn.fujitsu.com>
Date: Fri, 14 Jan 2011 14:45:56 +0800
From: Fu Liankun <fuliankun@cn.fujitsu.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSV4 :All lock operations should be sent to the server for
 resolution
Content-Type: text/plain; charset=GB2312
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

The RFC3530 describes that the client's all lock operations, including those
requesting non-exclusive locks, should be sent to the server for resolution,
even if it holds a read open delegation. But the kernel implements like that
lock operations can be performed locally when a client holds an open
delegation.

The following are the RFC3530 provisions for Open Delegation and File Locks:

9.4.2.  Open Delegation and File Locks

   When a client holds a write open delegation, lock operations may be
   performed locally.  This includes those required for mandatory file
   locking.  This can be done since the delegation implies that there
   can be no conflicting locks.  Similarly, all of the revalidations
   that would normally be associated with obtaining locks and the
   flushing of data associated with the releasing of locks need not be
   done.

   When a client holds a read open delegation, lock operations are not
   performed locally.  All lock operations, including those requesting
   non-exclusive locks, are sent to the server for resolution.

Signed-off-by: Fu Liankun <fuliankun@cn.fujitsu.com>
---
 fs/nfs/nfs4proc.c |    7 -------
 1 files changed, 0 insertions(+), 7 deletions(-)

diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
index 0f24cdf..3bba85b 100644
--- a/fs/nfs/nfs4proc.c
+++ b/fs/nfs/nfs4proc.c
@@ -4215,13 +4215,6 @@ static int _nfs4_proc_setlk(struct nfs4_state *state, int cmd, struct file_lock
 	if (status < 0)
 		goto out;
 	down_read(&nfsi->rwsem);
-	if (test_bit(NFS_DELEGATED_STATE, &state->flags)) {
-		/* Yes: cache locks! */
-		/* ...but avoid races with delegation recall... */
-		request->fl_flags = fl_flags & ~FL_SLEEP;
-		status = do_vfs_lock(request->fl_file, request);
-		goto out_unlock;
-	}
 	status = _nfs4_do_setlk(state, cmd, request, NFS_LOCK_NEW);
 	if (status != 0)
 		goto out_unlock;
-- 
1.7.3.1

