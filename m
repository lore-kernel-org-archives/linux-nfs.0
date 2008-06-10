From: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Subject: RE: Problems with large number of clients and reads
Date: Tue, 10 Jun 2008 09:30:18 -0500
Message-ID: <0122F800A3B64C449565A9E8C297701002D75D9F@hoexmb9.conoco.net>
References: <1212519001.24900.14.camel@hololw58> <20080606160922.GG30863@fieldses.org> <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net> <20080609185355.GF28584@fieldses.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Cc: <linux-nfs@vger.kernel.org>
To: "J. Bruce Fields" <bfields@fieldses.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mailman1.ppco.com ([138.32.41.4]:45712 "EHLO mailman1.ppco.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488AbYFJOa1 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 10 Jun 2008 10:30:27 -0400
Received: from bvlextrd3.conoco.net (bvlextrd3.conoco.net [138.32.41.15])
	by mailman1.ppco.com (Switch-3.2.7/Switch-3.2.7) with ESMTP id m5AEUPg1013193
	for <linux-nfs@vger.kernel.org>; Tue, 10 Jun 2008 09:30:25 -0500
In-Reply-To: <20080609185355.GF28584@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

 

> -----Original Message-----
> From: J. Bruce Fields [mailto:bfields@fieldses.org] 
> Sent: Monday, June 09, 2008 1:54 PM
> To: Weathers, Norman R.
> Cc: linux-nfs@vger.kernel.org
> Subject: Re: Problems with large number of clients and reads
> 
> On Mon, Jun 09, 2008 at 09:19:03AM -0500, Weathers, Norman R. wrote:
> > >I'd've thought that suggests a leak of memory allocated by 
> kmalloc().
> > 
> > >Does the size-4096 cache decrease eventually, or does it stay that
> > >large until you reboot?
> > 
> > I would agree that it "looks" like a memory leak.  If I restart NFS,
> > the size-4096 cache goes from 12 GB to under 50 MB,
> 
> And restarting nfsd is the only thing you've found that will do this?
> (So decreasing the number of threads, or stopping all the client won't
> do anything to the size-4096 number?)

Unfortunately, I cannot stop the clients (middle of long running jobs).
I might be able to test this soon.  If I have the number of threads
high,
yes I can reduce the number of threads and it appears to lower some of
the
memory, but even with as little as three threads, the memory usage
climbs very
high, just not as high as if there are say 8 threads.  When the memory
usage
climbs high, it can cause the box to not respond over the network (ssh,
rsh),
and even be very sluggish when I am connected over our serial console to
the server(s).  This same scenario has been happening with kernels that
I have
tried from 2.6.22.x on to the 2.6.25 series.  The 2.6.25 series is
interesting in
that I can push the same load from a box with the 2.6.25 kernel and not
have a load
over .3 (with 3 threads), but with the 2.6.22.x kernel, I have a load of
over 3
when I hit the same conditions.

Also, this is all with the SLAB cache option.  SLUB crashes everytime I
use it
under heavy load.


> 
> > but then depending
> > upon how hard the box is utilized, it starts to climb back up.
> 
> > I have
> > seen it climb back up to 3 or 4 GB right after the restart, but that
> > is much better because the regular disk cache will grow 
> from the 2 GB
> > that it was pressured into back to 5 or 8 GB, so all of the 
> files have
> > been reread into memory and things are progressing smoothly.  It is
> > weird.  I really think that this has to do with a lot of connections
> > happening at once, because I can run slabtop and see a node that is
> > running full out, but only have a couple hundred megs of 
> the size-4096
> > slab being used, and then turn around and see another node that is
> > pushing out 245 MB/s and all of the sudden using over 12 GB of the
> > size-4096.  It is very odd...  If I lower the number of 
> threads from a
> > usable 64 to a low of 3 threads, I have less of a chance of the
> > servers going haywire, to the point of being so loaded they 
> may crash
> > or you cannot contact them over the network (fortunately, I have
> > serial on these boxes so that I can get on the nodes if they reach
> > that point).  If I run 8 threads, and with enough clients, 
> I can bring
> > down one of these servers. size-4096 goes through the roof, and
> > depending on the hour of the day, the server can either crash or
> > becomes unresponsive.
> 
> These are doing only NFS v2 and v3?  (No v4?)
> 
> --b.
>


It should only be NFS v3 tcp. 
