Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:52007 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab2HLRgk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 12 Aug 2012 13:36:40 -0400
Message-ID: <5027E98B.7050603@panasas.com>
Date: Sun, 12 Aug 2012 20:36:11 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Peng Tao <bergwolf@gmail.com>, Benny Halevy <bhalevy@tonian.com>,
        Andy Adamson <andros@netapp.com>
CC: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Tigran Mkrtchyan <tigran.mkrtchyan@desy.de>,
        "Isaman, Fred" <Fred.Isaman@netapp.com>,
        "Welch, Brent" <welch@panasas.com>,
        Garth Gibson <garth.gibson@panasas.com>
Subject: Re: [PATCH] NFSv4.1: Remove a bogus BUG_ON() in nfs4_layoutreturn_done
References: <1344457310-26442-1-git-send-email-Trond.Myklebust@netapp.com>  <CA+a=Yy7SX+cPLFiNy552bU9ZMS_rSwvaSpV732_mDwpcPAH5Wg@mail.gmail.com>  <1344522979.23523.2.camel@lade.trondhjem.org>  <CA+a=Yy7tDi0kQGvjPeb=O_9XMnZDm-_31VTkNF7wEW7Pb0BZow@mail.gmail.com> <1344526780.25447.6.camel@lade.trondhjem.org>
In-Reply-To: <1344526780.25447.6.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On 08/09/2012 06:39 PM, Myklebust, Trond wrote:
> If the problem is that the DS is failing to respond, how does the client
> know that the in-flight I/O has ended?

For the client, the above DS in question, has timed-out, we have reset
it's session and closed it's sockets. And all it's RPC requests have
been, or are being, ended with a timeout-error. So the timed-out
DS is a no-op. All it's IO request will end very soon, if not already.

A DS time-out is just a very valid, and meaningful response, just like
an op-done-with-error. This was what Andy added to the RFC's errata
which I agree with.

> 
> No. It is using the layoutreturn to tell the MDS to fence off I/O to a
> data server that is not responding. It isn't attempting to use the
> layout after the layoutreturn: 

> the whole point is that we are attempting
> write-through-MDS after the attempt to write through the DS timed out.
> 

Trond STOP!!! this is pure bullshit. You guys took the opportunity of
me being in Hospital, and the rest of the bunch not having a clue. And
snuck in a patch that is totally wrong for everyone, not taking care of
any other LD *crashes* . And especially when this patch is wrong even for
files layout.

This above here is where you are wrong!! You don't understand my point,
and ignore my comments. So let me state it as clear as I can.

(Lets assume files layout, for blocks and objects it's a bit different
 but mostly the same.)

- Heavy IO is going on, the device_id in question has *3* DSs in it's
  device topography. Say DS1, DS2, DS3

- We have been queuing IO, and all queues are full. (we have 3 queues in
  in question, right? What is the maximum Q depth per files-DS? I know
  that in blocks and objects we usually have, I think, something like 128.
  This is a *tunable* in the block-layer's request-queue. Is it not some
  negotiated parameter with the NFS servers?)

- Now, boom DS2 has timed-out. The Linux-client resets the session and
  internally closes all sockets of that session. All the RPCs that
  belong to DS2 are being returned up with a timeout error. This one
  is just the first of all those belonging to this DS2. They will
  be decrementing the reference for this layout very, very soon.

- But what about DS1, and DS3 RPCs. What should we do with those?
  This is where you guys (Trond and Andy) are wrong. We must also
  wait for these RPC's as well. And opposite to what you think, this
  should not take long. Let me explain:

  We don't know anything about DS1 and DS3, each might be, either,
  "Having the same communication problem, like DS2". Or "is just working
  fine". So lets say for example that DS3 will also time-out in the
  future, and that DS1 is just fine and is writing as usual.

  * DS1 - Since it's working, it has most probably already done
    with all it's IO, because the NFS timeout is usually much longer
    then the normal RPC time, and since we are queuing evenly on
    all 3 DSs, at this point must probably, all of DS1 RPCs are
    already done. (And layout has been de-referenced).

  * DS3 - Will timeout in the future, when will that be?
    So let me start with, saying:
    (1). We could enhance our code and proactively, 
        "cancel/abort" all RPCs that belong to DS3 (more on this
         below)
    (2). Or We can prove that DS3's RPCs will timeout at worst
         case 1 x NFS-timeout after above DS2 timeout event, or
         2 x NFS-timeout after the queuing of the first timed-out
         RPC. And statistically in the average case DS3 will timeout
         very near the time DS2 timed-out.

         This is easy since the last IO we queued was the one that
         made DS2's queue to be full, and it was kept full because
         DS2 stopped responding and nothing emptied the queue.

     So the easiest we can do is wait for DS3 to timeout, soon
     enough, and once that will happen, session will be reset and all
     RPCs will end with an error.

So in the worst case scenario we can recover 2 x NFS-timeout after
a network partition, which is just 1 x NFS-timeout, after your
schizophrenic FENCE_ME_OFF, newly invented operation.

What we can do to enhance our code to reduce error recovery to
1 x NFS-timeout:

- DS3 above:
  (As I said DS1's queues are now empty, because it was working fine,
   So DS3 is a representation of all DS's that have RPCs at the
   time DS2 timed-out, which belong to this layout)

  We can proactively abort all RPCs belonging to DS3. If there is
  a way to internally abort RPC's use that. Else just reset it's
  session and all sockets will close (and reopen), and all RPC's
  will end with a disconnect error.

- Both DS2 that timed-out, and DS3 that was aborted. Should be
  marked with a flag. When new IO that belong to some other
  inode through some other layout+device_id encounters a flagged
  device, it should abort and turn to MDS IO, with also invalidating
  it's layout, and hens, soon enough the device_id for DS2&3 will be
  de-referenced and be removed from device cache. (And all referencing
  layouts are now gone)
  So we do not continue queuing new IO to dead devices. And since most
  probably MDS will not give us dead servers in new layout, we should be
  good.

In summery.
- FENCE_ME_OFF is a new operation, and is not === LAYOUT_RETURN. Client
  *must not* skb-send a single byte belonging to a layout, after the send
  of LAYOUT_RETURN.
  (It need not wait for OPT_DONE from DS to do that, it just must make
   sure, that all it's internal, or on-the-wire request, are aborted
   by easily closing the sockets they belong too, and/or waiting for
   healthy DS's IO to be OPT_DONE . So the client is not dependent on
   any DS response, it is only dependent on it's internal state being
   *clean* from any more skb-send(s))

- The proper implementation of LAYOUT_RETURN on error for fast turnover
  is not hard, and does not involve a new invented NFS operation such
  as FENCE_ME_OFF. Proper codded client, independently, without
  the aid of any FENCE_ME_OFF operation, can achieve a faster turnaround
  by actively returning all layouts that belong to a bad DS, and not
  waiting for a fence-off of a single layout, then encountering just
  the same error with all other layouts that have the same DS     

- And I know that just as you did not read my emails from before
  me going to Hospital, you will continue to not understand this
  one, or what I'm trying to explain, and will most probably ignore
  all of it. But please note one thing:

    YOU have sabotaged the NFS 4.1 Linux client, which is now totally
    not STD complaint, and have introduced CRASHs. And for no good
    reason.

No thanks
Boaz
