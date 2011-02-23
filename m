Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:50741 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751541Ab1BWFx3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 23 Feb 2011 00:53:29 -0500
Date: Wed, 23 Feb 2011 16:53:17 +1100
From: NeilBrown <neilb@suse.de>
To: Rob Landley <rlandley@parallels.com>
Cc: <linux-nfs@vger.kernel.org>
Subject: Re: CACHE_NEW_EXPIRY is 120, nextcheck initialized to 30*60=1800?
Message-ID: <20110223165317.60cf5a3b@notabene.brown>
In-Reply-To: <4D64861F.5000707@parallels.com>
References: <4D63BAA0.3090505@parallels.com>
	<20110223080731.6c013be2@notabene.brown>
	<4D64861F.5000707@parallels.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, 22 Feb 2011 21:59:27 -0600 Rob Landley <rlandley@parallels.com> wrote:

> On 02/22/2011 03:07 PM, NeilBrown wrote:
> > On Tue, 22 Feb 2011 07:31:12 -0600 Rob Landley <rlandley@parallels.com> wrote:
> > 
> >> In net/sunrpc/cache.c line 416 or so (function cache_clean()) there's
> >> this bit:
> >>
> >> else {
> >>         current_index = 0;
> >>         current_detail->nextcheck = seconds_since_boot()+30*60;
> >> }
> >>
> >> The other uses of seconds_since_boot() add CACHE_NEW_EXPIRY (which is
> >> 120).  This is A) more than ten times that, B) a magic inline constant.
> >>
> >> Is there a reason for this?  (Some subtle cache lifetime balancing thing?)
> > 
> > Apples and oranges are both fruit, but don't taste the same...
> 
> I know what "apples and oranges" means, thanks.
> 
> I'm trying to understand this code, and finding a lot of it hard to
> figure out.  For example, in net/sunrpc/svcauth_unix.c there are two
> instances of:
> 
>   expiry = get_expiry(&mesg);
>   if (expiry ==0)
>           return -EINVAL;
> 

The value '0' means that the (textual) mesg didn't look like a value number.


> Except that get_expiry() defined in include/linux/sunrpc/cache.h returns
> the difference between the int stored at &mesg and getboottime(), which
> implies that the value can go negative fairly easily if the system is
> busy with something else for a second, so comparing for equality with
> zero seems odd if it's easy to _miss_.  Possibly some kind of timer is
> scheduled to force this test to happen at the expiry time, but if so I
> haven't found it yet...

The value in 'mesg' should always be well in the future (wrt 'gettimeofday').
The value returned by getboottime will always be in the past (wrt
'gettimeofday').
So the difference will only be negative if userspace requested an expiry time
that was before the time when the system was booted.
It could get an EINVAL, which it what it would deserve, but it would be more
likely to get an entry that is already expired (which is a reasonable result).

The 'expiry' number is a 'seconds since epoch' number, in case that wasn't
obvious.

> 
> (I'm trying to hunt down a specific bug where a cached value of some
> kind is using the wrong struct net * context, and thus if I mount nfsv3
> from the host context it works, and from a container it also works, but
> if I have different (overlapping) network routings in host and container
> and I mount the same IP from the host from the container it doesn't
> work, even if I _unmount_ the host's copy before mounting the
> container's copy (or vice versa).  But that it starts working again when
> I give it a couple minutes after the umount for the cache data to time
> out...)

I'm a little fuzzy about the whole 'struct net * context' thing, but in
cache.c, it only seems to be connected with server-side things, while you
seem to be talking about client-side things so maybe there is a disconnect
there.  Not sure though.


> 
> Mostly I'm assuming you guys know what you're doing and that my
> understanding of the enormous layers of nested cacheing is incomplete,
> but there's a lot of complexity to dig through here...

You are too kind.   "Once thought we knew what we were doing" is about as
much as I'd own up to :-)

If you are looking at client-side handling of net contexts, you probably want
to start at rpc_create which does something with args->net.
Find out where that value came from, and where it is going to.  Maybe that
will help.  (But if you find any wild geese, let me know!)

NeilBrown
