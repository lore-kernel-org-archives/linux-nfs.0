From: Jeff Layton <jlayton@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Sat, 6 Jun 2009 07:11:53 -0400
Message-ID: <20090606071153.164d92dd@tlielax.poochiereds.net>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>
	<200906051224.40592.vapier@gentoo.org>
	<20090605133634.23357e8e@tlielax.poochiereds.net>
	<200906051650.42007.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36532 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753716AbZFFLLy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 6 Jun 2009 07:11:54 -0400
In-Reply-To: <200906051650.42007.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 5 Jun 2009 16:50:41 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> On Friday 05 June 2009 13:36:34 Jeff Layton wrote:
> > On Fri, 5 Jun 2009 12:24:39 -0400 Mike Frysinger wrote:
> > > On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
> > > > Doing this now would add wider testing exposure for these codepaths and
> > > > help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
> > > > new library dependency for packagers, or they'll need to take the
> > > > conscious step to --disable-tirpc when they configure.
> > >
> > > or have the configure script dump a warning whenever libtirpc is not used
> > > ...
> >
> > The problem there is that these sorts of warnings tend to get lost in
> > the noise. So then you have the situation where people aren't sure
> > whether they built against libtirpc or not. Only running ldd against
> > the binaries will tell you.
> 
> the configure script knows whether it's going to be building against libtirpc.  
> it isnt going to happen randomly during `make`.
> AC_MSG_WARNING([
> 
> You really should think about switching to libtirpc
> 
> ])
> 
> maybe it's different in Gentoo, but people report configure warnings all the 
> time ;)
> 

Well, Gentoo probably has a larger percentage of people compiling the
sources. Other distros generally distribute the binaries. But to be
fair, it's not unreasonable to expect people who are compiling from
sources to know what they're doing.

> > > > We could make it so that configure looks for libtirpc and if it's not
> > > > available, configures the build against legacy RPC interfaces. I think
> > > > this is a bad idea however. While it should "just work" either way,
> > > > there are some small behavioral differences when TIRPC support is built
> > > > in. I think it's probably better to make enabling and disabling TIRPC a
> > > > conscious step.
> > >
> > > i think this is the correct behavior for unspecified configure flags
> >
> > In general, yes. In this case though I think it's reasonable to force
> > people compiling the package without tirpc installed to take the
> > conscious step to either install the right libs and headers, or to add
> > --disable-tirpc.
> >
> > I think doing so will lead to a more deterministic outcome in this
> > situation. If that's a problem however, I'm willing to listen to the
> > reasoning and reconsider...
> 
> i just dont agree with having to re-run configure to "fix" a condition that 
> the configure script should already be able to handle.  but i'm speaking in 
> general terms here, not specific to what you propose as that isnt exactly the 
> same thing.  i dont feel too strongly here, especially since it doesnt affect 
> me in any realistic way.
> -mike

Ok, fair enough. I don't feel terribly strongly about this either and
that is the the conventional way that configure options work (don't
fail unless absolutely necessary). I'll see about coding up a patch
that makes --enable-tirpc the default but falls back to legacy RPC code
with a warning if TIRPC libs/headers aren't present.

Thanks for the input...

-- 
Jeff Layton <jlayton@redhat.com>
