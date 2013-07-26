Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:41227 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755507Ab3GZOTS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 26 Jul 2013 10:19:18 -0400
Date: Fri, 26 Jul 2013 10:19:16 -0400
From: "J.Bruce Fields" <bfields@citi.umich.edu>
To: NeilBrown <neilb@suse.de>
Cc: Ben Myers <bpm@sgi.com>, Olga Kornievskaia <aglo@citi.umich.edu>,
        NFS <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] NFSD/sunrpc: avoid deadlock on TCP connection due to
 memory pressure.
Message-ID: <20130726141916.GA30651@fieldses.org>
References: <20130710190727.GA22305@fieldses.org>
 <20130715143203.51bc583b@notabene.brown>
 <20130716015803.GA5271@fieldses.org>
 <20130716140021.312b5b07@notabene.brown>
 <20130716142430.GA11977@fieldses.org>
 <20130718000319.GL1681@sgi.com>
 <20130724210746.GB5777@fieldses.org>
 <20130725113023.7bcbc347@notabene.brown>
 <20130725201805.GB17962@fieldses.org>
 <20130726063303.0d1495b3@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130726063303.0d1495b3@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jul 26, 2013 at 06:33:03AM +1000, NeilBrown wrote:
> On Thu, 25 Jul 2013 16:18:05 -0400 "J.Bruce Fields" <bfields@citi.umich.edu>
> wrote:
> 
> > On Thu, Jul 25, 2013 at 11:30:23AM +1000, NeilBrown wrote:
> > > 
> > > Since we enabled auto-tuning for sunrpc TCP connections we do not
> > > guarantee that there is enough write-space on each connection to
> > > queue a reply.
...
> > This is great, thanks!
> > 
> > Inclined to queue it up for 3.11 and stable....
> 
> I'd agree for 3.11.
> It feels a bit border-line for stable.  "dead-lock" and "has been seen in the
> wild" are technically enough justification...
> I'd probably mark it as "pleas don't apply to -stable until 3.11 is released"
> or something like that, just for a bit of breathing space.
> Your call though.


So my takeaway from http://lwn.net/Articles/559113/ was that Linus and
Greg were requesting that:

	- criteria for -stable and late -rc's should really be about the
	  same, and
	- people should follow Documentation/stable-kernel-rules.txt.

So as an exercise to remind me what those rules are:

Easy questions:

	- "no bigger than 100 lines, with context."  Check.
	- "It must fix only one thing."  Check.
	- "real bug that bothers people".  Check.
	- "tested": yep.  It doesn't actually say "tested on stable
	  trees", and I recall this did land you with a tricky bug one
	  time when a prerequisite was omitted from the backport.

Judgement calls:

	- "obviously correct": it's short, but admittedly subtle, and
	  performance regressions can take a while to get sorted out.
	- "It must fix a problem that causes a build error (but not for
	  things marked CONFIG_BROKEN), an oops, a hang, data
	  corruption, a real security issue, or some "oh, that's not
	  good" issue.  In short, something critical."  We could argue
	  that "server stops responding" is critical, though not to the
	  same degree as a panic.
	- OR: alternatively: "Serious issues as reported by a user of a
	  distribution kernel may also be considered if they fix a
	  notable performance or interactivity issue." The only bz I've
	  personally seen was the result of artificial testing of some
	  kind, and it sounds like your case involved a disk failure?

--b.
