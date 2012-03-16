Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:16511 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1032930Ab2CPPZm convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Mar 2012 11:25:42 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Andy Adamson <androsadamson@gmail.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 1 08/11] SUNRPC: add rpc_drain_queue to empty an
 rpc_waitq
Date: Fri, 16 Mar 2012 15:25:41 +0000
Message-ID: <8587FE07-0E16-4E0B-BCBE-7B295B89062C@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
 <1331836850-5195-9-git-send-email-andros@netapp.com>
 <1331856643.24392.3.camel@lade.trondhjem.org>
 <CAHVgHyWPPu_+9-6mr__n3q-BP=0C+=_5SwTwzZqMiBqQJonp+A@mail.gmail.com>
 <1331911317.2518.14.camel@lade.trondhjem.org>
In-Reply-To: <1331911317.2518.14.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 16, 2012, at 11:21 AM, Myklebust, Trond wrote:

> On Fri, 2012-03-16 at 11:13 -0400, Andy Adamson wrote:
>> On Thu, Mar 15, 2012 at 8:10 PM, Myklebust, Trond
>> <Trond.Myklebust@netapp.com> wrote:
>>> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>>>> From: Andy Adamson <andros@netapp.com>
>>>> 
>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>> ---
>>>> include/linux/sunrpc/sched.h |    1 +
>>>> net/sunrpc/sched.c           |   27 +++++++++++++++++++++++++++
>>>> 2 files changed, 28 insertions(+), 0 deletions(-)
>>>> 
>>>> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
>>>> index dc0c3cc..fce0873 100644
>>>> --- a/include/linux/sunrpc/sched.h
>>>> +++ b/include/linux/sunrpc/sched.h
>>>> @@ -235,6 +235,7 @@ void              rpc_sleep_on_priority(struct rpc_wait_queue *,
>>>> void         rpc_wake_up_queued_task(struct rpc_wait_queue *,
>>>>                                      struct rpc_task *);
>>>> void         rpc_wake_up(struct rpc_wait_queue *);
>>>> +void         rpc_drain_queue(struct rpc_wait_queue *);
>>>> struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
>>>> struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
>>>>                                      bool (*)(struct rpc_task *, void *),
>>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>>> index 1c570a8..11928ff 100644
>>>> --- a/net/sunrpc/sched.c
>>>> +++ b/net/sunrpc/sched.c
>>>> @@ -551,6 +551,33 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
>>>> EXPORT_SYMBOL_GPL(rpc_wake_up);
>>>> 
>>>> /**
>>>> + * rpc_drain_queue - empty the queue and wake up all rpc_tasks
>>>> + * @queue: rpc_wait_queue on which the tasks are sleeping
>>>> + *
>>>> + * Grabs queue->lock
>>>> + */
>>>> +void rpc_drain_queue(struct rpc_wait_queue *queue)
>>>> +{
>>>> +     struct rpc_task *task;
>>>> +     struct list_head *head;
>>>> +
>>>> +     spin_lock_bh(&queue->lock);
>>>> +     head = &queue->tasks[queue->maxpriority];
>>>> +     for (;;) {
>>>> +             while (!list_empty(head)) {
>>>> +                     task = list_entry(head->next, struct rpc_task,
>>>> +                                       u.tk_wait.list);
>>>> +                     rpc_wake_up_task_queue_locked(queue, task);
>>>> +             }
>>>> +             if (head == &queue->tasks[0])
>>>> +                     break;
>>>> +             head--;
>>>> +     }
>>>> +     spin_unlock_bh(&queue->lock);
>>>> +}
>>>> +EXPORT_SYMBOL_GPL(rpc_drain_queue);
>>>> +
>>> 
>>> Confused... How is this function any different from rpc_wake_up()?
>> 
>> Because it actually drains the queues where rpc_wake_up does not.  See
>> the attached output where I added the same printks to both
>> rpc_drain_queue and rpc_wake_up.
> 
> So you are seeing a bug in rpc_wake_up()? I'm surprised; a bug of that
> magnitude should have caused a lot of hangs. Can you please look into
> what is happening.

OK. Didn't know it was a bug - just thought the comment was off...

-->Andy

> 
> -- 
> Trond Myklebust
> Linux NFS client maintainer
> 
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
> 

