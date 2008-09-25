From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] sunrpc: make warning in svc_check_conn_limits() more
 generic
Date: Thu, 25 Sep 2008 16:23:15 -0400
Message-ID: <20080925162315.6f29d092@tleilax.poochiereds.net>
References: <1221225127-6042-1-git-send-email-jlayton@redhat.com>
	<20080924215742.GG10841@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: linux-nfs@vger.kernel.org, neilb@suse.de
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:38552 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752293AbYIYUZj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 25 Sep 2008 16:25:39 -0400
In-Reply-To: <20080924215742.GG10841@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 24 Sep 2008 17:57:42 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Fri, Sep 12, 2008 at 09:12:07AM -0400, Jeff Layton wrote:
> > I got a bug report from a user who got this message in his logs:
> > 
> >     lockd: too many open TCP sockets, consider increasing number of nfsd
> >            threads.
> > 
> > ...lockd also started refusing connections at this point. He was
> > apparently doing some testing with a highly contended lock. lockd
> > started refusing connections after the first 80 and started printing
> > this warning. He tried increasing the number of nfsd threads, which of
> > course didn't do any good. This patch removes the "nfsd" from the
> > message to make this a little less confusing.
> > 
> > There is still an artificial limit of 80 concurrent clients with lockd.
> > svc_check_conn_limits has this hardcoded check:
> > 
> >     if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20) {
> > 
> > ...my feeling is that we need to either raise the number or eliminate
> > this check for single-threaded services like lockd. I'd first like to
> > understand the rationale for setting the limit here, however. Can anyone
> > clarify?
> 
> No idea, but yes, this is a problem.
> 
> Brainstorming other options:
> 
> 	- add a new sv_maxconnections field, give it a better default,
> 	  and maybe make it tunable some day?  (Oh goody, another knob
> 	  to twiddle).

Ugh. Another tunable... :)

It would be nice to avoid this if at all possible.

> 	- implement the suggestion in the comment above this function
> 	  and limit connections per ip address.  I guess the idea would
> 	  be to prevent a single buggy client from bringing everyone
> 	  down.  Is that really likely?  Results in the presence of NAT
> 	  could be hard to debug.

Yes, this seems somewhat unreliable. Still might be reasonable in
the absence of better ideas.

> 	- Base the limit on available memory instead of number of
> 	  threads?

Possibly, but this would probably need to be tunable. If we do that
we might as well implement sv_maxconnections and just base the default
value on the amount of memory...

> 	- Kill the check entirely?  It'd help to know whether it was
> 	  originally prompted by some specific situation....
> 

Another possibility is to just eliminate this check on single threaded
services. Basically change this:

if (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20)

...to...

if (serv->sv_nrthreads > 1 &&
    (serv->sv_tmpcnt > (serv->sv_nrthreads+3)*20))

...that does mean that a single-threaded nfsd wouldn't get this
warning, but not many people run just 1 nfsd thread. I think all the
other in-tree RPC services are single threaded so they'd avoid this
limitation.

I agree though -- it would be nice to know what this check was
actually intended to do before we go changing it around. It looks
like this has been in place for a long time...

Some historical commits on this that might help clarify:

http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=b114cbb6ee9ad47434ebbfadff9ec5c9c68d4cff

http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=03c1bdb317baa0bde755a4587bfa6715d8ee6ea7

http://git.kernel.org/?p=linux/kernel/git/torvalds/old-2.6-bkcvs.git;a=commitdiff;h=66f4554afe47eabe4993cd308c02b16ff9b6b06b

At a cursory glance, it looks like this check might be keeping us
from hitting other resource constraints. So if we remove them, we
may need to increase buffer sizes etc...

cc'ing Neil since his name is on some of the earlier patches. Neil,
any thoughts on how best to deal with this?

-- 
Jeff Layton <jlayton@redhat.com>
