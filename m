Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:51336 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1162159Ab2CSQtf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2012 12:49:35 -0400
From: "Adamson, Andy" <William.Adamson@netapp.com>
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Andy Adamson <androsadamson@gmail.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH Version 1 08/11] SUNRPC: add rpc_drain_queue to empty an
 rpc_waitq
Date: Mon, 19 Mar 2012 16:49:34 +0000
Message-ID: <1BF4551A-75CC-4E5F-A39B-A8DE645653F3@netapp.com>
References: <1331836850-5195-1-git-send-email-andros@netapp.com>
 <1331836850-5195-9-git-send-email-andros@netapp.com>
 <1331856643.24392.3.camel@lade.trondhjem.org>
 <CAHVgHyWPPu_+9-6mr__n3q-BP=0C+=_5SwTwzZqMiBqQJonp+A@mail.gmail.com>
 <1331911317.2518.14.camel@lade.trondhjem.org>
 <8587FE07-0E16-4E0B-BCBE-7B295B89062C@netapp.com>
 <69F651CF-0BAF-491F-B557-BC0607356E4F@netapp.com>
In-Reply-To: <69F651CF-0BAF-491F-B557-BC0607356E4F@netapp.com>
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Mar 19, 2012, at 12:44 PM, Andy Adamson wrote:

> 
> The reason rpc_wake_up() does not wake up all the tasks, is that it uses list_for_each_entry_safe which assigns the "next" task->u.tk_wait.lists pointer in it's for loop without taking into consideration the priority queue tasks hanging off the  task->u.tk_wait.links list (note "list" vrs "link") assigned in the for loop body by the call to rpc_wake_up_task_queue_locked.
> 
> Say we have a wait queue with the following: One task in the list (T1) and two priority tasks in T1's "links" list (T2, T3).
> 
> H -> T1 -> H    the next pointers in the "lists" list (T1->u.tk_wait.list) hanging off the list head "H"
> 
> T1 -> T2 -> T3->T1  the next pointers in the "links" list. (T1->u.tk_wait.links is the list head)
> 
> Here is what rpc_wake_up_task_queue_locked does (it calls __rpc_remove_wait_queue_priority on priority queues)
> 
> H -> T2 ->H
> 
> T2 -> T3 -> T2
> 
> with T1 removed.  This is exactly what should happen, T1 is removed, T1's u.tk_wait.links list is spliced onto T2's u.tk_wait.links, and T2 is moved to H's list of u.tk_wait.list tasks.
> 
> 
> #define list_for_each_entry_safe(pos, n, head, member)                  \
>        for (pos = list_entry((head)->next, typeof(*pos), member),      \
>                n = list_entry(pos->member.next, typeof(*pos), member); \
>             &pos->member != (head);                                    \
>             pos = n, n = list_entry(n->member.next, typeof(*n), member))
> 
> 
> BUT!  the for loop in  list_for_each_entry_safe(task, next, head, u.tk_wait.list)  does the following on the above example:
> 
> Start:
> 
> H-> T1 -> H
> T1 -> T2 -> T3 -> T1
> 
> for loop Iniitializer:
> 
> task = list_entry((head)->next, typeof(*task), u.tk_wait.list): 
> next = list_entry(task->u.tk_wait.list.next, typeof(*task), u.tk_wait.list)
> 
> so task = T1, next = H.
> 
> for loop test:
> task != H. This is FALSE

oops - got my TRUE/FALSE mixed ;)
 this is TRUE so execute body

> 
> for loop body:
> call rpc_wake_up_task_queue_locked
> 
> H -> T2 -> H
> T2 ->.T3 -> T2
> 
> for loop increment step
> task = next; 
> next = list_entry(next->u.tk_wait.list.next, typeof(*next), u.tk_wait.list);
> 
> so task = H, next = H.
> 
> for loop test
> 
> task != H  This is TRUE

and this is FALSE do don't execute body

-->Andy
> 
> so stop.
> 
> Note that only T1 was processed - T2 and T3 are still on the queue.
> 
> So list_for_each_entry_safe will not process any u.tk_wait.links tasks, because the next pointer is assigned prior to the call to rpc_wake_up_task_queue_locked, so the for loop increment (or initialization) setting of:
> 
> task = next:
> 
> does NOT pick up the fact that (in our example) T1 was REPLACED by T2, not just removed.
> 
> On the other hand, the rpc_drain_queue() patch uses while(!list_empty()) instead of list_for_each_entry_safe() and happily processes all of the tasks on the queue:
> 
> H -> T1 -> H
> 
> lilst is not empty, so call rpc_wake_up_task_queue_locked.
> 
> H -> T2 -> H
> 
> list is not empty; so call rpc_wake_up _task_queue_locked.
> 
> H -> T3 -> H
> 
> list is not empty; so call rpc_wake_up_task_queue_locked
> 
> list is empty.
> 
> 
> -->Andy
> 
> On Mar 16, 2012, at 11:25 AM, Adamson, Andy wrote:
> 
>> 
>> On Mar 16, 2012, at 11:21 AM, Myklebust, Trond wrote:
>> 
>>> On Fri, 2012-03-16 at 11:13 -0400, Andy Adamson wrote:
>>>> On Thu, Mar 15, 2012 at 8:10 PM, Myklebust, Trond
>>>> <Trond.Myklebust@netapp.com> wrote:
>>>>> On Thu, 2012-03-15 at 14:40 -0400, andros@netapp.com wrote:
>>>>>> From: Andy Adamson <andros@netapp.com>
>>>>>> 
>>>>>> Signed-off-by: Andy Adamson <andros@netapp.com>
>>>>>> ---
>>>>>> include/linux/sunrpc/sched.h |    1 +
>>>>>> net/sunrpc/sched.c           |   27 +++++++++++++++++++++++++++
>>>>>> 2 files changed, 28 insertions(+), 0 deletions(-)
>>>>>> 
>>>>>> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
>>>>>> index dc0c3cc..fce0873 100644
>>>>>> --- a/include/linux/sunrpc/sched.h
>>>>>> +++ b/include/linux/sunrpc/sched.h
>>>>>> @@ -235,6 +235,7 @@ void              rpc_sleep_on_priority(struct rpc_wait_queue *,
>>>>>> void         rpc_wake_up_queued_task(struct rpc_wait_queue *,
>>>>>>                                    struct rpc_task *);
>>>>>> void         rpc_wake_up(struct rpc_wait_queue *);
>>>>>> +void         rpc_drain_queue(struct rpc_wait_queue *);
>>>>>> struct rpc_task *rpc_wake_up_next(struct rpc_wait_queue *);
>>>>>> struct rpc_task *rpc_wake_up_first(struct rpc_wait_queue *,
>>>>>>                                    bool (*)(struct rpc_task *, void *),
>>>>>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>>>>>> index 1c570a8..11928ff 100644
>>>>>> --- a/net/sunrpc/sched.c
>>>>>> +++ b/net/sunrpc/sched.c
>>>>>> @@ -551,6 +551,33 @@ void rpc_wake_up(struct rpc_wait_queue *queue)
>>>>>> EXPORT_SYMBOL_GPL(rpc_wake_up);
>>>>>> 
>>>>>> /**
>>>>>> + * rpc_drain_queue - empty the queue and wake up all rpc_tasks
>>>>>> + * @queue: rpc_wait_queue on which the tasks are sleeping
>>>>>> + *
>>>>>> + * Grabs queue->lock
>>>>>> + */
>>>>>> +void rpc_drain_queue(struct rpc_wait_queue *queue)
>>>>>> +{
>>>>>> +     struct rpc_task *task;
>>>>>> +     struct list_head *head;
>>>>>> +
>>>>>> +     spin_lock_bh(&queue->lock);
>>>>>> +     head = &queue->tasks[queue->maxpriority];
>>>>>> +     for (;;) {
>>>>>> +             while (!list_empty(head)) {
>>>>>> +                     task = list_entry(head->next, struct rpc_task,
>>>>>> +                                       u.tk_wait.list);
>>>>>> +                     rpc_wake_up_task_queue_locked(queue, task);
>>>>>> +             }
>>>>>> +             if (head == &queue->tasks[0])
>>>>>> +                     break;
>>>>>> +             head--;
>>>>>> +     }
>>>>>> +     spin_unlock_bh(&queue->lock);
>>>>>> +}
>>>>>> +EXPORT_SYMBOL_GPL(rpc_drain_queue);
>>>>>> +
>>>>> 
>>>>> Confused... How is this function any different from rpc_wake_up()?
>>>> 
>>>> Because it actually drains the queues where rpc_wake_up does not.  See
>>>> the attached output where I added the same printks to both
>>>> rpc_drain_queue and rpc_wake_up.
>>> 
>>> So you are seeing a bug in rpc_wake_up()? I'm surprised; a bug of that
>>> magnitude should have caused a lot of hangs. Can you please look into
>>> what is happening.
>> 
>> OK. Didn't know it was a bug - just thought the comment was off...
>> 
>> -->Andy
>> 
>>> 
>>> -- 
>>> Trond Myklebust
>>> Linux NFS client maintainer
>>> 
>>> NetApp
>>> Trond.Myklebust@netapp.com
>>> www.netapp.com
>>> 
>> 
> 

