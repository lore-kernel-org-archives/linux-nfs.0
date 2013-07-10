Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37572 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754603Ab3GJC1n (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 22:27:43 -0400
Date: Tue, 9 Jul 2013 22:27:35 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Olga Kornievskaia <aglo@citi.umich.edu>, NFS <linux-nfs@vger.kernel.org>
Subject: Re: Is tcp autotuning really what NFS wants?
Message-ID: <20130710022735.GI8281@fieldses.org>
References: <20130710092255.0240a36d@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130710092255.0240a36d@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 10, 2013 at 09:22:55AM +1000, NeilBrown wrote:
> 
> Hi,
>  I just noticed this commit:
> 
> commit 9660439861aa8dbd5e2b8087f33e20760c2c9afc
> Author: Olga Kornievskaia <aglo@citi.umich.edu>
> Date:   Tue Oct 21 14:13:47 2008 -0400
> 
>     svcrpc: take advantage of tcp autotuning
> 
> 
> which I must confess surprised me.  I wonder if the full implications of
> removing that functionality were understood.
> 
> Previously nfsd would set the transmit buffer space for a connection to
> ensure there is plenty to hold all replies.  Now it doesn't.
> 
> nfsd refuses to accept a request if there isn't enough space in the transmit
> buffer to send a reply.  This is important to ensure that each reply gets
> sent atomically without blocking and there is no risk of replies getting
> interleaved.
> 
> The server starts out with a large estimate of the reply space (1M) and for
> NFSv3 and v2 it quickly adjusts this down to something realistic.  For NFSv4
> it is much harder to estimate the space needed so it just assumes every
> reply will require 1M of space.
> 
> This means that with NFSv4, as soon as you have enough concurrent requests
> such that 1M each reserves all of whatever window size was auto-tuned, new
> requests on that connection will be ignored.
>
> This could significantly limit the amount of parallelism that can be achieved
> for a single TCP connection (and given that the Linux client strongly prefers
> a single connection now, this could become more of an issue).

Worse, I believe it can deadlock completely if the transmit buffer
shrinks too far, and people really have run into this:

	http://mid.gmane.org/<20130125185748.GC29596@fieldses.org>

Trond's suggestion looked at the time like it might work and be doable:

	http://mid.gmane.org/<4FA345DA4F4AE44899BD2B03EEEC2FA91833C1D8@sacexcmbx05-prd.hq.netapp.com>

but I dropped it.

The v4-specific situation might not be hard to improve: the v4
processing decodes the whole compound at the start, so it knows the
sequence of ops before it does anything else and could compute a tighter
bound on the reply size at that point.

> I don't know if this is a real issue that needs addressing - I hit in the
> context of a server filesystem which was misbehaving and so caused this issue
> to become obvious.  But in this case it is certainly the filesystem, not the
> NFS server, which is causing the problem.

Yeah it looks a real problem.

Some good test cases would be useful if we could find some.

And, yes, my screwup for merging 966043986 without solving those other
problems first.  I was confused.

It does make a difference on high bandwidth-product networks (something
people have also hit).  I'd rather not regress there and also would
rather not require manual tuning for something we should be able to get
right automatically.

--b.
