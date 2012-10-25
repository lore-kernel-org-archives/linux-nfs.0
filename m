Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:57563 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755992Ab2JYP1I (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Oct 2012 11:27:08 -0400
Date: Thu, 25 Oct 2012 11:27:06 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH v3 1/4] nfsd: add a usermodehelper upcall for NFSv4
 client ID tracking
Message-ID: <20121025112706.086ab02a@corrin.poochiereds.net>
In-Reply-To: <20121025150608.GB6846@fieldses.org>
References: <1351089018-24551-1-git-send-email-jlayton@redhat.com>
	<1351089018-24551-2-git-send-email-jlayton@redhat.com>
	<20121024210310.GG6697@fieldses.org>
	<20121025073936.4a57cf24@tlielax.poochiereds.net>
	<20121025150608.GB6846@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 25 Oct 2012 11:06:09 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Thu, Oct 25, 2012 at 07:39:36AM -0400, Jeff Layton wrote:
> > On Wed, 24 Oct 2012 17:03:10 -0400
> > "J. Bruce Fields" <bfields@fieldses.org> wrote:
> > 
> > > On Wed, Oct 24, 2012 at 10:30:15AM -0400, Jeff Layton wrote:
> > > > Add a new client tracker upcall type that uses call_usermodehelper to
> > > > call out to a program. This seems to be the preferred method of
> > > > calling out to usermode these days for seldom-called upcalls. It's
> > > > simple and doesn't require a running daemon, so it should "just work"
> > > > as long as the binary is installed.
> > > > 
> > > > The client tracking exit operation is also changed to check for a
> > > > NULL pointer before running. The UMH upcall doesn't need to do anything
> > > > at module teardown time.
> > > 
> > > That does look relatively simple, neat.
> > > 
> > > One complaint, a preexisting problem, really: we're passing up the md5
> > > of the client owner name.  We should pass up the original client name,
> > > instead, and make that what we store internally in cl_name.  If nothing
> > > else, it could be useful for debugging.
> > > 
> > > Those names can be up to 1K, though--is that a problem?
> > > 
> > 
> > We do pass the original client name (hex-encoded) as the second
> > argument on some of the commands. If you look in the database, here's
> > what a row of the clients table looks like:
> > 
> > sqlite> select * from clients;
> > 2001:470:8:d63:3a60:77ff:fe93:a95d/2001:470:8:d63:5054:ff:fe9b:3976 tcp|1351162903
> > 
> > The part before the '|' is the client name blob, and the part after is
> > the epoch timestamp for it.
> 
> Bah, sorry, I forgot how the state code worked and confused cl_name and
> cl_recdir....
> 

Yes, it's quite confusing ;)

> > We also pass the md5-hashed directory pathname as
> > $NFSDCLTRACK_LEGACY_RECDIR in "check", and the
> > $NFSDCLTRACK_LEGACY_TOPDIR in "gracedone". My rationale for passing
> > that info on rather than just having userspace find/calculate it
> > follows...
> 
> And you may well be right, but I'm still confused:
> 
> > > I don't understand why the kernel needs to be involved here--can't
> > > userspace find the old directory on its own?
> > 
> > My original thinking was to do all of this in userspace and not have
> > the kernel pass any extra info, but was waved off by several folks who
> > do userspace development, mostly for reason #3 below.
> > 
> > We could, in principle, do all of the legacy migration in userland.
> > There are a few reasons to have the kernel involved however:
> > 
> > 1) this is not using the keys API, so we have no way to change the
> > arguments passed to the program without kernel involvement. So, we'd
> > probably need a kernel parm to disable the legacy transition mode
> > anyway.
> 
> There's no need to change the arguments if one can be calculated from
> the other.  So this comes down to the crypto police problem?
> 

Mostly. I think doing it this way is also slightly more efficient. Why
bother with all of the code to recalculate the hash if the kernel has
already done that for us? Passing that info up to userland is simple...

> > I suppose that we could make the kernel call a wrapper script that in
> > turn sources a file under /etc/sysconfig or /etc/default that has extra
> > command-line arguments. That seems like more trouble than it's worth,
> > but we could consider doing that if you think it's desirable.
> > 
> > 2) I think having the kernel pass this info is at least slightly better
> > for performance. We eliminate the need to
> > open /proc/fs/nfsd/nfsv4recoverydir at all, and go straight to where we
> > need to go. We also eliminate the need to re-calculate the md5 hash in
> > userspace this way.
> 
> The latter's a one-time expense at transition time, and the former
> doesn't sound like a big deal.
> 

Well, not one time exactly. We don't have a mechanism to say that the
transition is "done". So, any time we end up not finding the client
string in the new DB, we'll have to recompute the hash and see if the
dir is there.

It is true that none of this is a big deal, but the less code we have
to deal with, the better, IMO...

> > 3) finally, we eliminate the need to pull in a md5 hashing routine into
> > the userland program. My reasoning for this is somewhat selfish...
> > 
> > The govt. FIPS certification states that you can only use certain
> > crypto algorithms in certain libraries. MD5 is not on that list.
> > 
> > Even if it were, you'd need to pull in library support to handle it --
> > you can't just roll your own routine to do crypto without running afoul
> > of the FIPS "enforcers".
> 
> MD5 is lame, good for FIPS for discouraging it, but this seems a little
> nuts.
> 
> But I guess I can understand: developers have shown a weakness for
> reimplementing these things badly, so the security people may feel they
> have no choice but to go around harassing anything that looks vaguely
> like crypto.  Ugh.
> 

Right. That's basically what this comes down to. It's possible that
this would be no big deal, but why bother with it if we don't have to?

> > We'd have to add a dependency on something
> > like libnss or openssl (and I know how steved feels about extra
> > nfs-utils dependencies).
> > 
> > When you boot in "FIPS mode", non-approved crypto code must be disabled
> > (unrunnable). The kernel already has some code to handle this. I
> > imagine that NFSv4 serving won't work at all in FIPS mode due to this
> > fact since SETCLIENTID/EXCHANGE_ID ops will fail (ouch).
> > 
> > Now, we could claim that no one will run this program unless they can
> > use md5 hashes anyway, or try to get an exception for using md5 here
> > since it's not really for security purposes, but it's giant PITA either
> > way. If we have the kernel just pass this info on, then we can sidestep
> > that issue altogether.
> 
> I'm fine with the transition not working in FIPS mode, as long as NFSv4
> doesn't work in FIPS mode anyway.
> 
> Ugly stupid idea: the kernel appears to have a userspace api now (using
> an AF_ALG socket family?).  Probably more trouble to use than just to
> cut-and-paste an md5 implementation, but maybe that works?
> 

I've never used it, but I think libnss might do that under the covers.

What disadvantages do you see in doing it the way I've proposed?

-- 
Jeff Layton <jlayton@redhat.com>
