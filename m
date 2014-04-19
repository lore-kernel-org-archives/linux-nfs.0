Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:35520 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751104AbaDSPvP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 19 Apr 2014 11:51:15 -0400
Date: Sat, 19 Apr 2014 08:51:12 -0700
From: Christoph Hellwig <hch@infradead.org>
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: Bruce Fields <bfields@fieldses.org>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 34/70] NFSd: Fix atomicity of delegation counter
Message-ID: <20140419155112.GA13579@infradead.org>
References: <1397846704-14567-26-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-27-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-28-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-29-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-30-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-31-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-32-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-33-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-34-git-send-email-trond.myklebust@primarydata.com>
 <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1397846704-14567-35-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Apr 18, 2014 at 02:44:28PM -0400, Trond Myklebust wrote:
> Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>

I think at this point nfs4_lock_state() is always held so it's not
quite a fix yet.  If that's not true the patch should be moved earlier
in the series.

> -static int num_delegations;
> +static atomic_long_t num_delegations;

Why the switch from a int to an (atomic) long here?  If that was
intentional it should be documented in the patch description.

> -	if (num_delegations > max_delegations)
> -		return NULL;
> +	atomic_long_inc(&num_delegations);
> +	smp_mb__after_atomic_inc();
> +	if (atomic_long_read(&num_delegations) > max_delegations)
> +		goto out_dec;

Just use atomic_long_inc_return here.

> +out_dec:
> +	atomic_long_dec(&num_delegations);
> +	smp_mb__after_atomic_dec();

I can't see any point for having these barriers.

