Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-wg0-f44.google.com ([74.125.82.44]:49607 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750950Ab2FETXE convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 15:23:04 -0400
Received: by wgbdr13 with SMTP id dr13so5451014wgb.1
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jun 2012 12:23:02 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <4FCE1DC1.6050100@panasas.com>
References: <1338571178-2096-1-git-send-email-andros@netapp.com>
	<1338571178-2096-2-git-send-email-andros@netapp.com>
	<4FCA98E7.2030006@panasas.com>
	<1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com>
	<4FCE1DC1.6050100@panasas.com>
Date: Tue, 5 Jun 2012 15:22:57 -0400
Message-ID: <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
From: Andy Adamson <androsadamson@gmail.com>
To: Boaz Harrosh <bharrosh@panasas.com>
Cc: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 5, 2012 at 10:54 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:
> On 06/05/2012 04:36 PM, Adamson, Andy wrote:
>
>> On Jun 2, 2012, at 6:51 PM, Boaz Harrosh wrote:
>>>
>>> In objects-layout we must report all errors on layout_return. We
>>> accumulate them and report of all errors at once. So we need
>>> the return after all in flights are back. (And no new IOs are
>>> sent) Otherwise we might miss some.
>>
>
>> _pnfs_retrun_layout removes all layouts, and should therefore only be
>> called once.
>
>
> I agree current behavior is a bug, hence my apology.
>
>> I'll can add the 'wait for all in-flight' functionality,
>> and we can switch behaviors (wait or not wait).
>>
>
>
> I disagree you must "delay" the send see below.
>
>>> Also the RFC mandates that we do not use any layout or have
>>> IOs in flight, once we return the layout.
>>
>>
>> You are referring to this piece of the spec?
>> Section 18.44.3
>>
>>   After this call,
>>    the client MUST NOT use the returned layout(s) and the associated
>>    storage protocol to access the file data.
>>
>>
>
>> The above says that the client MUST NOT send any _new_ i/o using the
>> layout. I don't see any reference to in-flight i/o,
>
>
> I don't see reference to in-flight i/o either, so what does that mean?
> Yes or No? It does not it's vague. For me in-flight means "USING"

I shot an arrow in the air - where it lands I know not where. Am I
still using the arrow after I shoot?  If so, exaclty when do I know
that it is not in use by me?

If my RPC's time out,
is the DS using the layout? Suppose it's not a network partition, or a
DS reboot, but just a DS under really heavy load (or for some other
reason) and does not reply within the timeout? Is the client still
using the layout?

So I wait for the "answer", get timeouts, and I have no more
information than if I didn't wait for the answer.  Regardless, once
the decision is made on the client to not send any more i/o using that
data server, I should let the MDS know.


>
> Because in-flight means half was written/read and half was not, if the
> lo_return was received in the middle then the half that came after was
> using the layout information after the Server received an lo_return,
> which clearly violates the above.

No it doesn't. That just means the DS is using the layout. The client
is done using the layout until it sends new i/o using the layout.

>
> In any way, at this point in the code you do not have the information of
> If the RPCs are in the middle of the transfer, hence defined as in-flight.
> Or they are just inside your internal client queues and will be sent clearly
> after the lo_return which surly violates the above. (Without the need of
> explicit definition of in flight.)

We are past the transmit state in the RPC FSM for the errors that
trigger the LAYOUTRETURN.

>
>> nor should there
>> be in the error case. I get a connection error. Did the i/o's I sent
>> get to the data server?

If they get to the data server, does the data server use them?! We can
never know. That is exactly why the client is no longer "using" the
layout.

>
>
> We should always assume that statistically half was sent and half was not
> In any way we will send the all "uncertain range" again.

Sure. We should also let the MDS know that we are resending the
"uncertain range"  ASAP. Thus the LAYOUTRETURN.

>
>> The reason to send a LAYOUTRETURN without
>> waiting for all the in-flights to return with a connection error is
>> precisely to fence any in-flight i/o because I'm resending through
>> the MDS.
>>
>
>
> This is clearly in contradiction of the RFC.

I disagree.

> And is imposing a Server
> behavior that was not specified in RFC.

No server behavior is imposed. Just an opportunity for the server to
do the MUST stated below.

Section 13.6

   As described in Section 12.5.1, a client
   MUST NOT send an I/O to a data server for which it does not hold a
   valid layout; the data server MUST reject such an I/O.


>
> All started IO to the specified DS will return with "connection error"
> pretty fast, right?

Depends on the timeout.

> because the first disconnect probably took a timeout, but
> once the socket identified a disconnect it will stay in that state
> until a reconnect, right.
>
> So what are you attempting to do, Make your internal client Q drain very fast
> since you are going through MDS?

If by the internal client Q you mean the DS session slot_tbl_waitq,
that is a separate issue. Those RPC's are redirected internally upon
waking from the Q, they never get sent to the DS.

We do indeed wait for each in-flight RPC to error out before
re-sending the data of the failed RPC to the MDS.

Your theory that the LAYOUTRETURN we call will somehow speed up our
recovery is wrong.


> But you are doing that by assuming the
> Server will fence ALL IO,

What? No!

> and not by simply aborting your own Q.

See above. Of course we abort/redirect our Q.

We choose not to lose data. We do abort any RPC/NFS/Session queues and
re-direct. Only the in-flight RPC's which we have no idea of their
success are resent _after_ getting the error.  The LAYOUTRETURN is an
indication to the MDS that all is not well.

> Highly unorthodox

I'm open to suggestions. :) As I pointed out above, the only reason to
send the LAYOUTRETURN is to let the MDS know that some I/O might be
resent. Once the server gets the returned layout, it MUST reject any
I/O using that layout. (section 13.6).

> and certainly in violation of above.

I disagree.

-->Andy

>
>>
>>>
>>> I was under the impression that only when the last reference
>>> on a layout is dropped only then we send the lo_return.
>>
>>> If it is not so, this is the proper fix.
>>
>>>
>>> 1. Mark LO invalid so all new IO waits or goes to MDS
>>> 3. When LO ref drops to Zero send the lo_return.
>>
>> Yes for the normal case (evict inode for the file layout),
>
>> but not if I'm in an error situation and I want to fence the DS from in-flight i/o.
>
> A client has no way stated in the protocol to cause a "fence". This is just your
> wishful thinking. lo_return is something else, lo_return means I'm no longer using
> the file, not "please protect me from myself, because I will send more IO after that,
> but please ignore it"
>
> All you can do is abort your own client Q, all these RPCs that did not get sent
> or errored-out will be resent through MDS, there might be half an RPC of overlap.
>
> Think of 4.2 when you will need to report these errors to MDS - on lo_return -
> Your code will not work.
>
> Lets backtrack a second. Let me see if I understand what is your trick:
> 1. Say we have a file with a files-layout of which device_id specifies 3 DSs.
> 2. And say I have a large IO generated by an app to that file.
> 3. In the middle of the IO, one of the DSs, say DS-B, returns with a "connection error"
> 4 The RPCs stripe_units generated to DS-B will all quickly return with "connection error"
>  after the first error.
> 5. But the RPCs to DS-A and DS-C will continue to IO. Until done.
>
> But since you will send the entire range of IO through MDS you want that DS-A, DS-C to
> reject any farther IO, and any RPCs in client Qs for DS-A and DS-C will return quickly
> with "io rejected".
>
> Is that your idea?
>
>>
>>> 4. After LAYOUTRETURN_DONE is back, re-enable layouts.
>>> I'm so sorry it is not so today. I should have tested for
>>> this. I admit that all my error injection tests are
>>> single-file single thread so I did not test for this.
>>>
>>> Sigh, work never ends. Tell me if I can help with this
>>
>> I'll add the wait/no-wait…
>>
>
>
> I would not want a sync wait at all. Please don't code any sync wait for me. It will not
> work for objects, and will produce dead-locks.
>
> What I need is that a flag is raised on the lo_seg, and when last ref on the
> lo_seg drops an lo_return is sent. So either the call to layout_return causes
> the lo_return, or the last io_done of the inflights will cause the send.
> (You see io_done is the one that calls layout_return in the first place)
>
> !! BUT Please do not do any waits at all for my sake, because this is a sure dead-lock !!
>
> And if you ask me It's the way you want it too, Because that's the RFC, and that's
> what you'll need for 4.2.
>
> And perhaps it should not be that hard to implement a Q abort, and not need that
> unorthodox fencing which is not specified in the RFC. And it might be also possible to only
> send IO of DS-B through MDS but keep the inflight IO to DS-A and DS-C valid and not resend.
>
>> -->Andy
>>
>>> Boaz
>
>
> Thanks
> Boaz
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
