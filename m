Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 977393B6C09
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 13:47:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791294468; cv=none; b=tTz5FjTqwrK09u74qrCjUr7HDCG8PsHO2KiSZTmxISE/5O2FttExWb434p/gDN+/55/6OFm/xu5A8DyFBQkY6j9nxIIL8PVyb3f8IXGwvn+kMsaKtXamfa7tya7FVIKmk1Ows06K2JgGm8YfmwREA3Al6oXg/UwB0yB+zwi4KI4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791294468; c=relaxed/simple;
	bh=MxyGa2i0GFPM1T2Ny30asuy+UCUNkZHMxNy6WfbG/GY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kw0/MWZ5I1xlgcTcEPWaA5IZzJ3kfEcMhw0nhjIakPp+q5vGjg2xdS/PDKUXoF5qD7iWRGepA8gHVmhCuJFHUZWRUuttEi6Ni6eGfLgFLofiFhlJG1dB6Fp5tMhs2Otk5FhbpvtIpPpf01ps0gd2DxTRzLU8ym3/0BejIxiPOD0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=TlXEotUy; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="TlXEotUy"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id F01311F000FF
	for <linux-nfs@vger.kernel.org>; Tue,  6 Oct 2026 13:47:46 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791294467;
	bh=4Gtx1novXP6NqQnE1CX/522SAS8aNnUdLs4H64hBEnI=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=TlXEotUyfN4Ui8BtrraBmYMlC9P3jQs2WXBc897AfBo6she2Q0cULcJBjw/A82sgt
	 MZkg6A1XoUu+KyrH/sxKIvJqP8bgkR+5k2gZZ0Cr29TX8ZcPXG02E2ydp5lyM377Li
	 1d++6uRHKxTZ7iCq75Hed5xo/RMxSaPo2jaTIA2ujAAvZuq5zj0g7ik4ZygO5wVNQ6
	 xfENvhRbb+oHnzWdXkJYiA7gCp/spmNCESnPrMi2WnHuTA7GL5B00tuOtPiEX/qCRH
	 uIh2dTypCoiy1zYdCWPE3taEILtmhMYMQRTDk5UocsenuY5RjAqenm9ANXzJBYMaKI
	 1UvmqcRbligyA==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 38455F40068;
	Tue,  6 Oct 2026 09:47:46 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 06 Oct 2026 09:47:46 -0400
X-ME-Sender: <xms:AvzEahggaACIo9zFZVWzcvHtKtkOmk_HRmamTBaSyQyeBTgK2Q5hnw>
    <xme:AvzEag0O2vopuPvVB2wHr61t0puX2buFVa7yDD06A3e26PhLn5ke0N-AczD7cvDKs
    xfE9I5cb50trvO251NPW0MIJ_6EbqFv8dmE54_3jEY9y_U0qPvu8r0>
X-ME-Proxy-Cause: dmFkZTFre9ofM+lzYYLcctWi1Mf9vIDpVpzAQnegcTHCGRTPoVIa7iVaZyBIeYH6XI6anR
    kT7+/hCBpSOtTlzv1f1kog+0sGLuhQm2MIWuTCmBNwigr/Rdzh4E8OmBsddbWqGvSvRSDj
    XxPVG2EJv8gtl33qDII7a0rdD0Qs2ISfKfGCBQImC6TabGg+dMmqjS1l2jdVmG5dXkO0Re
    ZNGJh3kKD5ni3hzsZCEsWWlG9X217CGxOWWulHbNTjsaQ+cm049OJW0XLsgKw+qK4fXFhX
    48JB58dMeCT4TtAcmMw/AcBWVuxz+6p9j1ZNnJj+Y+eTTh+GKP199TqALT+swGW+mHyAMk
    zPdfpzwMNCVsCrxa0ld/tyt6S65DHINoPhzYuVKJMTUPPei3eR3spECwjtxoVVrYJKTGfa
    w5y2kCQugxk3gGCLp942QYY0dG5zbknpoRCzfNHvgl7qg5pKg08g6dCQjN8aw6sdK6bwzf
    R47odG02mSQCuQtY3Gy9ZX9KywebqZFyzCm/rSwazNGYqY8LvMuJA0G0kDkEap+vHwsRq3
    oln9LeOptCj2tXC/kxcq5xhw3gnSALJeroOzy91hazDTgLleqzC+jc6iCHFTCVncT3xJ7Q
    1bzjBQZy7gZwytDsScwVZTTLvkfUW7ztaAl25+BXhpfdT0eCxy2bbozbanUA
X-ME-Proxy: <xmx:AvzEajYumCiRKQTPglPX9TIhKgQIojx-yQfvmEXrHf7Lc5XPGk2CGQ>
    <xmx:AvzEaqgCF5v8ixS2wAUVQFzOtvGHrxGA0Nr62EIvfW-MuRGjwgNPDA>
    <xmx:AvzEalcfqKGobYysh97vu8Rcx-CqndrFhUAMzZ8310V6VJ-CfsIQPg>
    <xmx:AvzEapkAXIkbjmtLLsQ1zDHSkAk4yJltVoqkjX3JQezjY1-_JsofSw>
    <xmx:AvzEaqzYsdyGabOS-_ax0L3d8lIH9pece-Ch_KmcqMJUZ99R9epzxwCA>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 13211780070; Tue,  6 Oct 2026 09:47:46 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AFCZ3x6p1CiR
Date: Tue, 06 Oct 2026 09:47:25 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "J Louis Kaplan" <Louis.Kaplan@arm.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Jeff Layton" <jlayton@kernel.org>, NeilBrown <neil@brown.name>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Tom Talpey" <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, linux-rdma@vger.kernel.org,
 "Anna Schumaker" <anna@kernel.org>, "Jason Gunthorpe" <jgg@ziepe.ca>,
 "Leon Romanovsky" <leon@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>
Message-Id: <cbc3ff79-4866-4433-a01b-3d5eeab1962b@app.fastmail.com>
In-Reply-To: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
References: <20261006090028.3412544-1-Louis.Kaplan@arm.com>
Subject: Re: [RFC PATCH 0/6] Improve NFS server direct throughput with passthrough
 enabled
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Tue, Oct 6, 2026, at 5:00 AM, J Louis Kaplan wrote:
> For NFSoRDMA using RoCE, and with IOMMU passthrough enabled, use of a
> 64KiB base page size was found to provide higher NFS read throughput
> than a 4KiB base page size. This patch series recovers some of that
> throughput with a 4k base page size by opportunistic use of large foli=
os
> for the svc reply buffer.

> LLM Usage
> =3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> The idea of folio usage here was human-generated from observations of
> performance differences between 4KiB and 64KiB page size kernels.

Actually a similar approach has been tried before, but on x86_64:

https://lore.kernel.org/linux-nfs/20260319133610.2556826-1-cel@kernel.or=
g/

And it had to be reverted:

- Mike Snitzer's report (4 Jun=C2=A02026):
    https://lore.kernel.org/linux-nfs/aiHlPmeZq3WgMwoJ@kernel.org/

- Jonathan Flynn's benchmark and perf data (5 Jun=C2=A02026), showing se=
rver
  CPU going from 8.54% to 76.35% with the commit present:
    https://lore.kernel.org/linux-nfs/3cb119b4b2a8aada30c0c60286778a54@m=
ail.gmail.com/

These two are the Closes: targets in the revert, which is a39f0ce0c9da
upstream and 284d5ba931a5 in stable.

Lock contention analysis and the decision to revert

- "[PATCH] svcrdma: Cap Read sink allocations at PAGE_ALLOC_COSTLY_ORDER"
  (5 Jun=C2=A02026), whose description carries the zone->lock analysis:
    https://lore.kernel.org/linux-nfs/20260606035722.83175-1-cel@kernel.=
org/
- Flynn's results for that fix (25.4 GiB/s, against 30.3 regressed and
  73.9 reverted):
    https://lore.kernel.org/linux-nfs/65a2cdb132b0c28e69a29955e3bd37e7@m=
ail.gmail.com/
- Your reply saying the two failed fixes mean 18755b8c2f24 has to be
  reverted (6 Jun=C2=A02026):
    https://lore.kernel.org/linux-nfs/096a2b91-7a19-48da-a06a-dc60e71509=
56@app.fastmail.com/

The earlier failed fix, "[PATCH] svcrdma: Avoid direct reclaim when
allocating Read sink buffers", is at
    https://lore.kernel.org/linux-nfs/20260605223118.75092-1-cel@kernel.=
org/.

So: Yes, we would like to ensure that svcrdma's RDMA Read buffers (at
least, and maybe RDMA Write) are contiguous so that the overhead of a
DMA mapping operation will be low. I'm not expert enough with the page
allocator's free path to address the lock contention problem, however.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
