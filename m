Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795446620;
	b=uypMdgCXRHkIxD3hryatsDlaDbW3Tql/2yOu0FmkKxAc5GR4BTOGgt5OMlSyCpuH6KPu
	 CJsqtJUaK1Gwa7nypkN9KwhJet4zx3uMxDDNQveTTlr1/q864S+b3cjLjfKLWLqTjMMC5
	 cO+PgHwox4Ugvs1EQEUqkCJ9FnoH/QY57g3GB0lpO/MRF8h29nzyTK44izm56AfQopZCM
	 Kmm24YTopCMvK6icxMRtqO/gIBtVmR406A49va1ygJGZwhUCodc+FKNsbRf1WSVeDCiMc
	 FwlC9+x0+jk2j9F6ufqDII8n1Gf7sOfKicXeeK0/j1gMA1TqIPWZV5rPc+OSgOMpjUQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795446620;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=LY0Ma2YTT0tb1ngWtv8IXluWXqW3x+R5fspk8pYjvvc=;
	b=egwY9kkb8TKCyrim/znMLAcKJt0SPOCn28lU+H3ZnR87ymIPw44mybPujcQ9uZRguY/W
	 dq07wM1qghIItW7X0J67hySdDtfosuu52VcvjetAcd8XlVGGIGrD8P/AvL9z7o4i2S5zY
	 Xe4nOiqD7RhoPt756e4c7MQwzx8o2JLfT6xzqFAtrzY2oMtOILtJZJTPcEOqUCw5mKwG5
	 3S7z0WB1tlte6aMNGg10ptLNCN/WLjAjNW47Hn4EpL4ycwjg3FGRc9Ok85UOAKSA5XFzy
	 pPAfzMVIUm4QvRRUS66byFI7/zg+NIssTYul1Hk0KI6/s+pxcbFe2KuKlZHWrzNYQAw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b="HGVGgf/s";
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 884F9606A330
	for <linux-nfs@vger.kernel.org>; Mon, 23 Nov 2026 15:10:20 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=HGVGgf/s
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 186191F00A01;
	Mon, 23 Nov 2026 15:10:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795446620;
	bh=LY0Ma2YTT0tb1ngWtv8IXluWXqW3x+R5fspk8pYjvvc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=HGVGgf/swyJkcjbE5hMPvjiV+Y75rTc6lv4gh3DtmJ0mH6Z+HCtJypXZuxGW6m+ih
	 V96nFT5PR3jwgjSb79ut1R/BuEKzwuxbysqUEzqurIZrnK+15gpSSmbWYjaIm7yl1z
	 Rvh3Dhb8f0HXxskMrpWQXP8Ed8MOuXv5pXxAgIwjtWLPKS1iXQkKn5ezIbVbmsh8ud
	 cWFNgaNGt+sej1YwBvyJhq8DbaoNa29Sy9A/SYEQwE/uoTxwKn1RYVqc8baJtKRsYW
	 4vh/4RiQxumZQtcChwPg0lNhQ5juLELngUZRt87eEd2hwFk/3YDQPlJ8qFrv00AKOV
	 eUGfFNhe6cJjw==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4DB06F4006C;
	Mon, 23 Nov 2026 10:10:19 -0500 (EST)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 23 Nov 2026 10:10:19 -0500
X-ME-Sender: <xms:W1cEa8fAqxookxXD56rcn4f4NA6GpddhTtlbsoU3vHnQJphkkZjlXg>
    <xme:W1cEa5CyVs8XVbhHIMJ1F7UNLRjzl22wq5GpqEI-lMXnLb1I_XeruQ3gZz5sdCIKk
    fOX5tlkw5tomw_kr0tbHnB7YMSPPFlm2nMIWvYdtqLhV2nwDKokdRw>
X-ME-Proxy-Cause: dmFkZTGtj2x37u99ZMo3oRwTVhzqHO+vIEwn9KkWid3ijrAsOVZYPBZLXn+zBqTdIOevx5
    dH5l8SkjKzTijH/Goy3QAn9oD2rUAxFLch5LS6W2ud0Z6hEa9vgTz5vjpuWszcNrpFMFMF
    Uy6IP70fKhnxSrVR0nCiOSDqfwvLg/tafq0zMEs/JNO0FsoJU5cuxm3ZGZEOCz9u8UHL0i
    RMGt7s9MsOGS8fIYriZrg3GnvijWqZOI/vNcDb8azA+xRSoIV+4f/NfV7XyAr914WLKDqd
    yifcLpMqAyFCoTDyHQJ0mR7SY/ik1PQjLYuhw08B9lfrlBrVzIqVdTP74c0nVTzVtLLwkF
    68R6rZvByQ0MyOhYz1r6pD4a7y9LwrzlsaOFBtZOSUY5+MZSm7BP19Hr0EL2cVoVOpxpc2
    9Y92bTNITgFwAclR23fPI/PZ7UsdwG405bEsCV+z0CGvDiYqYEaNlVv9MMHGbMHQ12j2sv
    tp6ezqTK/AOCY+R4zlr/f31xszHU79trbVC7+5XCOkAsi5B9Ol+RSwOlSnVMbXzdoF4AD/
    MFEkp4t29MZudtcOQR9gveKWLsLQrjut66uMc1jjUayXkH0ww2H+o7d5wxxP3Cafub7FlJ
    m4NT6wqSWY7mwiaHYhTZHCiNPXMW4oMCwjs2NFj8jPtGUM1ShX3CSioguqMA
X-ME-Proxy: <xmx:W1cEa58XrubbV3uf-zjBfkZQTAJJnR0hZRTLHh_xV0rbVL1Nwcs0VA>
    <xmx:W1cEa5vmpCoYt1uRRgg-unsYtieql7xPGyakg4Z9huaOqR7kkCwktQ>
    <xmx:W1cEa5PCDNNHVBVAsiRCvjYw8RL0sigjH9-h5_3NL49ZlzgR3Vej_Q>
    <xmx:W1cEa-jKdl9GiEFsBbqBmQCsqX7wCvdVnLguGNaCbESiv8gqMl7cug>
    <xmx:W1cEa76p3iSFmHeMh2PYqUE-hMHuCbaXVXmCzqHB7KVEaPidfYvUEHax>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 3131B780077; Mon, 23 Nov 2026 10:10:19 -0500 (EST)
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
X-ThreadId: A6sD4Nk7Fv--
Date: Mon, 23 Nov 2026 10:09:59 -0500
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, linux-nfs@vger.kernel.org,
 "Jon Curley" <jcurley@everpuredata.com>,
 "Eric Badger" <ebadger@everpuredata.com>,
 "Shiva Lingappa" <slingappa@everpuredata.com>, stable@vger.kernel.org
Message-Id: <90d0ff6e-e9d2-4b2b-9b89-8245ce502e99@slotpi15m67>
In-Reply-To: <20261120010342.2152535-1-tmenninger@everpuredata.com>
References: <20261120010342.2152535-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH] xprtrdma: Retire the connection generation when a connect attempt
 fails
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 11/19/26 8:03 PM, Tim Menninger wrote:
> -	} else
> +	} else {
>  		rpcrdma_xprt_disconnect(r_xprt);
> -	xprt_unlock_connect(xprt, r_xprt);
> +		xprt->connect_cookie++;
> +	}
>  	xprt_wake_pending_tasks(xprt, rc);
> +	xprt_unlock_connect(xprt, r_xprt);

LGTM, with a couple of cosmetic suggestions.

Moving the wake above the unlock keeps a task that records the new
connect_cookie from receiving the failed attempt's error. The code
before this patch and xs_udp_setup_socket() both unlock first, so a
later well-meaning clean-up could easily move the wake back and
reopen the race. Let's add a comment above the wake, to let readers
know this ordering is intentional.

Consider moving the cookie increment up to just after
xprt_clear_connecting(), so that every connect attempt bumps the
cookie in one place. This is an optional clean-up for clarity.


A couple of pre-existing bugs turned up as well. I'm noting these
here for the record, not as a request for you to address them.

1. xprt_rdma_connect() never applies its reconnect backoff.
   rpcrdma_xprt_disconnect() always clears r_xprt->rx_ep, so the ep
   check in xprt_rdma_connect() fails and the delay is always zero.
   call_connect_status() delays an -ECONNREFUSED retry by three
   seconds, but a reject with IB_CM_REJ_STALE_CONN maps to
   -ENOTCONN and retries immediately.

2. The AF_LOCAL transport appears to have the same stale-cookie
   problem your patch fixes for RDMA. xs_local_setup_socket() wakes
   waiters with the connect error without bumping connect_cookie,
   and a successful AF_LOCAL connect does not bump it either.

"2." suggests this logic would be best hoisted out of the individual
transports. But that's follow-on work for someone who feels
sufficiently industrious.

Reviewed-by: Chuck Lever <cel@kernel.org>


-- 
Chuck Lever
