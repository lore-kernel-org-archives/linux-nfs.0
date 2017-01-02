Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:36249 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755831AbdABOEV (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 2 Jan 2017 09:04:21 -0500
Received: by mail-pg0-f67.google.com with SMTP id n5so30556807pgh.3
        for <linux-nfs@vger.kernel.org>; Mon, 02 Jan 2017 06:04:21 -0800 (PST)
To: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Cc: Anna Schumaker <Anna.Schumaker@netapp.com>, kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFSv4.x/callback: make sure callback thread is interruptible
Message-ID: <2026e1dc-4a96-2359-dc62-f391a2d795a8@gmail.com>
Date: Mon, 2 Jan 2017 22:04:11 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit bb6aeba736ba "NFSv4.x: Switch to using svc_set_num_threads()
 to manage the callback threads" change nfs start/stop threads
through svc_set_num_threads().

It destroy old threads by SIGINT signal, but our nfs4_callback_svc()
isn't interruptible. So that, the callback threads will never be killed.

# mount -t nfs -overs=4.2 nfstestnic:/ /mnt/
# ps -ajx |grep NFS
    2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
# umount /mnt
# ps -ajx |grep NFS
    2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
# mount -t nfs -overs=4.2 nfstestnic:/ /mnt/
# umount /mnt
# ps -ajx |grep NFS
    2  5927     0     0 ?           -1 S        0   0:00 [NFSv4 callback]
    2  5963     0     0 ?           -1 S        0   0:00 [NFSv4 callback]

After one mount, there will be one callback thread left that cannot killed,
the same time, nfs.ko will never be unplugged.

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/callback.c | 41 +++++++++++++++++++++++++++++++++++++----
 1 file changed, 37 insertions(+), 4 deletions(-)

diff --git a/fs/nfs/callback.c b/fs/nfs/callback.c
index 484bebc..0738470 100644
--- a/fs/nfs/callback.c
+++ b/fs/nfs/callback.c
@@ -73,6 +73,15 @@ nfs4_callback_svc(void *vrqstp)
 	int err;
 	struct svc_rqst *rqstp = vrqstp;
 
+	/*
+	 * thread is spawned with all signals set to SIG_IGN, re-enable
+	 * the ones that will bring down the thread
+	 */
+	allow_signal(SIGKILL);
+	allow_signal(SIGHUP);
+	allow_signal(SIGINT);
+	allow_signal(SIGQUIT);
+
 	set_freezable();
 
 	while (!kthread_should_stop()) {
@@ -80,11 +89,19 @@ nfs4_callback_svc(void *vrqstp)
 		 * Listen for a request on the socket
 		 */
 		err = svc_recv(rqstp, MAX_SCHEDULE_TIMEOUT);
-		if (err == -EAGAIN || err == -EINTR)
+		if (err == -EAGAIN)
 			continue;
+		else if (err == -EINTR)
+			break;
 		svc_process(rqstp);
 	}
-	return 0;
+
+	flush_signals(current);
+	rqstp->rq_server = NULL;
+
+	/* Release the thread */
+	svc_exit_thread(rqstp);
+	module_put_and_exit(0);
 }
 
 #if defined(CONFIG_NFS_V4_1)
@@ -100,6 +117,15 @@ nfs41_callback_svc(void *vrqstp)
 	int error;
 	DEFINE_WAIT(wq);
 
+	/*
+	 * thread is spawned with all signals set to SIG_IGN, re-enable
+	 * the ones that will bring down the thread
+	 */
+	allow_signal(SIGKILL);
+	allow_signal(SIGHUP);
+	allow_signal(SIGINT);
+	allow_signal(SIGQUIT);
+
 	set_freezable();
 
 	while (!kthread_should_stop()) {
@@ -121,11 +147,18 @@ nfs41_callback_svc(void *vrqstp)
 		} else {
 			spin_unlock_bh(&serv->sv_cb_lock);
 			schedule();
+			if (signalled())
+				break;
 			finish_wait(&serv->sv_cb_waitq, &wq);
 		}
-		flush_signals(current);
 	}
-	return 0;
+
+	flush_signals(current);
+	rqstp->rq_server = NULL;
+
+	/* Release the thread */
+	svc_exit_thread(rqstp);
+	module_put_and_exit(0);
 }
 
 static inline void nfs_callback_bc_serv(u32 minorversion, struct rpc_xprt *xprt,
-- 
2.9.3

