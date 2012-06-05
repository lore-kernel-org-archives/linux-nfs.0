Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:45839 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750810Ab2FEOzT (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 10:55:19 -0400
Message-ID: <4FCE1DC1.6050100@panasas.com>
Date: Tue, 5 Jun 2012 17:54:57 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Adamson, Andy" <William.Adamson@netapp.com>
CC: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com> <4FCA98E7.2030006@panasas.com> <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com>
In-Reply-To: <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2012 04:36 PM, Adamson, Andy wrote:

> On Jun 2, 2012, at 6:51 PM, Boaz Harrosh wrote:
>>
>> In objects-layout we must report all errors on layout_return. We
>> accumulate them and report of all errors at once. So we need
>> the return after all in flights are back. (And no new IOs are
>> sent) Otherwise we might miss some.
> 

> _pnfs_retrun_layout removes all layouts, and should therefore only be
> called once. 


I agree current behavior is a bug, hence my apology.

> I'll can add the 'wait for all in-flight' functionality,
> and we can switch behaviors (wait or not wait).
> 


I disagree you must "delay" the send see below.

>> Also the RFC mandates that we do not use any layout or have
>> IOs in flight, once we return the layout.
> 
> 
> You are referring to this piece of the spec?
> Section 18.44.3   
> 
>   After this call,
>    the client MUST NOT use the returned layout(s) and the associated
>    storage protocol to access the file data.
> 
> 

> The above says that the client MUST NOT send any _new_ i/o using the
> layout. I don't see any reference to in-flight i/o, 


I don't see reference to in-flight i/o either, so what does that mean?
Yes or No? It does not it's vague. For me in-flight means "USING"

Because in-flight means half was written/read and half was not, if the
lo_return was received in the middle then the half that came after was
using the layout information after the Server received an lo_return,
which clearly violates the above.

In any way, at this point in the code you do not have the information of
If the RPCs are in the middle of the transfer, hence defined as in-flight.
Or they are just inside your internal client queues and will be sent clearly
after the lo_return which surly violates the above. (Without the need of
explicit definition of in flight.)

> nor should there
> be in the error case. I get a connection error. Did the i/o's I sent
> get to the data server? 


We should always assume that statistically half was sent and half was not
In any way we will send the all "uncertain range" again.

> The reason to send a LAYOUTRETURN without
> waiting for all the in-flights to return with a connection error is
> precisely to fence any in-flight i/o because I'm resending through
> the MDS.
> 


This is clearly in contradiction of the RFC. And is imposing a Server
behavior that was not specified in RFC.

All started IO to the specified DS will return with "connection error"
pretty fast, right? because the first disconnect probably took a timeout, but
once the socket identified a disconnect it will stay in that state
until a reconnect, right.

So what are you attempting to do, Make your internal client Q drain very fast
since you are going through MDS? But you are doing that by assuming the
Server will fence ALL IO, and not by simply aborting your own Q. Highly unorthodox 
and certainly in violation of above.

> 
>>
>> I was under the impression that only when the last reference
>> on a layout is dropped only then we send the lo_return.
> 
>> If it is not so, this is the proper fix.
> 
>>
>> 1. Mark LO invalid so all new IO waits or goes to MDS
>> 3. When LO ref drops to Zero send the lo_return.
> 
> Yes for the normal case (evict inode for the file layout),

> but not if I'm in an error situation and I want to fence the DS from in-flight i/o.

A client has no way stated in the protocol to cause a "fence". This is just your
wishful thinking. lo_return is something else, lo_return means I'm no longer using
the file, not "please protect me from myself, because I will send more IO after that,
but please ignore it"

All you can do is abort your own client Q, all these RPCs that did not get sent
or errored-out will be resent through MDS, there might be half an RPC of overlap.

Think of 4.2 when you will need to report these errors to MDS - on lo_return -
Your code will not work.

Lets backtrack a second. Let me see if I understand what is your trick:
1. Say we have a file with a files-layout of which device_id specifies 3 DSs.
2. And say I have a large IO generated by an app to that file.
3. In the middle of the IO, one of the DSs, say DS-B, returns with a "connection error"
4 The RPCs stripe_units generated to DS-B will all quickly return with "connection error"
  after the first error.
5. But the RPCs to DS-A and DS-C will continue to IO. Until done.

But since you will send the entire range of IO through MDS you want that DS-A, DS-C to
reject any farther IO, and any RPCs in client Qs for DS-A and DS-C will return quickly
with "io rejected".

Is that your idea?

> 
>> 4. After LAYOUTRETURN_DONE is back, re-enable layouts.
>> I'm so sorry it is not so today. I should have tested for
>> this. I admit that all my error injection tests are
>> single-file single thread so I did not test for this.
>>
>> Sigh, work never ends. Tell me if I can help with this
> 
> I'll add the wait/no-wait…
> 


I would not want a sync wait at all. Please don't code any sync wait for me. It will not
work for objects, and will produce dead-locks.

What I need is that a flag is raised on the lo_seg, and when last ref on the
lo_seg drops an lo_return is sent. So either the call to layout_return causes
the lo_return, or the last io_done of the inflights will cause the send.
(You see io_done is the one that calls layout_return in the first place)

!! BUT Please do not do any waits at all for my sake, because this is a sure dead-lock !!

And if you ask me It's the way you want it too, Because that's the RFC, and that's
what you'll need for 4.2.

And perhaps it should not be that hard to implement a Q abort, and not need that
unorthodox fencing which is not specified in the RFC. And it might be also possible to only
send IO of DS-B through MDS but keep the inflight IO to DS-A and DS-C valid and not resend.

> -->Andy
> 
>> Boaz


Thanks
Boaz

