Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-qc0-f175.google.com ([209.85.216.175]:64123 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932828AbaLBA36 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 19:29:58 -0500
Received: by mail-qc0-f175.google.com with SMTP id b13so9635907qcw.34
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2014 16:29:56 -0800 (PST)
From: Jeff Layton <jeff.layton@primarydata.com>
Date: Mon, 1 Dec 2014 19:29:54 -0500
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Jeff Layton <jeff.layton@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Chris Worley <chris.worley@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 1/4] sunrpc: add a rcu_head to svc_rqst and use
 kfree_rcu to free it
Message-ID: <20141201192954.17b89214@tlielax.poochiereds.net>
In-Reply-To: <CAHQdGtS=deh6zZXGv132PKzLROMXQBA83zV=dw_0RLTAqksuiQ@mail.gmail.com>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<1416597571-4265-2-git-send-email-jlayton@primarydata.com>
	<20141201224407.GD30749@fieldses.org>
	<20141201180533.7c8a7587@tlielax.poochiereds.net>
	<CAHQdGtS=deh6zZXGv132PKzLROMXQBA83zV=dw_0RLTAqksuiQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 1 Dec 2014 18:36:16 -0500
Trond Myklebust <trond.myklebust@primarydata.com> wrote:

> On Mon, Dec 1, 2014 at 6:05 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> > On Mon, 1 Dec 2014 17:44:07 -0500
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> >
> >> On Fri, Nov 21, 2014 at 02:19:28PM -0500, Jeff Layton wrote:
> >> > ...also make the manipulation of sp_all_threads list use RCU-friendly
> >> > functions.
> >> >
> >> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
> >> > Tested-by: Chris Worley <chris.worley@primarydata.com>
> >> > ---
> >> >  include/linux/sunrpc/svc.h    |  2 ++
> >> >  include/trace/events/sunrpc.h |  3 ++-
> >> >  net/sunrpc/svc.c              | 10 ++++++----
> >> >  3 files changed, 10 insertions(+), 5 deletions(-)
> >> >
> >> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
> >> > index 5f0ab39bf7c3..7f80a99c59e4 100644
> >> > --- a/include/linux/sunrpc/svc.h
> >> > +++ b/include/linux/sunrpc/svc.h
> >> > @@ -223,6 +223,7 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
> >> >  struct svc_rqst {
> >> >     struct list_head        rq_list;        /* idle list */
> >> >     struct list_head        rq_all;         /* all threads list */
> >> > +   struct rcu_head         rq_rcu_head;    /* for RCU deferred kfree */
> >> >     struct svc_xprt *       rq_xprt;        /* transport ptr */
> >> >
> >> >     struct sockaddr_storage rq_addr;        /* peer address */
> >> > @@ -262,6 +263,7 @@ struct svc_rqst {
> >> >  #define    RQ_SPLICE_OK    (4)                     /* turned off in gss privacy
> >> >                                              * to prevent encrypting page
> >> >                                              * cache pages */
> >> > +#define    RQ_VICTIM       (5)                     /* about to be shut down */
> >> >     unsigned long           rq_flags;       /* flags field */
> >> >
> >> >     void *                  rq_argp;        /* decoded arguments */
> >> > diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
> >> > index 5848fc235869..08a5fed50f34 100644
> >> > --- a/include/trace/events/sunrpc.h
> >> > +++ b/include/trace/events/sunrpc.h
> >> > @@ -418,7 +418,8 @@ TRACE_EVENT(xs_tcp_data_recv,
> >> >             { (1UL << RQ_LOCAL),            "RQ_LOCAL"},            \
> >> >             { (1UL << RQ_USEDEFERRAL),      "RQ_USEDEFERRAL"},      \
> >> >             { (1UL << RQ_DROPME),           "RQ_DROPME"},           \
> >> > -           { (1UL << RQ_SPLICE_OK),        "RQ_SPLICE_OK"})
> >> > +           { (1UL << RQ_SPLICE_OK),        "RQ_SPLICE_OK"},        \
> >> > +           { (1UL << RQ_VICTIM),           "RQ_VICTIM"})
> >> >
> >> >  TRACE_EVENT(svc_recv,
> >> >     TP_PROTO(struct svc_rqst *rqst, int status),
> >> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
> >> > index 5d9a443d21f6..4edef32f3b9f 100644
> >> > --- a/net/sunrpc/svc.c
> >> > +++ b/net/sunrpc/svc.c
> >> > @@ -616,7 +616,7 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
> >> >     serv->sv_nrthreads++;
> >> >     spin_lock_bh(&pool->sp_lock);
> >> >     pool->sp_nrthreads++;
> >> > -   list_add(&rqstp->rq_all, &pool->sp_all_threads);
> >> > +   list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
> >> >     spin_unlock_bh(&pool->sp_lock);
> >> >     rqstp->rq_server = serv;
> >> >     rqstp->rq_pool = pool;
> >> > @@ -684,7 +684,8 @@ found_pool:
> >> >              * so we don't try to kill it again.
> >> >              */
> >> >             rqstp = list_entry(pool->sp_all_threads.next, struct svc_rqst, rq_all);
> >> > -           list_del_init(&rqstp->rq_all);
> >> > +           set_bit(RQ_VICTIM, &rqstp->rq_flags);
> >> > +           list_del_rcu(&rqstp->rq_all);
> >> >             task = rqstp->rq_task;
> >> >     }
> >> >     spin_unlock_bh(&pool->sp_lock);
> >> > @@ -782,10 +783,11 @@ svc_exit_thread(struct svc_rqst *rqstp)
> >> >
> >> >     spin_lock_bh(&pool->sp_lock);
> >> >     pool->sp_nrthreads--;
> >> > -   list_del(&rqstp->rq_all);
> >> > +   if (!test_and_set_bit(RQ_VICTIM, &rqstp->rq_flags))
> >> > +           list_del_rcu(&rqstp->rq_all);
> >>
> >> Both users of RQ_VICTIM are under the sp_lock, so we don't really need
> >> an atomic test_and_set_bit, do we?
> >>
> >
> > No, it doesn't really need to be an atomic test_and_set_bit. We could
> > just as easily do:
> >
> > if (!test_bit(...)) {
> >         set_bit(...)
> >         list_del_rcu()
> > }
> 
> Isn't there a chance that the non-atomic version might end up
> clobbering one of the other bits that is not set/cleared under the
> sp_lock?
> 

There are two atomicity "concerns" here...

The main thing is to ensure that we use set_bit or test_and_set_bit to
set the flag. What we *can't* use is __set_bit which is non-atomic
or we'd end up hitting the exact problem you're talking about (possibly
changing an unrelated flag in the field that happened to flip at nearly
the same time).

What's not necessary here is to use test_and_set_bit since all of this
is done under spinlock anyway. In principle, we could do a test_bit and
then follow that up with a set_bit if it's clear. But, I don't think
that really buys us much, and tend to find the test_and_set_bit to be
clearer when reading the code.

-- 
Jeff Layton <jlayton@primarydata.com>
