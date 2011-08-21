Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail2.shareable.org ([80.68.89.115]:47861 "EHLO
	mail2.shareable.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751233Ab1HUUVD (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 21 Aug 2011 16:21:03 -0400
Date: Sun, 21 Aug 2011 21:20:58 +0100
From: Jamie Lokier <jamie@shareable.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Al Viro <viro@ZenIV.linux.org.uk>, Sylvain Rochet <gradator@gradator.net>,
        linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: PROBLEM: 2.6.35.7 to 3.0 Inotify events missing
Message-ID: <20110821202058.GF14899@jl-vm1.vm.bytemark.co.uk>
References: <20101018223540.GA20730@gradator.net>
 <20110819230344.GA24784@gradator.net>
 <20110819233756.GI11512@jl-vm1.vm.bytemark.co.uk>
 <20110820012943.GD2203@ZenIV.linux.org.uk>
 <20110820030335.GA14899@jl-vm1.vm.bytemark.co.uk>
 <20110821170714.GB9296@fieldses.org>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20110821170714.GB9296@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

J. Bruce Fields wrote:
> On Sat, Aug 20, 2011 at 04:03:35AM +0100, Jamie Lokier wrote:
> > Well you still have your sense of humour...
> > 
> > I've never understood why you think it's about the file manager /
> > desktop, or why you so strongly dislike the feature.  It originated
> > there historically, but that is not it's primary use.
> > 
> > The implementation, sure, but you seem to dislike the very *principle*
> > of subscribing to changes.
> > 
> > Every interesting use of inotify that I've seen is for some kind of
> > cache support, to eliminate the majority of stat() calls, to remove
> > disk I/O (no stat means no inode), to ensure correctness (st_mtime is
> > coarse and unreliable),
> 
> It seems rather fragile as an mtime replacement unless it's also got
> some sort of logging built in at a pretty low level so that you don't
> lose events while you're not listening.

It mainly serves as an accelerator for existing stat/mtime checks,
though it does improve change detection in the last second or so since
a previous change, which with mtime you have to make pessimistic or
sometimes-incorrect assumptions.

Quite a few programs use inotify now because it saves a little power,
and is a bit more responsive than, say, polling config files with stat().

For reliable filesystem tracking across times when not listening,
especially if you don't trust the clock to have no backward steps (and
you should not), a lazy change count file attribute would do.  It's
been discussed but never implemented.

> And of course events have to be defined very carefully to avoid problems
> such as this one.

This thread has revealed quite a big hole, I agree.  Apps cannot even
use their normal filesystem-type whitelisting to catch this.  This is bad!

It is not the first hole that was found in inotify/dnotify, but it's
the first one I'm aware of that wasn't pointed out long ago and
then quietly ignored :-/

> > and to avoid having to modify every
> > application which might affect any file from which cached items are
> > derived to explicitly notify all the applications which might use any
> > of those files.
> > 
> > You like high performance, reliable and correct behaviour, and high
> > scalability.  So I have never understood why you dislike the
> > change-subscription principle so strongly, because it is a natural
> > ally to those properties.
> 
> I don't think we've seen a design that does all of that yet.

Designs get discussed from time to time, over the decades.

I think one of the reasons it doesn't go further is Al's well-known
objection -- why put the effort in if you know it will be rejected.
And a widespread view that it's just unimportant GUI file manager fluff.
The latter also means dependability issues have tended not to be taken
seriously.

-- Jamie
