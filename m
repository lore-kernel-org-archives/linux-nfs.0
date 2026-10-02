Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id BEDEA2D0C75;
	Fri,  2 Oct 2026 01:19:24 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790903966; cv=none; b=BuHFiQanVPjoIW/6D6NsBNqOet1OwZ6QO81AiGduw5iHaVtpNPWT6Mh92LDFaZvAI5hyGlYzCP2iBr1xTVnzr39hKxE9uOgbd+SzfGXJIG2cHLb4Vsoqs8iWtElK2KyVIkkzLjBIZj9vZ23Q8hqQznSFpR/DMDmUVrGizl521LI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790903966; c=relaxed/simple;
	bh=Jy1WW58wYextaXVT4Evh3rZIYctDRwMu1h6nQwo8jq0=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=CVUWxHucfdW0OcIb0DypsGRYb8mhaHn4pyOAQejwnaMHrEMjv7x5O+82QXbMFq91UzRZXmAC+IX8obcLxnBlKTx3ds6xalq3ZmyHcylxkzUNtVrN1neZqwO27kAaq5vrmMawZbOF0imIvougZ6PZQXRFT3uipvOizQc9+bZSoSc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=E1fbjVWx; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="E1fbjVWx"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0C96C1F00898;
	Fri,  2 Oct 2026 01:19:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790903964;
	bh=ZgL8KT6UyYqk0aSUs+XywFLceK5PXM95ccl5tMC4M6c=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=E1fbjVWx8HUEkOsH/p+8hEkz6uPVfYJ1N56tobODFjTZ4G0SpbHOpb3gJBYtB+k5V
	 rmIQt4VHKFCrYqU+GshRab7S/8cfb5Toy3llZbW03orlXY2HQbZz2VYm3dzg73qyCm
	 L96aUvyVeGmDCToIFNJUVFtjawLq3cLsj7r3Vt2atEhDg6so42rreYSLf7UXARgkT/
	 QgK8pvBEFq281BgDebVEXqanIpaWh+FiXk2BW7DgyeCHN5UuYNGg1B82+qDnznBxmO
	 vYJluQbam+z7h/XL7Oa2X5Nclp5TH/ClxAPHABGZI87yHKY0V78XorIsKkH3k43Arv
	 ZIQNK5qSaUtcA==
Subject:
 Re: [PATCH v3 net-next 2/9] net: add sk_set_nospace() and sk_clear_nospace()
From: netdev-bot+sashiko@kernel.org
To: edumazet@kernel.org
Cc: davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, horms@kernel.org,
 ncardwell@google.com, kuniyu@google.com, edumazet@google.com,
 netdev@vger.kernel.org, aahringo@redhat.com, teigland@redhat.com,
 gfs2@lists.linux.dev, john.fastabend@gmail.com, jakub@cloudflare.com,
 sd@queasysnail.net, jiayuan.chen@linux.dev, matttbe@kernel.org,
 martineau@kernel.org, geliang@kernel.org, mptcp@lists.linux.dev,
 guwen@linux.alibaba.com, dust.li@linux.alibaba.com, alibuda@linux.alibaba.com,
 cel@kernel.org, jlayton@kernel.org, neil@brown.name, okorniev@redhat.com,
 Dai.Ngo@oracle.com, tom@talpey.com, trondmy@kernel.org, anna@kernel.org,
 linux-nfs@vger.kernel.org, achender@kernel.org, rds-devel@oss.oracle.com,
 philipp.reisner@linbit.com, lars.ellenberg@linbit.com,
 christoph.boehmwalder@linbit.com, axboe@kernel.dk, drbd-dev@lists.linux.dev,
 kbusch@kernel.org, hch@lst.de, sagi@grimberg.me, kch@nvidia.com,
 linux-nvme@lists.infradead.org, idryomov@gmail.com, amarkuze@redhat.com,
 slava@dubeyko.com, ceph-devel@vger.kernel.org
Date: Fri, 02 Oct 2026 01:19:21 +0000
Message-ID: <179090396163.434549.17078456875328527207@kernel.org>
In-Reply-To: <20260929071743.23624-3-edumazet@kernel.org>
References: <20260929071743.23624-3-edumazet@kernel.org>
X-sashiko-severity: Low
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found more severe
issue(s) in other patches of this series. This mail is only an FYI, in case
you want to address the nit picks below when you respin.

Low priority / nit picks for your consideration:

- [Low] The kernel-doc added in net/core/sock.c for the new helpers does
  not match how the helpers are used, both in this patch and later in…
- [Low] sk_set_nospace() and sk_clear_nospace() (net/core/sock.c) read
  sk->sk_socket with a plain load (`struct socket *sock = sk->sk_socket;…

--

net: add sk_set_nospace() and sk_clear_nospace()

This commit adds two helpers, sk_set_nospace() and sk_clear_nospace().
They set or clear SOCK_NOSPACE in sk->sk_socket->flags after a NULL
check, and the commit converts the core networking callers to use them.
It prepares for a later patch that gives TCP a private copy of the bit.

> diff --git a/net/core/sock.c b/net/core/sock.c
> index 2948dffcc3e1b..11a22aec7e414 100644
> --- a/net/core/sock.c
> +++ b/net/core/sock.c
> @@ -2957,6 +2957,39 @@ void sock_kzfree_s(struct sock *sk, void *mem, int size)
>  }
>  EXPORT_SYMBOL(sock_kzfree_s);
>  
> +/**
> + *	sk_set_nospace - tell the transport a writer is waiting for space
> + *	@sk: socket
> + *
> + *	Must be called before the final check of the available send space,
> + *	so that the transport can not miss the request and forget to call
> + *	sk->sk_write_space() once space is available again.
> + */
> +void sk_set_nospace(struct sock *sk)
> +{
> +	struct socket *sock = sk->sk_socket;
> +
> +	if (sock)
> +		set_bit(SOCK_NOSPACE, &sock->flags);
> +}

[Severity: Low]

Should this be READ_ONCE(sk->sk_socket)?

The writer side uses a marked store:

include/net/sock.h:sk_set_socket() {
	WRITE_ONCE(sk->sk_socket, sock);
}

sock_orphan() makes that store holding only sk_callback_lock:

	write_lock_bh(&sk->sk_callback_lock);
	sock_set_flag(sk, SOCK_DEAD);
	sk_set_socket(sk, NULL);

At least one path can reach these helpers at the same time as that store.
It does not take sk_callback_lock and does not check socket ownership:

CPU1 (SMC CDC receive tasklet)
smc_cdc_msg_recv()
  bh_lock_sock(&smc->sk)
  smc_cdc_msg_recv_action()
    ...
      smc_tx_write_space()
        sk_clear_nospace()
          sock = sk->sk_socket;

CPU2
close()
  smc_release()
    lock_sock(sk)
    sock_orphan(sk)
      WRITE_ONCE(sk->sk_socket, NULL)

Won't KCSAN report this plain read racing with the marked write?

The compiler is also allowed to reload sk->sk_socket after the NULL
check when it computes &sock->flags. That would undo the NULL check that
the commit message relies on to make the helpers "more robust".

This patch also adds a second plain read of sk->sk_socket to
sk_stream_write_space() and smc_tx_write_space(). Both functions already
had the pointer in a local sock variable.

sk_clear_nospace() below has the same plain load. It is still there at
the end of the series, after "tcp: add tp->tcp_nospace".

> +EXPORT_SYMBOL(sk_set_nospace);
> +
> +/**
> + *	sk_clear_nospace - tell the transport no writer is waiting for space
> + *	@sk: socket
> + *
> + *	Called from ->sk_write_space() handlers, once send space has been
> + *	made available to writers.
> + */

[Severity: Low]

Does this kernel-doc, and the one for sk_set_nospace() above, match how
the helpers are actually used?

This comment says the helper is "Called from ->sk_write_space() handlers".
kcm_tx_work() is a workqueue handler, though, and it clears the bit
before it calls ->sk_write_space():

net/kcm/kcmsock.c:kcm_tx_work() {
    ...
	if (likely(sk->sk_socket) &&
	    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
		sk_clear_nospace(sk);
		sk->sk_write_space(sk);
	}
    ...
}

Later in the series, "sunrpc: use sk_set_nospace() and
sk_clear_nospace()" adds a call to it from svc_tcp_has_wspace() in
net/sunrpc/svcsock.c. That is an ->xpo_has_wspace check, not a
write_space callback.

The sk_set_nospace() comment says it "Must be called before the final
check of the available send space". Several converted callers, however,
set the bit on an -EAGAIN exit and never check again. There the point is
to arm a later ->sk_write_space() or EPOLLOUT:

net/core/stream.c:sk_stream_wait_memory() {
    ...
do_eagain:
    ...
	sk_set_nospace(sk);
	err = -EAGAIN;
	goto out;
}

The !timeo branches in smc_tx_wait() and sock_alloc_send_pskb() work
the same way.

The comment also does not say that sk_set_nospace() is only a set_bit()
with no barrier. Callers have to provide a full barrier between setting
the bit and re-checking. Today that comes from smp_mb__after_atomic() in
tcp_poll(), smc_poll() and mptcp_check_writeable(), and from
prepare_to_wait() in sock_wait_for_wmem().

Could the kernel-doc also cover the -EAGAIN use, the callers outside
write_space handlers, and the barrier the caller must provide?

> +void sk_clear_nospace(struct sock *sk)
> +{
> +	struct socket *sock = sk->sk_socket;
> +
> +	if (sock)
> +		clear_bit(SOCK_NOSPACE, &sock->flags);
> +}
> +EXPORT_SYMBOL(sk_clear_nospace);

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260929071743.23624-1-edumazet%40kernel.org
