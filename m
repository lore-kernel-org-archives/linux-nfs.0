Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57577 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752516Ab3HVN6v (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 22 Aug 2013 09:58:51 -0400
Date: Thu, 22 Aug 2013 09:58:47 -0400
From: Jeff Layton <jlayton@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        Andy Adamson <andros@netapp.com>, steved@redhat.com
Subject: Re: [PATCH] SUNRPC: We must not use list_for_each_entry_safe() in
 rpc_wake_up()
Message-ID: <20130822095847.398a1685@tlielax.poochiereds.net>
In-Reply-To: <20130822095224.13eec221@tlielax.poochiereds.net>
References: <1332181002-10302-1-git-send-email-Trond.Myklebust@netapp.com>
	<20130822095224.13eec221@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 22 Aug 2013 09:52:24 -0400
Jeff Layton <jlayton@redhat.com> wrote:

> On Mon, 19 Mar 2012 14:16:42 -0400
> Trond Myklebust <Trond.Myklebust@netapp.com> wrote:
> 
> > The problem is that for the case of priority queues, we
> > have to assume that __rpc_remove_wait_queue_priority will move new
> > elements from the tk_wait.links lists into the queue->tasks[] list.
> > We therefore cannot use list_for_each_entry_safe() on queue->tasks[],
> > since that will skip these new tasks that __rpc_remove_wait_queue_priority
> > is adding.
> > 
> > Without this fix, rpc_wake_up and rpc_wake_up_status will both fail
> > to wake up all functions on priority wait queues, which can result
> > in some nasty hangs.
> > 
> > Reported-by: Andy Adamson <andros@netapp.com>
> > Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> > Cc: stable@vger.kernel.org
> > ---
> >  net/sunrpc/sched.c |   15 +++++++++++----
> >  1 files changed, 11 insertions(+), 4 deletions(-)
> > 
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index 1c570a8..994cfea 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -534,14 +534,18 @@ EXPORT_SYMBOL_GPL(rpc_wake_up_next);
> >   */
> >  void rpc_wake_up(struct rpc_wait_queue *queue)
> >  {
> > -	struct rpc_task *task, *next;
> >  	struct list_head *head;
> >  
> >  	spin_lock_bh(&queue->lock);
> >  	head = &queue->tasks[queue->maxpriority];
> >  	for (;;) {
> > -		list_for_each_entry_safe(task, next, head, u.tk_wait.list)
> > +		while (!list_empty(head)) {
> > +			struct rpc_task *task;
> > +			task = list_first_entry(head,
> > +					struct rpc_task,
> > +					u.tk_wait.list);
> >  			rpc_wake_up_task_queue_locked(queue, task);
> > +		}
> >  		if (head == &queue->tasks[0])
> >  			break;
> >  		head--;
> > @@ -559,13 +563,16 @@ EXPORT_SYMBOL_GPL(rpc_wake_up);
> >   */
> >  void rpc_wake_up_status(struct rpc_wait_queue *queue, int status)
> >  {
> > -	struct rpc_task *task, *next;
> >  	struct list_head *head;
> >  
> >  	spin_lock_bh(&queue->lock);
> >  	head = &queue->tasks[queue->maxpriority];
> >  	for (;;) {
> > -		list_for_each_entry_safe(task, next, head, u.tk_wait.list) {
> > +		while (!list_empty(head)) {
> > +			struct rpc_task *task;
> > +			task = list_first_entry(head,
> > +					struct rpc_task,
> > +					u.tk_wait.list);
> >  			task->tk_status = status;
> >  			rpc_wake_up_task_queue_locked(queue, task);
> >  		}
> 
> I have a question about this (old) patch...
> 
> Steve D. backported this patch for RHEL5, and it's causing a deadlock
> there. This is mainly due to the fact that this code in RHEL5 is based
> on 2.6.18 and is quite different (it still has the RPC_TASK_WAKEUP
> flag, and there's an inversion problem with it in the code). I don't
> think it's a problem in most later kernels.
> 
> What I'm not clear on is this: how can new entries end up on these lists
> even though we hold the queue->lock here? It looks like the queue->lock
> is always held when __rpc_remove_wait_queue_priority is called.
> 
> Even if there is some way for that to happen, how is it safe to add
> entries to that list without taking the lock? That seems like it would
> be a great way to corrupt the list.
> 
> Thanks,

<facepalm>

I get it now. We do hold the queue->lock. I guess the concern is that
this will occur when we end up calling rpc_wake_up_task_queue_locked
from within the loop. 

Sorry for the noise! Now to figure out how to fix this in RHEL5...
-- 
Jeff Layton <jlayton@redhat.com>
