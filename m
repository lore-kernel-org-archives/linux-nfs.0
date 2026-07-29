Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83F82261B8D;
	Wed, 29 Jul 2026 01:47:13 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785289634; cv=none; b=p9NGYfY0/korba398wJ/TqBBFD/LcAmpLqDdQ1HZ3m14xJptXI0Csj24lngl3ixQzuJE88QI6bmMfX4Fx9GRlZdXronx4Q9fdGFoasGGR4bZp6KbUh2BtwtDTttAhW8z/6/xpXKZQh1EUsJ1Nrd2/U3GjBBTp08KAbJ+WBbV31c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785289634; c=relaxed/simple;
	bh=c0YNd4IZUBkYF9akZWEfpi0Z/dqK2k8TKJlAyFGgE9Q=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=iwyelAzpUZDBoZ9YyNugdAn9OEfdLhBfoZie5FAElhcJtzy6gWWQ3DfrUTzB54HJXO44f4z8SzSPk8VDHiy6eJwL5VMgnzCj/Lc5KXvVJR94icywV6jI8p92WYbb8Xmn5mlkP81xbbVWgmBov2OE7BPj2zU93VmC21nivSJTlmU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BocqlgQW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BocqlgQW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F0A471F000E9;
	Wed, 29 Jul 2026 01:47:12 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785289633;
	bh=FZ9bLhEfXbtuqJs939McUYwR4v0HFoiHTRDeayXY/nQ=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=BocqlgQW4YhNWOGbFwHJF42wBOQU+PBshUUx55RZwGTLZN4veGcN6ryLjnWrZEOIl
	 33aPmdsg8taW5lK1g6AiR6sZRj2G1toL0EtVSfYHRO63UG1Wc9mhraBwk5cW51jnSA
	 50eSjjM0HzyrSz6mPxCQqBdCjmLdYNQAygJWOlUt4zSTOC7+BCMWPcJ8WbYZeVpjvb
	 82ApdL1QRIPT0dhGSRFoXmvI+Ebuw3pbqXhbtv7DicWvazYlZXXRgIbJrElXTnJGEU
	 EO+FEM+PnH2PZLOme3SaEq5BkCCJZKZ17i7rbScAaV1a/Sy20QEMCQ9akCAHnSqWoW
	 2UFcdMyWJDojQ==
Date: Tue, 28 Jul 2026 18:47:12 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, John
 Fastabend <john.fastabend@gmail.com>, Sabrina Dubroca <sd@queasysnail.net>,
 Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 1/6] net/tls: Bound consecutive no-data
 records in tls_sw_read_sock()
Message-ID: <20260728184712.09cc50f4@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-1-29545d034f3c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 20 Jul 2026 10:27:55 -0400 Chuck Lever wrote:
> A record that delivers no payload -- an empty TLS 1.3 data record
> today, a control record once read_sock_rectype() lands -- leaves
> tls_sw_read_sock() in its loop without advancing the caller's read
> descriptor. A peer that streams such records keeps the receive loop
> running, and the socket lock held, for as long as the records
> arrive.
> 
> Cap the number of consecutive no-data records consumed per call. The
> count resets on any record that delivers bytes, so a normal stream
> is unaffected; a peer supplying only empty records is bounded to
> TLS_RX_NODATA_LIMIT iterations before the call returns 0. read_sock
> consumers treat that as "no progress, re-poll" rather than EOF, so
> the connection stays up and makes progress once real data arrives.
> 
> Only tls_sw_read_sock() needs this cap. Its consumers drive the receive
> loop from kernel context -- a work item or service thread holding the
> socket lock across the whole call with no return to userspace -- so an
> unbounded empty-record stream keeps that context and the lock pinned
> for as long as the flood lasts. The cap supplies the return boundary
> that a system call would otherwise provide. tls_sw_splice_read()
> and tls_sw_recvmsg() already have one: they run in the calling task's
> context, reschedule while draining the socket backlog (cond_resched()
> in __release_sock()), and drop the socket lock when the call returns. A
> flood there costs the caller only its own scheduler time, so the cap
> would add nothing.

Is this alluding to PREEMPT_NONE (which for practical purposes is 
no longer a thing AFAIU)?
