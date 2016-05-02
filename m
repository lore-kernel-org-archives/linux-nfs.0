Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:51115 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752805AbcEBN2N (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 2 May 2016 09:28:13 -0400
Date: Mon, 2 May 2016 15:28:04 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: George Spelvin <linux@horizon.com>
Cc: linux-kernel@vger.kernel.org, tglx@linutronix.de,
        torvalds@linux-foundation.org, bfields@fieldses.org,
        eric.dumazet@gmail.com, jlayton@poochiereds.net,
        linux-nfs@vger.kernel.org, riel@redhat.com
Subject: Re: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32
 bits
Message-ID: <20160502132804.GF12845@twins.programming.kicks-ass.net>
References: <alpine.DEB.2.11.1605020908080.3692@nanos>
 <20160502102016.17936.qmail@ns.horizon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20160502102016.17936.qmail@ns.horizon.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, May 02, 2016 at 06:20:16AM -0400, George Spelvin wrote:
> Subject: [PATCH 1/2] <linux/hash.h>: Make hash_64(), hash_ptr() return 32 bits

> +static __always_inline u64 hash_64(u64 val, unsigned bits)
> +{
>  	/* High bits are more random, so use them. */
> +	return __hash_64(val) >> (64 - bits);
>  }

Is the subject stale or the above a mistake? Because hash_64() still
very much seems to return u64.

Also, I think I would prefer to keep it like this, I would like to use
it for kernel/locking/lockdep.c:iterate_chain_key(), which currently is
a somewhat crap hash.

Something like:

static inline u64 iterate_chain_key(u64 key1, u64 key2)
{
	return hash_64(key1 ^ key2, 64);
}

