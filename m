From: Tom Tucker <tom@opengridcomputing.com>
Subject: Re: [PATCH 3/3] SUNRPC: svc_xprt_enqueue should not refuse to enqueue
 'XPT_DEAD' transports
Date: Mon, 05 Jan 2009 14:13:32 -0600
Message-ID: <496269EC.3080507@opengridcomputing.com>
References: <20081017123207.GA14979@rabbit.intern.cm-ag>	 <1225539927.2221.3.camel@localhost.localdomain>	 <1225546878.4390.3.camel@heimdal.trondhjem.org>	 <1227596962.16868.22.camel@localhost.localdomain>	 <1227619696.7057.19.camel@heimdal.trondhjem.org>	 <1227620339.9425.99.camel@zakaz.uk.xensource.com>	 <1227621434.7057.33.camel@heimdal.trondhjem.org>	 <1227621877.9425.102.camel@zakaz.uk.xensource.com>	 <1227737539.31008.2.camel@localhost.localdomain>	 <1228090631.7112.11.camel@heimdal.trondhjem.org>	 <1228090815.7112.15.camel@heimdal.trondhjem.org>	 <49491C58.9@opengridcomputing.com>	 <1229540877.7257.97.camel@heimdal.trondhjem.org>	 <495E8AB2.8020805@opengridcomputing.com>	 <1231096358.7363.6.camel@heimdal.trondhjem.org>	 <1231097131.7363.11.camel@heimdal.trondhjem.org>	 <49623DB4.609
 0103@opengridcomputing.com>	 <1231175613.7127.6.camel@heimdal.trondhjem.org>	 <49626085.9020609@opengridcomputing.com> <1231185115.7127.28.camel@heimdal.trondhjem.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Trond Myklebust <trond.myklebust@fys.uio.no>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from smtp.opengridcomputing.com ([209.198.142.2]:41935 "EHLO
	smtp.opengridcomputing.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753464AbZAEUNc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 Jan 2009 15:13:32 -0500
In-Reply-To: <1231185115.7127.28.camel-rJ7iovZKK19ZJLDQqaL3InhyD016LWXt@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Trond Myklebust wrote:
> On Mon, 2009-01-05 at 13:33 -0600, Tom Tucker wrote:
>> Trond Myklebust wrote:
>>> On Mon, 2009-01-05 at 11:04 -0600, Tom Tucker wrote:
>>>> Trond Myklebust wrote:
>>>>> On Sun, 2009-01-04 at 14:12 -0500, Trond Myklebust wrote:
>>>> [...snip...]
>>>>
>>>>>> I see nothing that stops svc_delete_xprt() from setting XPT_DEAD after
>>>>>> the above test in svc_revisit(), and before the test inside
>>>>>> svc_xprt_enqueue(). What's preventing a race there?
>>>>> I suppose one way to fix it would be to hold the xprt->xpt_lock across
>>>>> the above test, and to make sure that you set XPT_DEFERRED while holding
>>>>> the lock, and _before_ you test for XPT_DEAD. That way, you guarantee
>>>>> that the svc_deferred_dequeue() loop in svc_delete_xprt() will pick up
>>>>> anything that races with the setting of XPT_DEAD.
>>>>>
>>>>> Trond
>>>> I think this patch fixes this. Thanks again,
>>>>
>>>> From: Tom Tucker <tom@opengridcomputing.com>
>>>> Date: Mon, 5 Jan 2009 10:56:03 -0600
>>>> Subject: [PATCH] svc: Clean up deferred requests on transport destruction
>>>>
>>>> A race between svc_revisit and svc_delete_xprt can result in
>>>> deferred requests holding references on a transport that can never be
>>>> recovered because dead transports are not enqueued for subsequent
>>>> processing.
>>>>
>>>> Check for XPT_DEAD in revisit to clean up completing deferrals on a dead
>>>> transport and sweep a transport's deferred queue to do the same for queued
>>>> but unprocessed deferrals.
>>>>
>>>> Signed-off-by: Tom Tucker <tom@opengridcomputing.com>
>>>>
>>>> ---
>>>>   net/sunrpc/svc_xprt.c |   29 ++++++++++++++++++++++-------
>>>>   1 files changed, 22 insertions(+), 7 deletions(-)
>>>>
>>>> diff --git a/net/sunrpc/svc_xprt.c b/net/sunrpc/svc_xprt.c
>>>> index bf5b5cd..375a695 100644
>>>> --- a/net/sunrpc/svc_xprt.c
>>>> +++ b/net/sunrpc/svc_xprt.c
>>>> @@ -837,6 +837,15 @@ static void svc_age_temp_xprts(unsigned long closure)
>>>>   void svc_delete_xprt(struct svc_xprt *xprt)
>>>>   {
>>>>          struct svc_serv *serv = xprt->xpt_server;
>>>> +       struct svc_deferred_req *dr;
>>>> +
>>>> +       /* Only do this once */
>>>> +       spin_lock(&xprt->xpt_lock);
>>>> +       if (test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
>>>> +               spin_unlock(&xprt->xpt_lock);
>>>> +               return;
>>>> +       }
>>>> +       spin_unlock(&xprt->xpt_lock);
>>> You shouldn't need to take the spinlock here if you just move the line
>>> 	set_bit(XPT_DEFERRED, &xprt->xpt_flags);
>>> in svc_revisit(). See below...
>>>
>> I'm confused...sorry.
>>
>> This lock in intended to avoid the following race:
>>
>> 				revisit:
>> 					- test_bit == 0
>> svc_delete_xprt:
>> 	- test_and_set_bit == 0
>> 	- iterates over deferred queue,
>> 	  but there's nothing in it yet
>> 	  to clean up.
>>
>> 					- Adds deferred request to transport's
>> 					  deferred list.
>> 					- enqueue fails because XPT_DEAD is set
>>
>> Now we've got a dangling reference.
>>
>> The lock forces the delete to wait until the revisit had
>> added the deferral to the transport list.
>>
>>
>>>>          dprintk("svc: svc_delete_xprt(%p)\n", xprt);
>>>>          xprt->xpt_ops->xpo_detach(xprt);
>>>> @@ -851,12 +860,16 @@ void svc_delete_xprt(struct svc_xprt *xprt)
>>>>           * while still attached to a queue, the queue itself
>>>>           * is about to be destroyed (in svc_destroy).
>>>>           */
>>>> -       if (!test_and_set_bit(XPT_DEAD, &xprt->xpt_flags)) {
>>>> -               BUG_ON(atomic_read(&xprt->xpt_ref.refcount) < 2);
>>>> -               if (test_bit(XPT_TEMP, &xprt->xpt_flags))
>>>> -                       serv->sv_tmpcnt--;
>>>> +       if (test_bit(XPT_TEMP, &xprt->xpt_flags))
>>>> +               serv->sv_tmpcnt--;
>>>> +
>>>> +       for (dr = svc_deferred_dequeue(xprt); dr;
>>>> +            dr = svc_deferred_dequeue(xprt)) {
>>>>                  svc_xprt_put(xprt);
>>>> +               kfree(dr);
>>>>          }
>>>> +
>>>> +       svc_xprt_put(xprt);
>>>>          spin_unlock_bh(&serv->sv_lock);
>>>>   }
>>>>
>>>> @@ -902,17 +915,19 @@ static void svc_revisit(struct cache_deferred_req *dreq, int too_many)
>>>>                  container_of(dreq, struct svc_deferred_req, handle);
>>>>          struct svc_xprt *xprt = dr->xprt;
>>>>
>>>> -       if (too_many) {
>>>> +       spin_lock(&xprt->xpt_lock);
>>>  +        set_bit(XPT_DEFERRED, &xprt->xpt_flags);
>>>
>> Given the above, how does this avoid the race?
> 
> By setting XPT_DEFERRED, you will force svc_deferred_dequeue to wait for
> the xprt->xpt_lock, which you are already holding. At that point, it
> would be OK for the test of XPT_DEAD to race, since you are still
> holding the xpt_lock, so the loop over svc_deferred_dequeue() will catch
> it...
> 

Right. I should have looked more carefully.


> Cheers
>   Trond
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

