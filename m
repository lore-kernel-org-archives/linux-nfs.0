Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 05B3E4772B1;
	Thu, 20 Aug 2026 17:22:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787246522; cv=none; b=nNQxRYbqrampMZnNwLtM1+016S1N244EvaWaQkim2JE8HsBtOLjwvlcD3wcBltg7/rh8zplboBa4ckDPZRVqVPPb9WHD8GOOfBKe0SSSoqKRkPOS+2WU0e/KfZzS9a9gGfJXjXq/MuPLraOZvO6ZWKXOyanNgb3xjk3HPt9x0GE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787246522; c=relaxed/simple;
	bh=xaRCU4DABpBti0oFI2m4fVq+NsklzvVsDvEfyojx2mg=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=aYjNGlj1JxQ6PUUNS8QsS/TvKCD+Cg3pAdg+FB9oAYcr7wB6yybyJ2jxfX6FpU7LaaakiFQucAjNwx7Sz6oIuSnMNy7QshFdzjgkpQ60GSei2TwGovnZ6m6kWuih1hwIbvXmVVEFd57KLVTwY15VYWlPrErdc6dTGkrQNA/Kug4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hM/ssmyd; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hM/ssmyd"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 750231F00A3A;
	Thu, 20 Aug 2026 17:22:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787246520;
	bh=y7DFt4aZ5Tua4fQPRExdQJxbIxruqvCgomh224Ieemo=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=hM/ssmyd7rgVQgAa69hWVrkemVoHi7xACjk+/PFC4QekNOpudjQIOJt/6/5/rEV81
	 k7uILnyw/335naQq6ajIJbNJDvKwqaSiDL2/JtueoF5Uhu43g+T7VNX1RmhKFM+WhD
	 IqojOqiPdi+HnO93nPc7sF5gDccUeBUYD0ZzRaPrScgSyUK6h5hl1zrrTUe26liUOS
	 GplWvC+zODKmPldLd1axquTaJ80LiYy8oubg7MwcqmZnxdexFzCBYR+0gfAhpTPGal
	 VEEGr+bmt9EKQLDTlHdA3SNnR6qOgIiMHErfaXjh8rL4oiSB5xabEa43lARwBBKwyX
	 9aGA66Kw9x7Ag==
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfauth.phl.internal (Postfix) with ESMTP id 573FDF40066;
	Thu, 20 Aug 2026 13:21:59 -0400 (EDT)
Received: from phl-imap-04 ([10.202.2.82])
  by phl-compute-02.internal (MEProxy); Thu, 20 Aug 2026 13:21:59 -0400
X-ME-Sender: <xms:tzeHakh7b0zkmgrQfgpJw_WCQ1E90-vzN6tgHENGGtbE6Co3FaGqtA>
    <xme:tzeHan0BKaZzvmxvkqXmFl6Xl3fR72sEth-arvsrSF_SvnOOsrfepV8VxAtJxHti7
    _y0dAeSFCEIx5wdhU1CKKAX3fjfF3_LVdB0mntGtm2-lOM2GUwe1f-9>
X-ME-Proxy-Cause: dmFkZTF1Pj98SjTC9tDjgHUiLFtytms3lQSeD8Jt+I3h58+1KKeR1z2lmru2++WtD1Go2m
    XoJmDLr0OZbMPlOgKcpBtv+1sy3E3PkSVfYgOrUOsazeXaHIvniXCAjxyfn1CNKCT14NQ6
    O30ALbJb2O535VisfNn8e8rbMIxK+1vExhj5k6WZaz9OeUtwFWWBpI+NgKQpJj/7XqhVzS
    22NWKqHsFY7tTHf72lhcYFb5e/iRXDyabCmA5j17xzJi8e07WHuIZD/nPDcZBf9k3lg7/V
    mnX/mSier4eDpVaZzEV5j4bLJbnFHMTwPDcKF6H2A/OfKoPNZIinEu/YhyDNPZG4XGekcj
    N2yufFfsQA9n9m9tGBAj21x2b+iBv84muKjZK0xxEZPzG3REC0NCQ4w+KdugDtcKPwi8h/
    UOR9Udd2rfPYWUQ9LQ/RAjd/Sl17SC5s0m13A4DWIMiFdmVgKI/3q6rEeBeXNnshxWf52S
    bP6UZ5Dwl2Cpf/XAwjaWEiK7KkrVt/BqH8v0Mao0BjH2iz4ynHqfWv9dgUEY5MTP0QHgBv
    c1kK5eIcNWgUI2XdtoHJVGgvecmO7Ed64P7ekvdvIRs5yMIbpsOZOBtpuefv1IyJvWUWcQ
    BNbNVZVT2XEujeSbHEVaAAubYRusaGGP5gcISpftwNLi8YyRQSaMX4dGB8lQ
X-ME-Proxy: <xmx:tzeHatnAjYCh0W8nwBOtJaq2zKToM6ieekk6cdyy49ckhNtErdyVUA>
    <xmx:tzeHaqU8S5NiCPcjIdMADVG167gP6XiqUSnSuOm2W3tTNDzirADwvQ>
    <xmx:tzeHajvNtoJX49_5addXXgQ3Xv_4lqHSVDfaGsi3mKw8n1i-t8l78w>
    <xmx:tzeHata9mETIPHt6Ihz1UHW9UITEGamTZo9o-h_UBena6lQwWg1fUA>
    <xmx:tzeHaiVgGFvrgCp-4X3L4bEUacIniUyTiHXJn5eL91eql8NYsW4I8TbO>
Feedback-ID: i20964851:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3CCF2B60F8F; Thu, 20 Aug 2026 13:21:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AfkgYjQ9KFw-
Date: Thu, 20 Aug 2026 13:21:39 -0400
From: "Anna Schumaker" <anna@kernel.org>
To: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
 linux-nfs@vger.kernel.org
Cc: "Trond Myklebust" <trondmy@kernel.org>, linux-kernel@vger.kernel.org
Message-Id: <ae822c8b-9d47-4a96-a61b-aef730c4c785@app.fastmail.com>
In-Reply-To: <20260817211600.1651876-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260817211600.1651876-2-Jeremy.Jean@oss.cyber.gouv.fr>
Subject: Re: [PATCH] NFSv4.1: initialize referring call pointers before decoding
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

Hi Jeremy,

On Mon, Aug 17, 2026, at 5:16 PM, J=C3=A9r=C3=A9my Jean wrote:
> decode_cb_sequence_args() allocates csa_rclists with kmalloc_objs(), so
> each referring_call_list starts uninitialized. decode_rc_list() assigns
> rcl_refcalls only when rcl_nrefcalls is nonzero. A valid list with zero
> referring calls therefore leaves the pointer uninitialized, and
> nfs4_callback_sequence() later passes it to kfree(). KASAN reports a
> double free in nfs_cb_sequence_empty_refcalls_test().
>
> Initialize the pointer before decoding the list.
>
> Fixes: 4aece6a19cf7 ("nfs41: cb_sequence xdr implementation")
> Assisted-by: Codex:gpt-5
> Signed-off-by: J=C3=A9r=C3=A9my Jean <Jeremy.Jean@oss.cyber.gouv.fr>
> ---
>  fs/nfs/callback_xdr.c | 1 +
>  1 file changed, 1 insertion(+)
>
> diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
> index 4382baddc9ee..5857f57f0644 100644
> --- a/fs/nfs/callback_xdr.c
> +++ b/fs/nfs/callback_xdr.c
> @@ -360,6 +360,7 @@ static __be32 decode_rc_list(struct xdr_stream *xd=
r,
>  	int i;
>  	__be32 status;
>=20
> +	rc_list->rcl_refcalls =3D NULL;

I think I would rather have this initialized to NULL from the beginning.
Could you instead update decode_cb_sequence_args() to use kzalloc_objs()
when allocating the referring_call_lists?

Thanks,
Anna

>  	status =3D decode_sessionid(xdr, &rc_list->rcl_sessionid);
>  	if (status)
>  		goto out;
> --=20
> 2.47.3
