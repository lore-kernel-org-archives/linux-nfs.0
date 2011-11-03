Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:34192 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752616Ab1KCVqq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Nov 2011 17:46:46 -0400
Subject: Re: GSSAPI Proxy initiative
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Simo Sorce <simo@redhat.com>
Cc: Nico Williams <nico@cryptonector.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Date: Thu, 03 Nov 2011 17:46:46 -0400
In-Reply-To: <1320355818.7734.685.camel@willson.li.ssimo.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	 <1320332310.7734.643.camel@willson.li.ssimo.org>
	 <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	 <1320337903.7734.670.camel@willson.li.ssimo.org>
	 <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	 <1320352784.18396.109.camel@lade.trondhjem.org>
	 <CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
	 <1320355818.7734.685.camel@willson.li.ssimo.org>
Content-Type: text/plain; charset="UTF-8"
Message-ID: <1320356806.18396.149.camel@lade.trondhjem.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-03 at 17:30 -0400, Simo Sorce wrote: 
> On Thu, 2011-11-03 at 15:53 -0500, Nico Williams wrote:
> > On Thu, Nov 3, 2011 at 3:39 PM, Trond Myklebust
> > <Trond.Myklebust@netapp.com> wrote:
> > >> What I had in mind was something like PAGs or keyrings.  Or, to be
> > >> much more specific, search for my name and the string "credentials
> > >> process groups" -- a PAG on steroids.
> > >>
> > >> The idea is that the IPC peer can observe the other's
> > >> PAG/keyring/CPG/whatever and use that to find the correct credentials
> > >> (authorization is still required though).
> > >
> > > Linux already has per-user, per-process and per-thread keyrings which
> > > offer a high security storage solution for keys. The problem with those
> > > is that they are difficult to use in an asynchronous context when the
> > > original user's process/thread context is no longer available to us.
> > 
> > For async IPC methods you'd want something like SCM_CREDENTIALS to
> > give you the keyring/PAG/whatever information you need abou thte peer.
> >  The ancillary data should be complete enough that you can past the
> > client process/thread being dead, although it's nice to not have to
> > process a request from a dead entity...
> > 
> > For sync IPC you need something like door_ucred().  And for sync IPC
> > you can make sure to get SIGCANCEL or equivalent when the client gets
> > canceled (this is the default in doors).
> > 
> > > Ideally, though, that's what we'd like to see used.
> > 
> > Agreed!
> 
> I have discussed use of the keyring in a private discussion before
> starting the thread, and it turns out the keyring has a number of
> limitations that makes it probably unsuitable for this project.
> 
> As an upcall mechanism it has some limitations on the size of the
> payloads, IIRC limited to a page, and that means that you cannot pass
> blobs carrying big kerberos tickets.
> 
> As a storage mechanism for credential caches it also has size limits.
> Currently the limit is 20k per user which is not even enough to hold a
> single ticket in some cases. This limit can be increased of course, but
> then you end keeping around a huge amount of unswappable ram depending
> on the number of users.

Allowing keys to be swapped out is a really really really really really
really bad idea when your kernel depends upon them being available as
part of the memory reclaim process, as would be the case when you are
talking about NFS, CIFS or AFS dirty page writebacks.

> So for long term storage of credentials we will probably not rely on
> kernel keyrings, nor as an upcall mechanism.

So this would be an argument for scrapping keyrings from the kernel? If
they're not good for kerberos tickets, why would we want to keep them at
all?
What would you replace them with, given the above requirements
concerning swapping?


-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

