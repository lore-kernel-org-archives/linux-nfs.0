From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Tue, 25 Aug 2009 15:00:09 -0400
Message-ID: <1251226809.25372.29.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <1250962724.8143.29.camel@heimdal.trondhjem.org>
	 <d4098e2f0908221628kfa208c5wa3367f8fbde1c1c9@mail.gmail.com>
	 <d4098e2f0908240332k55ff2789r9aaa17cb5cd99cdf@mail.gmail.com>
	 <1251115893.6325.23.camel@heimdal.trondhjem.org>
	 <d4098e2f0908250901y359e51cewb1e22e7193922c52@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-nfs <linux-nfs@vger.kernel.org>
To: Stefan Egli <stefan.egli@gmail.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:37653 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755954AbZHYTAM (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 25 Aug 2009 15:00:12 -0400
In-Reply-To: <d4098e2f0908250901y359e51cewb1e22e7193922c52-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-08-25 at 18:01 +0200, Stefan Egli wrote:
> Thanks Trond for the input! I've got just one more puzzle (s.below)
> 
> On Mon, Aug 24, 2009 at 2:11 PM, Trond Myklebust wrote:
> >
> > On Mon, 2009-08-24 at 12:32 +0200, Stefan Egli wrote:
> >
> > > 2) I'm still not sure I understand that patch correctly though
> > >    (37d9d76d8b3a2ac5817e1fa3263cfe0fdb439e5): Would the tivoli restore
> > >    be able to mess with mtimes and *therefore* cause the 4-5 hour cache
> > >    inconsistency I'm seeing? If yes, would the patch then magically fix this?
> >
> > If tivoli is messing with the mtime, then it _might_ cause the
> > condition, in a restore situation by changing the directory contents but
> > not the mtime (which is what tells the NFS client and applications that
> > the directory contents have changed).
> > By looking at the ctime too, the client can always tell that something
> > has changed, and thus clear its cache.
> 
> I suspect, the problem I'm seeing could be similar to this one:
> 
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/269172
> 
> What puzzles me with that 269172 bug is that it requires that you
> first do a 'ls' on machine A - then do that script mentioned in the
> bug on machine B -
> and then do another 'ls' on machine A. This looks like with the first 'ls'
> machine A fills its attribute-cache - which then later on becomes out-of-sync
> with what the NFS server says.
> 
> In my situation though, I'm not doing any ls in the subdirectories affected -
> which would mean it's not 100% explainable with the above bug... bugger...
> 
> or is it ?

Yes. The NFS client will cache mtime whether or not you do an 'ls'. I
suspect the only reason for the 'ls' in that launchpad bug report, is to
force an mtime update (and to fill the readdir cache).

Cheers
  Trond

