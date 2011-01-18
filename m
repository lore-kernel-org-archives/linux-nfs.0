Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:58052 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751597Ab1ARWBW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 18 Jan 2011 17:01:22 -0500
Subject: Re: NFS dio aio bug
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <AANLkTikE8CT=6XQn550Cw6V0B7GWezpeUrhctFN8vSE7@mail.gmail.com>
Date: Tue, 18 Jan 2011 17:01:12 -0500
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Message-Id: <D4A3D0CB-DA82-4E2E-BCAD-B03108AA4284@oracle.com>
References: <AANLkTinjkvVySCA93F+p66KrTuqMfMF064ggNSg0yauX@mail.gmail.com> <4E70BD9B-DB23-42EC-B28D-998E16FEC189@oracle.com> <AANLkTikE8CT=6XQn550Cw6V0B7GWezpeUrhctFN8vSE7@mail.gmail.com>
To: Nick Piggin <npiggin@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Jan 14, 2011, at 4:48 PM, Nick Piggin wrote:

> On Sat, Jan 15, 2011 at 3:08 AM, Chuck Lever <chuck.lever@oracle.com> wrote:
>> Hi Nick-
>> 
>> On Jan 13, 2011, at 8:29 PM, Nick Piggin wrote:
>> 
>>> Hi Trond,
>>> 
>>> I'm getting use after frees in aio code in NFS
>> 
>> Can you describe how to reproduce this?
> 
> It was with the aio-dio stress code from xfstests, #207 I think
> or 208.
> 
> Running it for a short time and then ^C ing it would tend to
> trigger it.
> 
> I'll have to get you more details after I come back from
> travelling in a week's time.

I can reproduce this fairly reliably here with test 208.  ^C makes it happen almost immediately, but it can also trigger sometimes just by running the test.

> 
>> 
>>> [ 2703.396766] Call Trace:
>>> [ 2703.396858]  [<ffffffff8100b057>] ? native_sched_clock+0x27/0x80
>>> [ 2703.396959]  [<ffffffff8108509e>] ? put_lock_stats+0xe/0x40
>>> [ 2703.397058]  [<ffffffff81088348>] ? lock_release_holdtime+0xa8/0x140
>>> [ 2703.397159]  [<ffffffff8108a2a5>] lock_acquire+0x95/0x1b0
>>> [ 2703.397260]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
>>> [ 2703.397361]  [<ffffffff81039701>] ? get_parent_ip+0x11/0x50
>>> [ 2703.397464]  [<ffffffff81612a31>] _raw_spin_lock_irq+0x41/0x80
>>> [ 2703.397564]  [<ffffffff811627db>] ? aio_put_req+0x2b/0x60
>>> [ 2703.397662]  [<ffffffff811627db>] aio_put_req+0x2b/0x60
>>> [ 2703.397761]  [<ffffffff811647fe>] do_io_submit+0x2be/0x7c0
>>> [ 2703.397895]  [<ffffffff81164d0b>] sys_io_submit+0xb/0x10
>>> [ 2703.397995]  [<ffffffff8100307b>] system_call_fastpath+0x16/0x1b
>>> 
>>> Adding some tracing, it is due to nfs completing the request then
>>> returning something other than -EIOCBQUEUED, so aio.c
>>> also completes the request.
>> 
>> Is this with reads, writes, or both?  Are the I/O requests smaller than, equal to, or larger than rsize or wsize?
>> 
>> We have a related bug report: hitting the BUG at fs/aio.c:552 (OEL5) and similar for more recent kernels.  Looks like dreq refcounting is faulty somehow.
> 
> I only saw it with writes. The request was being completed
> in nfs direct write path when I added some tracing. It was
> very easy to reproduce, I just didn't have time to bisect it,
> but I can do that when I get back if you don't have it solved
> by then.

I'm looking at it now.  This looks exactly like the symptoms of our bug.  Thanks for the report and the reproducer.

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




