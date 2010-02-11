From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/2] NFS: Too many GETATTR and ACCESS calls after direct I/O
Date: Thu, 11 Feb 2010 14:09:08 -0500
Message-ID: <20100211190908.2666.85972.stgit@localhost.localdomain>
References: <20100211185757.2666.90001.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Cc: linux-nfs@vger.kernel.org
To: trond.myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:46716 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756463Ab0BKTKU (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 11 Feb 2010 14:10:20 -0500
In-Reply-To: <20100211185757.2666.90001.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

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

