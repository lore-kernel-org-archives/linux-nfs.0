Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f178.google.com ([74.125.82.178]:44518 "EHLO
	mail-we0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbaI3QaJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Sep 2014 12:30:09 -0400
Received: by mail-we0-f178.google.com with SMTP id k48so570927wev.9
        for <linux-nfs@vger.kernel.org>; Tue, 30 Sep 2014 09:30:06 -0700 (PDT)
Date: Tue, 30 Sep 2014 17:30:04 +0100 (BST)
From: Mark Hills <mark.hills@framestore.com>
To: Benjamin Coddington <bcodding@redhat.com>
cc: linux-nfs@vger.kernel.org
Subject: Re: NFS server QoS ideas
In-Reply-To: <alpine.LRH.2.11.1409241958400.8059@sh-el6.eng.rdu2.redhat.com>
Message-ID: <alpine.LFD.2.01.1409301657470.11031@sys880.ldn.framestore.com>
References: <alpine.LFD.2.01.1409241248320.7614@sys880.ldn.framestore.com> <alpine.LRH.2.11.1409241958400.8059@sh-el6.eng.rdu2.redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 24 Sep 2014, Benjamin Coddington wrote:

> Hi Mark, I've often thought about working on a project like this - 
> usually when I've been trying to keep a number of systems responsive 
> when there's been one very aggressive client, which typically would be 
> identified by a single uid, or a uid:ip pair.  I think your second 
> criteria would be the most useful.

Thanks Ben.

To do uid:ip paid would be similarly possible, but actually we're also 
interested in uid only -- to balance load between users on a cluster.
 
> I've done absolutely no research on this, but I had thought offhandedly 
> that a solution might integrate with cgroups somehow.

I'm not sure, as this is a server-side thing, there's no real processes to 
partition in cgroups.
 
> That's not much (less than 2 cents), but I think this feature would be
> welcomed warmly by sysadmins running shared NFS systems.

Thanks, good to hear.

I'd appreciate any input or caveats from anyone on the ideas I posted for 
implementing this.

Thanks

-- 
Mark


> On Wed, 24 Sep 2014, Mark Hills wrote:
> 
> > I am looking at possibilities to implement QoS (quality of service) in an
> > NFS server -- for a multiuser HPC environment, on NFSv3.
> > 
> > The desire is for a fully loaded server to process requests in some kind
> > of "fair share" (like round robin) or priorities based on some attribute;
> > eg. uid at the client, request type + origin, or even directory etc.
> > 
> > Criteria could be fairly blunt and specific to our use case to begin with.
> > 
> > I've looked at the code with the following ideas for where to start.
> > 
> > It seems the implementation depends a lot on which attributes to
> > share/schedule on:
> > 
> > 1) by client IP:
> > 
> >   make use the existing structures
> > 
> >   enhance the svc_xprt_enqueue/dequeue process to schedule svc_xprt
> >   as these are already per-client
> > 
> > 2) by client uid or other RPC attribute:
> > 
> >   have svc_recv make multiple calls to svc_handle_xprt
> > 
> >   buffer the requests into multiple queues held at svc_pool (re-use
> >   xpt_deferred?)
> > 
> > 3) by NFS operation, file handle etc.:
> > 
> >   most awkward, as there is not buffering of requests at the NFS level
> >   or shared between threads
> > 
> >   perhaps do as (2) but with a function in svc_program to return
> >   scheduling criteria
> > 
> > It looks like I need to consider the behaviour when there are multiple
> > svc_pool (ie. NUMA)
> > 
> > This is the first time I've looked into this code, I'm interested in any
> > comments/criticisms or alternatives.
> > 
> > Thanks
> > 
> > -- 
> > Mark
