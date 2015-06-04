Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:33687 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752230AbbFDVVf convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 17:21:35 -0400
Received: by qkhg32 with SMTP id g32so30933252qkh.0
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 14:21:35 -0700 (PDT)
Content-Type: text/plain; charset=windows-1252
Mime-Version: 1.0 (Mac OS X Mail 7.3 \(1878.6\))
Subject: Re: [BUG] nfs3 client stops retrying to connect
From: Chuck Lever <chucklever@gmail.com>
In-Reply-To: <20150604200621.GA10335@bender.morinfr.org>
Date: Thu, 4 Jun 2015 17:23:47 -0400
Cc: Linux NFS Mailing List <linux-nfs@vger.kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Chris Mason <clm@fb.com>
Message-Id: <1E6DAEB8-754B-4F88-8301-4A1A9134922A@gmail.com>
References: <20150521012155.GA19680@bender.morinfr.org> <DAF3CB64-5777-4F74-A31E-4F3FE55D14AD@gmail.com> <20150604200621.GA10335@bender.morinfr.org>
To: Guillaume Morin <guillaume@morinfr.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


On Jun 4, 2015, at 4:06 PM, Guillaume Morin <guillaume@morinfr.org> wrote:

> Hi Chuck,
> 
> On 03 Jun 14:31, Chuck Lever wrote:
>>> If somehow xs_close() is called before the callback
>>> happens, I think it could leave XPRT_CONNECTING on forever though
>>> (since xs_tcp_setup_socket is never called), see
>>> https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/net/sunrpc/xprtsock.c?id=refs/tags/v3.14.43#n887
>>> 
>>> I am still have a few clients with the stuck mount so I could gather
>>> more information if necessary.
>> 
>> A series of commits were merged into the v4.0 kernel, starting with commit 4dda9c8a5e34,
>> that changed the TCP connect logic significantly. It would be helpful to know if the
>> problem can be reproduced when your clients are running the v4.0 kernel.
> 
> Understood but I actually cannot reproduce it on 3.14 as well so I am
> not hopeful I'll be able to try this.

I’ve heard other reports of similar behavior. Finding a reproducer would
be a good first step to confirming when it broke and whether it’s been
addressed in recent kernels.

It would also help to watch the logic in slow motion to see where the
problem manifests.

I know it’s going to be tough to find a reproducer.

> This just happened during a kernel panic of our nfs server which stayed
> down for a while, then only a dozen machines could not recover, the rest
> was fine.  So it is definitely not that easy to trigger.
> 
> So far all my attempts to reproduce this have failed.  I tried mostly by
> setting iptables to send RSTs back to the server randomly using iptables
> and dropping syns pretty often. If you have any suggestions, that'd be
> great

Is there a workload running on that mount point? It probably shouldn’t
be idle when you try your experiment.

> Do you have any thoughts about my impression that there could be race
> between cancelling the callback in xs_close() that could leave
> XPRT_CONNECTING on?

I agree that XPRT_CONNECTING is probably the source of the issue.

But xs_tcp_close() can be called directly by autoclose (not likely if
there are pending RPCs) or transport shutdown (also not likely, same
reason). I’m skeptical there’s a race involving xs_close().

I’m wondering if there was a missing state change upcall, or the state
change upcall happened and xs_tcp_cancal_linger_timeout() exited
without clearing XPRT_CONNECTING.

It’s rather academic, though. All this code was replaced in 4.0.

--
Chuck Lever
chucklever@gmail.com



