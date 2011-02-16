Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:2654 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755457Ab1BPO0Q convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 16 Feb 2011 09:26:16 -0500
Subject: Re: [PATCH] nfs: don't queue synchronous NFSv4 close rpc_release
 to nfsiod
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: linux-nfs@vger.kernel.org
In-Reply-To: <1297865354.6596.13.camel@heimdal.trondhjem.org>
References: <1297781939-1400-1-git-send-email-jlayton@redhat.com>
	 <1297783898.10103.22.camel@heimdal.trondhjem.org>
	 <20110215113053.345e3abc@tlielax.poochiereds.net>
	 <1297813624.10103.34.camel@heimdal.trondhjem.org>
	 <1297865354.6596.13.camel@heimdal.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 16 Feb 2011 09:26:13 -0500
Message-ID: <1297866373.6596.18.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2011-02-16 at 09:09 -0500, Trond Myklebust wrote: 
> On Tue, 2011-02-15 at 18:47 -0500, Trond Myklebust wrote: 
> > diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
> > index 243fc09..11b71b1 100644
> > --- a/net/sunrpc/sched.c
> > +++ b/net/sunrpc/sched.c
> > @@ -252,23 +252,39 @@ static void rpc_set_active(struct rpc_task *task)
> >  
> >  /*
> >   * Mark an RPC call as having completed by clearing the 'active' bit
> > + * and then waking up all tasks that were sleeping.
> >   */
> > -static void rpc_mark_complete_task(struct rpc_task *task)
> > +static int rpc_complete_task(struct rpc_task *task)
> >  {
> > -	smp_mb__before_clear_bit();
> > +	void *m = &task->tk_runstate;
> > +	wait_queue_head_t *wq = bit_waitqueue(m, RPC_TASK_ACTIVE);
> > +	struct wait_bit_key k = __WAIT_BIT_KEY_INITIALIZER(m, RPC_TASK_ACTIVE);
> > +	unsigned long flags;
> > +	int ret;
> > +
> > +	spin_lock_irqsave(&wq->lock, flags);
> >  	clear_bit(RPC_TASK_ACTIVE, &task->tk_runstate);
> > -	smp_mb__after_clear_bit();
> > -	wake_up_bit(&task->tk_runstate, RPC_TASK_ACTIVE);
> > +	if (waitqueue_active(wq))
> > +		__wake_up_locked_key(wq, TASK_NORMAL, &k);
> > +	ret = atomic_dec_and_test(&task->tk_count);
> > +	spin_unlock_irqrestore(&wq->lock, flags);
> > +	return ret;
> >  }
> >  
> >  /*
> >   * Allow callers to wait for completion of an RPC call
> > + *
> > + * Note the use of out_of_line_wait_on_bit() rather than wait_on_bit()
> > + * to enforce taking of the wq->lock and hence avoid races with
> > + * rpc_complete_task().
> >   */
> >  int __rpc_wait_for_completion_task(struct rpc_task *task, int (*action)(void *))
> >  {
> > +	BUG_ON(!RPC_IS_ASYNC(task));
> > +
> >  	if (action == NULL)
> >  		action = rpc_wait_bit_killable;
> > -	return wait_on_bit(&task->tk_runstate, RPC_TASK_ACTIVE,
> > +	return out_of_line_wait_on_bit(&task->tk_runstate, RPC_TASK_ACTIVE,
> >  			action, TASK_KILLABLE);
> >  }
> >  EXPORT_SYMBOL_GPL(__rpc_wait_for_completion_task);
> 
> Never mind. The above ordering scheme is broken by the fact that
> 'wake_bit_function' calls autoremove_wake_function, which again means
> that finish_wait optimises away the spin lock.
> 
> Back to the drawing board...

...and after yet another cup of coffee the solution suggests itself: we
just need to reorder the calls to __wake_up_locked_key and the
atomic_dec_and_test in rpc_complete_task. The revised patch is appended.

Cheers
  Trond 

8<---------------------------------------------------------------------------- 
