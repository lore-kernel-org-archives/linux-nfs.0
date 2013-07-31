Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:25695 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751803Ab3GaPTm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 31 Jul 2013 11:19:42 -0400
Date: Wed, 31 Jul 2013 11:19:38 -0400
From: Scott Mayhew <smayhew@redhat.com>
To: Jeff Layton <jlayton@redhat.com>
Cc: Anton Starikov <ant.starikov@gmail.com>,
        Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: Re: NFS4 server, performance and cache consistency in comparison
 with solaris.
Message-ID: <20130731151938.GC3875@tonberry.usersys.redhat.com>
References: <E774E8EC-5CC0-436F-A8F3-0AB84534C316@gmail.com>
 <7385CFE1-E63F-45C5-A38C-59C6FC4F0C5C@gmail.com>
 <20130731071527.5c68e5e8@tlielax.poochiereds.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130731071527.5c68e5e8@tlielax.poochiereds.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 31 Jul 2013, Jeff Layton wrote:

> On Wed, 31 Jul 2013 08:25:09 +0200
> Anton Starikov <ant.starikov@gmail.com> wrote:
> 
> > Actually, my mistake.
> > option "sync" on a client side also does not change something. Probably it is RHEL bug, but I see "sync" in /proc/mounts only when I mount with noac. When I mount with "sync", it is not present in /proc/mounts.
> > 
> > Anton.
> > 
> 
> Do you already have an existing mount to the same server without '-o
> sync' ? If so, then I think that's a known bug. I'd post a link to it
> here, but it's unfortunately marked "private" for reasons that aren't
> clear to me.
> 
> I think Scott (cc'ed here) has a patch for this bug in mainline kernels
> and in RHEL6. If you open a support case with us, then we can see about
> getting you a test kernel with it.
> 
I probably marked it private by mistake.  It's public now.
Anton -- if you do file a support case with us, make sure you reference
https://bugzilla.redhat.com/show_bug.cgi?id=915862

-Scott

> > 
> > On Jul 31, 2013, at 6:35 AM, Anton Starikov <ant.starikov@gmail.com> wrote:
> > 
> > > Hey, 
> > > 
> > > we are in the process of migration of our storage from solaris to linux (RHEL6) and I see some strange things, which depends on server side.
> > > 
> > > In our old solaris setup we have slower network (1GbE vs 10GbE), much slower storage than new one, but still when I export volume with default solaris options and mount on linux clients with options:
> > > rw,relatime,vers=4,rsize=1048576,wsize=1048576,namlen=255,hard,proto=tcp,port=0,timeo=600,retrans=2,sec=sys,minorversion=0,local_lock=none
> > > 
> > > I have reasonable performance combined with reasonable cache consistency, i.e. when on one client some process keeps writing file (process opens file and writes to it while running, it also flushes stream like couple of times a second) on the NFS volume, on another client I can follow current state of this file practically realtime.
> > > 
> > > When I export from linux host with options: 
> > > 
> > > rw,sync,wdelay,hide,nocrossmnt,insecure,no_root_squash,no_all_squash,no_subtree_check,secure_locks,no_acl,mountpoint,anonuid=65534,anongid=65534,sec=sys,rw,no_root_squash,no_all_squash (it is options as shown in /var/lib/nfs/etab),
> > > 
> > > and mount on linux clients with the same options as with old setup, I have great "dbench 4" performance (about 200Mb/s), but consistency is nonexistent, in the same case (one client keep writing to file, second is reading), on second client I can see state of file with delayed for 5-30 secs. Out of curiosity I tried to use "sync" in loop on a first client (where it writes) to flush cache, but it does not affect something. File isn't really large, but client updates it 2-4 times a sec.
> > > 
> > > All my attempts to improve consistency had two possible impacts:
> > > 
> > > 1) either still luck of consistency (like actimeo=0,lookupcache=none) and reasonable or good dbench results.
> > > 2) consistency is recovered (or almost recovered) (like sync, noac), but dbench results drops to 10MB/s or even less! 
> > > 
> > > Taking into account that mounting happens with the same options on a client side in both cases, it there some server-side trick with options?
> > > 
> > > Time is synchronised between hosts. 
> > > 
> > > Anton.
> > 
> 
> 
> This is all due to client-side effects, so there's little you can do
> server-side to affect this.
> 
> lookupcache= option probably won't make a lot of difference here, but
> actimeo= option likely would. actimeo= means that the client never
> caches attributes, so every time it needs to check cache coherency it
> has to issue a GETATTR to the server. Dialing this to a more reasonable
> value (e.g. actimeo=1 or so) should still give you pretty tight cache
> coherency w/o killing performance too badly.
> 
> The cache coherency logic in the Linux NFS client is pretty complex,
> but typically when you have a file that's changing rapidly it should
> quickly dial down the attribute cache timeout to the default minimum
> (3s). None of that matters though unless you have the "writing" client
> aggressively flushing the dirty data out to the server.
> 
> -- 
> Jeff Layton <jlayton@redhat.com>
