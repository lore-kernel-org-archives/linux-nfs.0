Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:10792 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755838Ab0BORT6 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 15 Feb 2010 12:19:58 -0500
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH] NFS: Too many GETATTR and ACCESS calls after direct I/O
Date: Mon, 15 Feb 2010 12:19:53 -0500
Message-Id: <1266254393-14553-1-git-send-email-Trond.Myklebust@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Chuck Lever <chuck.lever@oracle.com>

The cached read and write paths initialize fattr->time_start in their
setup procedures.  The value of fattr->time_start is propagated to
read_cache_jiffies by nfs_update_inode().  Subsequent calls to
nfs_attribute_timeout() will then use a good time stamp when
computing the attribute cache timeout, and squelch unneeded GETATTR
calls.

Since the direct I/O paths erroneously leave the inode's
fattr->time_start field set to zero, read_cache_jiffies for that inode
is set to zero after any direct read or write operation.  This
triggers an otw GETATTR or ACCESS call to update the file's attribute
and access caches properly, even when the NFS READ or WRITE replies
have usable post-op attributes.

Make sure the direct read and write setup code performs the same fattr
initialization as the cached I/O paths to prevent unnecessary GETATTR
calls.

This was likely introduced by commit 0e574af1 in 2.6.15, which appears
to add new nfs_fattr_init() call sites in the cached read and write
paths, but not in the equivalent places in fs/nfs/direct.c.  A
subsequent commit in the same series, 33801147, introduces the
fattr->time_start field.

Interestingly, the direct write reschedule path already has a call to
nfs_fattr_init() in the right place.

Reported-by: Quentin Barnes <qbarnes@yahoo-inc.com>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
Cc: stable@kernel.org
Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---
 fs/nfs/direct.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e1d415e..0d28982 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -342,6 +342,7 @@ static ssize_t nfs_direct_read_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.fattr = &data->fattr;
 		data->res.eof = 0;
 		data->res.count = bytes;
+		nfs_fattr_init(&data->fattr);
 		msg.rpc_argp = &data->args;
 		msg.rpc_resp = &data->res;
 
@@ -575,6 +576,7 @@ static void nfs_direct_commit_schedule(struct nfs_direct_req *dreq)
 	data->res.count = 0;
 	data->res.fattr = &data->fattr;
 	data->res.verf = &data->verf;
+	nfs_fattr_init(&data->fattr);
 
 	NFS_PROTO(data->inode)->commit_setup(data, &msg);
 
@@ -766,6 +768,7 @@ static ssize_t nfs_direct_write_schedule_segment(struct nfs_direct_req *dreq,
 		data->res.fattr = &data->fattr;
 		data->res.count = bytes;
 		data->res.verf = &data->verf;
+		nfs_fattr_init(&data->fattr);
 
 		task_setup_data.task = &data->task;
 		task_setup_data.callback_data = data;
-- 
1.6.6

