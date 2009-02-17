From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH] NFS: Pagecache usage optimization on nfs
Date: Tue, 17 Feb 2009 09:18:42 -0500
Message-ID: <1234880322.8412.124.camel@heimdal.trondhjem.org>
References: <6.0.0.20.2.20090217132810.05709598@172.19.0.2>
	 <200902172343.13838.nickpiggin@yahoo.com.au>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Hisashi Hifumi <hifumi.hisashi-gVGce1chcLdL9jVzuh4AOg@public.gmane.org>,
	linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Nick Piggin <nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:13607 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751741AbZBQOTD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Feb 2009 09:19:03 -0500
In-Reply-To: <200902172343.13838.nickpiggin-/E1597aS9LT0CCvOHzKKcA@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, 2009-02-17 at 23:43 +1100, Nick Piggin wrote:
> On Tuesday 17 February 2009 15:55:12 Hisashi Hifumi wrote:
> > Hi, Trond.
> >
> > I wrote "is_partially_uptodate" aops for nfs client named
> > nfs_is_partially_uptodate(). This aops checks that nfs_page is attached to
> > a page and read IO to a page is within the range between wb_pgbase and
> > wb_pgbase + wb_bytes of the nfs_page. If this aops succeed, we do not have
> > to issue actual read IO to NFS server even if a page is not uptodate
> > because the portion we want to read are uptodate. So with this patch random
> > read/write mixed workloads or random read after random write workloads can
> > be optimized and we can get performance improvement.
> >
> > I did benchmark test using sysbench.
> >
> > sysbench --num-threads=16 --max-requests=100000 --test=fileio
> > --file-block-size=2K --file-total-size=200M --file-test-mode=rndrw
> > --file-fsync-freq=0
> > --file-rw-ratio=0.5 run
> >
> > The result was:
> >
> > -2.6.29-rc4
> >
> > Operations performed:  33356 Read, 66682 Write, 128 Other = 100166 Total
> > Read 65.148Mb  Written 130.24Mb  Total transferred 195.39Mb  (3.1093Mb/sec)
> >  1591.97 Requests/sec executed
> >
> > Test execution summary:
> >     total time:                          62.8391s
> >     total number of events:              100038
> >     total time taken by event execution: 841.7603
> >     per-request statistics:
> >          min:                            0.0000s
> >          avg:                            0.0084s
> >          max:                            16.4564s
> >          approx.  95 percentile:         0.0446s
> >
> > Threads fairness:
> >     events (avg/stddev):           6252.3750/306.48
> >     execution time (avg/stddev):   52.6100/0.38
> >
> >
> > -2.6.29-rc4 + patch
> >
> > Operations performed:  33346 Read, 66662 Write, 128 Other = 100136 Total
> > Read 65.129Mb  Written 130.2Mb  Total transferred 195.33Mb  (5.0113Mb/sec)
> >  2565.81 Requests/sec executed
> >
> > Test execution summary:
> >     total time:                          38.9772s
> >     total number of events:              100008
> >     total time taken by event execution: 339.6821
> >     per-request statistics:
> >          min:                            0.0000s
> >          avg:                            0.0034s
> >          max:                            1.6768s
> >          approx.  95 percentile:         0.0200s
> >
> > Threads fairness:
> >     events (avg/stddev):           6250.5000/302.04
> >     execution time (avg/stddev):   21.2301/0.45
> >
> >
> > I/O performance was significantly improved by following patch.
> 
> OK, but again this is not something too sane to do is it (ask for 2K IO
> size on 4K page system)? What are the comparison results with 4K IO
> size? I guess it will help some cases, but it's probably hard to find
> realistic workloads that see such an improvement.

The other thing that worries me about it is that the scheme relies
entirely on using the page dirtying mechanism to track updated parts of
a page. You will lose that information as soon as the page cache is
flushed to disk.
IOW: I would expect those numbers to change greatly if you increase the
file size to the point where the VM starts evicting the pages.

There are plenty of ways in which one can tune the performance of NFS.
It all depends on the application. For instance, our lack of tracking of
holes means that we tend to perform very poorly when dealing with reads
of sparse files such as in the above test. Perhaps that might be
considered as an alternative idea?

Cheers
  Trond
-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com
