Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1A9D1432E81
	for <linux-nfs@vger.kernel.org>; Mon, 10 Aug 2026 17:44:00 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786383842; cv=none; b=R9cebiRTdziCWs8+e6IiGXKj6n4RtyNM4jHCyg4tNEdgg8vn+BtskjGFBJOnVM5i/xEUEOz/9BMhOtjBQmT/bJhHMY+sb9Kw+LfUmRVaBJkOqhQab225KT4EEnU9fND8hRRIKstk4cJUSruGtX6+e+geVu9qoWt1s18uJhqF89M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786383842; c=relaxed/simple;
	bh=eMo2YeMTqfcMBrObUIYLIqrD9yqaiRNrfywm7LWgOiY=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=ofDGlb+PR91EvhqCOm4okaDQ3PmWPoI8eiKJLNz1EONIwLSxmnj08e7Z+rRyNm6EO2U8GMHpskCL71BA6b17ShfMtk3zfEfH5WiYhTDbAhf/0EPtvd+ar8u17fd0Z7Qh9oPYANUaPmbd4qormdmLTJ+90fIFQEKWtt5aHFu2uxs=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=SCGyXw07; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="SCGyXw07"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7C7D91F000E9;
	Mon, 10 Aug 2026 17:44:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786383840;
	bh=eMo2YeMTqfcMBrObUIYLIqrD9yqaiRNrfywm7LWgOiY=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=SCGyXw07yP6jwniBmBe3QNWPKnpBZajXG3RMnAc74PAnr21WyUJq23nBMOw8JbA4I
	 6aiEQ0xxyJScJ3EvDFfY89RWKz4QwlfoOR9hqaj7QmQU7tgLbpa+xDxYTASCueD3Ht
	 pJalaJGddHVW80OB1vdvXUpiG9mEqIbzZ/q+w+Ls0aoBotIBDqOVk9t6FHCfR+34/D
	 kwQ/mB9jFqIrTUR88/A6dERyDXZWd1g98C9X9X99gdl1rfJUM31AFi8wZgFuK0+9V5
	 GPAN8fEEGwomOvSjuNlB9nthkpu4B9DmMVf26QdXWD3gkUaNaLrl0Pnk0CsCuCU/X+
	 pW+clT3I/uojQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 7E849F40069;
	Mon, 10 Aug 2026 13:43:59 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 10 Aug 2026 13:43:59 -0400
X-ME-Sender: <xms:3w16asE4YSliV5mGwzmiAdyAM4xy7igdTLAjSScnvRc2Wu9xneiSFw>
    <xme:3w16agJk3YL5Z4Q5kGbKPJEzKBzYzN_pqwcs83WErBYFB--Wc5_v0Z_2ROnqOEinR
    28n45p-1GY1v3oEAwY1PAYCqSoBz31T7YV__nh17VRlevEH8ga-W1k>
X-ME-Proxy-Cause: dmFkZTGkNQVNHl9OHa6MFe3mc55cBWA7CnLmC7KrftZtbYJbt0RP7wbiJXxNH0U7yjLYRP
    wRrCf6U4/YEtKnczrZ/sVgP1vlIPXEvcgbsmodyHFPtlGO8Vt/Fna/llUmpfRa0A+/tE9o
    FjRJbvfpJVcfwrTSZ8hR7aLLKNrxNZ547sA5xXwNDLyOUBc2+oLGz7zhpJqYYGsdFBorGu
    w8w/gY6vOdx31EYiiEJiYHB0/j5E+gK6PTXsv46+25g1XoVMcx3FNSvlVHWvg8UVFtkCMB
    C9unhJfELx5Lp5GdGmaa1xgffzpG95KzpnNH34kLZBykGU1IWXjBXPFotD5moa6Bk0J/dj
    3Sw2rO+jULu64i5uexrDLBwEaC5iVRYt1e2fKeHk1/v0Y3/CrWJJi4CMHAmVxfDeWY9lfr
    6L1GzfGnkob4BmAwjGiq2eOMI+5f+yH/fOwmAqdaW0GrM4Y9fAiMGkRVc3CBHoeN024TP2
    lA/jKm+phJAe7EexOBTKZzI9horU6eex7owDfp/gj0SHpdpxrP0sT4Z8r7k3OB9uoUqylV
    LKsMVcS5IAEHAYUKoQvtvD9zx7bvGVGA0iVAzWjZGaCCFRpr+TIp673aCXx540Px3QrmsU
    htLXdKnh7fsOHDlSAhwE29r3+OsSUXPSOKFhDsuvtyCwaGeUR//4YyECwzAg
X-ME-Proxy: <xmx:3w16aueTr1vB83LIaAxKCvxRXWxyPkUiZMVdKNiI5AVhxX4Y4Fqv_A>
    <xmx:3w16ao7xRgJ2kOdCxgnWvpL3geP-JOSxBeg3FMEU22CH-y18GGwlmA>
    <xmx:3w16attB18-biJIx6scXzNwQ4iEGYmvh39hWA9PKsietgZgA0L67qA>
    <xmx:3w16aggsA9ZwSGF6AMmWVg5cvmzGMU3o6W6qPPggpzA92sKahZVl0A>
    <xmx:3w16agpLI_T-vyKrXZU5DEBtMf4trLpFY3osPsyuxi8vRYs2Qk9ZK1r8>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 62708780070; Mon, 10 Aug 2026 13:43:59 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: Af7HRwfiMKVk
Date: Mon, 10 Aug 2026 13:43:42 -0400
From: "Chuck Lever" <cel@kernel.org>
To: =?UTF-8?Q?J=C3=A9r=C3=A9my_Jean?= <Jeremy.Jean@oss.cyber.gouv.fr>,
 linux-nfs@vger.kernel.org
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 stable@vger.kernel.org
Message-Id: <ee2b8840-736a-4f6f-be51-4e57859da6cc@app.fastmail.com>
In-Reply-To: <20260809170748.1223617-1-Jeremy.Jean@oss.cyber.gouv.fr>
References: <20260809170748.1223617-1-Jeremy.Jean@oss.cyber.gouv.fr>
Subject: Re: [PATCH] SUNRPC: wait for in-flight client TLS handshake callback
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: quoted-printable



On Sun, Aug 9, 2026, at 1:07 PM, J=C3=A9r=C3=A9my Jean wrote:
> xs_tls_handshake_sync() gives xs_tls_handshake_done() a reference to t=
he
> lower transport before submitting the handshake request. On timeout or
> signal, the synchronous waiter drops that reference after calling
> tls_handshake_cancel().
>
> handshake_req_cancel() returns false when handshake_complete() has
> already marked the request complete. In that case the completion callb=
ack
> can still be running, so dropping the callback-owned reference in the
> waiter can free the lower transport before xs_tls_handshake_done() sto=
res
> xprt_err or drops its own reference.
>
> If cancellation loses to completion, wait until xs_tls_handshake_done()
> signals handshake_done and let the callback release its reference. This
> mirrors the server-side handshake lifetime handling and keeps the time=
out
> or signal return value unchanged.
>
> Fixes: 75eb6af7acdf ("SUNRPC: Add a TCP-with-TLS RPC transport class")
> Cc: stable@vger.kernel.org
> Assisted-by: Codex:gpt-5
> Signed-off-by: J=C3=A9r=C3=A9my Jean <Jeremy.Jean@oss.cyber.gouv.fr>

Reviewed-by: Chuck Lever <cel@kernel.org>


--=20
Chuck Lever
