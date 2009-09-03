Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:50049 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751978AbZICNBd (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 3 Sep 2009 09:01:33 -0400
Subject: Re: VM issue causing high CPU loads
From: Trond Myklebust <trond.myklebust@fys.uio.no>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Yohan <ytordjman@corp.free.fr>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org, Neil Brown <neilb@suse.de>,
        "J. Bruce Fields" <bfields@fieldses.org>, mikevs@xs4all.net
In-Reply-To: <20090902170642.f4381c1d.akpm@linux-foundation.org>
References: <4A92A25A.4050608@yohan.staff.proxad.net>
	 <20090824162155.ce323f08.akpm@linux-foundation.org>
	 <4A96463E.5080002@corp.free.fr> <4A9C34F8.2010307@corp.free.fr>
	 <20090902170642.f4381c1d.akpm@linux-foundation.org>
Content-Type: text/plain
Date: Thu, 03 Sep 2009 09:01:24 -0400
Message-Id: <1251982884.18338.9.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2009-09-02 at 17:06 -0700, Andrew Morton wrote:
> On Mon, 31 Aug 2009 22:39:20 +0200
> Yohan <ytordjman@corp.free.fr> wrote:
> 
> > Yohan wrote:
> > > Andrew Morton wrote:
> > >> On Mon, 24 Aug 2009 16:23:22 +0200
> > >> Yohan <kernel@yohan.staff.proxad.net> wrote:  
> > >>> Hi,
> > >>>
> > >>>     Is someone have an idea for that :
> > >>>
> > >>>         http://bugzilla.kernel.org/show_bug.cgi?id=14024
> > >>>     
> > >> Please generate a kernel profile to work out where all the CPU tie is
> > >> being spent.  Documentation/basic_profiling.txt is a starting point.
> > >>   
> > > I post some new reports, it seems that the problem is in  
> > > rpcauth_lookup_credcache ...
> 
> Thanks, that helps a lot.
> 
> > > for information, this is an imap mail server that mounts ~10 netapp 
> > > over ~300 mountpoints..
> >     I saw that : http://patchwork.kernel.org/patch/24747/
> 
> I wonder what happened with Miquel's patch?

At the time, I asked him to split out the various changes into several
patches.

His patch did a lot of different things that would impact workloads in
different ways. For instance, while increasing the hash table size is
not likely to have a huge performance degradation for most people, the
change that decreases the garbage collection timeout is very likely to
cause issues (particularly with RPCSEC_GSS setups)...

> > I did only:
> > 
> > --- linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-03-23 23:04:09.000000000 +0100
> > +++ linux-2.6.27.21/include/linux/sunrpc/auth.h	2009-05-19 16:02:35.000000000 +0200
> > @@ -62,8 +62,12 @@ 
> >   */
> > - #define RPC_CREDCACHE_HASHBITS	4
> > + #define RPC_CREDCACHE_HASHBITS	12
> > 
> > 
> > And i test it in prod since sunday: i only have 36% of one core used by 
> > system
> > versus more than 3 cores used by system in another server that did a 
> > drop_caches at morning...
> > 
> 
> OK, but it's still pretty bad.  Let's tell the NFS guys.
> 
> In http://bugzilla.kernel.org/show_bug.cgi?id=14024 we appear to have a
> major meltdown caused by the linear search in
> rpcauth_lookup_credcache() with Yohan's workload.
> 

OK. Could we please have some more details about the actual workload
involved here?
As far as I can see, there is no RPCSEC_GSS involved, so credentials
should never expire. They will be reused as long as processes aren't
switching between thousands and thousands of different combinations of
uid, gid and groups.



