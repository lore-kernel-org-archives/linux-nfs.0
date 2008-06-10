From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: Problems with large number of clients and reads
Date: Tue, 10 Jun 2008 13:16:02 -0400
Message-ID: <20080610171602.GG20184@fieldses.org>
References: <1212519001.24900.14.camel@hololw58> <20080606160922.GG30863@fieldses.org> <0122F800A3B64C449565A9E8C2977010155587@hoexmb9.conoco.net> <20080609185355.GF28584@fieldses.org> <0122F800A3B64C449565A9E8C297701002D75D9F@hoexmb9.conoco.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: "Weathers, Norman R." <Norman.R.Weathers-496aOtIFJR1B+Kdf37RAV9BPR1lH4CV8@public.gmane.org>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:54895 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751014AbYFJRQE (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jun 2008 13:16:04 -0400
In-Reply-To: <0122F800A3B64C449565A9E8C297701002D75D9F-zIGg2qceuZx7uNL6xugVa6xOck334EZe@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Tue, Jun 10, 2008 at 09:30:18AM -0500, Weathers, Norman R. wrote:
> Unfortunately, I cannot stop the clients (middle of long running
> jobs).  I might be able to test this soon.  If I have the number of
> threads high, yes I can reduce the number of threads and it appears to
> lower some of the memory, but even with as little as three threads,
> the memory usage climbs very high, just not as high as if there are
> say 8 threads.  When the memory usage climbs high, it can cause the
> box to not respond over the network (ssh, rsh), and even be very
> sluggish when I am connected over our serial console to the server(s).
> This same scenario has been happening with kernels that I have tried
> from 2.6.22.x on to the 2.6.25 series.  The 2.6.25 series is
> interesting in that I can push the same load from a box with the
> 2.6.25 kernel and not have a load over .3 (with 3 threads), but with
> the 2.6.22.x kernel, I have a load of over 3 when I hit the same
> conditions.

OK, I think what we want to do is turn on CONFIG_DEBUG_SLAB_LEAK.  I've
never used it before, but it looks like it will report which functions
are allocating from each slab cache, which may be exactly what we need
to know.  So:

	1. Install a kernel with both CONFIG_DEBUG_SLAB ("Debug slab
	memory allocations") and CONFIG_DEBUG_SLAB_LEAK ("Memory leak
	debugging") turned on.  They're both under the "kernel hacking"
	section of the kernel config.  (If you have a file
	/proc/slab_allocators, then you already have these turned on and
	you can skip this step.)

	2. Do whatever you need to do to reproduce the problem.

	3. Get a copy of /proc/slabinfo and /proc/slab_allocators.

Then we can take a look at that and see if it sheds any light.

I think that debugging will hurt the server performance, so you won't
want to keep it turned on all the time.

> 
> Also, this is all with the SLAB cache option.  SLUB crashes everytime
> I use it under heavy load.

Have you reported the SLUB bugs to lkml?

--b.
