Received: from fhigh-b4-smtp.messagingengine.com (fhigh-b4-smtp.messagingengine.com [202.12.124.155])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C9242419313;
	Wed, 29 Jul 2026 20:46:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.155
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785357972; cv=none; b=DvYWLIwiaI6UQHUGeLY9/9Y5QrYJ8thCy5ghaDBdrBSmlwGsKx7Qn4nZMWid+0WSTv/b8QTiJjQcWE0VlIua8rVbLdFgAdNS95iJGuvS6ZFS8GgdclyvuNYywbSUxVA1nO1JrP4PFRadLgmu+tOKRde5hvNjWIFKxarN48/azv4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785357972; c=relaxed/simple;
	bh=iIylnDyNlKqUY19HIHdYELhce30PoGQsrN41zwDN5Qk=;
	h=Date:From:To:Cc:Subject:Message-ID:References:MIME-Version:
	 Content-Type:Content-Disposition:In-Reply-To; b=PrfgLNXdh7Y/4uD+fvRoAKo6WSB7+zYOVCPFMUHF/rBK+R8Ag7OW6t+HGOLRa0mlvyz2cHmzHYzjwrp2uEjJrXv7rUsGlOjZudkn6IyIdfvavbS7I+G1BdbTvSoqLhag5ncVubHADAJWb//V53zytpr4Je4++/7Ma0EUSd1PeAE=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=fastmail.org; spf=pass smtp.mailfrom=fastmail.org; dkim=pass (2048-bit key) header.d=fastmail.org header.i=@fastmail.org header.b=gEYZvwMc; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=BRAekxCB; arc=none smtp.client-ip=202.12.124.155
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=fastmail.org
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=fastmail.org
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=fastmail.org header.i=@fastmail.org header.b="gEYZvwMc";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="BRAekxCB"
Received: from phl-compute-02.internal (phl-compute-02.internal [10.202.2.42])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 3F1BB7A036B;
	Wed, 29 Jul 2026 16:46:06 -0400 (EDT)
Received: from phl-frontend-04 ([10.202.2.163])
  by phl-compute-02.internal (MEProxy); Wed, 29 Jul 2026 16:46:06 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=fastmail.org; h=
	cc:cc:content-type:content-type:date:date:from:from:in-reply-to
	:in-reply-to:message-id:mime-version:references:reply-to:subject
	:subject:to:to; s=fm2; t=1785357966; x=1785444366; bh=iIylnDyNlK
	qUY19HIHdYELhce30PoGQsrN41zwDN5Qk=; b=gEYZvwMc54tRmBfwAd7+GvA2il
	8qB/GFN4TTG3CuPopOLn/A8oDY2kGlZfyBPWtUNeSMgdRxYhiZq1ZxDB9F4wAvtz
	g/FKYbIT2yX2vmzkSygQG8NS2VnLY7Ll2p/nXOPTOG38YjO2Bbib/fhrEJn+kYtA
	t25fvAN4qOlmCYJ1Mvzwd6IPEBPm3lSn+0S5ddMJGCm96xCD6Bcr173wLkRcwZ+l
	m1+X8Y72u1XZEU0sCy4ei2n9AdbM18dgCgyMi1fuN0M6PvIiWRpLxiAl7oNucpYz
	wy1FOn+n3qvgYsUmjK+25kzc0jUYh3EQmxzYAzukrUmO23rhYcP8yhlslGSQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-type:content-type:date:date
	:feedback-id:feedback-id:from:from:in-reply-to:in-reply-to
	:message-id:mime-version:references:reply-to:subject:subject:to
	:to:x-me-proxy:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=
	1785357966; x=1785444366; bh=iIylnDyNlKqUY19HIHdYELhce30PoGQsrN4
	1zwDN5Qk=; b=BRAekxCBrDfGIXc6y4YEW69DeDCA5Acrd21DOxOP7wLWxQ7E7q1
	FYm/aNLGR5euBHhQhqctjqCkSsjE8a8zk/uDKKVuVxtyHMpgsRn2MjqG3pdUQrZj
	/j2lWUoDuUvpWU8BRbMTxqNiF4JybaizFcmtTjtqS8s6rS3ltlOSYI0Yj1lT0O4u
	O/ONIq49dI347nxEHiCTETJkLmwYuSuqx6a/SGPQPf3upYMHFIH6DMKaroBS/3oF
	qLSlvIYxd+YuA4iqSvwN0m9foGkZ5DGXf+2E8moW/6PV1KbUJx/sye15RfHDby2x
	UsF25P5PmRhyKvDMVpSM0pap4YWAaSP7fjQ==
X-ME-Sender: <xms:jmZqapJHCPiCA6U0imISsQLtQkH5itjKnz64ftdAheaF9YiCBUC7Xg>
    <xme:jmZqauH-Z6Z5fR_kdSRlb6_n6krhm0qiSEdsM0ZKBW1MlNl1r-YVKIfevBSzV33Pa
    z0DckRjJZgm59B5t1tCUir_xgYNr1XGGHWUNfVtBFRaGYqXUZPqh-g>
X-ME-Received: <xmr:jmZqatTz6rT2PHSwG_-k7BeWLANdSwUpDtsIIRH7GKPMSYYXWrGyZ2rJjfg>
X-ME-Proxy-Cause: dmFkZTFWxyAeYcJlQ6RAi59ZK0Xo2hCgWvMnN0gSAosUFzT+iBr/hlKszy6To4/eNCMW2+
    jD3txodtQ0SG+cmv0LCNoeUqAviseSYdaFzzTQO4un6wwUJAUm2Yl2xCGWvRjuiShPyQ3c
    Hvg2zRC98GdNeXWHEbN+Cp5uiYAHe+ytRakDZKQOOaRy4kUxmck0OYu+zVxxbzCDh5oKDc
    k3ZT2YkJumtzwXCQGtixUKJXRETvmiwZ7cPH7lVZXH9mpVlamMYqjGVZUmDGV+uqAyOqcb
    CnPqVAzc4zm0gqzAhniKiQUJVj0+h14x4LOVENFcyo6kNExHo4yffDCKxLJBABDMnGX9Eh
    lnWg0N2wNABgwNkrEvSjablvedENQflqhdA8jDGZSag74LqYxTSotVr00JP7m5+wQJJQDK
    cTohFaUz2wvU0sTNUWg21QaH+Gam2kXRuQ9+1BA+36N3K0D5pwMKKlj/RH3zUWeBpqgCDQ
    6AQgxtqMtbB7T8Gq/vJk8DykxFcZDAjd8SsczWeA+xQvm0l65QdIUw80a2h99gzy3OxTqv
    b88RtZrg9isnmKkSQSALj/lixlMDSfy0b+tKq2Vvq/s0TlQhCeAYyfI7YRWyTvWprVkEa4
    72MH8E5q5rqDmwaCQ2dZCMGWX/2AxjmMUXQg5kI1vvCwF9fVjS+El/84OFDw
X-ME-Proxy: <xmx:jmZqaqeK-7U5zIfAAPM_WIPnERWmC9rTzxC30THerhOJsF1NJqnWUg>
    <xmx:jmZqasptY2cA7QlUIZ4aPpv0mBI5eZhTg3bt_oYPJ5NJP4Upe1hnLQ>
    <xmx:jmZqar-qHqCGWar5eW_yhlpSwopGd2Mw4JaS5VV89Cc-_HFsPFfJzw>
    <xmx:jmZqaoccACsvRmhYYkefo5PQhLAnTPhGQdt5qP6_frnPKZxINLFCrw>
    <xmx:jmZqaikuMmGVzQY6EMxDJ0XLnfWXTBVnoqiJjlT2NX3lN_FDRgsMYyPy>
Feedback-ID: ib53e4b78:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Wed,
 29 Jul 2026 16:46:05 -0400 (EDT)
Date: Wed, 29 Jul 2026 15:46:04 -0500
From: Ian Bridges <icb@fastmail.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-hardening@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: Replace strlcat() with snprintf() in
 rpc_sockaddr2uaddr()
Message-ID: <ampmjIxEAmUkHXyM@dev>
References: <aj9bie25tpHnz7_G@dev>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <aj9bie25tpHnz7_G@dev>

On Sat, Jun 27, 2026 at 12:11:41AM -0500, Ian Bridges wrote:

Gentle ping. This patch has had no response since it was posted on
June 27. The code it converts is unchanged on mainline as of this
week, and the patch still applies cleanly. Happy to resend if that
is easier.

Thanks,
Ian
