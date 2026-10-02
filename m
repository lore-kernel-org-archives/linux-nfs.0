Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AC5832D0C75;
	Fri,  2 Oct 2026 01:19:27 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790903968; cv=none; b=hb13If0pGA+1guB+ZWXOGSp8/Op/6ijm+itcp7FUteol3dXkFWT9u01q6N8ZthfNcKwZvZn9vQxrUoMJykXJ+KOsxB4JHqs/gE9O3ixKNkhDdB2HjroGEOzNXs6mLqbOe+IGpCBC9XxA+LnuCGiWp0UH5DX/3hnCO7spNKFQUyc=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790903968; c=relaxed/simple;
	bh=OKNrQMhyXEDpqmEu+exjq6q8XBhoZP//xXVKI16ebvI=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=pW5RFAyWbz6PcqRZ5mDmAEXYjoxivF8kJAPD17UxTqCxa2wmLqASKjNWzcXnzqQRCGJYaRlQi+TQN+ch/mVDbU9XmMe/mpqoNMJt4wpI4Ll8SxfmRJFAtG2LdHnsNkWg1GVlUlLFZrn3VanKsJA5MyMNfPzOobNHXyR6lbc2vF4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ErJrQb9S; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ErJrQb9S"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EFC231F00893;
	Fri,  2 Oct 2026 01:19:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790903967;
	bh=5ZaH7kjR91t+LbbdbOtI4sfeLxRZza0chRAHxNS1iZ0=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=ErJrQb9S6f1R8SuFuhRXDxtU8WylahNE8JFxYAKJbzR2Ra+k4EfG9s0Q2jOzgBvXC
	 qz1D8sPUNaERGcuTc2onmU+T5EW1cBavf0efZzDUNJwqPa+eFpDt1A9dDVSDV2Vspg
	 2pPjPRUpaDdfmGgV0q6bldA+XzCTotbFizw2N8tHRFy8V2aflQMbR2Uxut34s+NAoj
	 dD5sGlmReE2yU3ptLwk926hWAJZjV2esT9gPoVquL/vAVgd7Ms1DfSTvVV/cYym95D
	 s6ujsM2cjFMa4em+WkhnJ6AZT/XUOn961ImH+2/owsLkh0DAxyVXs61S/yRVcrG8t6
	 fIr88V2mvqjdA==
Subject: Re: [PATCH v3 net-next 9/9] tcp: add tp->tcp_nospace
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
Date: Fri, 02 Oct 2026 01:19:24 +0000
Message-ID: <179090396455.434549.14548496564842351902@kernel.org>
In-Reply-To: <20260929071743.23624-10-edumazet@kernel.org>
References: <20260929071743.23624-10-edumazet@kernel.org>
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

- [Low] The commit message says struct socket lives in a cache line
  "which the TCP fast paths do not otherwise touch".
- [Low] A child socket inherits the listener's tp->tcp_nospace and
  nothing resets it.

--

tcp: add tp->tcp_nospace

This commit adds tp->tcp_nospace, a copy of SOCK_NOSPACE that lives in the
tcp_sock_write_tx cache line group. With it, tcp_check_space() no longer
has to read sk->sk_socket->flags on every ACK and every transmit.
sk_set_nospace() and sk_clear_nospace() keep the rule that SOCK_NOSPACE
set implies tp->tcp_nospace set. MPTCP subflows pin tp->tcp_nospace to 1
in subflow_ulp_init().

> struct socket lives in its own cache line, which the TCP fast paths do
> not otherwise touch, so testing sk->sk_socket->flags pulls in an extra
> cache line that is cold when the working set is large.

[Severity: Low]
Is this still accurate after this patch? Only tcp_check_space() was
converted to use the new field.

tcp_write_xmit() calls tcp_cwnd_validate() whenever it has sent packets.
If the flow is not cwnd limited and the write queue is empty,
tcp_cwnd_validate() still reads sk->sk_socket->flags:

net/ipv4/tcp_output.c:tcp_cwnd_validate() {
    ...
		if (tcp_write_queue_empty(sk) && sk->sk_socket &&
		    test_bit(SOCK_NOSPACE, &sk->sk_socket->flags) &&
		    (1 << sk->sk_state) & (TCPF_ESTABLISHED | TCPF_CLOSE_WAIT))
			tcp_chrono_start(sk, TCP_CHRONO_SNDBUF_LIMITED);
    ...
}

tcp_cwnd_application_limited() also reads it on the
slow_start_after_idle path:

net/ipv4/tcp_output.c:tcp_cwnd_application_limited() {
    ...
	if (inet_csk(sk)->icsk_ca_state == TCP_CA_Open &&
	    sk->sk_socket && !test_bit(SOCK_NOSPACE, &sk->sk_socket->flags)) {
    ...
}

Request/response senders limited by the application empty the write
queue on every transmit. Their transmits would still pull in the struct
socket cache line. The microbenchmark only times tcp_check_space(), so it
would not show this.

The new rule (SOCK_NOSPACE set => tp->tcp_nospace set) means both sites
could check READ_ONCE(tp->tcp_nospace) first without changing behavior.
Would that be worth doing? If not, could the commit message avoid saying
the fast paths no longer touch struct socket?

[ ... ]

> diff --git a/net/mptcp/subflow.c b/net/mptcp/subflow.c
> index f0a6725d2c376..e297c88be503b 100644
> --- a/net/mptcp/subflow.c
> +++ b/net/mptcp/subflow.c
> @@ -2001,6 +2001,11 @@ static int subflow_ulp_init(struct sock *sk)
>  	pr_debug("subflow=%p, family=%d\n", ctx, sk->sk_family);
>  
>  	tp->is_mptcp = 1;
> +	/* Subflows share the MPTCP socket, and thus its SOCK_NOSPACE bit,
> +	 * which tcp_check_space() can not mirror. Pin the mirror so that
> +	 * __tcp_check_space() always tests the shared bit.
> +	 */
> +	tp->tcp_nospace = 1;

[Severity: Low]
Do passive children of an MPTCP listener inherit this pinned value, even
when they fall back to plain TCP?

The listener subflow gets tcp_nospace = 1 here through
mptcp_subflow_create_socket()->tcp_set_ulp()->subflow_ulp_init(). Its
is_mptcp stays 1, so tcp_clear_nospace() never clears it.

tcp_create_openreq_child()->inet_csk_clone_lock()->sk_clone_lock() then
copies the tcp_sock, and nothing resets tcp_nospace.

When the SYN comes from a peer without MPTCP,
subflow_ulp_clone()->subflow_ulp_fallback() makes the child plain TCP:

	tcp_sk(sk)->is_mptcp = 0;

mptcp_stream_accept() then grafts it as a plain TCP socket. Its new
struct socket has SOCK_NOSPACE clear. This new early return in
__tcp_check_space() then applies:

	if (!sock || !test_bit(SOCK_NOSPACE, &sock->flags))
		return;

So tcp_new_space()->sk_stream_write_space()->sk_clear_nospace() is never
reached, and that is the only place the hint gets cleared. It stays set
until the application first fills its send buffer.

Until then, every ACK and every transmit calls __tcp_check_space() out of
line and reads sk->sk_socket->flags. These connections would not get the
optimization.

The rule still holds, so no EPOLLOUT is lost. Could tcp_nospace be reset
for the child, for example in tcp_create_openreq_child() or in
subflow_ulp_fallback()?

The same can happen with a plain TCP listener. If a socket was connected,
ended up with tcp_nospace = 1, was disconnected and then put into
listen(), its children inherit the stale value too. tcp_disconnect() does
not reset it either.

[ ... ]

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260929071743.23624-1-edumazet%40kernel.org
