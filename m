Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 0367344CF52;
	Mon,  5 Oct 2026 23:30:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791243015; cv=none; b=FhOQbiBg3sNFGlfF3pTpGhY2ZsUuorQtNprXWwoXJkVk44JitsGn5RJMY2xouYCTtkxNymtVXguLCw24a+vQMnls0vBtsiDNAPhqNLz68DHyBYAqW1tnLayyHJme2liR8G1f0boaY1mnXMA2gKKJR31T0ZZeC63CKS9emkE8OJY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791243015; c=relaxed/simple;
	bh=6XLeBHow2Pcci0n51TIHatXIIa0VAS2+TXe5xcWQ4kA=;
	h=Content-Type:MIME-Version:Subject:From:Message-Id:Date:References:
	 In-Reply-To:To:Cc; b=IQPTWsg53UeZDswppiOaXQtBBJZWVPPzDQcLFhumJQn0DJzaRcIGoKCgqsvtBBrnQD0By1DOcVkyOsR3aTMhM1Tj1kx/rZEkjJ/Jm7u0w/KgsOb9HP28lMx0uFfyWcKj/7hNcBUH5eCgmQ+FfGTPAAQerW9pYKyz9FTbhGhds/g=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=QowSKdTg; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="QowSKdTg"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 452681F000FF;
	Mon,  5 Oct 2026 23:30:13 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791243013;
	bh=SmEheTWh0J3/BQpX78BoIhroKKmwa4bnJ1PAI32f3F8=;
	h=Subject:From:Date:References:In-Reply-To:To:Cc;
	b=QowSKdTglffOCMECbjuqpAMyBjSXe0IwVe2eeCPRlbiPFr8CUDY2rnL5/c0wwX+u2
	 FK6woTdZrstoZC0cokzBWn1TFSI1m8PNX3EaxwdhSw7YKX6W/HJdK16A0vEFMupZF5
	 xygIzUXPVlc8yi1qcvJt/uri3Uzz3xNJolOxe+4VqU7nhzJbS0kPUjJaEsKvIR5EPP
	 pn3qbFkaAQI68vdXFigt/222laEsF0AJ8H0H2YMIoyMLv8jJLRzvhhbQBUnawfKlEW
	 gC0f8trnGlCXpLbQVNG8/W35ZRw1rCfB6IdkoZ9YFj5CMcD8u6ghZAZBCG/wIzu+IG
	 +KZdLHtzzZZow==
Received: from [10.30.226.235] (localhost [IPv6:::1])
	by aws-us-west-2-korg-oddjob-rhel9-1.codeaurora.org (Postfix) with ESMTP id 3A23A392667F;
	Mon,  5 Oct 2026 23:30:13 +0000 (UTC)
Content-Type: text/plain; charset="utf-8"
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Subject: Re: [PATCH v3 net-next 0/9] tcp: avoid struct socket cache line miss
 in
 tcp_check_space()
From: patchwork-bot+netdevbpf@kernel.org
Message-Id: 
 <179124301177.1937173.6611394010312791388.git-patchwork-notify@kernel.org>
Date: Mon, 05 Oct 2026 23:30:11 +0000
References: <20260929071743.23624-1-edumazet@kernel.org>
In-Reply-To: <20260929071743.23624-1-edumazet@kernel.org>
To: Eric Dumazet <edumazet@kernel.org>
Cc: davem@davemloft.net, kuba@kernel.org, pabeni@redhat.com, horms@kernel.org,
 ncardwell@google.com, kuniyu@google.com, edumazet@google.com,
 netdev@vger.kernel.org, aahringo@redhat.com, teigland@redhat.com,
 gfs2@lists.linux.dev, john.fastabend@gmail.com, jakub@cloudflare.com,
 sd@queasysnail.net, jiayuan.chen@linux.dev, matttbe@kernel.org,
 martineau@kernel.org, geliang@kernel.org, mptcp@lists.linux.dev,
 guwen@linux.alibaba.com, dust.li@linux.alibaba.com,
 alibuda@linux.alibaba.com, cel@kernel.org, jlayton@kernel.org,
 neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com, tom@talpey.com,
 trondmy@kernel.org, anna@kernel.org, linux-nfs@vger.kernel.org,
 achender@kernel.org, rds-devel@oss.oracle.com, philipp.reisner@linbit.com,
 lars.ellenberg@linbit.com, christoph.boehmwalder@linbit.com, axboe@kernel.dk,
 drbd-dev@lists.linux.dev, kbusch@kernel.org, hch@lst.de, sagi@grimberg.me,
 kch@nvidia.com, linux-nvme@lists.infradead.org, idryomov@gmail.com,
 amarkuze@redhat.com, slava@dubeyko.com, ceph-devel@vger.kernel.org

Hello:

This series was applied to netdev/net-next.git (main)
by Jakub Kicinski <kuba@kernel.org>:

On Tue, 29 Sep 2026 07:17:34 +0000 you wrote:
> tcp_check_space() is called on every incoming ACK and every transmitted
> packet, and tests SOCK_NOSPACE in sk->sk_socket->flags.  Because struct
> socket lives in its own cache line and the TCP fast paths do not touch
> it for anything else, that test pulls in an extra cache line that is
> cold when the working set of active sockets is large.
> 
> This series mirrors SOCK_NOSPACE into a new u8 field, tp->tcp_nospace,
> placed right after tp->chrono_type in the tcp_sock_write_tx cache line
> group (fitting in an existing 3-byte hole before chrono_start, so no
> other field moves and sizeof(struct tcp_sock) is unchanged).  Both the
> transmit and ACK fast paths already touch that cache line, making the
> fast-path test in tcp_check_space() free of extra cache misses while
> keeping __tcp_check_space() authoritative on SOCK_NOSPACE.
> 
> [...]

Here is the summary with links:
  - [v3,net-next,1/9] dlm: fix send buffer backpressure handling
    https://git.kernel.org/netdev/net-next/c/e234d7625598
  - [v3,net-next,2/9] net: add sk_set_nospace() and sk_clear_nospace()
    https://git.kernel.org/netdev/net-next/c/6ba48a271bdb
  - [v3,net-next,3/9] sunrpc: use sk_set_nospace() and sk_clear_nospace()
    https://git.kernel.org/netdev/net-next/c/28613c4d4757
  - [v3,net-next,4/9] rds: use sk_set_nospace()
    https://git.kernel.org/netdev/net-next/c/b747807ccaf9
  - [v3,net-next,5/9] dlm: use sk_set_nospace() and sk_clear_nospace()
    https://git.kernel.org/netdev/net-next/c/0e0be63cb35d
  - [v3,net-next,6/9] drbd: use sk_set_nospace()
    https://git.kernel.org/netdev/net-next/c/24280d1d2832
  - [v3,net-next,7/9] nvme-tcp: use sk_clear_nospace()
    https://git.kernel.org/netdev/net-next/c/f80fa2ddfe95
  - [v3,net-next,8/9] libceph: use sk_clear_nospace()
    https://git.kernel.org/netdev/net-next/c/5181ac617537
  - [v3,net-next,9/9] tcp: add tp->tcp_nospace
    https://git.kernel.org/netdev/net-next/c/4eee6d58ad14

You are awesome, thank you!
-- 
Deet-doot-dot, I am a bot.
https://korg.docs.kernel.org/patchwork/pwbot.html


