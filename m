Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:40277 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751574Ab3I0Uuy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 27 Sep 2013 16:50:54 -0400
Date: Fri, 27 Sep 2013 13:50:13 -0700
From: Zach Brown <zab@redhat.com>
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: Ric Wheeler <rwheeler@redhat.com>, Miklos Szeredi <miklos@szeredi.hu>,
        Anna Schumaker <schumaker.anna@gmail.com>,
        Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Linux-Fsdevel <linux-fsdevel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        Bryan Schumaker <bjschuma@netapp.com>,
        "Martin K. Petersen" <mkp@mkp.net>, Jens Axboe <axboe@kernel.dk>,
        Mark Fasheh <mfasheh@suse.com>, Joel Becker <jlbec@evilplan.org>,
        Eric Wong <normalperson@yhbt.net>
Subject: Re: [RFC] extending splice for copy offloading
Message-ID: <20130927205013.GZ30372@lenny.home.zabbo.net>
References: <CAELBmZBGD4rph=gjLCPKCdEj+nzEQ-F=DExoL+h3vRm7qF7dCQ@mail.gmail.com>
 <20130925183828.GA30372@lenny.home.zabbo.net>
 <CAFX2JfnyF8kyMYzCdqdr2JkoyQCom1bFLpFj89wODjoju54-Ow@mail.gmail.com>
 <20130925190620.GB30372@lenny.home.zabbo.net>
 <20130925195526.GA18971@fieldses.org>
 <20130925210742.GG30372@lenny.home.zabbo.net>
 <CAJfpegsQ0A3T+46o9nsPwaH83JCbgyhgRNGPgzTqs0EcsmDuiQ@mail.gmail.com>
 <20130926185508.GO30372@lenny.home.zabbo.net>
 <5244A68F.906@redhat.com>
 <20130927200550.GA22640@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130927200550.GA22640@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


> > >Sure.  So we'd have:
> > >
> > >- no flag default that forbids knowingly copying with shared references
> > >   so that it will be used by default by people who feel strongly about
> > >   their assumptions about independent write durability.
> > >
> > >- a flag that allows shared references for people who would otherwise
> > >   use the file system shared reference ioctls (ocfs2 reflink, btrfs
> > >   clone) but would like it to also do server-side read/write copies
> > >   over nfs without additional intervention.
> > >
> > >- a flag that requires shared references for callers who don't want
> > >   giant copies to take forever if they aren't instant.  (The qemu guys
> > >   asked for this at Plumbers.)
> 
> Why not implement only the last flag only as  the first step?  It seems
> like the simplest one.  So I think that would mean:
> 
> 	- no worrying about cancelling, etc.
> 	- apps should be told to pass the entire range at once (normally
> 	  the whole file).
> 	- The NFS server probably shouldn't do the internal copy loop by
> 	  default.
> 
> We can't prevent some storage system from implementing a high-latency
> copy operation, but we can refuse to provide them any help (providing no
> progress reports or easy way to cancel) and then they can deal with the
> complaints from their users.

I can see where you're going with that, yeah.

It'd make less sense as a splice extension, then, perhaps.  It'd be more
like a generic entry point for the existing ioctls.  Maybe even just
defining the semantics of a common ioctl.

Hmm.

> Also, I don't get the first option above at all.  The argument is that
> it's safer to have more copies?  How much safety does another copy on
> the same disk really give you?  Do systems that do dedup provide
> interfaces to turn it off per-file?

Yeah, got me.  It's certainly nonsense on a lot of FTL logging
implementations (which are making their way into SMR drives in the
future).

> But I understand that Zach's tired of the woodshedding and I could live
> with the above I guess....

No, it's fine.  At least people are expressing some interest in the
interface!  That's a marked improvement over the state of things in the
past.

- z
