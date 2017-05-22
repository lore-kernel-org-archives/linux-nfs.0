Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f170.google.com ([209.85.220.170]:33651 "EHLO
        mail-qk0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933994AbdEVOZb (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 22 May 2017 10:25:31 -0400
Received: by mail-qk0-f170.google.com with SMTP id y201so107052516qka.0
        for <linux-nfs@vger.kernel.org>; Mon, 22 May 2017 07:25:30 -0700 (PDT)
Message-ID: <1495463128.2816.8.camel@redhat.com>
Subject: Re: EXCHANGE_ID with same network address but different server owner
From: Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <trondmy@primarydata.com>,
        "bfields@fieldses.org" <bfields@fieldses.org>,
        David Howells <dhowells@redhat.com>
Cc: "stefanha@redhat.com" <stefanha@redhat.com>,
        "bfields@redhat.com" <bfields@redhat.com>,
        "SteveD@redhat.com" <SteveD@redhat.com>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        "chuck.lever@oracle.com" <chuck.lever@oracle.com>
Date: Mon, 22 May 2017 10:25:28 -0400
In-Reply-To: <1495123747.13396.4.camel@primarydata.com>
References: <1494601295.10434.1.camel@primarydata.com>
         <021509A5-FA89-4289-B190-26DC317A09F6@oracle.com>
         <20170515144306.GB16013@stefanha-x1.localdomain>
         <20170515160248.GD9697@parsley.fieldses.org>
         <20170516131142.GA12711@fieldses.org>
         <20170518133441.GC4155@stefanha-x1.localdomain>
         <A720C1BD-D218-43A2-B6FD-C72B1E58D98C@oracle.com>
         <1495119887.11859.1.camel@primarydata.com>
         <20170518150850.GB16256@parsley.fieldses.org>
         <1495120629.13396.1.camel@primarydata.com>
         <20170518152822.GA9725@fieldses.org>
         <1495123747.13396.4.camel@primarydata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2017-05-18 at 16:09 +0000, Trond Myklebust wrote:
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
> 
> > In any case, from the protocol point of view these all sound like
> > client
> > implementation details.
> 
> If you are seeing an obvious architecture for the client, then please
> share...
> 
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
> 

This is the crux of the problem with containers in general.

We've been pretending for a long time that the kernel doesn't really
need to understand them and can just worry about namespaces, but that
really hasn't worked out well so far.

I think we need to consider making a "container" a first-class object in
the kernel. Note that that would also help solve the long-standing
problem of how to handle usermode helper upcalls in containers.

I do happen to know of one kernel developer (cc'ed here) who has been
working on something along those lines...
-- 
Jeff Layton <jlayton@redhat.com>
