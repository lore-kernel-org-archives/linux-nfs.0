Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 2CFA649E134;
	Mon, 21 Sep 2026 13:28:18 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789997299; cv=none; b=kGX7lZo5/LIerE0mHftjXeCo2th7TArEYNtbA5GpxvM93DpZ3JmjtsCBlHSEHBbVSfmXk+Zpe2YmP1WRtb/5c0B0RWl9b5kYv7tNIQOIBbFExGmZ9yXmeS2mgAX/dv7HVF28xq81rp1KVT/DbnVzBLmX1MX0WyJy8xwCBMnucNY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789997299; c=relaxed/simple;
	bh=bU1l6F/FpVpyanPTk2wALJj2RtXeYDJAPQOFYHff/8E=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=eecHoN0wpQlOG0u4rBRvb0gKn5wvjHwamLM3e3laPafx6898nTq7e3lwLyQfwC/eoyH75Xk99E+fTi+QfRzbNy/Bq4Jg3iztTf5eEnRtR/r56DncFUI6vGVKS9NEjraSsDkl5x2HISRq7GBNB3HOhrPX4Nrcs2Ah2j6CURycrPw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=oUM45XqD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="oUM45XqD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7FD8D1F00898;
	Mon, 21 Sep 2026 13:28:17 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789997298;
	bh=d1Ey5jvylOJ79erdc6vFg11uZt+7Y6QIOD5AR/uXzi4=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=oUM45XqDtzWwZZYljoA4P7DWKZEpTfJ76UlTv1j0mdNtdwOHwn48ioFrdxC4REojT
	 qiJ2SxvPwm7J6fl5mSCgukfIcT25vcRGG1lpxYmj104py1YPLi7Yvjw45RxaxklDjg
	 gdtoA0eBO0mpt/1hmBntc1nmtSAw3c0mPY5lsaDxGKwY2rcrHR39Iw6iWUPRurp11e
	 tHfNAWq5dMts5iww3Ezw5xQTDalTDXbUGFSHjWbYeJQjzdJ7SEdu+J+qnb/CshMEJv
	 3yS9oYDBLEdspuae6zOsWKPnetslrYv8Ma8NhbsxooUBOlEYLrxVxKqhGmdUZt98/l
	 JGrfmluZDsxbw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id A8619F40067;
	Mon, 21 Sep 2026 09:28:16 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 21 Sep 2026 09:28:16 -0400
X-ME-Sender: <xms:8DCxaonF3EdorBzUB-A3zDG6gpYbcSTunYIOd3VIQ6llDAtnqN08aw>
    <xme:8DCxaioFVLZcXc0dhlSsGk3XHczLbOfkcTD0NQMEhEt-pysK8Q1RvG9bqZfpntw4X
    p1FVeK1GWYg9Dwbn54XJnBDhfcls2VUklRnwk1_S_RK-Iw43Iah5MI>
X-ME-Proxy-Cause: dmFkZTEOiXdpmpFDaaGkDmXKiq3VQKWyRpQ3W7SRvAo/XC35Gow0yHxFrHMUycyHFE9ULR
    En1DsBtaQ21QLmXdW3cjWvmQKU90scopAn7B1Dd7Qd8i9t+wLQMGy0Aw/6EKW++8UefdJQ
    ZedoTGCcJpcGTrFI81onA5/HF6GS8qRthPQ6kqjPUNfGEBwOhBEeoyJqGS6Wk/MD0/njUQ
    e8NLcoqrpRKFF/tOIZLiBxTuVWzCrtcR4oeLeWWuGvJEoRQ7tnVerL3h4sZc4ULgjBfiA3
    9UAKkpwCKJWnycInpAbKfPNxCBkDaJu91tDfuhqp9Nd0R0cDIaFvf8Wxwy7HfX/P1r4xWj
    5Pvb0WJkigO+Vh8fg072TZr7GU3HEW9L8BpknkxV/YDRXelApIRdcafgJNfWM9pgGWedqt
    ZWeXTsH3u1HJDvzOQJiV7VBqGckEUbMDzpr6a5CRHNXVFE/NkoU2xideJM6ZRMTHWs+UF6
    Hc01Y0FjlAaUkT8RDrykCVj9fpvU6/V6+4WbCjYcRXd+EpccC2037SdwyjHgOfb+6lLolX
    4Bw8O4vT21ry0nJY+jNWQBx4DiKxn2I4OMcwBqqLcMf3C0saSM3uM87ybpdu7RwiPS2mPd
    z3QfPmwmPcJcpTwLIaUHyYhyvIflirHKhHrCIk/zYz6+ufhFclyu1rl7jrjA
X-ME-Proxy: <xmx:8DCxatHXMi5a0bL5hhrtPbYtoS04EF7Y0jZGuWpqeqVBYPeprr6YeQ>
    <xmx:8DCxauWn72wzTM5fNcZRCu66F8rSp-iEPMR9QbSn9pZPuiAnl3-t5Q>
    <xmx:8DCxahWLwZI3MHz-DqhLvhChOotkfFb7Q5uh-sUkv3EQCo1QjuN1iw>
    <xmx:8DCxakL2bP8UXVRrSSRqCCusZ_mjuWpeIf2Bz_fhI5AraeQPOVBd-A>
    <xmx:8DCxahD7mW7Yao5d-4wvPab8ebkt2f_CPg0tlXM8i3Z3TNb_PNwhkPwn>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3B5B5780070; Mon, 21 Sep 2026 09:28:16 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: A3W2oquP0uN-
Date: Mon, 21 Sep 2026 09:27:47 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
 "Jeff Layton" <jlayton@kernel.org>, "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, netdev@vger.kernel.org,
 linux-kernel@vger.kernel.org
Message-Id: <c0704c72-ea15-4e2b-b145-d6de6d469b85@app.fastmail.com>
In-Reply-To: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260920210712.2887738-2-Jeremy.Jean@oss.cyber.gouv.fr>
Subject: Re: [PATCH v2] SUNRPC: restrict integrity replies to authenticated payload
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Sun, Sep 20, 2026, at 5:07 PM, J=C3=A9r=C3=A9my Jean wrote:
> gss_unwrap_resp_integ() authenticates only databody_integ. The checksum
> object and any bytes after it are not covered by the integrity check, =
but
> remain visible to the XDR decoder.
>
> This makes RPCSEC_GSS reply payloads malleable by bypassing crypto
> integrity. A modified reply can contain only the RPCSEC_GSS sequence
> number in databody_integ, reuse the reply verifier MIC as the body MIC,
> and append bytes that the decoder consumes without invalidating the MI=
C.
>
> Decode the checksum length into mic.len and truncate the decode stream
> after MIC verification so only the authenticated payload remains visib=
le.
> Reject bodies shorter than the mandatory sequence number before using =
the
> body length.
>
> Fixes: 1da177e4c3f41 ("Linux-2.6.12-rc2")
> Assisted-by: Codex:gpt-5
> Signed-off-by: J=C3=A9r=C3=A9my Jean <Jeremy.Jean@oss.cyber.gouv.fr>
> ---
> Changes in v2:
> - Drop the redundant xdr_stream_remaining() guard before truncation.
>
> v1:=20
> https://lore.kernel.org/all/20260919212024.2335794-2-Jeremy.Jean@oss.c=
yber.gouv.fr/
>
>  net/sunrpc/auth_gss/auth_gss.c | 13 ++++++++-----
>  1 file changed, 8 insertions(+), 5 deletions(-)

Reviewed-by: Chuck Lever <cel@kernel.org>

--=20
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
