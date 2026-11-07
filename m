Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794070756;
	b=n70C5xnnI1bQv7RYjxoM4OFYz+A6Fyct55MRv4yoOK9SfipM9KIyvvyPs1qd0PG5oldA
	 gaJ/ZboNGei3GKUIAq/SUFn5xVuISConBSMdua8CPwlQJwUooc6ydeXZ/cN5cWsaAQlcM
	 LojGlVn19c/XFUv0g+s9reBRVmb0qRq0m0A2fmNui5bLoaXRwTd7s7Hyz/eGHt2x7eRJN
	 Q54ViLm+2oaUlcQTbROv0NXyWpNWLb580zU6qtiZxw3xJwWAah65Ne1jvcy9QLHwe9ykO
	 j5FVAA1m1+6bG+PxlIxrKvn0larDUUHvXo012NIxfPfI5P6aPsmQ5eySFPIdtOjfr+g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794070756;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=XB+OkVQbMcO+LUraUbLF1sANoiWbTCfLaAjVLeE4XeA=;
	b=kcC0pyLOqzeaP5IksD/1f2NDTfQKEIWop3Q4NmUPU95NdY6z22/Ov5bwEMbFe+GUACuF
	 2YCHsIq7UAjfkLez1iOWhnPWQZZMjtkv8+/Xx+w9ZGBJWrImQ9tZ+5PcwZ4VQ8+vxTMVM
	 PWWDePWvhdj6iA3KXkoVyKMwkb2Ezy2+Vm8/6weSxygZ8fPgrSH3XuzfBVA0KJLVlf28U
	 wbuIHgY+gXQovh1PX0b23qVdlQNnTR+ATLe1l+zEH8ZBOol19aojOc/rBGpeFp/5GktnQ
	 2qSVN2MwFBJynwN7DWlH37LUDY4+wuteE53D8gH5bXaWRtAvZr7gdn8rRhyIbmGejQw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hZQjyFkE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7118C606A32C;
	Sat,  7 Nov 2026 16:59:16 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hZQjyFkE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id CAA261F008A1;
	Sat,  7 Nov 2026 16:59:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794070756;
	bh=XB+OkVQbMcO+LUraUbLF1sANoiWbTCfLaAjVLeE4XeA=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=hZQjyFkEJrCUrkJL/lgPJO7YnpMyCvVhznZNGPovMVM/8c4DQ1panVIMM1+n4PZFc
	 +PXut6vDzHA7gRVhT4mDnYOsP+CmHlsyIwj8zHhhPUtQCYlpImRiVh6+YtP5nFqKiW
	 cJJNtyFJDXpEg20cKPE9B83myeolSvj1NTH7P6micajX2R6Bbny2IDfLiHvVYT2c26
	 eXESbFK9IS5EqMJNSViQnO2kVYRbVtFvxzz/rDTzmlJxzX8V5IHK76x5anu1s7nCpj
	 vIlWbTpJCH+5kgRgAoJab6/I5yqmaPM5AOewqeKvhwvKAlyzgRcEu1fld9oNxIxOOQ
	 UgA4JgI1Fd+8A==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 0A5C2F40066;
	Sat,  7 Nov 2026 11:59:15 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sat, 07 Nov 2026 11:59:15 -0500
X-ME-Sender: <xms:4ljvallngjRD6NWmzW0TMN5VFxlk1hbAtOKUXy0cfbmfA80qxAwOug>
    <xme:4ljvarrK-tNzlp-nORRnAyeB6PW8w0Q7a-T9H_TCWs33WQVy_wwv9m4axjhD7obUD
    bWk3spjmF1nT1K2bVnWTgwTemO_e7ONzYVe8HP1r4IanMkh7yt9bVk5>
X-ME-Proxy-Cause: dmFkZTEr9g/XhpKHR3x3/gHE4Vc2Qx2ysHbLTUw6akZAqKGISsDhwGj4wuHOZmVz7MncHU
    iJl5g6rJ/lomWih3rWZNXpegajuRwU9tP1BYlUhmgjd25/5s6oPTSyrYtYawYyQnki9gK5
    LN4IjBYAauKA16Xzh3kQ7jBOzCVyIfkpTOXJWUoVWsrAwx7zPJTrKJqSoAgMirOOsfVb2Q
    jYIrYG72M0AT53sHLc+lzyY50KYnv+Ks5dFfZpEubRdAoH5x6BzfYbf1lXBkCBbmejjw5a
    ZiZbfOJ0ijfpye91J7ToH7MzjxqPYFFEwbM+QwhLEHT3OzALAaazPZvIsa8CoTIcW+dAGF
    1e3kLZwCuylsCFMj8Nvo3VkFtob4lvT86zl1/dYnNtVhGWH49nMjkyFmzzG14acwtbK4vS
    Mf0vPKVv5OIL85adxsrTsNiRmCaXZ77Nvv9+UagMsMFs6xzsyhOpwu2gVC49iMa0OtqNQd
    kSfYtLDb6YlYXPr6iYCWbGLvYHD9Fh+WpA49yUFNlvV8VxzFpsUWxJQ8HouCb48j5um2Ug
    4FI43FS4bKkS7faNBeHMSHWZh8fjjV5FaAGzQY1PnObKATkp7R10V80TidWYLsh0Wdfok8
    gJM9XD5osm33VzFak2yQ94XpD1fOfdZAyojpXditfNcn6vWlyGby/ngLnfcQ
X-ME-Proxy: <xmx:4ljvaoGgTcMb0KFTMZaPAQBPg81YxtJxeM50mjGLwsDY2hdynCzrrw>
    <xmx:41jvasRbXUrCycmPp_aefi8Yk0z9VSEDqDwuJsIhugqEtBFlSJ_3ig>
    <xmx:41jvahKh6ijn6scCuFieCrq8TXYrEnryoctmV0UdmLNaPmMPok4i7g>
    <xmx:41jvavbEAlDbmY-ltmQToFeCU9irThuRHEBitR3in7U-68hVjNDLQA>
    <xmx:41jvar-8LmBWDEykKQvyT1rcK4E2a-QIwaUMZ1pf9Blgq1KWigsN1g_a>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id DF82F782738; Sat,  7 Nov 2026 11:59:14 -0500 (EST)
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
X-ThreadId: ADLdsf9o_80g
Date: Sat, 07 Nov 2026 11:58:54 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Chengyu Liu" <lui2012qwq@gmail.com>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 stable@vger.kernel.org
Message-Id: <9120727b-38e6-4ac5-86a1-db40fbb6f085@app.fastmail.com>
In-Reply-To: 
 <CAE=Q7=7Ct5pPrT+HLG6PgWKW0z__WDZ0LtRJWQs00SYfFJjQ6Q@mail.gmail.com>
References: <20261103181410.1601083-1-lui2012qwq@gmail.com>
 <CAE=Q7=7Ct5pPrT+HLG6PgWKW0z__WDZ0LtRJWQs00SYfFJjQ6Q@mail.gmail.com>
Subject: Re: [PATCH] nfs_common: release decoded ACL on nfsacl_decode() error
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Fri, Nov 6, 2026, at 11:38 PM, Chengyu Liu wrote:
> Hi,
>
> I noticed that the Patchwork status of my patch has changed to
> "Handled Elsewhere". I'm not sure how to interpret this status. Has
> the patch been picked up by another maintainer, or is there anything I
> need to do on my end, such as resubmitting it to another mailing list?

I manage the patchwork instance for NFSD. The NFS client maintainers
don't use it. "Handled elsewhere" in this case means I could have
taken it through the NFSD tree, but since the NFS client is now the
only consumer of that API, I'm going to let the client folks handle
it.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
