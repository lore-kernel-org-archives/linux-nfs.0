Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:33653 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932693Ab1KDOe4 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 4 Nov 2011 10:34:56 -0400
Date: Fri, 4 Nov 2011 10:34:53 -0400
To: Simo Sorce <simo@redhat.com>
Cc: "Myklebust, Trond" <Trond.Myklebust@netapp.com>,
        Nico Williams <nico@cryptonector.com>, dhowells <dhowells@redhat.com>,
        linux-nfs@vger.kernel.org, krbdev <krbdev@mit.edu>
Subject: Re: GSSAPI Proxy initiative
Message-ID: <20111104143453.GB31541@fieldses.org>
References: <CAK3OfOhe_wZz2hKG-6HcSp_Y0=hLuRrKKb=7XOHg3sd_sz5pjw@mail.gmail.com>
 <1320337903.7734.670.camel@willson.li.ssimo.org>
 <CAK3OfOjj0GOPpeEBi4kA9jqP-vfgYqYMdv1P44H3ve0gU0hg5g@mail.gmail.com>
 <1320352784.18396.109.camel@lade.trondhjem.org>
 <CAK3OfOj5P36Z=mD4jo23kkWhzrqXEUU19Q1gDPZ0j=KiDvD1Sw@mail.gmail.com>
 <1320355818.7734.685.camel@willson.li.ssimo.org>
 <1320356806.18396.149.camel@lade.trondhjem.org>
 <1320357606.7734.697.camel@willson.li.ssimo.org>
 <2E1EB2CF9ED1CB4AA966F0EB76EAB4430BFA90EE@SACMVEXC2-PRD.hq.netapp.com>
 <1320364024.7734.705.camel@willson.li.ssimo.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1320364024.7734.705.camel@willson.li.ssimo.org>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Nov 03, 2011 at 07:47:04PM -0400, Simo Sorce wrote:
> On Thu, 2011-11-03 at 15:16 -0700, Myklebust, Trond wrote:
> 
> [..]
> 
> > No, but we still need to be able to do recovery of rpcsec_gss contexts
> > once they are broken, and right now we have a major flaw due to the
> > fact that recovery depends on a lot of small processes and data that
> > is allowed to be swapped out at the moment when we need them the most
> > (i.e. in a memory reclaim situation).
> > 
> > If the server reboots while our client is in the middle of writing
> > back a file (or several files), then the client needs to recover those
> > rpcsec_gss contexts that authenticate the processes which own any
> > dirty pages that remain to be written out.
> > Key security is an irrelevant concern once your kernel deadlocks in an
> > OOM state.
> 
> [..]
> 
> > > Currently credential caches are stored in files, is there a problem
> > > with that model ? Do you need access to credential caches from the
> > > kernel when under memory pressure ?
> 
> > Yes, there is a major problem with that model, and yes we do
> > potentially need access to credential caches when in a recovery
> > situation (which is a situation when we are usually under memory
> > pressure).
> 
> This sounds like a catch 22 situation.
> Even if the keys are pinned in kernel memory you still need the GSSAPI
> Proxy daemon in order to re-establish the security context, and that
> process could have been swapped off too.

Yes, this has been hashed over before.

You can try to pin it in memory.  And then you'd also need some way the
process could tell the kernel (e.g. when doing a system call that
required allocation) that it was working on behalf of a filesystem.  But
at that point moving context negotiation into the kernel might be more
practical.

Seems like a hard problem, but it would nice to at least have some
long-term plan.

--b.
