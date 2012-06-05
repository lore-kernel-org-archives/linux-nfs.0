Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:60080 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab2FEUu1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jun 2012 16:50:27 -0400
Message-ID: <4FCE70E0.8080502@panasas.com>
Date: Tue, 5 Jun 2012 23:49:36 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Andy Adamson <androsadamson@gmail.com>
CC: "Adamson, Andy" <William.Adamson@netapp.com>,
        "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        "<linux-nfs@vger.kernel.org>" <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 2/3] NFSv4.1 mark layout when already returned
References: <1338571178-2096-1-git-send-email-andros@netapp.com> <1338571178-2096-2-git-send-email-andros@netapp.com> <4FCA98E7.2030006@panasas.com> <1C92D18B-1977-4A12-A4DA-84DAC4B3E81E@netapp.com> <4FCE1DC1.6050100@panasas.com> <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com>
In-Reply-To: <CAHVgHyXVCUdVFMO1WcRofOCvgDs7Reqsrs39qrZR7UnXWzG8RQ@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/05/2012 10:22 PM, Andy Adamson wrote:

> On Tue, Jun 5, 2012 at 10:54 AM, Boaz Harrosh <bharrosh@panasas.com> wrote:

> 

I do not understand why the communication is so hard between us. Since I'm
the foreigner speaking, I'll take it on me. So I'll try to explain better.


> We are past the transmit state in the RPC FSM for the errors that
> trigger the LAYOUTRETURN.
> 


!! I'm not talking about the RPC that just produced the time-out and is
calling layout_return(), this one, I agree fully, is done with. and is out of our
hands. (We will not send a single byte on it)

I'm talking about the other requests that are still holding the reference
count on the layout. In what stage are they? can you guaranty at layout_return
that they will not send any more bytes after the above event?

If like you say below they are aborted then the reference will drop soon
enough. Right?

>>

<>

> 
> If they get to the data server, does the data server use them?! We can
> never know. That is exactly why the client is no longer "using" the
> layout.
> 


Are you sure?? again we are in a situation where one RPC has returned. But I see
that the layout has other requests using it. Hence reference count is not zero

Are you sure that the client is guarantied to not send a single byte after
this event. Even RPCs of the same layout but to different DSs that are
fine? If you are sure then please show me, because this is not how I read
this code.

The way I read this code is that it is all highly concurrent. You can't even
guaranty that you are not in the middle of a pagelist_write/read() surly before
any actual RPC send. What will cause that to stop? The only guaranty I see
is the reference count on the layout. It's the only barrier you have that
guaranties you are not sending any more bytes using this layout.

<>

> 
> If by the internal client Q you mean the DS session slot_tbl_waitq,
> that is a separate issue. Those RPC's are redirected internally upon
> waking from the Q, they never get sent to the DS.
> 
> We do indeed wait for each in-flight RPC to error out before
> re-sending the data of the failed RPC to the MDS.
> 
> Your theory that the LAYOUTRETURN we call will somehow speed up our
> recovery is wrong.
> 
> 
>> But you are doing that by assuming the
>> Server will fence ALL IO,
> 
> What? No!
> 
>> and not by simply aborting your own Q.
> 
> See above. Of course we abort/redirect our Q.
> 
> We choose not to lose data. We do abort any RPC/NFS/Session queues and
> re-direct. Only the in-flight RPC's which we have no idea of their
> success are resent _after_ getting the error.  The LAYOUTRETURN is an
> indication to the MDS that all is not well.
> 
>> Highly unorthodox
> 
> I'm open to suggestions. :) As I pointed out above, the only reason to
> send the LAYOUTRETURN is to let the MDS know that some I/O might be
> resent. Once the server gets the returned layout, it MUST reject any
> I/O using that layout. (section 13.6).
> 
>> and certainly in violation of above.
> 
> I disagree.
> 
> -->Andy
> 


You signed off here so surly you are not going to answer my most
important question. Which was

* I need to not sync-wait in layout return. I need a FLAG marked on
  the layout_segment which will cause it's layout_return on last reference.

And so do you. Because before the last reference you are not guarantied
that some other thread in the client is not busy sending bytes and/or
preparing new RPCs to be sent, to other DSs using the same layout.

Again I do not understand your motivation. Please if you answer any of my
comments answer this one first:

There are bunch of IO sent to multiple DSs and one RPC times out.

1. Some RPCs have been fully sent and are waiting reply
   I agree these are the arrows out of the bow and out of your hands
2. Some RPCs are in the middle of been sent, you started sending the
   header but not all the bytes. (Are there more than one per DS in this
   state)
3. Some RPCs are in internal client Queues and did not start transmission
4. Some RPCs are just been prepared by other threads they have taken the
   reference count on the layout_segment and will send new RPC soon.

Actually the above "one RPC timed out" is in the [1] group, right?

What you are saying is that we only guarantied to have state [1] RPCs.
That [2] [3] and [4] are out of the picture and have been aborted and/or
taken care of, and/or serialized by some locks. Well I find this hard to
believe. Certainly in objects layout I don't see any such guaranty.

And actually if you are right. Then why don't you do what I suggest
since it will be very soon after the current error-rpc that all the
rest will be aborted and the reference will drop, right?

The way you describe it only the RPCs in state [1] might take time
to return because they are out of your hand and might take a long
time to timeout.

So is it that you don't want to wait for these in state [1]?
I just want to understand.

And at last I want to come back to my concern.

* You want that the LAYOUTRETURN be sent as the *first* RPC that errored
  since you somehow magically guaranty that the client will not send a
  single byte after that. (And why I do not yet understand)

* But for objects-layout It needs the LAYOUTRETURN sent as part of the
  *last* IO in the batch of IOs that was sent as part of the layout.
   This is because it has no magic guaranties that bytes will not be sent
   at the error exit of some middle IO.

   And mainly because it must send a LAYOUTRETURN with all the errors it
   received. If the LAYOUTRETURN was sent with the first one, it might miss
   all the other errors. of the other IO requests. Actually it will be a
   memory leak.

So when you write the code could you please look into these things.

And one last thing:

You seem to be doing a full file LAYOUTRETURN as part of the layout_hdr
But objects and blocks (And also files I think) need a LAYOUTRETURN per
lo_segment. The handling (and ref-counting) should be completely
lo_segment based. In fact the Server and protocol knows nothing about
layout_hdr. What the RFC calls a LAYOUT is what the client named as lo_segment.

Thanks
Boaz
