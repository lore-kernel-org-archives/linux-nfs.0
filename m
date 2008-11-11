From: "NeilBrown" <neilb@suse.de>
Subject: Re: [PATCH] gssd:  unblock DNOTIFY_SIGNAL in case it was blocked.
Date: Wed, 12 Nov 2008 09:20:20 +1100 (EST)
Message-ID: <ced7f54f33cb02088b6d9c10603c047e.squirrel@neil.brown.name>
References: <18712.46537.9006.490726@notabene.brown>
    <20081111190940.GA8775@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: kwc@citi.umich.edu, linux-nfs@vger.kernel.org
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:50652 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751617AbYKKWU3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 11 Nov 2008 17:20:29 -0500
In-Reply-To: <20081111190940.GA8775@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, November 12, 2008 6:09 am, J. Bruce Fields wrote:
> On Tue, Nov 11, 2008 at 09:29:29AM +1100, Neil Brown wrote:
>>
>> I have a situation where rpc.gssd appears to not be working.
>> Mount attempts which need to communicate with it block.
>>
>> I've narrowed down the problem to that fact that all realtime signals
>> have been blocked.  This means that DNOTIFY_SIGNAL (which is a
>> realtime signal) is never delivered, so gssd never rescans the
>> rpc_pipe/nfs directory.
>>
>> I haven't figured out why the signals are blocked yet, but having
>> rpc.gssd fail mysteriously in that situation isn't pleasant.
>>
>> So I wonder what people think of the following patch.  It simply
>> unblocks the signal.  Alternately we can check if it is blocked and
>> warn - I'm not really sure of the significance of blocking all these
>> signals.  Maybe it's wrong to just unblock them.
>
> So we don't know what it is that's doing the blocking?

That information has just come to hand.  It seems to be kde.
start_kde (or whatever it is called) and all descendants have these
signals blocked.  xfce seems to do the same thing.  gnome doesn't.

So if you start rpc.gssd from a terminal window while logged in via
KDE, it doesn't behave as expected.

>
>> As an aside, maybe we could change gssd_run to use "ppoll" rather than
>> "poll".  Then it would not have to wake up every 500msec to see if it
>> missed a signal. We would probably have to check kernel version was at
>> least 2.6.16....
>
> Yes. (What does glibc itself do in the ppoll library call if the kernel
> doesn't support it?)

Probably tries to fake it and ends up with a racy implementation.  That
is what it does with pselect.

An alternate would be to not use signals at all (generally a very good
idea) by use inotify instead of dnotify.  But that hasn't always worked
either.

Here is a question:  On which kernel did GSS support first become a really
usable option?  If that is sufficiently recent that it includes either
ppoll or inotify-on-rpc_pipe, then we could just use the modern technology
and tell people that rpc.gssd isn't supported on older kernels because
it doesn't really work anyway.  Would that get us anywhere?

Another alternate.  rpc.gssd currently wakes up every 500msec to check
a global variable that might have been set by a signal arriving.
There would be little extra cost if doing a 'stat' of the rpc_pipe/nfs
directory to see if it had changed (is the timestamp updated when a
change happens?).  This would just be one quick syscall.  Then we could
be much less dependent on correct delivery of the signal.  We could even
not use dnotify at all.


NeilBrown

