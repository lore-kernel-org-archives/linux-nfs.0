Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44483 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752829Ab0JLAHT (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Oct 2010 20:07:19 -0400
Date: Mon, 11 Oct 2010 20:07:18 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: NeilBrown <neilb@suse.de>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] sunrpc: Simplify cache_defer_req and related
 functions.
Message-ID: <20101012000718.GF16442@fieldses.org>
References: <20101007042637.26629.60300.stgit@localhost.localdomain>
 <20101007042946.26629.7991.stgit@localhost.localdomain>
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20101007042946.26629.7991.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Thu, Oct 07, 2010 at 03:29:46PM +1100, NeilBrown wrote:
> The return value from cache_defer_req is somewhat confusing.
> Various different error codes are returned, but the single caller is
> only interested in success or failure.
> 
> In fact it can measure this success or failure itself by checking
> CACHE_PENDING, which makes the point of the code more explicit.
> 
> So change cache_defer_req to return 'void' and test CACHE_PENDING
> after it completes, to see if the request was actually deferred or
> not.
> 
> Similarly setup_deferral and cache_wait_req don't need a return value,
> so make them void and remove some code.
> 
> The call to cache_revisit_request (to guard against a race) is only
> needed for the second call to setup_deferral, so move it out of
> setup_deferral to after that second call.  With the first call the
> race is handled differently (by explicitly calling
> 'wait_for_completion').

Thanks, applied both of these.  But, this:

> -static int cache_wait_req(struct cache_req *req, struct cache_head *item)
...
> +		cache_wait_req(req, item, timeout);

suggests this version of the patch wasn't really tested!  Would you mind
doing some testing on the version I've just pushed out?

--b.
