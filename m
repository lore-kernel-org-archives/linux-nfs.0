From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH 2/2] lockd: set svc_serv->sv_maxconn to a more
 reasonable value
Date: Mon, 20 Oct 2008 10:38:25 -0400
Message-ID: <20081020103825.3e98da06@tleilax.poochiereds.net>
References: <1224267970-15769-1-git-send-email-jlayton@redhat.com>
	<1224267970-15769-2-git-send-email-jlayton@redhat.com>
	<20081017211833.GF14960@fieldses.org>
	<20081017181057.2b15b458@tleilax.poochiereds.net>
	<18683.54685.61422.969081@notabene.brown>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: "J. Bruce Fields" <bfields@fieldses.org>, linux-nfs@vger.kernel.org
To: Neil Brown <neilb@suse.de>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:45044 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751011AbYJTOih (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 20 Oct 2008 10:38:37 -0400
In-Reply-To: <18683.54685.61422.969081-wvvUuzkyo1EYVZTmpyfIwg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, 20 Oct 2008 11:49:33 +1100
Neil Brown <neilb@suse.de> wrote:

> On Friday October 17, jlayton@redhat.com wrote:
> > 
> > I'm OK with that too. I just used this since Neil suggested it. I have
> > no idea what a reasonable value should really be. I suppose this should
> > probably be set to the maximum number of clients we expect to support
> > (assuming 1 connection to lockd from each client).
> 
> I suggested it (using the NFILE rlimit) because I was looking for a
> natural way to make it configurable, and asked myself "how would this
> be handled by a user-space daemon".  I managed to address one of those
> questions, but not really the more useful one.
> 
> > 
> > > What would actually happen if we allowed too many connections?  What
> > > would fail first?  Is there some way to detect that situation and use
> > > that to drop connections?
> > > 
> > 
> > I'm not clear on this either. Here's my naive take (could be very 
> > wrong):
> 
> I've got no really idea either.
> But when we are building network-facing software, you need to be
> cautious and use the "deny unless explicitly permitted" approached.
> It may be safe to allow an arbitrarily large number of connections.
> But until you can be certain of that you should fail-safe and impose a
> limit.
> 

For now, I think we should probably go with the patchset as-is (modulo
the comment change that Neil suggested), it at least addresses the
immediate problem of too many lockd connections.

In the long run, since it's not clear what we're preventing by doing
this, does it make sense to base the default sv_maxconn on the number
of threads? In principle, we could have a server that has 2000 clients,
but they each only rarely touch their NFS mount. In that case, we may
be able to get by with fewer nfsd's, but we'd want to increase the
number of allowed connections. The reverse is also true.

Perhaps we should just declare a constant sv_maxconn value for each
service, give each a way to tune it and use some other scheme (duty
cycle of nfsd's?) to warn the admin that they should consider increasing
the number of threads.

-- 
Jeff Layton <jlayton@redhat.com>
