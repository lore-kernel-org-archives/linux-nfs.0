Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52067 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750839Ab0JOAJc convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 14 Oct 2010 20:09:32 -0400
Received: by wyb28 with SMTP id 28so151534wyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 14 Oct 2010 17:09:30 -0700 (PDT)
In-Reply-To: <20101014171522.GA553@fieldses.org>
References: <AANLkTin8tXxRFA5G8c9jKLv6aeEM8YLRX54YT5GozxK+@mail.gmail.com>
	<20101014171522.GA553@fieldses.org>
Date: Thu, 14 Oct 2010 20:09:26 -0400
Message-ID: <AANLkTikiyuT=_3WU4ru__J+e0O-eZ5ksWUm1fqK9AwU0@mail.gmail.com>
Subject: Re: Thread scheduling issues
From: Lyle Seaman <lyleseaman@gmail.com>
To: linux-nfs@vger.kernel.org
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Sorry to add to the confusion.  It is a 2.6.32.23 kernel, allegedly:
Linux prodLMS03 2.6.32-23-server #37-Ubuntu SMP Fri Jun 11 09:11:11
UTC 2010 x86_6
4 GNU/Linux

Though I won't be 100% sure what's in it unless I build one myself from source.

>>  363        if (pool->sp_nwaking >= SVC_MAX_WAKING) {
>> //  == 5 -lws
>>  364                /* too many threads are runnable and trying to wake up */
>>  365                thread_avail = 0;
>>  366                pool->sp_stats.overloads_avoided++;
>>  367        }
>
> That strikes me as a more likely cause of your problem.  But it was
> reverted in v2.6.33, and you say you're using v2.6.35.22, so there's
> some confusion here?

I think that the problem is the combination of the above with the
half-second sleep, and my next step is to build a kernel and tweak
both of those.

> I think the code was trying to avoid reading an rpc request
> until it was reasonably sure it would have the resources to complete it,
> so we didn't end up with a thread stuck waiting on a half-received rpc.

Yes, that's what it looks like to me too.  I'd have to think hard
about how to balance the different factors and avoid deadlock,
particularly where the client and server are sharing the same VM pool.
 It seems to me that preventing stuck threads is most important if
threads are the scarce resource, but I suppose memory could be a
problem too.   One issue is that data is acknowledged when it is
consumed by NFS so you can't just decide "whoops, I'm out of memory",
throw it away, and let the client resend - at least, not if using
RPC/TCP. (we could do that in AFS because we had two different kind of
acknowledgements, incidentally)

The symptoms of the problem are:

workload is biased towards small writes, ~ 4k ave size.

ops are:
getattr 40%  setattr 5% lookup 10% access 19%
read 5% write 8% commit 8%

low CPU utilization - usr+sys < 5%, idle == 0, wait > 95%
high disk-wait %age ==> "disk bound", but that's a bit misleading, see below
low # of nfsd in D state, usually 3-8, very occasionally 20.
50 nfsd threads are configured, but those last 30 just never run.
small #s (3-ish) of simultaneous I/Os delivered to disk subsystem as
reported by 'sar -d'.
2 clients with lots of pent-up demand ( > 50 threads on each are
blocked waiting for NFS )

local processes on the NFS server are still getting great performance
out of the disk subsystem, so the driver/HBA isn't the bottleneck.
sar reports mean svc times <4ms.  I don't know how much to trust sar
though.

The disk subsystem is one LUN in a shared SAN with lots of capacity,
if only I could deliver more than a handful of ops to it at one time.
"disk-bound" just means that adding cpu won't help with the same
workload, but it doesn't mean that the disk subsystem is incapable of
handling additional load if I can get it there.

Watching /proc/fs/nfsd/pool_stats shows deltas from previous sample in
the range of
0 ~4x x ~2x x 0
( pool, packets, sockets_queued, threads_woken, overloads_avoided,
threads_timedout )

That is, at every sample, the value of sockets_queued is exactly equal
to overloads_avoided, and can be as much as half the number of total
calls handled (though usually it is much less).

5 threads which are blocked waiting for the underlying filesystem op
do not cause increments  of "overloads_avoided" counter.  That looks
like a, hmm, heuristic for systems with more disk capacity and less
CPU than I have.  I don't absolutely *know* that this particular
alloc_page is failing but it sure fits the data.   Next step for me is
instrumenting and counting that branch, but I thought I'd check to see
if this had been talked about before, since I can't find it in the
archives or bugzilla.

exporting the fs with -o async helps but I don't like doing it.
