From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: NFS v3 cached directory content out of sync
Date: Sat, 22 Aug 2009 13:36:06 -0400
Message-ID: <1250962566.8143.26.camel@heimdal.trondhjem.org>
References: <d4098e2f0908211122y5d024dd1sd2f80356749315cc@mail.gmail.com>
	 <1250880591.27154.18.camel@heimdal.trondhjem.org>
	 <d4098e2f0908211208j55dee16fy146ddb8de81d8722@mail.gmail.com>
	 <20090821191511.GB29380@hostway.ca>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Stefan Egli <stefan.egli@gmail.com>,
	linux-nfs <linux-nfs@vger.kernel.org>
To: Simon Kirby <sim@hostway.ca>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:38433 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932884AbZHVRgK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sat, 22 Aug 2009 13:36:10 -0400
In-Reply-To: <20090821191511.GB29380@hostway.ca>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-08-21 at 12:15 -0700, Simon Kirby wrote:
> On Fri, Aug 21, 2009 at 09:08:01PM +0200, Stefan Egli wrote:
> 
> > >> ?Question 4: If we'd somehow manually detected such a directory
> > >> content inconsistency - would there be something like a 'hey NFS
> > >> client, flush all NFS caches NOW' thing?
> > >
> > > No.
> > 
> > unmount / mount would - but that's obviously not feasible. bugger
> > there's nothing for that...
> 
> Wouldn't (admittedly sledgehammer) echo 3 > /proc/sys/vm/drop_caches
> accomplish this?

Only if you are certain that there are no processes actually using that
directory or any of its subdirs/files.

Cheers
  Trond

