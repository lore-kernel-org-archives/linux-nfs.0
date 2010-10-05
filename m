Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:8280 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752311Ab0JEO2q (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 5 Oct 2010 10:28:46 -0400
Date: Tue, 5 Oct 2010 10:27:52 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Chuck Lever <chuck.lever@oracle.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Sachin Prabhu <sprabhu@redhat.com>,
        linux-nfs <linux-nfs@vger.kernel.org>
Subject: Re: Should we be aggressively invalidating cache when using
 -onolock?
Message-ID: <20101005102752.67b75416@tlielax.poochiereds.net>
In-Reply-To: <20100920182536.GA17543@fieldses.org>
References: <1103741.22.1284726314119.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
	<29790688.25.1284726394683.JavaMail.sprabhu@dhcp-1-233.fab.redhat.com>
	<20100917174644.GD25515@fieldses.org>
	<20100918070932.1c1bb700@corrin.poochiereds.net>
	<20100919185318.GE32071@fieldses.org>
	<88791E8C-1109-480A-A3FA-E9DBA1DBF75D@oracle.com>
	<20100920182536.GA17543@fieldses.org>
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 20 Sep 2010 14:25:36 -0400
"J. Bruce Fields" <bfields@fieldses.org> wrote:

> On Mon, Sep 20, 2010 at 10:41:59AM -0400, Chuck Lever wrote:
> > At one point long ago, I had asked Trond if we could get rid of the
> > cache-invalidation-on-lock behavior if "-onolock" was in effect.  He
> > said at the time that this would eliminate the only recourse
> > applications have for invalidating the data cache in case it was
> > stale, and NACK'd the request.
> 
> Argh.  I guess I can see the argument, though.
> 
> > I suggested introducing a new mount option called "llock" that would
> > be semantically the same as "llock" on other operating systems, to do
> > this.  It never went anywhere.
> > 
> > We now seem to have a fresh opportunity to address this issue with the
> > recent addition of "local_lock".  Can we augment this option or add
> > another which allows better control of caching behavior during a file
> > lock?
> 
> I wouldn't stand in the way, but it does start to sound like a rather
> confusing array of choices.
> 

I can sort of see the argument too, but on the other hand...does anyone
*really* use locks in this way? If we want a mechanism to allow the
client to force cache invalidation on an inode it seems like we'd be
better off with an interface for that purpose only (dare I say
ioctl? :).

Piggybacking this behavior into the locking interfaces seems like it
punishes -o nolock performance for the benefit of some questionable
usage patterns.

Mixing this in with -o local_lock also seems confusing, but if we want
to do that it's probably best to make that call before any kernels ship
with -o local_lock.

Trond, care to weigh in on this?
-- 
Jeff Layton <jlayton@redhat.com>
