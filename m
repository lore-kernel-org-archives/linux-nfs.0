Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34772 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752887AbcI2BnB (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Wed, 28 Sep 2016 21:43:01 -0400
Message-ID: <1475113378.28155.124.camel@edumazet-glaptop3.roam.corp.google.com>
Subject: Re: [PATCH net-next v3 2/3] udp: implement memory accounting helpers
From: Eric Dumazet <eric.dumazet@gmail.com>
To: Paolo Abeni <pabeni@redhat.com>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        James Morris <jmorris@namei.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Alexander Duyck <aduyck@mirantis.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Eric Dumazet <edumazet@google.com>, Tom Herbert <tom@herbertland.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Edward Cree <ecree@solarflare.com>, linux-nfs@vger.kernel.org
Date: Wed, 28 Sep 2016 18:42:58 -0700
In-Reply-To: <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
References: <cover.1475048434.git.pabeni@redhat.com>
         <6f445861ef2ce2e626a1df4946bc3f43f3d43e3f.1475048434.git.pabeni@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, 2016-09-28 at 12:52 +0200, Paolo Abeni wrote:

> +static void udp_rmem_release(struct sock *sk, int partial)
> +{
> +	struct udp_sock *up = udp_sk(sk);
> +	int fwd, amt;
> +
> +	if (partial && !udp_under_memory_pressure(sk))
> +		return;
> +
> +	/* we can have concurrent release; if we catch any conflict
> +	 * we let only one of them do the work
> +	 */
> +	if (atomic_dec_if_positive(&up->can_reclaim) < 0)
> +		return;
> +
> +	fwd = __udp_forward(up, atomic_read(&sk->sk_rmem_alloc));
> +	if (fwd < SK_MEM_QUANTUM + partial) {
> +		atomic_inc(&up->can_reclaim);
> +		return;
> +	}
> +
> +	amt = (fwd - partial) & ~(SK_MEM_QUANTUM - 1);
> +	atomic_sub(amt, &up->mem_allocated);
> +	atomic_inc(&up->can_reclaim);
> +
> +	__sk_mem_reduce_allocated(sk, amt >> SK_MEM_QUANTUM_SHIFT);
> +	sk->sk_forward_alloc = fwd - amt;
> +}


This is racy... all these atomics make me nervous...



