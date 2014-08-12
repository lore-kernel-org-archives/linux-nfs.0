Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:43710 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751608AbaHLV36 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 12 Aug 2014 17:29:58 -0400
Date: Tue, 12 Aug 2014 17:29:57 -0400
From: Bruce Fields <bfields@fieldses.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 08/11] SUNRPC: get rid of the request wait queue
Message-ID: <20140812212957.GA27527@fieldses.org>
References: <1407085393-3175-4-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-5-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-6-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-7-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-8-git-send-email-trond.myklebust@primarydata.com>
 <1407085393-3175-9-git-send-email-trond.myklebust@primarydata.com>
 <20140812195308.GC25914@fieldses.org>
 <CAHQdGtR6-yGfuu2WZSD1JpmLbO5XuoU3QoU37e_oVWpYspDxCA@mail.gmail.com>
 <20140812202316.GE25914@fieldses.org>
 <CAHQdGtS+1osSEZyB-q=kYaH0wokKZ3XHc+7f3WWso03LhE-JbA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <CAHQdGtS+1osSEZyB-q=kYaH0wokKZ3XHc+7f3WWso03LhE-JbA@mail.gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Aug 12, 2014 at 04:54:53PM -0400, Trond Myklebust wrote:
> On Tue, Aug 12, 2014 at 4:23 PM, Bruce Fields <bfields@fieldses.org> wrote:
> > On Tue, Aug 12, 2014 at 04:09:52PM -0400, Trond Myklebust wrote:
> >> On Tue, Aug 12, 2014 at 3:53 PM, Bruce Fields <bfields@fieldses.org> wrote:
> >> > On Sun, Aug 03, 2014 at 01:03:10PM -0400, Trond Myklebust wrote:
> >> >> We're always _only_ waking up tasks from within the sp_threads list, so
> >> >> we know that they are enqueued and alive. The rq_wait waitqueue is just
> >> >> a distraction with extra atomic semantics.
> >> >>
> >> >> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
> >> >> ---
> >> >>  include/linux/sunrpc/svc.h |  1 -
> >> >>  net/sunrpc/svc.c           |  2 --
> >> >>  net/sunrpc/svc_xprt.c      | 32 +++++++++++++++++---------------
> >> >>  3 files changed, 17 insertions(+), 18 deletions(-)
> >> >>
> >> >> diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> >> >> index 1bc7cd05b22e..3ec769b65c7f 100644
> >> >> --- a/include/linux/sunrpc/svc.h
> >> >> +++ b/include/linux/sunrpc/svc.h
> >> >> @@ -280,7 +280,6 @@ struct svc_rqst {
> >> >>       int                     rq_splice_ok;   /* turned off in gss privacy
> >> >>                                                * to prevent encrypting page
> >> >>                                                * cache pages */
> >> >> -     wait_queue_head_t       rq_wait;        /* synchronization */
> >> >>       struct task_struct      *rq_task;       /* service thread */
> >> >>  };
> >> >>
> >> >> diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> >> index 5de6801cd924..dfb78c4f3031 100644
> >> >> --- a/net/sunrpc/svc.c
> >> >> +++ b/net/sunrpc/svc.c
> >> >> @@ -612,8 +612,6 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
> >> >>       if (!rqstp)
> >> >>               goto out_enomem;
> >> >>
> >> >> -     init_waitqueue_head(&rqstp->rq_wait);
> >> >> -
> >> >>       serv->sv_nrthreads++;
> >> >>       spin_lock_bh(&pool->sp_lock);
> >> >>       pool->sp_nrthreads++;
> >> >> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
> >> >> index 2c30193c7a13..438e91c12851 100644
> >> >> --- a/net/sunrpc/svc_xprt.c
> >> >> +++ b/net/sunrpc/svc_xprt.c
> >> >> @@ -348,8 +348,6 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> >> >>
> >> >>       cpu = get_cpu();
> >> >>       pool = svc_pool_for_cpu(xprt->xpt_server, cpu);
> >> >> -     put_cpu();
> >> >> -
> >> >>       spin_lock_bh(&pool->sp_lock);
> >> >>
> >> >>       if (!list_empty(&pool->sp_threads) &&
> >> >> @@ -382,10 +380,15 @@ static void svc_xprt_do_enqueue(struct svc_xprt *xprt)
> >> >>                       printk(KERN_ERR
> >> >>                               "svc_xprt_enqueue: server %p, rq_xprt=%p!\n",
> >> >>                               rqstp, rqstp->rq_xprt);
> >> >> -             rqstp->rq_xprt = xprt;
> >> >> +             /* Note the order of the following 3 lines:
> >> >> +              * We want to assign xprt to rqstp->rq_xprt only _after_
> >> >> +              * we've woken up the process, so that we don't race with
> >> >> +              * the lockless check in svc_get_next_xprt().
> >> >
> >> > Sorry, I'm not following this: what exactly is the race?
> >>
> >> There are 2 potential races, both due to the lockless check for rqstp->rq_xprt.
> >>
> >> 1) You need to ensure that the reference count in xprt is bumped
> >> before assigning to rqstp->rq_xprt, because svc_get_next_xprt() does a
> >> lockless check for rqstp->rq_xprt != NULL, so there is no lock to
> >> ensure that the refcount bump occurs before whoever called
> >> svc_get_next_xprt() calls svc_xprt_put()...
> >>
> >> 2) You want to ensure that you don't call wake_up_process() after
> >> exiting svc_get_next_xprt() since you would no longer be guaranteed
> >> that the task still exists. By calling wake_up_process() before
> >> setting rqstp->rq_xprt, you ensure that if the task wakes up before
> >> calling wake_up_process(), then the test for rqstp->rq_xprt == NULL
> >> forces you into the spin_lock_bh() protected region, where it is safe
> >> to test rqstp->rq_xprt again and decide whether or not the task is
> >> still queued on &pool->sp_threads.
> >
> > Got it.  So how about making that comment:
> >
> >         /*
> >          * Once we assign rq_xprt, a concurrent task in
> >          * svc_get_next_xprt() could put the xprt, or could exit.
> >          * Therefore, the get and the wake_up need to come first.
> >          */
> >
> > Is that close enough?
> >
> 
> It's close: it's not so much any concurrent task, it's specifically
> the one that we're trying to wake up that may find itself waking up
> prematurely due to the schedule_timeout(), and then racing due to the
> lockless check.


Got it.  I'll make it:

	/*
	 * The task rq_task could be concurrently executing the lockless
	 * check of rq_xprt in svc_get_next_xprt().  Once we set
	 * rq_xprt, that task could return from svc_get_next_xprt(), and
	 * then could put the last reference to the xprt, or could exit.
	 * Therefore, our get and wake_up need to come first:
	 */

--b.
