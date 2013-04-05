Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:35144 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161236Ab3DEMka (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 5 Apr 2013 08:40:30 -0400
Date: Fri, 5 Apr 2013 08:40:25 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Bodo Stroesser <bstroesser@ts.fujitsu.com>
Cc: neilb@suse.de, linux-nfs@vger.kernel.org
Subject: Re: sunrpc/cache.c: races while updating cache entries
Message-ID: <20130405124025.GC951@fieldses.org>
References: <61eb00$3itd78@dgate20u.abg.fsc.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <61eb00$3itd78@dgate20u.abg.fsc.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Apr 04, 2013 at 07:59:35PM +0200, Bodo Stroesser wrote:
> There is no reason for apologies. The thread meanwhile seems to be a bit
> confusing :-)
> 
> Current state is:
> 
> - Neil Brown has created two series of patches. One for SLES11-SP1 and a
>   second one for -SP2
> 
> - AFAICS, the series for -SP2 will match with mainline also.
> 
> - Today I found and fixed the (hopefully) last problem in the -SP1 series.
>   My test using this patchset will run until Monday.
> 
> - Provided the test on SP1 succeeds, probably on Tuesday I'll start to test
>   the patches for SP2 (and mainline). If it runs fine, we'll have a tested
>   patchset not later than Mon 15th.

OK, great, as long as it hasn't just been forgotten!

I'd also be curious to understand why we aren't getting a lot of
complaints about this from elsewhere....  Is there something unique
about your setup?  Do the bugs that remain upstream take a long time to
reproduce?

--b.
