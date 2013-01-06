Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-oa0-f47.google.com ([209.85.219.47]:45409 "EHLO
	mail-oa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753139Ab3AFWMQ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 6 Jan 2013 17:12:16 -0500
Received: by mail-oa0-f47.google.com with SMTP id h1so17254620oag.34
        for <linux-nfs@vger.kernel.org>; Sun, 06 Jan 2013 14:12:15 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20130104005345.GA4407@fieldses.org>
References: <CADug+U6-=+_Xy41Lw3hnOqSR84Bo7MjKDL_PykiZVdUx=b8tAA@mail.gmail.com>
	<20130104005345.GA4407@fieldses.org>
Date: Mon, 7 Jan 2013 00:12:15 +0200
Message-ID: <CADug+U698gbtJnxUEOn0b7MhejYugSSRsV9i_b7jMaRs08Wpog@mail.gmail.com>
Subject: Re: [PATCH 1/1] sunrpc: Fix lockd sleeping until timeout
From: Andriy Skulysh <andriy_skulysh@xyratex.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

There is a race in enqueueing thread to a pool and
waking up a thread.
lockd doesn't wake up on reception of lock granted callback
if svc_wake_up() is called before lockd's thread is added
to a pool.

Signed-off-by: Andriy Skulysh <Andriy_Skulysh@xyratex.com>
---
 include/linux/sunrpc/svc.h |    1 +
 net/sunrpc/svc_xprt.c      |    9 ++++++++-
 2 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
index 676ddf5..1f0216b 100644
--- a/include/linux/sunrpc/svc.h
+++ b/include/linux/sunrpc/svc.h
@@ -50,6 +50,7 @@ struct svc_pool {
 	unsigned int		sp_nrthreads;	/* # of threads in pool */
 	struct list_head	sp_all_threads;	/* all server threads */
 	struct svc_pool_stats	sp_stats;	/* statistics on pool operation */
+	int			sp_task_pending;/* has pending task */
 } ____cacheline_aligned_in_smp;

 /*
diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
index b8e47fa..5a9d40c 100644
--- a/net/sunrpc/svc_xprt.c
+++ b/net/sunrpc/svc_xprt.c
@@ -499,7 +499,8 @@ void svc_wake_up(struct svc_serv *serv)
 			rqstp->rq_xprt = NULL;
 			 */
 			wake_up(&rqstp->rq_wait);
-		}
+		} else
+			pool->sp_task_pending = 1;
 		spin_unlock_bh(&pool->sp_lock);
 	}
 }
@@ -634,7 +635,13 @@ struct svc_xprt *svc_get_next_xprt(struct
svc_rqst *rqstp, long timeout)
 		 * long for cache updates.
 		 */
 		rqstp->rq_chandle.thread_wait = 1*HZ;
+		pool->sp_task_pending = 0;
 	} else {
+		if (pool->sp_task_pending) {
+			pool->sp_task_pending = 0;
+			spin_unlock_bh(&pool->sp_lock);
+			return ERR_PTR(-EAGAIN);
+		}
 		/* No data pending. Go to sleep */
 		svc_thread_enqueue(pool, rqstp);

-- 
1.7.1


On 4 January 2013 02:53, J. Bruce Fields <bfields@fieldses.org> wrote:
> That should be ERR_PTR(-EAGAIN).
fixed.
>
> Other than this this looks right to me....
>
> Out of curiosity: how did you run across this problem, and how did you
> test the fix?
I can reproduce it with single ping_pong with nfs on top of Lustre filesystem.

Andriy.
