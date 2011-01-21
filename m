Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:51230 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753046Ab1AUDFL (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 20 Jan 2011 22:05:11 -0500
Received: by mail-vw0-f46.google.com with SMTP id 16so612009vws.19
        for <linux-nfs@vger.kernel.org>; Thu, 20 Jan 2011 19:05:11 -0800 (PST)
From: Chuck Lever <chuck.lever@oracle.com>
Subject: [PATCH 1/4] NFS: Fix "kernel BUG at fs/aio.c:554!"
To: trond.myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org
Date: Thu, 20 Jan 2011 22:05:08 -0500
Message-ID: <20110121030508.1056.51625.stgit@matisse.1015granger.net>
In-Reply-To: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
References: <20110121030314.1056.96774.stgit@matisse.1015granger.net>
Content-Type: text/plain; charset="utf-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Nick Piggin reports:

> I'm getting use after frees in aio code in NFS
>
> [ 2703.396766] Call Trace:
> [ 2703.396858]  [<ffffffff8100b057>] ? native_sched_clock+0x27/0x80
> [ 2703.396959]  [<ffffffff8108509e>] ? put_lock_stats+0xe/0x40
> [ 2703.397058]  [<ffffffff81088348>] ? lock_release_holdtime+0xa8/0x140
> [ 2703.397159]  [<ffffffff8108a2a5>] lock_acquire+0x95/0x1b0
> [ 2703.397260]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> [ 2703.397361]  [<ffffffff81039701>] ? get_parent_ip+0x11/0x50
> [ 2703.397464]  [<ffffffff81612a31>] _raw_spin_lock_irq+0x41/0x80
> [ 2703.397564]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
> [ 2703.397662]  [<ffffffff811627db>] aio_put_req+0x2b/0x60
> [ 2703.397761]  [<ffffffff811647fe>] do_io_submit+0x2be/0x7c0
> [ 2703.397895]  [<ffffffff81164d0b>] sys_io_submit+0xb/0x10
> [ 2703.397995]  [<ffffffff8100307b>] system_call_fastpath+0x16/0x1b
>
> Adding some tracing, it is due to nfs completing the request then
> returning something other than -EIOCBQUEUED, so aio.c
> also completes the request.

To address this, prevent the NFS direct I/O engine from completing
async iocbs when the forward path returns an error without starting
any I/O.

This fix appears to survive ^C during both "xfstest no. 208" and "fsx
-Z."

It's likely this bug has existed for a very long while, as we are seeing
very similar symptoms in OEL 5.  Copying stable.

Cc: Stable <stable@kernel.org>
Signed-off-by: Chuck Lever <chuck.lever@oracle.com>
---

 fs/nfs/direct.c |   30 ++++++++++++++++--------------
 1 files changed, 16 insertions(+), 14 deletions(-)

diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
index e6ace0d..bde25ca 100644
--- a/fs/nfs/direct.c
+++ b/fs/nfs/direct.c
@@ -407,15 +407,16 @@ static ssize_t nfs_direct_read_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 
+	/*
+	 * If no bytes were started, return the error, and let the
+	 * generic layer handle the completion.
+	 */
+	if (requested_bytes == 0)
+		return result < 0 ? result : -EIO;
+
 	if (put_dreq(dreq))
 		nfs_direct_complete(dreq);
-
-	if (requested_bytes != 0)
-		return 0;
-
-	if (result < 0)
-		return result;
-	return -EIO;
+	return 0;
 }
 
 static ssize_t nfs_direct_read(struct kiocb *iocb, const struct iovec *iov,
@@ -841,15 +842,16 @@ static ssize_t nfs_direct_write_schedule_iovec(struct nfs_direct_req *dreq,
 		pos += vec->iov_len;
 	}
 
+	/*
+	 * If no bytes were started, return the error, and let the
+	 * generic layer handle the completion.
+	 */
+	if (requested_bytes == 0)
+		return result < 0 ? result : -EIO;
+
 	if (put_dreq(dreq))
 		nfs_direct_write_complete(dreq, dreq->inode);
-
-	if (requested_bytes != 0)
-		return 0;
-
-	if (result < 0)
-		return result;
-	return -EIO;
+	return 0;
 }
 
 static ssize_t nfs_direct_write(struct kiocb *iocb, const struct iovec *iov,

