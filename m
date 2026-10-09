Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C1BA344F544;
	Fri,  9 Oct 2026 19:41:08 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791574876; cv=none; b=WWWlY4vVq2x8DAMiXe6XYoRNo4j91tHH7iDuqmlswS45g5CrjfHbfKCeamJe2vGfrNtHmz7e0gonf6GevhTrc8AaN8cmHPLHwd7iFxwsecGOHwDbV4QnNCIgWeL3CmxaFH8P8razRFLk7eApV/hNdaRyjOyuRcz7QdZ7KiE94FI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791574876; c=relaxed/simple;
	bh=qE7MTt4BGcpRKDSoy2OHuGGL4066Bjr5wE12UIwf/nE=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=KS+vzD5rTuecha5nubaBTlLJMHM2iY1WeHtc/dECLbjKurT8H5A1WFn8snsKHBxiloOLPStu4IgNQTFqnx/QPqcb5m0KGHm9yHJxpXxnUwHXF9G9o9KVzwBXOA/VAz8YZ6e4Orly5nzF0Dqe62K9oxbaQuCz/xM0XcGFGuI1mOo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=ePuKnpRi; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="ePuKnpRi"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8EEE91F00898;
	Fri,  9 Oct 2026 19:41:07 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791574867;
	bh=0+HxdfpCd0lGOL923ZgNNScB6cTLzMhRAVhXSQOhDp4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=ePuKnpRiUiEPUNtRZbZNduCO+pLQ7HKZmX5wkQMMrA7tV/3zgW8/tYGnFM9xDvPtp
	 tjkqeoIoanPl1EGilMYxN6iXUQx5F21HgHuKOO1w+qREnYRRuKJRRKrkl31qWN/BRq
	 P4VJeGDJjilhh9AiQC4NOeWOC4GDr3KuXeYPO25qJfS5Yg3b3un3YYNG4fVMHBSPjg
	 zD4zRcV06yR1ey+HXzZW0Iaj+jWd9ZtpvSQ8ZvKyaCkqnDN3pSlkzEUidoC9FGttlH
	 z6DvVGS87Pf3jzRTpeTKpwT0gYhRj18GJ7vBUAnp8ZlrrjWzs/Y4DFNtedvk93OfKL
	 bfSDhKs5ZCeXw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E8B1DF40066;
	Fri,  9 Oct 2026 15:41:06 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Fri, 09 Oct 2026 15:41:06 -0400
X-ME-Sender: <xms:UkPJamwNxJGQbsJBEubJSZSZk_REJEtxKqwSp0mX9Hj6Rq4k-BqW5A>
    <xme:UkPJatGSpxdzc3m3SXIsJhJ5Tb1VADTrWYMCWQ9djEdFBeHHayJsm0H_9R7iQQDQb
    RbHDptH5VVKPpIHnEZBOxLlISMEKDQVcJL3pOZvF2t0DTSNyuuFfwOs>
X-ME-Proxy-Cause: dmFkZTGSiTPAtGOtyP1wIURv6n+bh2o/hREy6sGtp6Q2MkIB9VDo2FvGtsNYUa3zd3f6pV
    L12EIJzrM37cbua8bXoardeuVbn14dedg0NSt1KLN/Nz+SVLyn3Kcil3TRVuZiuveTEIrI
    +5vVN7Clsjvuxlr0cwe36kT7+mihnjpUpy7CxnvkdU3sAWJ5im3IZ3SRkmT8900xwEQWsE
    zobBoNDy3jCmeeGi3j3V3f36y1vCvIa42zd8AboJweM/WWdN/MLpm82sK9kqHYK/zqT9cl
    XAGR/bFmKJ/9lZc5HZdlGM3hSsOj04Xgpvj6asdeof98rBUXAplKQysnrRdkp5wy9urAF7
    1mbzTnKRGMpDEdrKQXilDxUGYMX0z0WKLzlxFy0LeFEaFcbCz8MNhjxcz8hEp6RZj4Lql8
    Uj32/R8uyeKlnvgSFdPPr6jnQTET9YSXCMt9E+QgVrApS3urSqEuzYvCRnNb2L6tx0GESD
    dVKgfK970SKdetubrKv/8ufHY/ucbU2X9tJEmUkwHlLL8987HdBGy+hdJA+S2tHw7kuCNb
    dWv2aTE8qMD77JdiVx4/SYKvQl/+RdSHw3WTNnO+NsafGTQBs3ys1DnwmPWjCZ0vg96pLD
    GIODp8rHkF51Ikd7/MEt8hebDeKlvEbYbQRyS9deegxcvbbAIEwfKi3+0wrQ
X-ME-Proxy: <xmx:UkPJaiDRrW77RKgkjcocOmRcgYndEmoeW_QMfooSowjkbSUh1Z1Nbg>
    <xmx:UkPJajBq0jiyZSYhfEY-1Kap_o2mkg1TfqAR8CR0QjEc20BS8Mezzg>
    <xmx:UkPJajlhKFqzuho95n-IcFpoLhrK_csCP1CvhIwrY3lzOklNF1kNbA>
    <xmx:UkPJajjnwMZRrE-pT9i-yUB1VEITmeNxOmSGdD7t-BvZI2EUE10hsg>
    <xmx:UkPJatilbCEJzhvQ8oezqstFbaxGPoGyRKKsNwB5N56sd4a-HxcG91IT>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C4A39780070; Fri,  9 Oct 2026 15:41:06 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A2C7vSpxgoAN
Date: Fri, 09 Oct 2026 15:40:46 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: "Olga Kornievskaia" <okorniev@redhat.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>,
 "Yongjian Mu" <ymu@everpuredata.com>, stable@vger.kernel.org
Message-Id: <e62ff502-be18-454e-8a64-80b366d477f4@app.fastmail.com>
In-Reply-To: <20261009181554.2280374-1-tmenninger@everpuredata.com>
References: <20261009181554.2280374-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH] xprtrdma: trim head iovec when the payload arrives via a Write
 chunk
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Oct 9, 2026, at 2:15 PM, Tim Menninger wrote:
> From: Yongjian Mu <ymu@everpuredata.com>
>
> The upper layer sets rq_rcv_buf.head[0].iov_len from its estimate of the
> reply header size. For RPCSEC_GSS that estimate includes
> auth->au_ralign, which gss_create_new() initializes to GSS_VERF_SLACK >>
> 2 (25 XDR words, or 100 bytes) and which is corrected to the real
> verifier size only after the first reply on that rpc_auth has been
> unwrapped. In this case, the krb5 MIC verifier is 36 bytes, so every
> request encoded before the first reply completes has a head that is 64
> bytes too long.
>
> On TCP this is harmless: xdr_realign_pages() moves the excess head
> bytes, which are genuine reply data, into the page list. With
> RPC-over-RDMA and a Write chunk (sec=krb5, i.e. RPC_GSS_SVC_NONE, where
> DDP is allowed), the payload has already been placed directly into the
> page list, and the receive buffer holds only the inline part of the
> reply. rpcrdma_inline_fixup() clamps its local copy of the head length
> to the inline length but leaves head.iov_len untouched, so
> xdr_realign_pages() still sees iov_len > cur and shifts whatever lies
> past the inline reply in the receive buffer into the front of the
> directly-placed payload:
>
>   rpc_xdr_recvfrom:  head=[...,196] page=524288 tail=[...,64]
>   rpc_xdr_alignment: nfsv4 READ offset=132 copied=64
>
> The first 64 bytes returned by each such READ are incorrect (zeroed, or
> shifted right by 64 bytes depending on the kernel's xdr_shrink_bufhead()
> implementation). This is readily hit with pNFS flexfiles over RDMA and
> sec=krb5: the per-DS rpc_clnt gets a fresh rpc_auth whose first RPC is a
> large READ. Reads following the first completed reply return the
> expected data.
>
> Commit cb0ae1fbb2f5 ("xprtrdma: Do not update {head, tail}.iov_len in
> rpcrdma_inline_fixup()") removed the head-length correction while fixing
> the handling of pure-inline krb5p replies.
>
> When a Write chunk conveyed the payload, trim head.iov_len (in both
> rq_rcv_buf and rq_private_buf, which call_decode() expects to match) to
> the inline length actually received so that the XDR layer does not
> realign the page list. Pure inline replies and Reply chunk replies are
> unchanged.

pNFS flexfiles exposes this issue because a per-DS rpc_clnt gets a fresh
rpc_auth, and its first RPC can be a large READ.

On the MDS mount (and on non-pNFS mounts) the first GSS reply is a small
non-DDP operation. The RPC client corrects the auth slack value before
any READ can occur.

Reviewed-by: Chuck Lever <cel@kernel.org>

Nit: The kernel-doc still says the upper layer's per-component maximums
live in head.iov_len and buflen, implying the transport leaves them alone.
That rule was set by commit cb0ae1fbb2f5.

But the inline fixup function now lowers both in rq_rcv_buf and
rq_private_buf when a Write chunk is present. The commit message should
mention that, and/or the kdoc should explain why Write chunks are a safe
exception to that rule.

Anna/Trond, does the NFS client or XDR code rely on the reply-side kvec
lengths staying as set during send preparation, or might there be an
in-tree reader of head[0].iov_len on the post-receive path that I missed?


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
