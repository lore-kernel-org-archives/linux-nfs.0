From: Jeff Layton <jlayton@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Fri, 5 Jun 2009 13:36:34 -0400
Message-ID: <20090605133634.23357e8e@tlielax.poochiereds.net>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>
	<200906051224.40592.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:36084 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752979AbZFERgi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Jun 2009 13:36:38 -0400
In-Reply-To: <200906051224.40592.vapier@gentoo.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 5 Jun 2009 12:24:39 -0400
Mike Frysinger <vapier@gentoo.org> wrote:

> On Friday 05 June 2009 07:36:48 Jeff Layton wrote:
> > Doing this now would add wider testing exposure for these codepaths and
> > help flush out bugs in TIRPC+IPV4 codepaths. OTOH, it means adding a
> > new library dependency for packagers, or they'll need to take the
> > conscious step to --disable-tirpc when they configure.
> 
> or have the configure script dump a warning whenever libtirpc is not used ...
> 

The problem there is that these sorts of warnings tend to get lost in
the noise. So then you have the situation where people aren't sure
whether they built against libtirpc or not. Only running ldd against
the binaries will tell you.

> > We could make it so that configure looks for libtirpc and if it's not
> > available, configures the build against legacy RPC interfaces. I think
> > this is a bad idea however. While it should "just work" either way,
> > there are some small behavioral differences when TIRPC support is built
> > in. I think it's probably better to make enabling and disabling TIRPC a
> > conscious step.
> 
> i think this is the correct behavior for unspecified configure flags

In general, yes. In this case though I think it's reasonable to force
people compiling the package without tirpc installed to take the
conscious step to either install the right libs and headers, or to add
--disable-tirpc.

I think doing so will lead to a more deterministic outcome in this
situation. If that's a problem however, I'm willing to listen to the
reasoning and reconsider...

-- 
Jeff Layton <jlayton@redhat.com>
