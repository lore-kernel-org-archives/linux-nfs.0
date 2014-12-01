Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vc0-f175.google.com ([209.85.220.175]:55811 "EHLO
	mail-vc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754025AbaLAXgR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 1 Dec 2014 18:36:17 -0500
Received: by mail-vc0-f175.google.com with SMTP id hy10so5201120vcb.20
        for <linux-nfs@vger.kernel.org>; Mon, 01 Dec 2014 15:36:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20141201180533.7c8a7587@tlielax.poochiereds.net>
References: <1416597571-4265-1-git-send-email-jlayton@primarydata.com>
	<1416597571-4265-2-git-send-email-jlayton@primarydata.com>
	<20141201224407.GD30749@fieldses.org>
	<20141201180533.7c8a7587@tlielax.poochiereds.net>
Date: Mon, 1 Dec 2014 18:36:16 -0500
Message-ID: <CAHQdGtS=deh6zZXGv132PKzLROMXQBA83zV=dw_0RLTAqksuiQ@mail.gmail.com>
Subject: Re: [PATCH 1/4] sunrpc: add a rcu_head to svc_rqst and use kfree_rcu
 to free it
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Jeff Layton <jeff.layton@primarydata.com>
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
        Chris Worley <chris.worley@primarydata.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Dec 1, 2014 at 6:05 PM, Jeff Layton <jeff.layton@primarydata.com> wrote:
> On Mon, 1 Dec 2014 17:44:07 -0500
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
>
>> On Fri, Nov 21, 2014 at 02:19:28PM -0500, Jeff Layton wrote:
>> > ...also make the manipulation of sp_all_threads list use RCU-friendly
>> > functions.
>> >
>> > Signed-off-by: Jeff Layton <jlayton@primarydata.com>
>> > Tested-by: Chris Worley <chris.worley@primarydata.com>
>> > ---
>> >  include/linux/sunrpc/svc.h    |  2 ++
>> >  include/trace/events/sunrpc.h |  3 ++-
>> >  net/sunrpc/svc.c              | 10 ++++++----
>> >  3 files changed, 10 insertions(+), 5 deletions(-)
>> >
>> > diff --git a/include/linux/sunrpc/svc.h b/include/linux/sunrpc/svc.h
>> > index 5f0ab39bf7c3..7f80a99c59e4 100644
>> > --- a/include/linux/sunrpc/svc.h
>> > +++ b/include/linux/sunrpc/svc.h
>> > @@ -223,6 +223,7 @@ static inline void svc_putu32(struct kvec *iov, __be32 val)
>> >  struct svc_rqst {
>> >     struct list_head        rq_list;        /* idle list */
>> >     struct list_head        rq_all;         /* all threads list */
>> > +   struct rcu_head         rq_rcu_head;    /* for RCU deferred kfree */
>> >     struct svc_xprt *       rq_xprt;        /* transport ptr */
>> >
>> >     struct sockaddr_storage rq_addr;        /* peer address */
>> > @@ -262,6 +263,7 @@ struct svc_rqst {
>> >  #define    RQ_SPLICE_OK    (4)                     /* turned off in gss privacy
>> >                                              * to prevent encrypting page
>> >                                              * cache pages */
>> > +#define    RQ_VICTIM       (5)                     /* about to be shut down */
>> >     unsigned long           rq_flags;       /* flags field */
>> >
>> >     void *                  rq_argp;        /* decoded arguments */
>> > diff --git a/include/trace/events/sunrpc.h b/include/trace/events/sunrpc.h
>> > index 5848fc235869..08a5fed50f34 100644
>> > --- a/include/trace/events/sunrpc.h
>> > +++ b/include/trace/events/sunrpc.h
>> > @@ -418,7 +418,8 @@ TRACE_EVENT(xs_tcp_data_recv,
>> >             { (1UL << RQ_LOCAL),            "RQ_LOCAL"},            \
>> >             { (1UL << RQ_USEDEFERRAL),      "RQ_USEDEFERRAL"},      \
>> >             { (1UL << RQ_DROPME),           "RQ_DROPME"},           \
>> > -           { (1UL << RQ_SPLICE_OK),        "RQ_SPLICE_OK"})
>> > +           { (1UL << RQ_SPLICE_OK),        "RQ_SPLICE_OK"},        \
>> > +           { (1UL << RQ_VICTIM),           "RQ_VICTIM"})
>> >
>> >  TRACE_EVENT(svc_recv,
>> >     TP_PROTO(struct svc_rqst *rqst, int status),
>> > diff --git a/net/sunrpc/svc.c b/net/sunrpc/svc.c
>> > index 5d9a443d21f6..4edef32f3b9f 100644
>> > --- a/net/sunrpc/svc.c
>> > +++ b/net/sunrpc/svc.c
>> > @@ -616,7 +616,7 @@ svc_prepare_thread(struct svc_serv *serv, struct svc_pool *pool, int node)
>> >     serv->sv_nrthreads++;
>> >     spin_lock_bh(&pool->sp_lock);
>> >     pool->sp_nrthreads++;
>> > -   list_add(&rqstp->rq_all, &pool->sp_all_threads);
>> > +   list_add_rcu(&rqstp->rq_all, &pool->sp_all_threads);
>> >     spin_unlock_bh(&pool->sp_lock);
>> >     rqstp->rq_server = serv;
>> >     rqstp->rq_pool = pool;
>> > @@ -684,7 +684,8 @@ found_pool:
>> >              * so we don't try to kill it again.
>> >              */
>> >             rqstp = list_entry(pool->sp_all_threads.next, struct svc_rqst, rq_all);
>> > -           list_del_init(&rqstp->rq_all);
>> > +           set_bit(RQ_VICTIM, &rqstp->rq_flags);
>> > +           list_del_rcu(&rqstp->rq_all);
>> >             task = rqstp->rq_task;
>> >     }
>> >     spin_unlock_bh(&pool->sp_lock);
>> > @@ -782,10 +783,11 @@ svc_exit_thread(struct svc_rqst *rqstp)
>> >
>> >     spin_lock_bh(&pool->sp_lock);
>> >     pool->sp_nrthreads--;
>> > -   list_del(&rqstp->rq_all);
>> > +   if (!test_and_set_bit(RQ_VICTIM, &rqstp->rq_flags))
>> > +           list_del_rcu(&rqstp->rq_all);
>>
>> Both users of RQ_VICTIM are under the sp_lock, so we don't really need
>> an atomic test_and_set_bit, do we?
>>
>
> No, it doesn't really need to be an atomic test_and_set_bit. We could
> just as easily do:
>
> if (!test_bit(...)) {
>         set_bit(...)
>         list_del_rcu()
> }

Isn't there a chance that the non-atomic version might end up
clobbering one of the other bits that is not set/cleared under the
sp_lock?

-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
