Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-we0-f176.google.com ([74.125.82.176]:61293 "EHLO
	mail-we0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbaIXHEX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 24 Sep 2014 03:04:23 -0400
Date: Wed, 24 Sep 2014 09:04:18 +0200
From: Ingo Molnar <mingo@kernel.org>
To: NeilBrown <neilb@suse.de>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-mm@kvack.org, Ingo Molnar <mingo@redhat.com>,
        linux-fsdevel@vger.kernel.org,
        Andrew Morton <akpm@linux-foundation.org>,
        Jeff Layton <jeff.layton@primarydata.com>,
        Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 1/5] SCHED: add some "wait..on_bit...timeout()"
 interfaces.
Message-ID: <20140924070418.GA990@gmail.com>
References: <20140924012422.4838.29188.stgit@notabene.brown>
 <20140924012832.4838.59410.stgit@notabene.brown>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20140924012832.4838.59410.stgit@notabene.brown>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>


* NeilBrown <neilb@suse.de> wrote:

> @@ -859,6 +860,8 @@ int wake_bit_function(wait_queue_t *wait, unsigned mode, int sync, void *key);
>  
>  extern int bit_wait(struct wait_bit_key *);
>  extern int bit_wait_io(struct wait_bit_key *);
> +extern int bit_wait_timeout(struct wait_bit_key *);
> +extern int bit_wait_io_timeout(struct wait_bit_key *);
>  
>  /**
>   * wait_on_bit - wait for a bit to be cleared
> diff --git a/kernel/sched/wait.c b/kernel/sched/wait.c
> index 15cab1a4f84e..380678b3cba4 100644
> --- a/kernel/sched/wait.c
> +++ b/kernel/sched/wait.c
> @@ -343,6 +343,18 @@ int __sched out_of_line_wait_on_bit(void *word, int bit,
>  }
>  EXPORT_SYMBOL(out_of_line_wait_on_bit);
>  
> +int __sched out_of_line_wait_on_bit_timeout(
> +	void *word, int bit, wait_bit_action_f *action,
> +	unsigned mode, unsigned long timeout)
> +{
> +	wait_queue_head_t *wq = bit_waitqueue(word, bit);
> +	DEFINE_WAIT_BIT(wait, word, bit);
> +
> +	wait.key.timeout = jiffies + timeout;
> +	return __wait_on_bit(wq, &wait, action, mode);
> +}
> +EXPORT_SYMBOL(out_of_line_wait_on_bit_timeout);
> +
>  int __sched
>  __wait_on_bit_lock(wait_queue_head_t *wq, struct wait_bit_queue *q,
>  			wait_bit_action_f *action, unsigned mode)
> @@ -520,3 +532,27 @@ __sched int bit_wait_io(struct wait_bit_key *word)
>  	return 0;
>  }
>  EXPORT_SYMBOL(bit_wait_io);
> +
> +__sched int bit_wait_timeout(struct wait_bit_key *word)
> +{
> +	unsigned long now = ACCESS_ONCE(jiffies);
> +	if (signal_pending_state(current->state, current))
> +		return 1;
> +	if (time_after_eq(now, word->timeout))
> +		return -EAGAIN;
> +	schedule_timeout(word->timeout - now);
> +	return 0;
> +}
> +EXPORT_SYMBOL(bit_wait_timeout);
> +
> +__sched int bit_wait_io_timeout(struct wait_bit_key *word)
> +{
> +	unsigned long now = ACCESS_ONCE(jiffies);
> +	if (signal_pending_state(current->state, current))
> +		return 1;
> +	if (time_after_eq(now, word->timeout))
> +		return -EAGAIN;
> +	io_schedule_timeout(word->timeout - now);
> +	return 0;
> +}
> +EXPORT_SYMBOL(bit_wait_io_timeout);

New scheduler APIs should be exported via EXPORT_SYMBOL_GPL().

Thanks,

	Ingo
