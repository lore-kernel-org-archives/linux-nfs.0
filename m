Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:58684 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754642Ab1BBSTV (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 2 Feb 2011 13:19:21 -0500
Date: Wed, 2 Feb 2011 13:19:17 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Konstantin Khorenko <khorenko@parallels.com>
Cc: Neil Brown <neilb@suse.de>, linux-nfs@vger.kernel.org,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
Subject: Re: [PATCH] NFSD: memory corruption due to writing beyond the stat
 array
Message-ID: <20110202181917.GD3015@fieldses.org>
References: <4D4815BD.5090404@parallels.com>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <4D4815BD.5090404@parallels.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Tue, Feb 01, 2011 at 05:16:29PM +0300, Konstantin Khorenko wrote:
> Hi All,
> 
> i've found a bug which makes NFSD to corrupt memory due to writing beyond the stat array.
> 
> Initially this issue was found on 2.6.18-x RHEL5 kernel, but the same seems to be true for the current mainstream kernel (checked on 2.6.38-rc3).
> 
> ./fs/nfsd/vfs.c:
> static inline struct raparms *
> nfsd_get_raparms(dev_t dev, ino_t ino)
> {
> ...
>        // here we searched our file in a readahead cache
>        // but not found it
> ...
>          depth = nfsdstats.ra_size*11/10;
> ...
>        // some stuff, but "depth" is not changed
> ...
>          nfsdstats.ra_depth[depth*10/nfsdstats.ra_size]++;
> ...
> }
> 
> And here we write to the 12th array element
> (nfsdstats.ra_size*11/10*10/nfsdstats.ra_size == 11),

Actually, I think that's true only if ra_size is divisible by 10; if
not, then depth will be something *less* than ra_size*11/10, so
depth*10/ra_size will be something less than 11 (namely 10).

> This means that each time we did not find a file in a readahead cache we
> corrupt memory.

... and ra_size is set to 16 * min(2, numthreads/8), so I think you'll
hit this only if min(2, numthreads/8) (rounded down) is a multiple of 5?
So for example someone using a number of threads that's a power of 2
shouldn't hit this case.

> Fortunately in a kernel with NFSDv4 compiled in it corrupts
> (inc) NFS4 ops counter, but in a kernel with NFSDv4 disabled it corrupts (inc)
> some other data, that lays in the memory beyond nfsdstats.
> 
> Proposed fix is attached.

So after the fix:

> -	depth = nfsdstats.ra_size*11/10;
> +	depth = nfsdstats.ra_size;

depth*10/nfsdstats will always be 10 in this case.  Looks good.

Thanks for finding this!

--b.
