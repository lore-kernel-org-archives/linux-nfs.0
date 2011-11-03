Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:26404 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752620Ab1KCWAQ (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Nov 2011 18:00:16 -0400
Subject: Re: GSSAPI Proxy initiative
From: Simo Sorce <simo@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Nico Williams <nico@cryptonector.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
In-Reply-To: <1320356806.18396.149.camel@lade.trondhjem.org>
References: <1320269170.7734.585.camel@willson.li.ssimo.org>
	 <CAK3OfOgaDjT9Smi8U1FCo=cGz5r5W2uub4xvYRqN4-9Pf-htXw@mail.gmail.com>
	 <1320332310.7734.643.camel@willson.li.ssimo.org>
	 <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
	 <1320337903.7734.670.camel@willson.li.ssimo.org>
	 <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
	 <1320352784.18396.109.camel@lade.trondhjem.org>
	 <CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
	 <1320355818.7734.685.camel@willson.li.ssimo.org>
	 <1320356806.18396.149.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 03 Nov 2011 18:00:06 -0400
Message-ID: <1320357606.7734.697.camel@willson.li.ssimo.org>
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2011-11-03 at 17:46 -0400, Trond Myklebust wrote:
> On Thu, 2011-11-03 at 17:30 -0400, Simo Sorce wrote: 
> > On Thu, 2011-11-03 at 15:53 -0500, Nico Williams wrote:
> > > On Thu, Nov 3, 2011 at 3:39 PM, Trond Myklebust
> > > <Trond.Myklebust@netapp.com> wrote:
> > > >> What I had in mind was something like PAGs or keyrings.  Or, to be
> > > >> much more specific, search for my name and the string "credentials
> > > >> process groups" -- a PAG on steroids.
> > > >>
> > > >> The idea is that the IPC peer can observe the other's
> > > >> PAG/keyring/CPG/whatever and use that to find the correct credentials
> > > >> (authorization is still required though).
> > > >
> > > > Linux already has per-user, per-process and per-thread keyrings which
> > > > offer a high security storage solution for keys. The problem with those
> > > > is that they are difficult to use in an asynchronous context when the
> > > > original user's process/thread context is no longer available to us.
> > > 
> > > For async IPC methods you'd want something like SCM_CREDENTIALS to
> > > give you the keyring/PAG/whatever information you need abou thte peer.
> > >  The ancillary data should be complete enough that you can past the
> > > client process/thread being dead, although it's nice to not have to
> > > process a request from a dead entity...
> > > 
> > > For sync IPC you need something like door_ucred().  And for sync IPC
> > > you can make sure to get SIGCANCEL or equivalent when the client gets
> > > canceled (this is the default in doors).
> > > 
> > > > Ideally, though, that's what we'd like to see used.
> > > 
> > > Agreed!
> > 
> > I have discussed use of the keyring in a private discussion before
> > starting the thread, and it turns out the keyring has a number of
> > limitations that makes it probably unsuitable for this project.
> > 
> > As an upcall mechanism it has some limitations on the size of the
> > payloads, IIRC limited to a page, and that means that you cannot pass
> > blobs carrying big kerberos tickets.
> > 
> > As a storage mechanism for credential caches it also has size limits.
> > Currently the limit is 20k per user which is not even enough to hold a
> > single ticket in some cases. This limit can be increased of course, but
> > then you end keeping around a huge amount of unswappable ram depending
> > on the number of users.
> 
> Allowing keys to be swapped out is a really really really really really
> really bad idea when your kernel depends upon them being available as
> part of the memory reclaim process, as would be the case when you are
> talking about NFS, CIFS or AFS dirty page writebacks.

You do not need long term keys on existing mounts which is the only case
where you have anything to release, gss context session keys will be
kept in the kernel but need not be shared with anything.
It is ok to use keyring if that's deemed the right place for session
keys, but I think you already have structures where you currently store
them so I don't thik you necessarily need to change that part of the
kernel implementation.

> > So for long term storage of credentials we will probably not rely on
> > kernel keyrings, nor as an upcall mechanism.
> 
> So this would be an argument for scrapping keyrings from the kernel? If
> they're not good for kerberos tickets, why would we want to keep them at
> all?

See above.

We could also break the tickets so that only the valuable part is kept
in the keyring, and the rest (encrypted with the session key) in a file.
I don;t think this influences the GSSAPI Proxy protocol and mechanism.
It is an implementation detail we can discuss within the linux specific
implementation.

> What would you replace them with, given the above requirements
> concerning swapping?

Currently credential caches are stored in files, is there a problem with
that model ? Do you need access to credential caches from the kernel
when under memory pressure ?  

Simo.

-- 
Simo Sorce * Red Hat, Inc * New York

