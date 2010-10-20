From: Sachin Prabhu <sprabhu@redhat.com>
Subject: Re: Should we be aggressively invalidating cache when using
 -onolock?
Date: Wed, 20 Oct 2010 06:42:42 -0400 (EDT)
Message-ID: <21109089.191.1287571357382.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
References: <20101005102752.67b75416@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Chuck Lever <chuck.lever@oracle.com>,
	linux-nfs <linux-nfs@vger.kernel.org>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Jeff Layton <jlayton@redhat.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx4-phx2.redhat.com ([209.132.183.25]:58864 "EHLO
	mx4-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752952Ab0JTKmv (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Oct 2010 06:42:51 -0400
In-Reply-To: <20101005102752.67b75416-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


----- "Jeff Layton" <jlayton@redhat.com> wrote:

> On Mon, 20 Sep 2010 14:25:36 -0400
> "J. Bruce Fields" <bfields@fieldses.org> wrote:
> 
> > On Mon, Sep 20, 2010 at 10:41:59AM -0400, Chuck Lever wrote:
> > > At one point long ago, I had asked Trond if we could get rid of
> the
> > > cache-invalidation-on-lock behavior if "-onolock" was in effect. 
> He
> > > said at the time that this would eliminate the only recourse
> > > applications have for invalidating the data cache in case it was
> > > stale, and NACK'd the request.
> > 
> > Argh.  I guess I can see the argument, though.
> > 
> > > I suggested introducing a new mount option called "llock" that
> would
> > > be semantically the same as "llock" on other operating systems, to
> do
> > > this.  It never went anywhere.
> > > 
> > > We now seem to have a fresh opportunity to address this issue with
> the
> > > recent addition of "local_lock".  Can we augment this option or
> add
> > > another which allows better control of caching behavior during a
> file
> > > lock?
> > 
> > I wouldn't stand in the way, but it does start to sound like a
> rather
> > confusing array of choices.
> > 
> 
> I can sort of see the argument too, but on the other hand...does
> anyone
> *really* use locks in this way? If we want a mechanism to allow the
> client to force cache invalidation on an inode it seems like we'd be
> better off with an interface for that purpose only (dare I say
> ioctl? :).
> 
> Piggybacking this behavior into the locking interfaces seems like it
> punishes -o nolock performance for the benefit of some questionable
> usage patterns.
> 
> Mixing this in with -o local_lock also seems confusing, but if we
> want
> to do that it's probably best to make that call before any kernels
> ship
> with -o local_lock.
> 
> Trond, care to weigh in on this?


Trond, 

What do you think about this issue?

Sachin Prabhu
