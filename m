Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id E03042D0C75;
	Fri,  2 Oct 2026 01:19:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790903963; cv=none; b=PWpAS2On1SFwywgWzlZEwCz2IHI3s312G8h1EqCY6/e0AlxbN9jVOWZayu2tqHYOATIndp87Be/MBM3xOiQeiZeY2newc3EbYIMiWSf+8NzgB9LP/5VgXp1Un3fTqtYDyD6BCWx7Zl/D23/Uf/80u9HWAIL67ueylRJ/7FAwsas=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790903963; c=relaxed/simple;
	bh=4nO8rBTyIXYBkEpdYgQA3o1XWX8YWIGlfr4w1sbeTBk=;
	h=Subject:From:To:Cc:Date:Message-ID:In-Reply-To:References:
	 Content-Type:MIME-Version; b=mFYcIPiTCzIE62MiQzXKXTbtmhri9kNrKiBmrrRoRzBpin206OwmpHajkS5VkmZOdBoGDUPG1kKzWZGGmBNoSM8fqcw5VZVdwli5DbXSonFRx/yZ0Cp19+SRqI6TFByTozqcxV8aUYt4s9OQZm7dBgWRDqlCpmO3BZNoaokTw/4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=KuA5PeAB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="KuA5PeAB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 1BEA51F00893;
	Fri,  2 Oct 2026 01:19:19 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790903961;
	bh=aZby0WeNlKN6rlwpn1/LnNcy7QUqDYIZv8b3LV0Liww=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=KuA5PeABrGCDRWE2c+jTnoLFrU//pbGuovhvcC7WRoTMqadKhnbC4f+PcUP5YFkX1
	 unr0lhG32+rUpcxEiGaP3SvZJBE38JOOnYtEe7NcQaP2tq2FmoSQpUxHbi57ooTLMn
	 Q5YgrSIv45LrfpYfWhZMGqTt5gp+UCm4En3h4iy13LO2lZSEKfkCL0MyrYTLRUB+5y
	 wOapxs1VHrcJVWsXp0OSik3Vj/iZ24MwH2rXigcYTAMf9eeki1dQ+O+Lnu4LdTypQJ
	 NSuZnww9Aw+av26zHa/GSTIdIPAkyFnpcJk2cohH8E7Exp59yR+Z4ApDkLbGOT4r8G
	 61OIfAEMCpdfQ==
Subject:
 Re: [PATCH v3 net-next 1/9] dlm: fix send buffer backpressure handling
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
Date: Fri, 02 Oct 2026 01:19:18 +0000
Message-ID: <179090395863.434549.3668493667259120759@kernel.org>
In-Reply-To: <20260929071743.23624-2-edumazet@kernel.org>
References: <20260929071743.23624-2-edumazet@kernel.org>
X-sashiko-severity: High
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

Thank you for your contribution! Sashiko AI review found 2 potential
issue(s) to consider.

Critical: 0 · High: 1 · Medium: 0 · Low: 1

If you believe none of the issues are legitimate, please reply to each
issue of Medium severity or higher and explain why the AI is wrong.
If any of them are legitimate and you plan to respin, please let patchwork
know by including "pw-bot: cr" as a separate line at the end of your reply
(one such reply per series is enough).

- [High] A TCP reset or TCP timeout while the connection is waiting for
  send space can stall the dlm connection permanently.
- [Low] In send_to_sock() (fs/dlm/lowcomms.c:1392-1397), the
  set_bit(SOCK_NOSPACE, &con->sock->sk->sk_socket->flags) under the…

--

dlm: fix send buffer backpressure handling

This commit changes send_to_sock() to test SOCK_NOSPACE instead of
SOCKWQ_ASYNC_NOSPACE in con->sock->flags. With that change the
CF_APP_LIMITED wait path is taken again when TCP returns -EAGAIN because
the send buffer is full. It also removes the clear_bit() of
SOCKWQ_ASYNC_NOSPACE from lowcomms_write_space(), since that bit no
longer lives in con->sock->flags.

> diff --git a/fs/dlm/lowcomms.c b/fs/dlm/lowcomms.c
> index 2aff1c7c17de4..abe9ae4c643fa 100644
> --- a/fs/dlm/lowcomms.c
> +++ b/fs/dlm/lowcomms.c

[ ... ]

> @@ -1391,7 +1389,7 @@ static int send_to_sock(struct connection *con)
>  	if (ret == -EAGAIN || ret == 0) {
>  		lock_sock(con->sock->sk);
>  		spin_lock_bh(&con->writequeue_lock);
> -		if (test_bit(SOCKWQ_ASYNC_NOSPACE, &con->sock->flags) &&
> +		if (test_bit(SOCK_NOSPACE, &con->sock->flags) &&
>  		    !test_and_set_bit(CF_APP_LIMITED, &con->flags)) {

[Severity: High]
Can a TCP reset or timeout that arrives while the connection is in this
state leave it stuck for good?

With this change, send_to_sock() sets CF_APP_LIMITED, clears
CF_SEND_PENDING and returns DLM_IO_END. After that,
lowcomms_queue_swork() will not queue swork:

fs/dlm/lowcomms.c:lowcomms_queue_swork() {
	if (!test_bit(CF_IO_STOP, &con->flags) &&
	    !test_bit(CF_APP_LIMITED, &con->flags) &&
	    !test_and_set_bit(CF_SEND_PENDING, &con->flags))
		queue_work(io_workqueue, &con->swork);
}

>From then on, only lowcomms_write_space() or close_connection() clears
CF_APP_LIMITED.

tcp_reset() and tcp_write_err() (RTO or keepalive timeout) both go
through tcp_done_with_error():

net/ipv4/tcp_input.c:tcp_done_with_error() {
    ...
	tcp_write_queue_purge(sk);
	tcp_done(sk);

	if (!sock_flag(sk, SOCK_DEAD))
		sk_error_report(sk);
}

Neither path calls sk_write_space(). tcp_done() calls sk_state_change,
but add_sock() only installs lowcomms_state_change for SCTP.

Every dlm recovery path appears to end in lowcomms_queue_swork(), which
returns early here:

lowcomms_error_report()
  dlm_midcomms_unack_msg_resend()
    dlm_lowcomms_resend_msg()
      _dlm_lowcomms_commit_msg()
        lowcomms_queue_swork()

On a receive error on the main connection, process_recv_sockets() also
only calls lowcomms_queue_swork():

		if (ret < 0) {
			if (test_bit(CF_IS_OTHERCON, &con->flags)) {
				close_connection(con, false);
			} else {
				spin_lock_bh(&con->writequeue_lock);
				lowcomms_queue_swork(con);
				spin_unlock_bh(&con->writequeue_lock);
			}

A RST does not call sk_data_ready, so the receive worker may not run at
all. New outgoing messages hit the same CF_APP_LIMITED check. If the peer
reconnects, accept_from_sock() puts the new socket on othercon because
the main connection's sock is still set.

Before this patch, the send worker kept requeueing itself with
DLM_IO_RESCHED. The next sock_sendmsg() then returned the socket error,
and process_send_sockets() called close_connection() and reconnected.

A peer RST seems realistic here. It happens when the peer's dlm closes
its socket with unread data in the receive queue, which is likely when
the peer is slow to drain. It also happens with ss -K or a middlebox RST.

If this happens, won't traffic to that node stay queued on a dead socket
until dlm_lowcomms_close() or lowcomms shutdown?

The commit message says that for SCTP, returning DLM_IO_END "would wait
for a callback that never comes". Doesn't the TCP error path have the
same problem?

Later patches in the series convert these bit operations to
sk_set_nospace()/sk_clear_nospace() and add tp->tcp_nospace. None of
them seem to change this behavior.

>  			/* Notify TCP that we're limited by the
>  			 * application window size.

[Severity: Low]
This isn't a bug, but the statement under this comment now does
nothing:

			set_bit(SOCK_NOSPACE, &con->sock->sk->sk_socket->flags);

The branch is only entered when test_bit(SOCK_NOSPACE, &con->sock->flags)
is already true. con->sock->sk->sk_socket is con->sock, so this sets a
bit that is already set.

TCP already sets it on its -EAGAIN paths (tcp_sendmsg_locked() and
sk_stream_wait_memory()). While lock_sock() is held, TCP input that could
run lowcomms_write_space() is deferred to the backlog, so nothing can
clear the bit between the test and the set.

Should the set_bit() and the "Notify TCP" comment be removed or
reworded?

The same applies later in the series, where this line becomes
sk_set_nospace(con->sock->sk).

-- 
Sashiko AI review · https://netdev-ai.bots.linux.dev/sashiko/#/patchset/20260929071743.23624-1-edumazet%40kernel.org
