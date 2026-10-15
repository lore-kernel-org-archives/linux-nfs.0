Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1FCA30E0EE
	for <linux-nfs@vger.kernel.org>; Thu, 15 Oct 2026 18:30:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792089028; cv=none; b=akfdP3W4XWwiR56L5dpH+OD1R8xm1P289J0O7N+tTpbZdNWyI+5o/m1HMpxzns0R+VGici8Vm/tmJig1O9RmGesZeK/Xxl8206b39hg/yVkZTalOpP4Is72cW8HlKamfnAviTi8zYbWzKXhooyoR75H2caWQnucPmWM/oqZnYxQ=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792089028; c=relaxed/simple;
	bh=3n63+mZEYnTl/Mw5t3lSEbJBvZxUH2MTWG5Qrlz6do0=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=fDm++7iLpHiNaIzV8cUiHzIsPMC2+p24ZmMmJijwYUJrHPAsDNZo+x00UkyPqgXcnByf5tHltdKLdcM7gsS9XK4Q6OrQMUQbXjIcQT7V006dcKPTvT13m/8Rc41s2llQoRKSv2inzTfpxUb/U/j/r5J1947mQCf5jDw1mDXVHEE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dXhBugc7; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dXhBugc7"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F3AC61F000C4;
	Thu, 15 Oct 2026 18:30:21 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792089022;
	bh=kMk9HeC0gdwWXCsH6P2NJQOl/jdcrGwW4AYDreY7rhk=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=dXhBugc7RI2d2GtQlTlZfN2ZAzUu3ipXbUVSDtSHDzAfKanYTpgPQB9GYW0rbFw1o
	 U0ljajpRTEfM3+iVSP3fV5eCc9BcrcGt4wW1gMPRqrW9fObdI2CSEezUIKUblDZuYg
	 8WvDY2rtLPIyBxOJZMliK9vRlbssJ7SAiAWXFjZ44+3kZOVDqHHPCmJpR2B6F9Zq7n
	 U6Z0Mq8NGVV1GPSYb/QBKrm5JPz80zbR2O2MoyfxpnMuiCXqZCSe+A+vBB3j1xJD8t
	 nKrxNwKeXQqeaPVcBi+qNocBpf+8IApqwuRgCRqdAsVhwSFFRsQmly+bOayNWQ2Z4o
	 CUUk/H6VIzfnw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 595D6F40068;
	Thu, 15 Oct 2026 14:30:21 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 15 Oct 2026 14:30:21 -0400
X-ME-Sender: <xms:vRvRalSkR27Z3KIUE2bhnCfGP-n5ZRvrWnH52MMqynlz2rNWeNQ4uA>
    <xme:vRvRaplDI4NETiQ4zTPkBfAFBI7LdwB-Vk6AyzTu8LczkkemR9ho4VFyQdDoJrL1q
    C4J8GUZfZb7C9YVT7zIy-3owtw-Soms_YDeIqbtTOCG-9L8y0VykA>
X-ME-Proxy-Cause: dmFkZTFGCXUpm5Xr62M/7C4QIwj/D+XUT6kXD4XVd4K4EBujtfTkFqUfpaGtiVln76l7Md
    kpuiJwSppkkLsRtYwXf5eEEbD3Awn/5A+elMPnceijz4MfgDsaaMpNuM6oFnIjs5IhiS4C
    3+kKuGZwuq5Sazw3OIH/hlPqo7Jxjf3gkkPaLnMW/F1wjzvu0UJ9A/UygxP3d40Cf3DO56
    gMsNNDVGlEsqGjxzLTJzxgX0zhC+c8MHsyDlyx8VGRViL6icM8qeNXP/iYkecAVCH/AG66
    iGDq2bjqxI/uzbzxKWlH5alRfbVDKFLGYwpJPKAvELmw9mRrjaqwF1jLkz8LPRm7DcggPa
    MmxbO/AZaKkFsM/pfmBJjihbrmZ4PgLO/So1VS/BW9azehKYQMAxPl802fAfMNK8C0bT81
    CodzA0I8p9ke8MMseHUACNcx6vyn7JsC21Wdk1NFVOMaSOtgGWmgwqHuEIYAtv1wQJZoPQ
    ghS8o+COPjN9Bqf5W2hbw2ve/bM42MhYhyA9WK4ZUi/JaMONxDR8UInfhK6kn8p9ZDkflh
    gVfsD7Y4qc6h8KzX1/w+WEDAEsUtKcZ9lthdVxobNdJMVwsQt2tDoyHUk/4Chq/D329C4k
    pHTcEN8JRyF+xwvjCG61qHYi8HVFwF69R37zZqspUABMckJ0ZhXHFo9l09Ow
X-ME-Proxy: <xmx:vRvRav4WzG3TBqImmZNuV74w05onCO6knkvgVLHpeSDhgVRSqD1_PQ>
    <xmx:vRvRagtp50-lys6cwUx5Bi9Qf3m8DkZpziJ5WCN20li7VWS3zOuCKg>
    <xmx:vRvRah3VXBYzbooyPeV92zRtYQUtO4L9Jd23Uo1yFREF3vaHE0146A>
    <xmx:vRvRapoIabwH279qot2ZcJCthaczTyH7LHjvz1bzAdX9jPyO8OUDsA>
    <xmx:vRvRahKc9Vb7xLlljTwr9j23nqE3dyLMplNhBlla7OzHmT7zht71WGY3>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 2A0AA782738; Thu, 15 Oct 2026 14:30:21 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AmqPMHVnhD9w
Date: Thu, 15 Oct 2026 14:30:01 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Andrei-Alexandru Bleortu" <me@andrei-z.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-kernel@vger.kernel.org,
 linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org
Message-Id: <ddd5a532-bdb2-4976-9b1b-6470414473ec@app.fastmail.com>
In-Reply-To: <20261015124826.2962950-2-me@andrei-z.com>
References: <20261015124826.2962950-1-me@andrei-z.com>
 <20261015124826.2962950-2-me@andrei-z.com>
Subject: Re: [PATCH 1/1] xprtrdma: Post small RPC Calls inline
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Oct 15, 2026, at 8:48 AM, Andrei-Alexandru Bleortu wrote:
> rpcrdma_ep_create() asks for no inline data, so every RPC Call is
> posted by reference. Before the HCA can transmit a Call it has to
> DMA-read the transport header and the RPC message from host memory,
> and for a small Call that read is on the latency path of every RPC.
>
> Ask for 256 bytes of inline data per Send WR when creating the QP. If
> the device refuses, ask for less. Intel irdma has a fixed limit of 216,
> 101 or 48 bytes, depending on the generation, and Alibaba erdma one of
> 96. On those devices, found by vendor ID, try these limits first, then
> step down 16 bytes at a time to none. libfabric's verbs provider also
> probes the inline limit by trial QP creation.
>
> Post a Call with IB_SEND_INLINE when its SGEs cover only the
> persistently mapped transport header and head buffers and it fits in the
> granted size. Calls with page or tail SGEs, and larger Calls, are posted
> by reference as before. IB_SEND_INLINE is unrelated to the RPC-over-RDMA
> inline threshold.
>
> Providers copy inline data from sg_list[].addr as a kernel virtual
> address, so on the inline path the SGEs point at the regbufs' virtual
> addresses. These SGEs are rebuilt for every Send and are not used for
> unmapping: rpcrdma_sendctx_dma_unmap() starts at the third SGE, and the
> regbufs stay mapped.
>
> fio ran 4 KiB direct I/O at queue depth 1 on an NFSv3 mount of a tmpfs
> export, between two Xeon Platinum 8360Y hosts with ConnectX-6 Dx over
> RoCEv2 at 100 Gb/s on a 7.0 kernel. An earlier version of this patch
> lowered the mean completion latency of random writes by 0.1923 us
> (95% CI 0.1139-0.2769) and of random reads by 0.2705 us (0.1908-0.3502).
> That version made the same check in frwr_send() and asked for 512
> bytes. The largest Call in those runs was 216 bytes.

These mean completion latency gains are noise compared to the client's
own RPC tasking machinery. Perhaps the additional code complexity is
not worth it yet.


> Assisted-by: LLM
> Signed-off-by: Andrei-Alexandru Bleortu <me@andrei-z.com>

> diff --git a/net/sunrpc/xprtrdma/verbs.c b/net/sunrpc/xprtrdma/verbs.c
> index 54957295a631..2e8a7fb6b1a6 100644
> --- a/net/sunrpc/xprtrdma/verbs.c
> +++ b/net/sunrpc/xprtrdma/verbs.c
> @@ -55,6 +55,7 @@
>  #include <linux/sunrpc/addr.h>
>  #include <linux/sunrpc/svc_rdma.h>
>  #include <linux/log2.h>
> +#include <linux/pci_ids.h>
> 
>  #include <asm/barrier.h>
> 
> @@ -63,6 +64,44 @@
>  #include "xprt_rdma.h"
>  #include <trace/events/rpcrdma.h>
> 
> +/* Bytes of inline data (IB_SEND_INLINE) to ask for on each Send WR.
> + * This is unrelated to the RPC-over-RDMA inline threshold.
> + */
> +#define RPCRDMA_WQE_INLINE_SIZE	(256)
> +#define RPCRDMA_WQE_INLINE_STEP	(16)
> +
> +/* The verbs API cannot report a device's inline data limit. Some
> + * drivers have a fixed one: Intel irdma 216, 101 or 48 depending on
> + * the generation, Alibaba erdma 96.

The table itself already states this, so the above comment does not
add value.


>                                       Try those first, by vendor ID,
> + * then step down RPCRDMA_WQE_INLINE_STEP bytes at a time to zero.
> + * libfabric's verbs provider also probes the limit
> + * (vrb_find_max_inline()).
> + */
> +static const struct {
> +	u32	vendor_id;
> +	u32	max_inline;
> +} rpcrdma_inline_limits[] = {
> +	{ PCI_VENDOR_ID_INTEL, 216 },
> +	{ PCI_VENDOR_ID_INTEL, 101 },
> +	{ PCI_VENDOR_ID_INTEL, 48 },
> +	{ PCI_VENDOR_ID_ALIBABA, 96 },
> +};

General policy is not to put device-specific details like this
in ULP code. So, NACK on holding these numbers in a table in
the rpcrdma.ko module.

I didn't look at the other ULPs you modified, but I expect that
they have a similar need to obtain this value. That suggests you
should first add a helper function to the IB core, or provide
the value in the qp attrs.

The retry-based approach means a connect can take over a dozen
QP creation retries on a device that does not support
IB_SEND_INLINE. To avoid the retry, you might consider adding a
new QP creation flag, say IB_QP_CREATE_INLINE_CLAMP, that changes
one rule of ib_create_qp(): with the flag set, a driver that
cannot grant the requested cap.max_inline_data grants the largest
value this QP can support instead of failing with -EINVAL, and
reports it back in cap.max_inline_data as it already does for
the rounded-up value. Zero is a legal answer, which is what mlx4,
pvrdma and rdmavt already return for kernel QPs.

The smaller sizes these devices provide are barely larger than
the RPC/RDMA transport header. It might be best to set a lower
bound (don't use inline at all for devices with inline limits
that can't cover the RPC/RDMA and RPC headers).

Also, at least for mlx5, the inline limit trades directly
against send queue depth and the QP's host memory footprint.

TL;DR: I'm not convinced adding several dozen lines of code
pays for a tenth of a microsecond latency improvement.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
