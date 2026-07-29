Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id AD70521ABBB;
	Wed, 29 Jul 2026 01:51:25 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785289886; cv=none; b=nxnEfO6QIOWwY0XB2z+OLWAZqVf36qkjkKME0oGw4uM3Sg41ehQg4BazTYUjFCpMPQWvGG/EEwadjnMBrt9TZnZAkf9VzcJSE26UZ67muDxdcBXtdDXhkG3k+xHIctLhqFADzzsjq1LIw/mZon1NILQj8AoxJyZnC0qlrRYz1uI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785289886; c=relaxed/simple;
	bh=+ngre8Z7Q3YijsOP6c8GtjqJptyQuR4YF1gczo2POvQ=;
	h=Date:From:To:Cc:Subject:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=U3xXNsx9sUz1AD7AnX9qzxiF/nRYUkfjdMHmVYsw9P+lyyIU26dSuR6J3XDW2aTD0R6FQQj7sspDPF0xjtMcVamsg4iudox1Hr2hNQiI2CtUJAUVOYJ4L3oudREcVprFASsZYBlvnfIpOnCBNHfYWqxJBJyYaOJsyGd/d6IRsNg=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DQONj25G; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DQONj25G"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id EA4941F000E9;
	Wed, 29 Jul 2026 01:51:24 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1785289885;
	bh=1TJYuTYBiuO3YSugJHOoO5oaqOy8MPAmWaUUvzVcQ7I=;
	h=Date:From:To:Cc:Subject:In-Reply-To:References;
	b=DQONj25GV2Wey00JUX09cfrEycAJ1lFsqrWwUFyfXrPji39f8GNuG7mP57xCDyQ75
	 2KPSYDGgXRZn+E2VGVH7qiBgGQUV+0FCJec4fXyVo79F/XfXJ6NGr53z9vLQ1lg7sl
	 bxWcuvowqyHwWFhnm6AuRa3YiuHt23Nbsel/zxAESH3QzOkR01t3dPQr5rnyGwJlQQ
	 Xk8PFMM8M7kkpxnGHVfgWu0kKFpwwzpNw6sA0TlgEEEXZkf2nuRxaTmyKcf1ycJLHe
	 nsxunE4vF2VGI8RZlLBjVfC/69/GTmffGD2gER1U4+JIu95m/2r1gyoTiE8U7xU4rW
	 0RWJFICoiBhzg==
Date: Tue, 28 Jul 2026 18:51:24 -0700
From: Jakub Kicinski <kuba@kernel.org>
To: Chuck Lever <cel@kernel.org>
Cc: Paolo Abeni <pabeni@redhat.com>, Simon Horman <horms@kernel.org>, John
 Fastabend <john.fastabend@gmail.com>, Sabrina Dubroca <sd@queasysnail.net>,
 Shuah Khan <shuah@kernel.org>, Jeff Layton <jlayton@kernel.org>, NeilBrown
 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>, netdev@vger.kernel.org,
 kernel-tls-handshake@lists.linux.dev, linux-kselftest@vger.kernel.org,
 linux-nfs@vger.kernel.org
Subject: Re: [PATCH net-next v2 2/6] net: Introduce read_sock_rectype
 proto_ops for control record delivery
Message-ID: <20260728185124.72e421c8@kernel.org>
In-Reply-To: <20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
References: <20260720-tcp-read-sock-v2-0-29545d034f3c@kernel.org>
	<20260720-tcp-read-sock-v2-2-29545d034f3c@kernel.org>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Mon, 20 Jul 2026 10:27:56 -0400 Chuck Lever wrote:
> Kernel TCP consumers that use the read_sock interface
> (proto_ops.read_sock) cannot receive TLS control messages (Alerts,
> Handshake records) when kTLS is active. The current
> tls_sw_read_sock() method rejects non-data records with -EINVAL, and
> the sk_read_actor_t callback has no channel for delivering record-
> type metadata.
> 
> Four kernel subsystems are affected: NFSD (sunrpc svcsock), NFS
> client (sunrpc xprtsock), NVMe target (nvmet-tcp), and NVMe host
> (nvme-tcp). Each of these either falls back to the sock_recvmsg()
> API or lacks TLS alert handling entirely.
> 
> A new read_sock_rectype method in struct proto_ops provides a
> separate code path that delivers non-data TLS records to a callback,
> without changing the behavior seen by existing read_sock consumers.
> 
> The new sk_read_rectype_actor_t callback type extends the
> sk_read_actor_t signature with a rectype parameter carrying the
> protocol-layer record type (for example, TLS_RECORD_TYPE_ALERT). The
> record-type callback returns 0 to consume a record or a negative
> value to requeue it and stop delivery; unlike the data callback, its
> return value does not count bytes.

To me this is an ugly one-off workaround that doesn't fit into 
the proto_ops (only TLS will use it). And you seem to net out
to the same LOC on SUNRPC side with and without this?

There needs to be a very strong reason for us to add APIs for
in kernel consumers.
