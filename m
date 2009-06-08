From: Jeff Layton <jlayton@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 19:08:25 -0400
Message-ID: <20090608190825.046355d4@tupile.poochiereds.net>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>
	<200906051224.40592.vapier@gentoo.org>
	<20090605133634.23357e8e@tlielax.poochiereds.net>
	<200906051650.42007.vapier@gentoo.org>
	<20090606071153.164d92dd@tlielax.poochiereds.net>
	<7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com>
	<20090606160230.247d3ca3@tlielax.poochiereds.net>
	<861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>
	<7A24DF798E223B4C9864E8F92E8C93EC031D1B12@SACMVEXC1-PRD.hq.netapp.com>
	<20090608125957.3c8f0c95@tlielax.poochiereds.net>
	<7A24DF798E223B4C9864E8F92E8C93EC031D1EFD@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
	"Mike Frysinger" <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:55512 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751478AbZFHXIf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 19:08:35 -0400
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC031D1EFD-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Jun 2009 15:17:55 -0700
"Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:

>  
> 
> > -----Original Message-----
> > From: Jeff Layton [mailto:jlayton@redhat.com] 
> > Sent: Monday, June 08, 2009 10:00 AM
> > To: Muntz, Daniel
> > Cc: Chuck Lever; Mike Frysinger; linux-nfs@vger.kernel.org
> > Subject: Re: should we make --enable-tirpc the default in 
> > current nfs-utils?
> > 
> > On Mon, 8 Jun 2009 08:46:23 -0700
> > "Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:
> > 
> > > > 
> > > > The reason to build without it is that libtirpc is 
> > largely untested 
> > > > code (on Linux), and the nfs-utils support to use TI-RPC is also 
> > > > largely untested.  I think the default config settings should 
> > > > configure a safe, known-working configuration, not the 
> > most advanced 
> > > > configuration.
> > > > 
> > > > As much as I like the idea of wider testing, the idea 
> > that we happen 
> > > > to be testing with live users is not inviting.  But I 
> > guess it's all 
> > > > we've got at this point.
> > > 
> > > It would be nice if RH had a way of testing this with 
> > Fedora without 
> > > making it the default in the standard nfs-utils package 
> > until _after_ 
> > > testing.  Perhaps nfs-utils has evolved to the point where it could 
> > > use a release-candidate model.  Then all distros could pull an RC 
> > > build if they want it, while production users could pull 
> > the last "stable"
> > > release.
> > 
> > This has very little to do with Red Hat. We can enable or 
> > disable TIRPC in our own distros without making this change 
> > upstream. The question here is whether we should make this 
> > the default now, or does it make more sense to wait until 
> > everything has been converted to TIRPC, and had IPv6 support 
> > added and *then* enable it.
> 
> But **IF** you had a release candidate model, then you would have a
> mechanism for OTHERS to pick up "pre-release" code and get the
> additional testing you are after.  Without it, your only option is to
> put un/little-tested code into mainline nfs-utils (I am going on your
> assertion and Chuck's that this code needs more testing).  I can't see
> any reasonable excuse (non-FUD as you say) for not doing things this
> way.
> 

I'm not sure what you're proposing...so you're saying we should cut a
release candidate version and apply nothing but this patch to it to
make --enable-tirpc the default? Or is this more a proposal to change
the nfs-utils release mode in general?

I'm a bit skeptical that that will result in better testing, but I'm
willing to listen to what you're proposing.

When I say that this code needs more testing, I mean exactly that.
Chuck and I have tested it and banged out as many bugs as we can find.
The next step is to get it into more people's hands. This will likely
uncover even more bugs, which we will then fix.

-- 
Jeff Layton <jlayton@redhat.com>
