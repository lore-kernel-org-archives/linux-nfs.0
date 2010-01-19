Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19566 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752078Ab0ASAjX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 18 Jan 2010 19:39:23 -0500
Date: Mon, 18 Jan 2010 19:39:18 -0500
From: Jeff Layton <jlayton@redhat.com>
To: Chuck Lever <chuck.lever@oracle.com>
Cc: steved@redhat.com, linux-nfs@vger.kernel.org
Subject: Re: enabling IPv6
Message-ID: <20100118193918.06695933@tlielax.poochiereds.net>
In-Reply-To: <3744FBA8-9198-43D4-BEE9-8E646C92BC02@oracle.com>
References: <20100118144746.1e05865e@tlielax.poochiereds.net>
	<0FE403CA-9487-485C-9949-FEC072EC2314@oracle.com>
	<20100118173336.18a8323b@tlielax.poochiereds.net>
	<3744FBA8-9198-43D4-BEE9-8E646C92BC02@oracle.com>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 18 Jan 2010 18:28:02 -0500
Chuck Lever <chuck.lever@oracle.com> wrote:

> 
> On Jan 18, 2010, at 5:33 PM, Jeff Layton wrote:
> 
> > On Mon, 18 Jan 2010 16:28:39 -0500
> > Chuck Lever <chuck.lever@oracle.com> wrote:
> >
> >>
> >> On Jan 18, 2010, at 2:47 PM, Jeff Layton wrote:
> >>
> >>> With the commit of the statd patches over the weekend, we're now
> >>> positioned to be able to ship IPv6-enabled nfs-utils in distros.  
> >>> There
> >>> is a potential snag though...
> >>>
> >>> Consider this situation:
> >>>
> >>> Admin has a Linux server set up. Server has both IPv4 and IPv6  
> >>> addrs.
> >>> Both addresses are in DNS.
> >>>
> >>> Without an IPv6-enabled nfs-utils, he mounts via IPv4 and all works
> >>> fine. Now with an IPv6 enabled nfs-utils, mount.nfs prefers the IPv6
> >>> addr and the mount fails (or hangs for a long time and then fails,  
> >>> if
> >>> it's using NFSv4)...
> >>
> >> Why should it fail?
> >
> > Because Linux NFS servers that work over IPv6 pretty much don't exist
> > yet.
> 
> More specifically, mount version and transport negotation is not  
> working in this case.  Otherwise, specifying "proto=" would be an  
> adequate solution.
> 
> >>> While I don't really like it, I think we may need to consider making
> >>> mount.nfs prefer IPv4 addrs when it can resolve a hostname to both  
> >>> v4
> >>> and v6. Otherwise, we run the risk of breaking an awful lot of  
> >>> working
> >>> setups...
> >>
> >> Isn't that what "proto=udp" vs. "proto=udp6" is for?
> >
> > Yes. But that assumes that the admin will know to use that. As it
> > stands now, they'll have to do a bit of investigation to figure out  
> > why
> > the mount failed and then figure out how to fix it.
> >
> > Obviously, that's less ideal than a solution that leaves setups  
> > working
> > that are working today. I don't think we ought to put the onus on  
> > users
> > to add extra mount options to stay working.
> 
> Notice that the server already tells you what it can and can't  
> support.  If the server doesn't support rpcbind v3 or v4, you can't  
> use IPv6.  If it does, it can report to the client that "udp6" and  
> "tcp6" are not registered.  Really, then, what we want is to teach  
> mount's version and transport negotiation to negotiate the protocol  
> family as well as the transport and NFS version.
> 

Maybe I'm not understanding the terminology correctly. Here's sort of
the "problem" as I see it:

mount.nfs decides the address of the server very early on. Once it
decides that address, it doesn't ever go back and try another. In the
absence of a proto= option, you get whatever address family happens to
be first in the list.

So, even if you can do a rpcbind query to determine what the server
supports (which isn't a given with NFSv4), by the time you find out
that it doesn't support NFS over IPv6 it's too late to do anything but
fail.

This problem is compounded by the fact that we now attempt NFSv4 by
default. In that case we can't really rely on being able to talk to
rpcbind and determine this quickly. It also takes a while for the
kernel's mount attempt to time out, so it's not really reasonable to
try multiple addresses in succession.

> But for now, it seems like the only case we are worried about here is  
> when the "proto/mountproto" options aren't specified on a text-based  
> mount.  Always choosing an IPv4 address in this case is likely a good  
> compromise.  nfs_validate_options() might be a better spot to sort all  
> this out than nfs_lookup(), though.
>
> It should also be pretty easy to parametrize this behavior in the  
> config file.
> 

Yes, the absence of a "proto=" option is the main worry.

We could put this in nfs_validate_options. It'll potentially mean 2
getaddrinfo calls for an IPv6 server, but it's doable if you think
that'll be cleaner.

By parameterize, you mean adding something like a "afpref=" option?
Something like:

    afpref=inet|inet6

If so, that should be doable too. I'm reticent to add new options if
we can help it, but am willing to go along with that if you and others
think it's the right solution.

-- 
Jeff Layton <jlayton@redhat.com>
