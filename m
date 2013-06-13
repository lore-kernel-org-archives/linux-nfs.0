Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:58918 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758232Ab3FMCEz (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 12 Jun 2013 22:04:55 -0400
Date: Wed, 12 Jun 2013 22:04:50 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: Bodo Stroesser <bstroesser@ts.fujitsu.com>, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130613020450.GB13028@fieldses.org>
References: <61eb00$3oamkh@dgate20u.abg.fsc.net>
 <20130613115456.02e28f94@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20130613115456.02e28f94@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Jun 13, 2013 at 11:54:56AM +1000, NeilBrown wrote:
> On 03 Jun 2013 16:27:06 +0200 Bodo Stroesser <bstroesser@ts.fujitsu.com>
> wrote:
> 
> > On Fri, Apr 19, 2013 at 06:56:00PM +0200, Bodo Stroesser wrote:
> > > 
> > > We started the test of the -SP2 (and mainline) series on Tue, 9th, but had no
> > > success.
> > > We did _not_ find a problem with the patches, but under -SP2 our test scenario
> > > has less than 40% of the throughput we saw under -SP1. With that low
> > > performance, we had a 4 day run without any dropped RPC request. But we don't
> > > know the error rate without the patches under these conditions. So we can't
> > > give an o.k. for the patches yet.
> > > 
> > > Currently we try to find the reason for the different behavior of SP1 and SP2
> > > 
> > 
> > Hi,
> > 
> > sorry for the delay. Meanwhile we found the reason for the small throughput
> > with -SP2. The problem resulted from a change in our own software.
> > 
> > Thus I could fix this and started a test on last Tuesday. I stopped the test
> > today after 6 days without any lost RPC. Without the patches I saw the first
> > dropped RPC after 3 hours. Thus, I think the patches for -SP2 are fine. 
> > 
> > @Neil: would patch 0006 of the -SP1 patchset be a good additional change for
> > mainline?
> > 
> > Bodo
> 
> Thanks for all the testing.
> 
> Bruce: where are you at with these?  Are you holding one to some that I sent
> previously, or should I resend them all?

No, I'm not holding on to any--if you could resend them all that would
be great.

--b.

> 
> 
> Bodo: no, I don't think that patch is appropriate for mainline.  It causes
> sunrpc_cache_pipe_upcall to abort if ->expiry_time is zero.  There is
> certainly no point in doing an upcall in that case, but the code in mainline
> is quite different to the code in -SP1 against which that patch made sense.
> 
> For mainline an equivalent optimisation which probably makes the interesting
> case more obvious would be:
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index d01eb07..291cc47 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -262,7 +262,8 @@ int cache_check(struct cache_detail *detail,
>  	if (rqstp == NULL) {
>  		if (rv == -EAGAIN)
>  			rv = -ENOENT;
> -	} else if (rv == -EAGAIN || age > refresh_age/2) {
> +	} else if (rv == -EAGAIN ||
> +		   (refresh_age > 0 && age > refresh_age/2)) {
>  		dprintk("RPC:       Want update, refage=%ld, age=%ld\n",
>  				refresh_age, age);
>  		if (!test_and_set_bit(CACHE_PENDING, &h->flags)) {
> 
> 
> i.e. trap that case in cache_check.
> 
> NeilBrown


