Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47514 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756613AbdERQcJ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 18 May 2017 12:32:09 -0400
Date: Thu, 18 May 2017 12:32:00 -0400
From: "J. Bruce Fields" <bfields@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>
Cc: "bfields@fieldses.org" <bfields@fieldses.org>,
        "stefanha@redhat.com" <stefanha@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
Message-ID: <20170518163159.GD16256@parsley.fieldses.org>
References: <20170515144306.GB16013@stefanha-x1.localdomain>
 <20170515160248.GD9697@parsley.fieldses.org>
 <20170516131142.GA12711@fieldses.org>
 <20170518133441.GC4155@stefanha-x1.localdomain>
 <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
 <1495119887.11859.1.camel@primarydata.com>
 <20170518150850.GB16256@parsley.fieldses.org>
 <1495120629.13396.1.camel@primarydata.com>
 <20170518152822.GA9725@fieldses.org>
 <1495123747.13396.4.camel@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1495123747.13396.4.camel@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 18, 2017 at 04:09:10PM +0000, Trond Myklebust wrote:
> On Thu, 2017-05-18 at 11:28 -0400, bfields@fieldses.org wrote:
> > On Thu, May 18, 2017 at 03:17:11PM +0000, Trond Myklebust wrote:
> > > For the case that Stefan is discussing (kvm) it would literally be
> > > a
> > > single process that is being migrated. For lxc and
> > > docker/kubernetes-
> > > style containers, it would be a collection of processes.
> > > 
> > > The mountpoints used by these containers are often owned by the
> > > host;
> > > they are typically set up before starting the containerised
> > > processes.
> > > Furthermore, there is typically no "start container" system call
> > > that
> > > we can use to identify which set of processes (or cgroups) are
> > > containerised, and should share a clientid.
> > 
> > Is that such a hard problem?
> > 
> 
> Err, yes... isn't it? How do I identify a container and know where to
> set the lease boundary?
> 
> Bear in mind that the definition of "container" is non-existent beyond
> the obvious "a loose collection of processes". It varies from the
> docker/lxc/virtuozzo style container, which uses namespaces to bound
> the processes, to the Google type of "container" that is actually just
> a set of cgroups and to the kvm/qemu single process.

Sure, but, can't we pick *something* to use as the boundary (network
namespace?), document it, and let userspace use that to tell us what it
wants?

> > In any case, from the protocol point of view these all sound like
> > client
> > implementation details.
> 
> If you are seeing an obvious architecture for the client, then please
> share...

Make clientids per-network-namespace and store them in nfs_net?  (Maybe
that's what's already done, I can't tell.)

> > The only problem I see with multiple client ID's is that you'd like
> > to
> > keep their delegations from conflicting with each other so they can
> > share cache.
> > 
> > But, maybe I'm missing something else.
> 
> Having to an EXCHANGE_ID + CREATE_SESSION on every call to
> fork()/clone() and a DESTROY_SESSION/DESTROY_EXCHANGEID in each process
> destructor? Lease renewal pings from 1000 processes running on 1000
> clients?
> 
> This is what I mean about container boundaries. If they aren't well
> defined, then we're down to doing precisely the above.

Again this sounds like a complaint about the kernel api rather than
about the protocol.  If the container management system knows what it
wants and we give it a way to explain it to us, then we avoid most of
that, right?

--b.
