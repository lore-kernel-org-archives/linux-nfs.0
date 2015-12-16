Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:46857 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932512AbbLPDKk (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 15 Dec 2015 22:10:40 -0500
From: NeilBrown <neilb@suse.com>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Date: Wed, 16 Dec 2015 14:10:30 +1100
Cc: Anna Schumaker <anna.schumaker@netapp.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] SUNRPC: restore fair scheduling to priority queues.
In-Reply-To: <CAHQdGtSbawsf+=uqz3D5UAPntHVKFnUgVZAYh3ym_Fs_+fHAoQ@mail.gmail.com>
References: <87twnjb7lq.fsf@notabene.neil.brown.name> <CAHQdGtSbawsf+=uqz3D5UAPntHVKFnUgVZAYh3ym_Fs_+fHAoQ@mail.gmail.com>
Message-ID: <874mfjay1l.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: multipart/signed; boundary="=-=-=";
	micalg=pgp-sha256; protocol="application/pgp-signature"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

--=-=-=
Content-Type: text/plain

On Wed, Dec 16 2015, Trond Myklebust wrote:

> On Tue, Dec 15, 2015 at 6:44 PM, NeilBrown <neilb@suse.com> wrote:
>>
>> Commit: c05eecf63610 ("SUNRPC: Don't allow low priority tasks to pre-empt higher priority ones")
>>
>> removed the 'fair scheduling' feature from SUNRPC priority queues.
>> This feature caused problems for some queues (send queue and session slot queue)
>> but is still needed for others, particularly the tcp slot queue.
>>
>> Without fairness, reads (priority 1) can starve background writes
>> (priority 0) so a streaming read can cause writeback to block
>> indefinitely.  This is not easy to measure with default settings as
>> the current slot table size is much larger than the read-ahead size.
>> However if the slot-table size is reduced (seen when backporting to
>> older kernels with a limited size) the problem is easily demonstrated.
>>
>> This patch conditionally restores fair scheduling.  It is now the
>> default unless rpc_sleep_on_priority() is called directly.  Then the
>> queue switches to strict priority observance.
>>
>> As that function is called for both the send queue and the session
>> slot queue and not for any others, this has exactly the desired
>> effect.
>>
>> The "count" field that was removed by the previous patch is restored.
>> A value for '255' means "strict priority queuing, no fair queuing".
>> Any other value is a could of owners to be processed before switching
>> to a different priority level, just like before.
>>
>> Signed-off-by: NeilBrown <neilb@suse.com>
>> ---
>>
>> It is quite possible that you won't like the overloading of
>> rpc_sleep_on_priority() to disable fair-scheduling and would prefer an
>> extra arg to rpc_init_priority_wait_queue().  I can do it that way if
>> you like.
>> NeilBrown
>>
>>
>>  include/linux/sunrpc/sched.h |  1 +
>>  net/sunrpc/sched.c           | 12 +++++++++---
>>  2 files changed, 10 insertions(+), 3 deletions(-)
>>
>> diff --git a/include/linux/sunrpc/sched.h b/include/linux/sunrpc/sched.h
>> index d703f0ef37d8..985efe8d7e26 100644
>> --- a/include/linux/sunrpc/sched.h
>> +++ b/include/linux/sunrpc/sched.h
>> @@ -184,6 +184,7 @@ struct rpc_wait_queue {
>>         pid_t                   owner;                  /* process id of last task serviced */
>>         unsigned char           maxpriority;            /* maximum priority (0 if queue is not a priority queue) */
>>         unsigned char           priority;               /* current priority */
>> +       unsigned char           count;                  /* # task groups remaining to be serviced */
>>         unsigned char           nr;                     /* # tasks remaining for cookie */
>>         unsigned short          qlen;                   /* total # tasks waiting in queue */
>>         struct rpc_timer        timer_list;
>> diff --git a/net/sunrpc/sched.c b/net/sunrpc/sched.c
>> index 73ad57a59989..e8fcd4f098bb 100644
>> --- a/net/sunrpc/sched.c
>> +++ b/net/sunrpc/sched.c
>> @@ -117,6 +117,8 @@ static void rpc_set_waitqueue_priority(struct rpc_wait_queue *queue, int priorit
>>                 rpc_rotate_queue_owner(queue);
>>                 queue->priority = priority;
>>         }
>> +       if (queue->count != 255)
>> +               queue->count = 1 << (priority * 2);
>>  }
>>
>>  static void rpc_set_waitqueue_owner(struct rpc_wait_queue *queue, pid_t pid)
>> @@ -144,8 +146,10 @@ static void __rpc_add_wait_queue_priority(struct rpc_wait_queue *queue,
>>         INIT_LIST_HEAD(&task->u.tk_wait.links);
>>         if (unlikely(queue_priority > queue->maxpriority))
>>                 queue_priority = queue->maxpriority;
>> -       if (queue_priority > queue->priority)
>> -               rpc_set_waitqueue_priority(queue, queue_priority);
>> +       if (queue->count == 255) {
>> +               if (queue_priority > queue->priority)
>> +                       rpc_set_waitqueue_priority(queue, queue_priority);
>> +       }
>>         q = &queue->tasks[queue_priority];
>>         list_for_each_entry(t, q, u.tk_wait.list) {
>>                 if (t->tk_owner == task->tk_owner) {
>> @@ -401,6 +405,7 @@ void rpc_sleep_on_priority(struct rpc_wait_queue *q, struct rpc_task *task,
>>          * Protect the queue operations.
>>          */
>>         spin_lock_bh(&q->lock);
>> +       q->count = 255;
>>         __rpc_sleep_on_priority(q, task, action, priority - RPC_PRIORITY_LOW);
>>         spin_unlock_bh(&q->lock);
>>  }
>> @@ -478,7 +483,8 @@ static struct rpc_task *__rpc_find_next_queued_priority(struct rpc_wait_queue *q
>>                 /*
>>                  * Check if we need to switch queues.
>>                  */
>> -               goto new_owner;
>> +               if (queue->count == 255 || --queue->count)
>> +                       goto new_owner;
>>         }
>>
>>         /*
>>
>
> Are we sure there is value in keeping FLUSH_LOWPRI for background writes?

There is currently also FLUSH_HIGHPRI for "for_reclaim" writes.
Should they be allowed to starve reads?

If you treated all reads and writed the same, then I can't see value in
restoring fair scheduling.   If there is any difference, then I suspect
we do need the fairness.

Thanks,
NeilBrown

--=-=-=
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBCAAGBQJWcNYmAAoJEDnsnt1WYoG5aYgQAIMpgrRm0e+8fqZ+Mj8NS9Ym
5ll5vRBs5WNJsnjwXuY6VGUkgi1zH7g2p+QTAFqTD7RjxCNAUFxWuUEzRSDdcsbB
XDUPBocPXurK/kQI90MuvO2EYWtIx4m5YmQcWHwRq5wEqCYB2C/+syvH74BeOaeq
2smsxea7j0/aafr1cJ8X4wVGa5gEg7URfAG0NteYN4qZ7QLFAUdnP58YIlcmhzMk
jEAnIa6R4a+cZtT1IcfaWcuo5I8duRFasmtJa3zt7Mho6WimBsWo81f7Rc6+GlH+
rFl7yK9Noxb6tvMaLkfmJygiT50oOVVtD7xyCWXntcWECV8/a6oWBgZ3m2hmSoNY
6ecCb4KAxM0GIwtC5nQGRNtyll+b1v9792l3XhPXoybQoq15Oz4jWKhz/CAGm2dJ
Kxl5pGdasoxY+rO8o0QyMi7ClRqb5kNY3dGj6Mrt/AYrk3FGTGKY8aIEe/+f9ek7
Z0sPihLud0LqHOIaZVZvxNGW8onwXVbGxBJYv7LIxY/Xt/orQJayKinibnmaKdg8
nUPSYu0EDw6SO3Sv9aLi9vlI7R24mdOt6ddTvHYEcVdorzdz+4qR4uSUTb+Tg8Td
pKLxHzh8Ki+KA/FiXZlQk1xBsf5zoKBDA2a8m+yfc3qByG26y/jqtuFs49ewRxsI
iVaGc9GKh/L47wFCg0CB
=uI/8
-----END PGP SIGNATURE-----
--=-=-=--
