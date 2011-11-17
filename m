Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:59687 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752144Ab1KQVrB (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Nov 2011 16:47:01 -0500
Date: Thu, 17 Nov 2011 16:46:30 -0500
From: Jeff Layton <jlayton@redhat.com>
To: John Hughes <john@Calva.COM>
Cc: Jim Rees <rees@umich.edu>, Trond Myklebust <trond.myklebust@netapp.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH] Don't hang user processes if Kerberos ticket for nfs4
 mount expires
Message-ID: <20111117164630.394027e7@tlielax.poochiereds.net>
In-Reply-To: <4EC50882.2080803@Calva.COM>
References: <4EC3FD8B.6000705@calvaedi.com>
	<20111116144718.78b2e288@corrin.poochiereds.net>
	<20111116234434.GA12882@umich.edu>
	<20111116203119.1d9c0dd6@corrin.poochiereds.net>
	<20111116203810.4e1b9d28@corrin.poochiereds.net>
	<4EC4EA91.5070607@Calva.COM>
	<4EC50882.2080803@Calva.COM>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 17 Nov 2011 14:13:38 +0100
John Hughes <john@Calva.COM> wrote:

> On 17/11/11 12:05, John Hughes wrote:
> > On 17/11/11 02:38, Jeff Layton wrote:
> >> Note too that the gssd code distinguishes between an expired TGT and a
> >> non-existent credcache. The latter will give you the error you desire
> >> here. So one possibility is just to remove the credcache from /tmp in
> >> this situation.
> >
> > Something to scan /tmp for expired credentials and zap em?  rpc.gssd 
> > would communicate that to the kernel?
> >
> > Whadaya know, that works.
> Here's a dumb perl script that could be run from, for example, .xsession 
> to automatically destroy expired ticket caches.
> 
> Would need a bit of trickery to make it go away on end of session and 
> something in /etc/pm/sleep.d to send it a SIGALRM when the system wakes 
> from suspend or hibernate.
> 
> It has a potential race between destroying an expired ticket and a new 
> ticket being granted.
> 
> I guess now I'll look at a hack to rpc.gssd for a neater way of doing this.
> 

Ok, I can remember a bit more about the genesis of this scheme...

At the time the argument went something like this:

No one expects that when their krb5 ticket expires that their
applications will fail. A case in point is something like a krb5 ssh
session. If I had a valid ticket when I initiated the session, then it
we would consider it a bug if it were to suddenly die when the ticket
expired.

Contrast that however with applications running on a kerberized NFS
mount. As soon as the ticket expires they start failing with
non-transient errors. This is probably the case as well with screen
locker you're using, but it's apparently able to recover enough to
allow the TGT to be renewed. I expect though, that you may have other
less visible programs that are dying in this situation or are getting
unexpected errors.

The current behavior was really intended as a first approximation. I
fully expected that it would need some refinement, but AFAIK, no one
has complained loudly about the current behavior until now, so I
haven't seen need to mess with it.

I'm not that familiar with kstart, but I assume that it gets a
renewable TGT and just renews it as needed? I have to wonder if that
sort of tool might be verboten in security conscious sites (the very
sort that want kerberized nfs).

If we decide that making this behavior switchable is the right thing to
do, then what you'll probably want to do is add a new command-line
option to rpc.gssd, and make it conditionally return -EKEYEXPIRED or
-EACCES in the downcall based on it. It should be a fairly simple
patch. See process_krb5_upcall() in rpc.gssd...

Long term, we probably need to consider this use-case in the GSSAPI
proxy initiative that Simo has been scoping out. It would be nice to
have a solution that would work for both home directory configurations
and long-running jobs without needing these sorts of hacks.

-- 
Jeff Layton <jlayton@redhat.com>
