Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f172.google.com ([209.85.220.172]:33957 "EHLO
	mail-qk0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752566AbbFECz0 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 22:55:26 -0400
Received: by qkoo18 with SMTP id o18so34287220qko.1
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 19:55:25 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [BUG] nfs3 client stops retrying to connect
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20150604221404.GA20363@bender.morinfr.org>
Date: Thu, 4 Jun 2015 22:57:39 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Message-Id: <22109174-5489-46AB-8C0A-62840D63DC97@gmail.com>
References: <20150521012155.GA19680@bender.morinfr.org> <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com> <20150604200621.GA10335@bender.morinfr.org> <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com> <20150604221404.GA20363@bender.morinfr.org>
To: Guillaume Morin <guillaume@morinfr.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 4, 2015, at 6:14 PM, Guillaume Morin <guillaume@morinfr.org> wrote:

> On 04 Jun 17:23, Chuck Lever wrote:
>>> This just happened during a kernel panic of our nfs server which stayed
>>> down for a while, then only a dozen machines could not recover, the rest
>>> was fine.  So it is definitely not that easy to trigger.
>>> 
>>> So far all my attempts to reproduce this have failed.  I tried mostly by
>>> setting iptables to send RSTs back to the server randomly using iptables
>>> and dropping syns pretty often. If you have any suggestions, that'd be
>>> great
>> 
>> Is there a workload running on that mount point? It probably shouldn't
>> be idle when you try your experiment.
> 
> I was just running ls -l on some dir.  I could do some writes with dd.
> The mount point that "froze" was lightly used and mostly for writes
> 
>>> Do you have any thoughts about my impression that there could be race
>>> between cancelling the callback in xs_close() that could leave
>>> XPRT_CONNECTING on?
>> 
>> I agree that XPRT_CONNECTING is probably the source of the issue.
>> 
>> But xs_tcp_close() can be called directly by autoclose (not likely if
>> there are pending RPCs) or transport shutdown (also not likely, same
>> reason). I'm skeptical there's a race involving xs_close().
>> 
>> I'm wondering if there was a missing state change upcall, or the state
>> change upcall happened and xs_tcp_cancal_linger_timeout() exited
>> without clearing XPRT_CONNECTING.
> 
> I am 100% sure that XPRT_CONNECTING is the issue because 1) the state
> had the flag up 2) there was absolutley no nfs network traffic between the
> client and the server 3) I "unfroze" the mounts by clearing it manually.
> 
> xs_tcp_cancel_linger_timeout, I think, is guaranteed to clear the flag.

I’m speculating based on some comments in the git log, but what if
the transport never sees TCP_CLOSE, but rather gets an error_report
callback instead?

> Either the callback is canceled and it clears the flag or the callback
> will do it.  I am not sure how this could leave the flag set but I am
> not familiar with this code, so I could totally be missing something
> obvious.
> 
> xs_tcp_close() is the only thing I have found which cancels the callback
> and does not clear the flag.

How would xs_tcp_close() be invoked?

>> It's rather academic, though. All this code was replaced in 4.0.
> 
> Well, it's not academic for all the users of the stable branches which
> might have this bug in the kernel they're running :-)

I didn’t mean to be glib. The point is, stable kernels are always fixed
by backporting an existing fix from a newer kernel.

> If I can reproduce this issue, I will happily test 4.0.

Thanks!

--
Chuck Lever
chucklever@gmail.com



