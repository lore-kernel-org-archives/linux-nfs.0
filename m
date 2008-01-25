From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: [PATCH 106/112] NFS: Optimise away the sigmask code in aio/dio
	reads and writes
Date: Fri, 25 Jan 2008 11:38:02 -0500
Message-ID: <20080125163801.31887.77000.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
References: <20080125163723.31887.68074.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:41387 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755763AbYAYRCF (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 25 Jan 2008 12:02:05 -0500
Received: from svlexrs01.hq.netapp.com (svlexrs01.corp.netapp.com [10.57.156.158])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id m0PH1HA2020978
	for <linux-nfs@vger.kernel.org>; Fri, 25 Jan 2008 09:01:54 -0800 (PST)
In-Reply-To: <20080125163723.31887.68074.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There are no interruptible waits for asynchronous RPC tasks, so we don't
need to wrap calls to rpc_run_task() with an
rpc_clnt_sigmask/rpc_clnt_unsigmask pair.

Instead we can wrap the wait_for_completion_interruptible() in
nfs_direct_wait(). This means that we completely optimise away sigmask
setting for the case of non-blocking aio/dio.

Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
---

 fs/nfs/direct.c |   13 +++++--------
 1 files changed, 5 insertions(+), 8 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index eadd87f..f8e165c 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -188,12 +188,17 @@ static void nfs_direct_req_release(struct nfs_direct_req *dreq)
 static ssize_t nfs_direct_wait(struct nfs_direct_req *dreq)
 {
 	ssize_t result = -EIOCBQUEUED;
+	struct rpc_clnt *clnt;
+	sigset_t oldset;
 
 	/* Async requests don't wait here */
 	if (dreq->iocb)
 		goto out;
 
+	clnt = NFS_CLIENT(dreq->inode);
+	rpc_clnt_sigmask(clnt, &oldset);
 	result = wait_for_completion_interruptible(&dreq->completion);
+	rpc_clnt_sigunmask(clnt, &oldset);
 
 	if (!result)
 		result = dreq->error;
@@ -403,9 +408,7 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 			       unsigned long nr_segs, loff_t pos)
 {
 	ssize_t result = 0;
-	sigset_t oldset;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	struct rpc_clnt *clnt = NFS_CLIENT(inode);
 	struct nfs_direct_req *dreq;
 
 	dreq = nfs_direct_req_alloc();
@@ -417,11 +420,9 @@ static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	rpc_clnt_sigmask(clnt, &oldset);
 	result = nfs_direct_read_schedule_iovec(dreq, iov, nr_segs, pos);
 	if (!result)
 		result = nfs_direct_wait(dreq);
-	rpc_clnt_sigunmask(clnt, &oldset);
 	nfs_direct_req_release(dreq);
 
 	return result;
@@ -816,9 +817,7 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 				size_t count)
 {
 	ssize_t result = 0;
-	sigset_t oldset;
 	struct inode *inode = iocb->ki_filp->f_mapping->host;
-	struct rpc_clnt *clnt = NFS_CLIENT(inode);
 	struct nfs_direct_req *dreq;
 	size_t wsize = NFS_SERVER(inode)->wsize;
 	int sync = NFS_UNSTABLE;
@@ -836,11 +835,9 @@ static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,
 	if (!is_sync_kiocb(iocb))
 		dreq->iocb = iocb;
 
-	rpc_clnt_sigmask(clnt, &oldset);
 	result = nfs_direct_write_schedule_iovec(dreq, iov, nr_segs, pos, sync);
 	if (!result)
 		result = nfs_direct_wait(dreq);
-	rpc_clnt_sigunmask(clnt, &oldset);
 	nfs_direct_req_release(dreq);
 
 	return result;
