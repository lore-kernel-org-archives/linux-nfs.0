Received: from fhigh-b3-smtp.messagingengine.com (fhigh-b3-smtp.messagingengine.com [202.12.124.154])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9CBD53EC81F
	for <linux-nfs@vger.kernel.org>; Tue,  4 Aug 2026 22:36:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.154
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785883006; cv=none; b=AcFkZfoCunGviQDmTl/GakcpMxJYOCzHVoMKkE1aFNuEj4R+fDrCAemrX6IyMPozcHP+zjy9cGtr8BMYlmM+yijw+5vP6clz3dPFj1q6nHHYfv016D+i4u1TJktUsgh+4759NnXMbWd9xnsbmtGwydEPmIUqsNiEQeqsUng+wEI=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785883006; c=relaxed/simple;
	bh=TIww+P3J+1YvMdr3tEau82BWT3odSbecXjx5G6r8tbk=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=socoD/cyvC27LY3Z9BdojhPX7A1NWjZbncywyApQrR1WFW2Ab6VhR74ZNglrP+9U5ERABfOd9rq+LcNQDZjeG2WE8EJoUjEQ/JHZBF7940yD4nxVzXJO8dJDD6zKEHP/czG32n5wZcU2cwVu1NwW4OXieCKVY/NILEueq9k5jlM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=eiMwD9f3; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=CjYQew8J; arc=none smtp.client-ip=202.12.124.154
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="eiMwD9f3";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="CjYQew8J"
Received: from phl-compute-08.internal (phl-compute-08.internal [10.202.2.48])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 7ABF37A00FE;
	Tue,  4 Aug 2026 18:36:43 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-08.internal (MEProxy); Tue, 04 Aug 2026 18:36:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm3; t=
	1785883003; x=1785969403; bh=jenHK6j+O75bZGAB3i4HiF3x00fjsai8Ny5
	07rsFJfw=; b=eiMwD9f3g7PxsBzlK3prKH14mBaIpqVOzjIh8k7lP9ACx/36prP
	D6ONo5+VmCKtD/O82YLNWpVMF8dGFGOtWAWeT9Ee1448FlNEZ9aUquC1W6NvLXTj
	/esZV/1fiAU2Nu7vXptjCTK/NFKTfzIZVUkzt4iBnjI9/ECyzcmQMqk4U4mxOxdj
	Qe//oAopZZg/sstkgkgTTlH9eZFadaXrHzh1SL4MWRqjfXUi8/yR65BgJdQ2UqF9
	y2a//HGFzz+h9QWZuS7Du+ol/9ioN5dgcY6InWZWrHpM1YOWzy/+AseVyqR+X1qL
	hKKuDgzF5ThRICMjgP/ZJXCuLrmYNm/cIVg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm3; t=1785883003; x=
	1785969403; bh=jenHK6j+O75bZGAB3i4HiF3x00fjsai8Ny507rsFJfw=; b=C
	jYQew8Joi30ib8JQpyTo+jbM8AG/LOWJJZqxXFJidFPqFWpGplupBMCXC2j+GX2Y
	pGPqMysnypL3k2X7UvJNYyqM6yUxPANvXhVKz7rHloOqyvEA4zGhyUofOEVJSl2g
	rUdXtYtC4kcxdKC0hVz9XXGheaPYW7d4TeiQgFWhewq43ajQS8wrF4xDit6OobJq
	/9g7ehdLNvdFAqdzDhOFXcThtaogxcTx1SH6LgnY27FLaYx2YiNlM5ml+KdmKBGO
	zCj9jPjNcl0lWesFCU51NLUYmqj0saGYnAfanQu7XonNgcv58hKNHxMT1DubgtW8
	QOtkLoAhEMtQnEW+FoqOQ==
X-ME-Sender: <xms:e2lyambzxl2rZ27dVm414oNchQgx4C218Q0wmErgNTU4kN1HuLWjwQ>
    <xme:e2lyatGH3HlM83XeUQqe_yNNxiLCHKBSL_fc2A1sYV6ikqSdcY-qD4RF4VTAp14_f
    a_vsxqVEhU_aocaXotD3N5VMy5YYtiuL0zgINd2hCiLRaSMmDI>
X-ME-Received: <xmr:e2lyaqz0WsCyzS6uiKch-2g2Y6PWYkN58on6VTucpuigMfNjJ5i4pWykqPwKSXdP1Q2nZDx6gW7u-iu1oAepSR52SLNVINE>
X-ME-Proxy-Cause: dmFkZTGREKB1Phu1BYe7zv3U366610GEYEBHEgjsNknricQPAkkRE05G50zsjLBQxLjWo1
    Gz6Ijnc6i9mwMVP9MKHhL2TAg5zJqaFmUm8GoDaN+gd9wNgxCYqGw/di5K1Q359f+zak54
    dQCne7OclP1/AN8F37IrHKHwAUb6YrEV9Q6SiG41oBlkqB694bBHPQy5+46ubd7eGVjExU
    DP2l6bxXdOWJXjuNAOPKkN+aQQgulWy0JJyn/qJ4WKmUSwNpl2B5bL8k5joHaUKDFlOSmS
    WKeDHx125ETan2SQJTfNHqqRRMhY1aNsWjP9xKxLdrdrlSDmDNOfBevImHWowA8JdpgEJ+
    sCg9etMYKZ/cTuaJpNrlY9sHxaYk+zienYuPqV0rqqaUxf2KHAxBJfPeC4ClIgfb47FwKx
    EHJ7+DeyJgvJjVdtJHG/XsyOnc24zn9KZh8LpqWC3EHDtOGUQ/Nkj7wU7vKuW8LrMNeT1j
    86Ti07r4X7luOdAPcFW0mFof3tWumlZuPjbumZUSNhhZceWljTmq0Bh0TnRg+ALsyS1vIW
    BgZ92y1SxL90Pej3qRkh/aF6wXvenUPRige5E3zMx8V4Ft/N2KBH7/a/Jz0e3M/6ZdRIt4
    ZtdYu42Kl7PrnmYUrl/MjMqgn0Wjx4t22mJPvRspYMzBmLJrsLhjTnqCItCg
X-ME-Proxy: <xmx:e2lyavkkCjkjukUlLvREOBOkm9lhYFhWX_MM7SrkItw6vBgexYZCVQ>
    <xmx:e2lyajlDi9AyRpMlU8MfYLkH_Pl0VNLe-qvCyhh3XSBL8ZijZ4fjQw>
    <xmx:e2lyahz0bN_FOdvxJakveK-fTLBZpTqx-BcQjnp4bZIBn6MmsU-rBg>
    <xmx:e2lyaoqOjWRUBQ02mwDEWW49k93TUTDASZ-ueZuqA9Ja97QHmYTttQ>
    <xmx:e2lyav6_9CAjbqQ-i9Z5jnc-b4y3ktUZjk474u0cK-ejZQDBPkjdsqA1>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 4 Aug 2026 18:36:41 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFSD: Point contributors and sashiko.dev to the
 nfsd-testing branch
In-reply-to: <20260804184630.1395002-1-cel@kernel.org>
References: <20260804184630.1395002-1-cel@kernel.org>
Date: Wed, 05 Aug 2026 08:36:37 +1000
Message-id: <178588299789.3252194.4480760424555994919@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Wed, 05 Aug 2026, Chuck Lever wrote:
> Scripting and automation is sensitive to branch names in the
> subsystem entries in MAINTAINERS. Rather than pulling from
> cel.git/master, we really want CI to pull from
> cel.git/nfsd-testing.
>=20
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  MAINTAINERS | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
>=20
> diff --git a/MAINTAINERS b/MAINTAINERS
> index 5114e6db7307..637c22e34f17 100644
> --- a/MAINTAINERS
> +++ b/MAINTAINERS
> @@ -14088,7 +14088,8 @@ L:	linux-nfs@vger.kernel.org
>  S:	Supported
>  P:	Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst
>  B:	https://bugzilla.kernel.org
> -T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-te=
sting
> +T:	git git://git.kernel.org/pub/scm/linux/kernel/git/cel/linux.git nfsd-ne=
xt

I wondered how that worked - good to see this fixed.
Thanks,
NeilBrown


>  F:	Documentation/filesystems/nfs/
>  F:	fs/lockd/
>  F:	fs/nfs_common/
> --=20
> 2.54.0
>=20
>=20

