From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: Exposing cache statistics
Date: Fri, 17 Apr 2009 08:54:56 -0400
Message-ID: <1239972896.5209.13.camel@heimdal.trondhjem.org>
References: <49E643CD.9070809@disney.com>
	 <1239828092.5177.139.camel@heimdal.trondhjem.org>
	 <49E7CE3E.8020006@disney.com>  <49E8626F.6000508@RedHat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Kevin Constantine <Kevin.Constantine-FfNkGbSheRGpB8w63BLUukEOCMrvLtNR@public.gmane.org>,
	Linux NFS Mailing list <linux-nfs@vger.kernel.org>
To: Steve Dickson <SteveD@redhat.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out1.uio.no ([129.240.10.57]:45283 "EHLO mail-out1.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756173AbZDQMzG (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 17 Apr 2009 08:55:06 -0400
In-Reply-To: <49E8626F.6000508-AfCzQyP5zfLQT0dZR+AlfA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2009-04-17 at 07:05 -0400, Steve Dickson wrote:
> 
> Kevin Constantine wrote:
> > Trond Myklebust wrote:
> >> On Wed, 2009-04-15 at 13:30 -0700, Kevin Constantine wrote:
> >>> Has there been any effort to expose caching statistics to the end
> >>> user?   On the client-side, it would be useful to see how much data
> >>> is being re-used from cache vs data that gets retrieved over the
> >>> wire.  Similarly on the server side, it would be nice to see how much
> >>> data is being served from cache vs having to pull the data from disk.
> >>>
> >>> Just wondering if anyone started anything to expose this sort of
> >>> information.
> >>
> >> See the nfs-iostat tool in the nfs-utils package:
> >>
> >>   
> >> http://git.linux-nfs.org/?p=steved/nfs-utils.git;a=tree;f=tools/nfs-iostat;h=929e303cc762a68dfd01546f5150eb294274164e;hb=refs/heads/master
> >>
> >>
> >> Note that you need a 2.6.17 kernel or newer.
> >>
> >> Cheers
> >>   Trond
> > 
> > Thanks Trond-
> > 
> > It seems like nfs-iostat is displaying the number of pages that are
> > being written to the read/write caches (i'm only looking at the
> > client-side at the moment), and what I'm interested in is the ratio of
> > pages being read from cache vs data being fetched from the server.
> > 
> > Is there any documentation on the layout of /proc/self/mountstats?
> No, unfortunately not... 

I'd suggest using the python code in nfs-iostat as a reference.

You should be able to figure out how much data is being read on the wire
by looking at nfs_stats['serverreadbytes']. Comparing that to the value
in nfs_stats['normalreadbytes'] (which tells you the total number of
bytes requested in read() calls) should give you a rough estimate for
how much data is being read from cache.

Cheers
  Trond

