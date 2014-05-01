Return-Path: linux-nfs-owner@vger.kernel.org
Received: from bombadil.infradead.org ([198.137.202.9]:46791 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753318AbaEAIEk (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 May 2014 04:04:40 -0400
Date: Thu, 1 May 2014 10:04:30 +0200
From: Peter Zijlstra <peterz@infradead.org>
To: NeilBrown <neilb@suse.de>
Cc: Ingo Molnar <mingo@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        "J. Bruce Fields" <bfields@fieldses.org>, linux-kernel@vger.kernel.org,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SCHED: allow wait_on_bit_action functions to support a
 timeout.
Message-ID: <20140501080430.GL11096@twins.programming.kicks-ass.net>
References: <20140501124143.5712eb96@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140501124143.5712eb96@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2014 at 12:41:43PM +1000, NeilBrown wrote:
> diff --git a/include/linux/wait.h b/include/linux/wait.h
> index 438dc6044587..162cbcde9dae 100644
> --- a/include/linux/wait.h
> +++ b/include/linux/wait.h
> @@ -25,6 +25,7 @@ struct wait_bit_key {
>  	void			*flags;
>  	int			bit_nr;
>  #define WAIT_ATOMIC_T_BIT_NR	-1
> +	unsigned long		private;
>  };
>  
>  struct wait_bit_queue {
> @@ -147,12 +148,12 @@ void __wake_up_sync_key(wait_queue_head_t *q, unsigned int mode, int nr, void *k
>  void __wake_up_locked(wait_queue_head_t *q, unsigned int mode, int nr);
>  void __wake_up_sync(wait_queue_head_t *q, unsigned int mode, int nr);
>  void __wake_up_bit(wait_queue_head_t *, void *, int);
> -int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
> -int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (*)(void *), unsigned);
> +int __wait_on_bit(wait_queue_head_t *, struct wait_bit_queue *, int (*)(struct wait_bit_key *), unsigned);
> +int __wait_on_bit_lock(wait_queue_head_t *, struct wait_bit_queue *, int (*)(struct wait_bit_key *), unsigned);


Would something like:

typedef int (*wait_bit_action_f)(struct wait_bit_key *);

make sense?
