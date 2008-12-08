From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH 00/17] First set of patches for 2.6.29 (take 2)
Date: Mon, 8 Dec 2008 17:47:29 -0500
Message-ID: <20081208224729.GH19417@fieldses.org>
References: <20081204191113.8039.76714.stgit@ingres.1015granger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-nfs@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.fieldses.org ([66.93.2.214]:42783 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752680AbYLHWra (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 8 Dec 2008 17:47:30 -0500
In-Reply-To: <20081204191113.8039.76714.stgit-07a7zB5ZJzbwdl/1UfZZQIVfYA8g3rJ/@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 04, 2008 at 02:19:35PM -0500, Chuck Lever wrote:
> Hi Bruce-
> 
> Thanks for the careful review.
> 
> Here's the second take of the patches I sent Monday.  I think I've
> addressed your concerns, and have split most of these patches into
> several smaller ones to facilitate review.  Enough details have
> changed that it would be worth a second close inspection.
> 
> Again, these patches add partial support for IPv6 to the kernel's
> NSM upcall implementation, and introduce various minor clean-ups
> and bug fixes.  I'd like them to be considered for 2.6.29.

OK, I've applied this set, and am looking at the second; thanks.

--b.

> 
> ---
> 
> Chuck Lever (17):
>       NSM: Check result of SM_UNMON upcall
>       NLM: Move the public declaration of nsm_unmonitor() to lockd.h
>       NSM: Release nsmhandle in nlm_destroy_host
>       NLM: Move the public declaration of nsm_monitor() to lockd.h
>       NSM: Make sure to return an error if the SM_MON call result is not zero
>       NSM: Remove BUG_ON() in nsm_monitor()
>       NLM: Remove redundant printk() in nlmclnt_lock()
>       NSM: Use sm_name instead of h_name in nsm_monitor() and nsm_unmonitor()
>       NSM: Support IPv6 version of mon_name
>       NSM: Use modern style for sm_name field in nsm_handle
>       NSM: convert printk(KERN_DEBUG) to a dprintk()
>       NSM: Use C99 structure initializer to initialize nsm_args
>       NLM: Add helper to handle IPv4 addresses
>       NLM: Support IPv6 scope IDs in nlm_display_address()
>       NLM: Remove AF_UNSPEC arm in nlm_display_address()
>       NLM: Remove address eye-catcher buffers from nlm_host
>       NLM: Use modern style for pointer fields in nlm_host
> 
> 
>  fs/lockd/clntproc.c            |    6 +--
>  fs/lockd/host.c                |   52 ++++++++++++----------
>  fs/lockd/mon.c                 |   96 ++++++++++++++++++++--------------------
>  include/linux/lockd/lockd.h    |   29 ++++++++----
>  include/linux/lockd/sm_inter.h |    2 -
>  5 files changed, 98 insertions(+), 87 deletions(-)
> 
> -- 
> Chuck Lever
