Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:32976 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753863AbbG2TPw (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 29 Jul 2015 15:15:52 -0400
Date: Wed, 29 Jul 2015 15:15:51 -0400
From: "'J. Bruce Fields'" <bfields@fieldses.org>
To: Frank Filz <ffilzlnx@mindspring.com>
Cc: "'Kinglong Mee'" <kinglongmee@gmail.com>, linux-nfs@vger.kernel.org,
        tigran.mkrtchyan@desy.de
Subject: Re: [PATCH 4/4] 4.1 create_session: Skip test of CB_NULL for nfs4.1
Message-ID: <20150729191551.GB21742@fieldses.org>
References: <55B76B9D.2090103@gmail.com>
 <008401d0c94e$f90e7250$eb2b56f0$@mindspring.com>
 <20150728175818.GD20951@fieldses.org>
 <009601d0c961$91186490$b3492db0$@mindspring.com>
 <20150728194730.GE20951@fieldses.org>
 <009b01d0c96f$5c0a5c00$141f1400$@mindspring.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <009b01d0c96f$5c0a5c00$141f1400$@mindspring.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jul 28, 2015 at 12:55:26PM -0700, Frank Filz wrote:
> > On Tue, Jul 28, 2015 at 11:16:21AM -0700, Frank Filz wrote:
> > > > On Tue, Jul 28, 2015 at 09:03:38AM -0700, Frank Filz wrote:
> > > > > Why are we removing these two test cases? The Ganesha NFS server
> > > > > at
> > > > least passes them.
> > > >
> > > > And there's nothing wrong with passing the tests, but unfortunately
> > > there's
> > > > not necessarily anything wrong with failing either: a 4.1 server
> > > > isn't
> > > required
> > > > to do a NULL callback to probe the backchannel.
> > > >
> > > > There might be a better test (depend on delegation recalls instead
> > > > of CB_NULL's?), till then I'm OK with turning them off by default.
> > >
> > > I guess I'd at least like to see some explanation of why we're turning
> > > the tests off by default. I'm just resistant to removing testing for no
> reason.
> > 
> > The story is: we turned off the CB_NULL probe in knfsd in the 4.1 case;
> it's
> > unnecessary, and it was causing some problems (due partly to other bugs,
> > but why ask for trouble?).  So these tests started failing.  I'd fix the
> server if
> > there was an actual bug, but it's the tests that are wrong in this case,
> so oh
> > well.
> 
> Ah, ok. I'd love to understand the issues there better, maybe Ganesha
> shouldn't be doing the CB_NULL either...

I've actually forgotten; the patches are from April so linux-nfs
archives from around there might have some discussion.  I think there
was actually a bug in client callback handling that frequent unnecessary
CB_NULL's were triggering.

> > > If the test doesn't actually test anything useful, that would be one
> > > explanation.
> > >
> > > If it's something that's not required and not all servers do it, then
> > > that's another explanation.
> > 
> > Right, this is it, CB_NULL probes aren't required.
> 
> Ok, with this perspective, I'm cool with the test being removed from
> default.
> 
> > We're testing something useful, but something you need a callback to test,
> > so trying to get some other kind of callback (like a deleg recall) would
> be
> > another option.
> 
> Hmm, more to think about from testing Ganesha perspective. The "simple"
> thing  (i.e. using FSAL_VFS) to test in Ganesha doesn't do delegations, so
> the CB_NULL might be the only callback it makes, which might make it
> somewhat useful to prove Ganesha's callback code isn't totally broken...

Yeah, for testing it's annoying that there's no reliable to provoke a
callback.  pynfs could probably be smarter about trying various methods,
and also about reporting the difference between "X failed" and "I
couldn't test X because I couldn't get server to optional thing Y".

--b.
