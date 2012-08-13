Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:51528 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754278Ab2HMXkO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 13 Aug 2012 19:40:14 -0400
Message-ID: <50299041.2040302@panasas.com>
Date: Tue, 14 Aug 2012 02:39:45 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>
CC: Peng Tao <bergwolf@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
        "Adamson, Andy" <William.Adamson@netapp.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "Welch, Brent" <welch@panasas.com>,
        Garth Gibson <garth.gibson@panasas.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>   <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>   <1344522979.23523.2.camel@lade.trondhjem.org>   <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com>  <1344526780.25447.6.camel@lade.trondhjem.org>  <5027E98B.7050603@panasas.com> <4FA345DA4F4AE44899BD2B03EEEC2FA939C3E7@SACEXCMBX04-PRD.hq.netapp.com>
In-Reply-To: <4FA345DA4F4AE44899BD2B03EEEC2FA939C3E7@SACEXCMBX04-PRD.hq.netapp.com>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 08/13/2012 07:26 PM, Myklebust, Trond wrote:

>> This above here is where you are wrong!! You don't understand my point,
>> and ignore my comments. So let me state it as clear as I can.
> 
> YOU are ignoring the reality of SunRPC. There is no abort/cancel/timeout
> for an RPC call once it has started. This is why we need fencing
> _specifically_ for the pNFS files client.
> 


Again we have a communication problem between us. I say some words and
mean one thing, and you say and hear the same words but attach different
meanings to them. This is no one's fault it's just is.

Lets do an experiment, mount a regular NFS4 in -o soft mode and start
writing to server, say with dd. Now disconnect the cable. After some timeout
the dd will return with "IO error", and will stop writing to file.

This is the timeout I mean. Surely some RPC-requests did not complete and
returned to NFS core with some kind of error.

With RPC-requests I do not mean the RPC protocol on the wire, I mean that
entity inside the Linux Kernel which represents an RPC. Surly some
linux-RPC-requests objects were not released do to a server "rpc-done"
received. But do to an internal mechanism that called the "release" method do to
a communication timeout.

So this is what I call "returned with a timeout". It does exist and used
every day.

Even better if I don't disconnect the wire but do an if_down or halt on the
server, the dd's IO error will happen immediately, not even wait for
any timeout. This is because the socket is orderly closed and all
sends/receives will return quickly with a "disconnect-error".

When I use a single Server like the nfs4 above. Then there is one fact
in above scenario that I want to point out:

    At some point in the NFS-Core state. There is a point that no more
    requests are issued, all old request have released, and an error is
    returned to the application. At that point the client will not call
    skb-send, and will not try farther communication with the Server.

This is what must happen with ALL DSs that belong to a layout, before
client should be LAYOUT_RETURN(ing). The client can only do it's job. That is:

   STOP any skb-send, to any of the DSs in a layout.
   Only then it is complying to the RFC.

So this is what I mean by "return with a timeout below"

>> (Lets assume files layout, for blocks and objects it's a bit different
>>  but mostly the same.)
> 
> That, and the fact that fencing hasn't been implemented for blocks and
> objects. 


That's not true. At Panasas and both at EMC there is fencing in place and
it is used every day. This is why I insist that it is very much
the same for all of us.

> The commit in question is 82c7c7a5a (NFSv4.1 return the LAYOUT
> for each file with failed DS connection I/O) and touches only
> fs/nfs/nfs4filelayout.c. It cannot be affecting blocks and objects.
> 


OK I had in mind the patches that Andy sent. I'll look again for what
actually went in. (It was all while I was unavailable)

>> - Heavy IO is going on, the device_id in question has *3* DSs in it's
>>   device topography. Say DS1, DS2, DS3
>>
>> - We have been queuing IO, and all queues are full. (we have 3 queues in
>>   in question, right? What is the maximum Q depth per files-DS? I know
>>   that in blocks and objects we usually have, I think, something like 128.
>>   This is a *tunable* in the block-layer's request-queue. Is it not some
>>   negotiated parameter with the NFS servers?)
>>
>> - Now, boom DS2 has timed-out. The Linux-client resets the session and
>>   internally closes all sockets of that session. All the RPCs that
>>   belong to DS2 are being returned up with a timeout error. This one
>>   is just the first of all those belonging to this DS2. They will
>>   be decrementing the reference for this layout very, very soon.
>>
>> - But what about DS1, and DS3 RPCs. What should we do with those?
>>   This is where you guys (Trond and Andy) are wrong. We must also
>>   wait for these RPC's as well. And opposite to what you think, this
>>   should not take long. Let me explain:
>>
>>   We don't know anything about DS1 and DS3, each might be, either,
>>   "Having the same communication problem, like DS2". Or "is just working
>>   fine". So lets say for example that DS3 will also time-out in the
>>   future, and that DS1 is just fine and is writing as usual.
>>
>>   * DS1 - Since it's working, it has most probably already done
>>     with all it's IO, because the NFS timeout is usually much longer
>>     then the normal RPC time, and since we are queuing evenly on
>>     all 3 DSs, at this point must probably, all of DS1 RPCs are
>>     already done. (And layout has been de-referenced).
>>
>>   * DS3 - Will timeout in the future, when will that be?
>>     So let me start with, saying:
>>     (1). We could enhance our code and proactively, 
>>         "cancel/abort" all RPCs that belong to DS3 (more on this
>>          below)
> 
> Which makes the race _WORSE_. As I said above, there is no 'cancel RPC'
> operation in SUNRPC. Once your RPC call is launched, it cannot be
> recalled. All your discussion above is about the client side, and
> ignores what may be happening on the data server side. The fencing is
> what is needed to deal with the data server picture.
> 


Again, some miss understanding. I never said we should not send
a LAYOUT_RETURN before writing through MDS. The opposite is true,
I think it is a novel idea and gives you the kind of barrier that
will harden and robust the system.

   WHAT I'm saying is that this cannot happen while the schizophrenic
   client is busily still actively skb-sending more and more bytes
   to all the other DSs in the layout. LONG AFTER THE LAYOUT_RETURN
   HAS BEEN SENT AND RESPONDED.

So what you are saying does not at all contradicts what I want.

   "The fencing is what is needed to deal with the data server picture"
    
    Fine But ONLY after the client has really stopped all sends.
    (Each one will do it's job)

BTW: The Server does not *need* the Client to send a LAYOUT_RETURN
     It's just a nice-to-have, which I'm fine with.
     Both Panasas and EMC when IO is sent through MDS, will first
     recall, overlapping layouts, and only then proceed with
     MDS processing. (This is some deeply rooted mechanism inside
     the FS, an MDS being just another client)

     So this is a known problem that is taken care of. But I totally
     agree with you, the client LAYOUT_RETURN(ing) the layout will save
     lots of protocol time by avoiding the recalls.
     Now you understand why in Objects we mandated this LAYOUT_RETURN
     on errors. And while at it we want the exact error reported.

>>     (2). Or We can prove that DS3's RPCs will timeout at worst
>>          case 1 x NFS-timeout after above DS2 timeout event, or
>>          2 x NFS-timeout after the queuing of the first timed-out
>>          RPC. And statistically in the average case DS3 will timeout
>>          very near the time DS2 timed-out.
>>
>>          This is easy since the last IO we queued was the one that
>>          made DS2's queue to be full, and it was kept full because
>>          DS2 stopped responding and nothing emptied the queue.
>>
>>      So the easiest we can do is wait for DS3 to timeout, soon
>>      enough, and once that will happen, session will be reset and all
>>      RPCs will end with an error.
> 
> 
> You are still only discussing the client side.
> 
> Read my lips: Sun RPC OPERATIONS DO NOT TIMEOUT AND CANNOT BE ABORTED OR
> CANCELED. Fencing is the closest we can come to an abort operation.
> 


Again I did not mean the "Sun RPC OPERATIONS" on the wire. I meant
the Linux-request-entity which while exist has a potential to be
submitted for skb-send. As seen above these entities do timeout
in "-o soft" mode and once released remove the potential of any more
future skb-sends on the wire.

BUT what I do not understand is: In above example we are talking
about DS3. We assumed that DS3 has a communication problem. So no amount
of "fencing" or vudu or any other kind of operation can ever affect
the client regarding DS3. Because even if On-the-server pending requests
from client on DS3 are fenced and discarded these errors will not
be communicated back the client. The client will sit idle on DS3
communication until the end of the timeout, regardless.

Actually what I propose for DS3 in the best robust client is to
destroy it's DS3's sessions and therefor cause all Linux-request-entities
to return much much faster, then if *just waiting* for the timeout to expire.

>> So in the worst case scenario we can recover 2 x NFS-timeout after
>> a network partition, which is just 1 x NFS-timeout, after your
>> schizophrenic FENCE_ME_OFF, newly invented operation.
>>
>> What we can do to enhance our code to reduce error recovery to
>> 1 x NFS-timeout:
>>
>> - DS3 above:
>>   (As I said DS1's queues are now empty, because it was working fine,
>>    So DS3 is a representation of all DS's that have RPCs at the
>>    time DS2 timed-out, which belong to this layout)
>>
>>   We can proactively abort all RPCs belonging to DS3. If there is
>>   a way to internally abort RPC's use that. Else just reset it's
>>   session and all sockets will close (and reopen), and all RPC's
>>   will end with a disconnect error.
> 
> Not on most servers that I'm aware of. If you close or reset the socket
> on the client, then the Linux server will happily continue to process
> those RPC calls; it just won't be able to send a reply.
> Furthermore, if the problem is that the data server isn't responding,
> then a socket close/reset tells you nothing either.
> 


Again I'm talking about the NFS-Internal-request-entities these will
be released, though guarantying that no more threads will use any of
these to send any more bytes over to any DSs.

AND yes, yes. Once the client has done it's job and stopped any future
skb-sends to *all* DSs in question, only then it can report to MDS:
  "Hey I'm done sending in all other routs here LAYOUT_RETURN"
  (Now fencing happens on servers)
  
  and client goes on and says
  
  "Hey can you MDS please also write this data"

Which is perfect for MDS because otherwise if it wants to make sure,
it will need to recall all outstanding layouts, exactly for your
reason, for concern for the data corruption that can happen.

>> - Both DS2 that timed-out, and DS3 that was aborted. Should be
>>   marked with a flag. When new IO that belong to some other
>>   inode through some other layout+device_id encounters a flagged
>>   device, it should abort and turn to MDS IO, with also invalidating
>>   it's layout, and hens, soon enough the device_id for DS2&3 will be
>>   de-referenced and be removed from device cache. (And all referencing
>>   layouts are now gone)
> 
> There is no RPC abort functionality Sun RPC. Again, this argument relies
> on functionality that _doesn't_ exist.
> 


Again I mean internally at the client. For example closing the socket will
have the effect I want. (And some other tricks we can talk about those
later, lets agree about the principal first)

>>   So we do not continue queuing new IO to dead devices. And since most
>>   probably MDS will not give us dead servers in new layout, we should be
>>   good.
>> In summery.
>> - FENCE_ME_OFF is a new operation, and is not === LAYOUT_RETURN. Client
>>   *must not* skb-send a single byte belonging to a layout, after the send
>>   of LAYOUT_RETURN.
>>   (It need not wait for OPT_DONE from DS to do that, it just must make
>>    sure, that all it's internal, or on-the-wire request, are aborted
>>    by easily closing the sockets they belong too, and/or waiting for
>>    healthy DS's IO to be OPT_DONE . So the client is not dependent on
>>    any DS response, it is only dependent on it's internal state being
>>    *clean* from any more skb-send(s))
> 
> Ditto
> 
>> - The proper implementation of LAYOUT_RETURN on error for fast turnover
>>   is not hard, and does not involve a new invented NFS operation such
>>   as FENCE_ME_OFF. Proper codded client, independently, without
>>   the aid of any FENCE_ME_OFF operation, can achieve a faster turnaround
>>   by actively returning all layouts that belong to a bad DS, and not
>>   waiting for a fence-off of a single layout, then encountering just
>>   the same error with all other layouts that have the same DS     
> 
> What do you mean by "all layouts that belong to a bad DS"? Layouts don't
> belong to a DS, and so there is no way to get from a DS to a layout.
> 


Why, sure. loop on all layouts and ask if it has a specific DS.

>> - And I know that just as you did not read my emails from before
>>   me going to Hospital, you will continue to not understand this
>>   one, or what I'm trying to explain, and will most probably ignore
>>   all of it. But please note one thing:
> 
> I read them, but just as now, they continue to ignore the reality about
> timeouts: timeouts mean _nothing_ in an RPC failover situation. There is
> no RPC abort functionality that you can rely on other than fencing.
> 


I hope I explained this by now. If not please, please, lets organize
a phone call. We can use Panasas conference number whenever you are
available. I think we communicate better in person.

Everyone else is also invited.

BUT there is one most important point for me:

   As stated by the RFC. Client must guaranty that no more bytes will be
   sent to any DSs in a layout, once LAYOUT_RETURN is sent. This is the
   only definition of LAYOUT_RETURN, and NO_MATCHING_LAYOUT as response
   to a LAYOUT_RECALL. Which is:
   Client has indicated no more future sends on a layout. (And server will
   enforce it with a fencing)

>>     YOU have sabotaged the NFS 4.1 Linux client, which is now totally
>>     not STD complaint, and have introduced CRASHs. And for no good
>>     reason.
> 
> See above.
> 


OK We'll have to see about these crashes, lets talk about them.

Thanks
Boaz
