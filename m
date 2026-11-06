Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793974910;
	b=OYDpFEnvGYh59bWz5lzDnO5QqPrdBM9mvzT+tQQixEz1oycxhF+oG2ra5PaqO/gURfmS
	 lJnD3G/i2MYmobOe18FtyeMR/1TtdK/5SPd7tR1lgvAvuj10bZfNA1U9ZJZsDN1Cbs357
	 5OX3qVIz1/RzY5X81LtaX9qJacPCgphv7LwBOQBD95QhaDe7iX0/vFR6kn9SMmbY8honS
	 xfjjLJT51WHDdi6klq2x4v65ObMFwGqbDPh/LuwmpgEY1sfEtimpUW0D+ao5lyHAsvMaV
	 jVlII+xaAcjD2xbLzNSP1pRDFAcwC1m7HWn/+vA0BTuoww95n1Co80YD24O6duUadnw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793974910;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=Qxmf++OdXmvNQjqneVICiQMhLuKJZ5A4y7qik8rj9LM=;
	b=Ldommn3NwyV1fe4As1+Hi+LaWxFi0JxQkqPS3M7VT8CgpLsoIpKi9zDLlNZsYbYYy3QF
	 dgBsy5+6W2pSyk6Fq3vQzls/hXX4hGZgyMdK8i7mtpYLR5ueVvBW4AQB9H9y7vHlA4bep
	 SdqfcE+Wi+389ybwr8v6FTUsU3Cdb0svrnuQLaGq+TcG0KBVCoG6BW3cKjtPEtULnr0rP
	 htd6dSPHL76MYTaedoJ2CPRpfJsPWRL84LN+zOP2T+188y1m0UFu/pqka6/BNM/U+eeV3
	 Rik7GE5hmkpB9MP4lT1hjEebAwFlIBTXpgdeIgRhBnLYxdcdZRe/R7XYSzRgCsNGX8Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YqGHO8SW;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 247C8606A329
	for <linux-nfs@vger.kernel.org>; Fri,  6 Nov 2026 14:21:50 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=YqGHO8SW
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C6791F0089F;
	Fri,  6 Nov 2026 14:21:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793974909;
	bh=Qxmf++OdXmvNQjqneVICiQMhLuKJZ5A4y7qik8rj9LM=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=YqGHO8SWu091Ub4+rgIBUOs8cWBchcrwC5QfMN857vJ9NFt5+MGk2vdTY6aCkoQ5T
	 YygPEj2B6ZP8IkpQIj/jdECMyzDjWsCaGFies0Cf6KVBzFM17ZfE5H7ntoHHZyKFzd
	 2XLiv7aM8QeFddMy4FbZxnZupjX7HCFgOLE9xwl2P/8762T3TqG2mlIdxn2eUc4+k2
	 ngOq6a4dAk1roN57dQy3c7yj7EuerMbeiivm3LrXiXcWBzEicC4u7E/t8LYswZshkI
	 ykFuwpohKsprIfGGCw3wWmh/+yBhFM0AJexbIpaB6E5LRoK3zYAMLUDu9hSVNYw4Rq
	 sdT823/Rn2uug==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C0F75F40066;
	Fri,  6 Nov 2026 09:21:48 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 06 Nov 2026 09:21:48 -0500
X-ME-Sender: <xms:fOLtatsKfokU5KJkkWd-39gRGRb7k52IKscKDPfPT-xuParxfB_Dsg>
    <xme:fOLtahQ13o993YBky7UwnDkzM2hCK0qylt1lWGQmIOdCHKrxM7fvIuopSzuACF2xz
    f43lmUWRHz-F1fWKLrMn1PNMidHYAD0Ijcu8PcOkhMxx54FAkH7lJU>
X-ME-Proxy-Cause: dmFkZTGb/nsXTrLbFf6NLkl4yzWUKasKf1vr/SxNKlfICOIyS4FfdI/SZtcFuJ1njZvNR/
    8XZxNGP8KhZASLsh1/+E4MZHUdelII678Nfg15/ktIau/mrQTXJ4XxcnaA6DuSvihEoxAF
    hijPsrJ/YpmaBTjVIGDx5jGYg3F+0l1dcFXDtMc/+9IQ6QB/WDtzl4egxbv/f0kDbhisxD
    B9glY/Ffo8D6K/DcpKd+gn7q/jdTq/PLM0Kfk+tNd2FcUW4pFXsZrPQqUaGWd0RnUY4Nwt
    FmCFAVZcMnuTTKmBJafbeV5LtE/5CIvBPYhXGkSQ1x/zvoCvsERJEWhgRWt4sGScRqpHfc
    W5LUWGBCMDPVD/5D2NpvFQrVWEFbWvHIhv4L9H1C7+SR2O7a/G+KaZh0gC/MGkWLcQr5Co
    l9ZU3OoJTqYvdV3MAoPo+ht2tTyTgh3nqYbJwvXX294K6YUKcGSItC7f5gC3HfqkpZzD1u
    k5VWi2ZcwpbVkcwuWPHZE6xcgMDXRsgjsI3S5ryO3vYTeLZ5S/Be+eZVYCdJW7BiIKcppz
    rvkxfLiF38/3RkZxR30CShy7KqHB/WxqTpG3+YlPgx1Dpf+wtq6WkI9ZqjHZlK/lK4pi5m
    qMvIftuxWLBwT+MjM+y0zHzklH4+Ze7WhH4XbICqhEimC7Wp7AISGti/AQoQ
X-ME-Proxy: <xmx:fOLtakEIDkvTAdGscgsNKfCWtqFUVxTZb0jXK7sGSqFgjrcLRQKE4A>
    <xmx:fOLtale7TrUD-y4BERRtaHBkawKSrLmvydKXYkIghnAI9RIrDaoUQA>
    <xmx:fOLtatr7ot5VWOKFR05-t8UaNEv6_SMvH9WOQqTxDJG82Dq9QSqs4w>
    <xmx:fOLtamCWDcUgGoOuyHLLKkFo5HHz37amnFGY5WQGGl_0obXF6RANTg>
    <xmx:fOLtamdoU3k4Q8rdOMh8vg7bgKsyL66HIQWJrvKY6TbdFmNlNBkJJpWY>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 9F057782738; Fri,  6 Nov 2026 09:21:48 -0500 (EST)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AqskSCTaNkUk
Date: Fri, 06 Nov 2026 09:21:28 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>
Cc: dai.ngo@oracle.com, jlayton@kernel.org, neil@brown.name,
 okorniev@redhat.com, tom@talpey.com, anna@kernel.org, jgg@ziepe.ca,
 leon@kernel.org, linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 trondmy@kernel.org
Message-Id: <7e3bbd89-b01f-43b8-9ce7-b549e949b0f4@slotpi15m67>
In-Reply-To: <20261008225450.664642-1-Louis.Kaplan@arm.com>
References: <59261d53-53fc-4195-a7f4-d9f117bb0150@app.fastmail.com>
 <20261008225450.664642-1-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 3/6] svcrdma: Coalesce contiguous pages when mapping replies
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Thu, Oct 8, 2026, at 6:54 PM, J Louis Kaplan wrote:
> Glad to hear that. I'm happy to split out smaller parts of work from
> this patch series if helpful.

I have a soon-to-be posted series that converts svcrdma to send and
receive through the bio_vec array in rqstp->rq_bvec, and it rewrites
the code your patches touch. A companion series does the same
conversion for svcsock and has to be posted first, because the two
series share helpers in net/sunrpc.

As I alluded to before, our long-term goal for the transport code is
to replace the use of the xdr_buf.pages array with an array of
pointers to biovecs. The goal is to replace struct page pointers
as the common coin in the NFS stack from filesystem to network layer.
The refactor will continue to represent only one page with a biovec.

I think you should be able to continue your focused improvements to
svcrdma on top of this work.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
