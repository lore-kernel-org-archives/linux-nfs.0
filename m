From: Jeff Layton <jlayton@redhat.com>
Subject: Re: should we make --enable-tirpc the default in current nfs-utils?
Date: Mon, 8 Jun 2009 12:59:57 -0400
Message-ID: <20090608125957.3c8f0c95@tlielax.poochiereds.net>
References: <20090605073648.5a5497b5@tlielax.poochiereds.net>
	<200906051224.40592.vapier@gentoo.org>
	<20090605133634.23357e8e@tlielax.poochiereds.net>
	<200906051650.42007.vapier@gentoo.org>
	<20090606071153.164d92dd@tlielax.poochiereds.net>
	<7A24DF798E223B4C9864E8F92E8C93EC031D19D3@SACMVEXC1-PRD.hq.netapp.com>
	<20090606160230.247d3ca3@tlielax.poochiereds.net>
	<861F88E5-EF00-48C8-8D1D-F0830D547DFA@oracle.com>
	<7A24DF798E223B4C9864E8F92E8C93EC031D1B12@SACMVEXC1-PRD.hq.netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "Chuck Lever" <chuck.lever@oracle.com>,
	"Mike Frysinger" <vapier@gentoo.org>, <linux-nfs@vger.kernel.org>
To: "Muntz, Daniel" <Dan.Muntz@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:49623 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755474AbZFHRAB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Jun 2009 13:00:01 -0400
In-Reply-To: <7A24DF798E223B4C9864E8F92E8C93EC031D1B12-hX7t0kiaRRpT+ZUat5FNkAK/GNPrWCqfQQ4Iyu8u01E@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 8 Jun 2009 08:46:23 -0700
"Muntz, Daniel" <Dan.Muntz@netapp.com> wrote:

> > 
> > The reason to build without it is that libtirpc is largely 
> > untested code (on Linux), and the nfs-utils support to use 
> > TI-RPC is also largely untested.  I think the default config 
> > settings should configure a safe, known-working 
> > configuration, not the most advanced configuration.
> > 
> > As much as I like the idea of wider testing, the idea that we 
> > happen to be testing with live users is not inviting.  But I 
> > guess it's all we've got at this point.  
> 
> It would be nice if RH had a way of testing this with Fedora without
> making it the default in the standard nfs-utils package until _after_
> testing.  Perhaps nfs-utils has evolved to the point where it could use
> a release-candidate model.  Then all distros could pull an RC build if
> they want it, while production users could pull the last "stable"
> release.

This has very little to do with Red Hat. We can enable or disable TIRPC
in our own distros without making this change upstream. The question
here is whether we should make this the default now, or does it make
more sense to wait until everything has been converted to TIRPC, and
had IPv6 support added and *then* enable it.

I believe the latter option will be more disruptive. Phasing support in
slowly makes sense and there's an easy "fix" for people who find they
have problems with it (--disable-tirpc).

-- 
Jeff Layton <jlayton@redhat.com>
