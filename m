Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 3DC1A472078;
	Sun, 20 Sep 2026 18:24:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789928669; cv=none; b=Q9JqXBvrxqGdlqdWm8+7zIJWxergQbLqXB3LjnP26RjXIXr0OKi3fuSwhq1pAoTf/iPeCBNUnfpvbaYSVXO7X81sJZLxM+hTnYJetcXRcclId1l+oMfiI5k8Z7Jbhns/v0ZxJLeKlPtOd/4GZKZNNVx3EZIpR7GaMeMrd1Ghtco=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789928669; c=relaxed/simple;
	bh=OtN3WM4TZ7j22Ot1R8PnWAbAjzbjWegacn22J5Vn9Gc=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=kT0ZvvqLHtgBRR1T2KhvaqXTKhMhhDO3Bf6frknHsDKUBItOs7jsjs9/DE0vY7ly5C+JgiIJYbd1sTl5j1suO8kTY3xuQJ90ZMdtbgUoqWyhMQZOZzgMz7HsvrQBj95Ly6+lH4dkYewrcyXhs9Ceqwj27bxdECGqhJsWQhk2PUY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=Z6Lq+nz8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="Z6Lq+nz8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8D2CC1F00893;
	Sun, 20 Sep 2026 18:24:25 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789928665;
	bh=GirpiP57LoSXI3TsoHXT6mFHUUAI+u4/IhtEm8omttw=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=Z6Lq+nz8qmYQ5p8JVZMtuok51Pgu1e6odpnK+oHgND5u32Ry3Gh6sCwf/8o5DUZyV
	 T3jyUEBlOMKnwIESRa5XQ5qLwH4JucWhj/dRFAnOMUPFaMM/O0lvcbG5QRgkJ4jr1Y
	 Ao3L/ckJJ8uPqFELfQm4gEvf1TLNCUtBM3c0XuZzn1sEF9vwI2/73gFJdETvJEQ3/o
	 985JRoQNC4YseygV8nR6QwEh6KeT42Sbv8FgocHbWOGKgaylwZzujqcjm4uoXbVbiJ
	 7AM/pH1KTqnluCyjvSr+rnjvR0QYfML9uBgL4vgRxqrsJ37g2pyKphayH++k3mHo1N
	 mdse1SNMM+7Sw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A34B2F40066;
	Sun, 20 Sep 2026 14:24:24 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 20 Sep 2026 14:24:24 -0400
X-ME-Sender: <xms:2CSwau-32lPy11h5cqo7TVrgR0XodUK59kktognwQIK1S8f1nWs5VA>
    <xme:2CSwapjeQ-MnP_Nt2IH65k9KxSt_X2-QmwjjbejKzbvuAUs7QTeWnxoLeqIpqTGUs
    cBoE6lr75xvzWDb-hcLUzo3AMKdvZ-Iy_XVTVoeYVI9ZGMWUsCOG4Q>
X-ME-Proxy-Cause: dmFkZTEKfLeK9ddA5o2er4T3A9g7EMScIjM6YAhWCOQaFtcTswbmTypRk5joA0xTpVlGTH
    I5GILNHkJ4vi+s1o5OrtbCm9YMHrGJRu4W4EHf6JVPnzOhH09T2x9G1/b26FZniz9XzRmY
    LVK/gmNkv28iYwG7QFppDh3pN7DHM0WwViTAjIwtM2GNjI+1vplNTCdrS2tpcQAN145DXs
    T8SSEurZU91D2FPlzaRSFEonsiGnB/U1ElGmORBNlkb+Lh58BP8te21gsojlNWfyxdLC8h
    kY7hZt07KIKaJaDHS6dqqZDJ/iy0kpYrZIm2tnmX3GLUcVdOTlEjeO4VyC28zVYKnKFgsf
    WuDfLUJlPTZmRJqduS3GIlHKh5KfGfw3Rjy7iY2c8ad4TvABfymcUkr/rARrGJ89h0ruTT
    Lx5PxdlaxL60z6vfcBM46Hst0V0ocNA80gt0lERkNe3cWsfo48xNFt9zLAKTlFl/1EQWJg
    HG6QTfmLRYR6o5o+/y+ju1snl79fWsgbfTN6Lw7hm7jAY/M+EK+69Q6usgpCyfufmwk/XP
    uRTG1ileFdUyjsrZmzB8hc7skzpThLBh4k5WqQSDiqPDrjFuLzmXQeZkKoTH8aj2vULdrq
    cc+1129ao109Y1tP2Ug2jjUZnZFhIntfcJAKdfy6KfsCTXAcar37hmSVdcJw
X-ME-Proxy: <xmx:2CSwaofzRIex4HTSYsNA0fWJf-PnlZzku8ZsV09pTNKIb8uj3edlHw>
    <xmx:2CSwamP4Uv5tF0QmEUMto2MlEOLdjT3-gxBfXjAxPkDDauLfJnWTgw>
    <xmx:2CSwarsEhCwK_GfarBiqMIG84p2XpusE5cgv2xSdVS16d2pwW6oXSw>
    <xmx:2CSwavDljUl0lAD8yDyAmTEWcv2Hdxq5rfBwBrxxD6cb6Pe0XUJSag>
    <xmx:2CSwaiZcXm7F0Ie7YLHbrGHAWZ6A7Z0NyM1yMx975Y2-tvW1zv100dJn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 80017780070; Sun, 20 Sep 2026 14:24:24 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A33QhYTfYD7B
Date: Sun, 20 Sep 2026 14:23:55 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>
Cc: jlayton@kernel.org, trondmy@kernel.org, anna@kernel.org,
 linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <b8bf0827-660e-4fad-b90b-21947bc8073e@slotpi15m67>
In-Reply-To: <20260919212024.2335794-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260919212024.2335794-2-Jeremy.Jean@oss.cyber.gouv.fr>
Subject: Re: [PATCH] SUNRPC: restrict integrity replies to authenticated payload
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable

On 9/19/26 5:20 PM, J=C3=A9r=C3=A9my Jean wrote:
> Decode the checksum length into mic.len and truncate the decode
> stream after MIC verification so only the authenticated payload
> remains visible.

Your analysis holds, and I don't see a relevant fix already queued
up.


> +	if (xdr_stream_remaining(xdr) < len - XDR_UNIT)
> +		goto unwrap_failed;

This branch cannot be taken. xdr_buf_subsegment() returns -1 unless
offset + len <=3D rcv_buf->len, and @offset was computed as
rcv_buf->len - xdr_stream_remaining(xdr) just above. Decoding the
sequence number then drops xdr_stream_remaining() by XDR_UNIT, so
here it is at least len - XDR_UNIT. Nothing in between disturbs
that: xdr_decode_word(), read_bytes_from_xdr_buf(), and
gss_verify_mic() only read. The new "len < XDR_UNIT" test already
keeps the subtraction from wrapping, which is the other input this
check could have caught.

One observation that needs no change: gss_krb5_verify_mic_v2()
covers only cksum_len bytes of the token, so an oversized checksum
length word verifies too, and mic.len still feeds
gss_update_rslack(). rcv_buf->len bounds the value, so an attacker
gains nothing but a poor slack estimate.

The rest LGTM.

net/sunrpc/auth_gss/auth_gss.c is NFS client code, so this one goes
through Trond and Anna rather than the NFSD tree.


--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
