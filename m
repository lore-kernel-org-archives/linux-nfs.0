Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 25FDE23394B
	for <linux-nfs@vger.kernel.org>; Sun,  6 Sep 2026 16:22:07 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788711728; cv=none; b=h8hSJxxKPr6nkWS/wZrJQQFprDX0dqyiem2DkrX9SPuYzP60gpqRwKKyqM/i1Jt98zEiwp7YxuzcuIlAJ9PyaZI9hAYhtVTofflbLR56te0uD4fL42zs+5wWaOqRD5Ok3xqGLBhIg5K/ITfY8ytoxY5pAoj77SerSr3QIiwvXh4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788711728; c=relaxed/simple;
	bh=nQVecsfLTTWeU7X0LyM7NtmHUZ3Y2h44eVfEwBw8sWM=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=pQ4qphx5oJvkyBg0Ppp4c+0tSOQ/Jy0QybiB4GG0/w25EhcvCMUEtQ/Ar96pVa5s4KlA27Gc34yKFl4GZNz6w9Vx4yombF6yEkshmoRZqrXS+aq/1Ne/nTC7DlOHPg1hLGirKpza9P2U4f4DEiMnv0kmgnWShQWkXXRwnYmFR3A=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=BoFRmdcB; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="BoFRmdcB"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B12D31F00A3E;
	Sun,  6 Sep 2026 16:22:06 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788711727;
	bh=qXRReA3fIrTQAvBSSv9pagwuWRLqTWi55PBJWR6WXRc=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=BoFRmdcB2WZVGp/JycofP0R5c0eHpkQWYWKZ8hpAMZdVbKViS1ZLf5xwC+FcGmjrF
	 vJ0/F8pwZrRAelkUDIhkStpHBmKKeC7UR+GbcibKu0Ba5k1lIQfAOxaG1tvXe078+4
	 G3eS86UVKDYauxvmkDR2xn1i0h9lJaoP1m2dX8CMnm7r26bKKoLcoTxw60vAvlPa4j
	 CiFcLlu5YvbtFDZGPF8mG/wF92RlVo2YwVA9zfLeqMCqyizRnpNeRxmo09ipg8BXLE
	 PrTAWaqQh9BW3/n5otiePb21CwO65o51WFm4VK5DD/mldViQsYCzsmegQevsH6yN46
	 gijL2JDWNQ3IQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id C583DF40067;
	Sun,  6 Sep 2026 12:22:05 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Sun, 06 Sep 2026 12:22:05 -0400
X-ME-Sender: <xms:LZOdaqSiPecz5ghIo-mLC6xqZb-LTML1HBgrUyTs9_nCI81U-cIfGw>
    <xme:LZOdaqlrHNj7Y-iRBAcPsfD0yrnED__02QRdvcnfdMW9HwuWKUNMtsisaJExBIFiW
    icwHkKvWxOhJh8mF6Xpza2-2G6rncwznCjfPHmEKtBpWzumM4xrDBF6>
X-ME-Proxy-Cause: dmFkZTGs7CzlLABK42Ygv8i+9sRvb1XcDCd2j1bUJGZD2TsupgtxYxvkecfWm7n7xS4ylM
    duLkYTVYUZ+hZYw8dY11sucaZU/ppHDPTfELtAC2can06gHZHEC+paga83aj7m9FXQ6roN
    fmq/C+cOhMWNnnHDNSKgT4WsuP8hhQXIrDrdACYmcN9Jw5wHnM0YHd4d4Wh60s8Io8cIe7
    tTnT9fq9GMQkfRPV3tytY1iRjLu7SmMRmGgmFczG20rozQF5++naT9PgSFjDggJVj4/VUT
    9FHaqIJnIH+pwsZjE96I59VO34sooxZRD1P0bezWPJFpaGv/Y9wwJPRBGyvGMfhl1vBcmI
    DeAWzpJWn5VA4wxaOACZQsh0iKkkDnDvyPSkDDjV2r9kNdJf0tb1C2ZXaLlhQ2gshx7Nnq
    z4zXPJOIPmd84BXkRWwbmBJZY+num/LoswXtRe6SyorA0Ty9I7MK2t/6Aon1CS+MEoW2Gs
    IWiq0ll4LCOYD7yhyp0jP6aXTJ+5aP69nWQPDsAAvbmBK9jXEs2Kjl9x7d+K2sh4oiMCQl
    3Al0DDPMrh2YiMlqXJsJCi9yTYQcNF/yzqGLRNU1LDj//LEu5Ct4Y0rTZbsqsDTn6leYVr
    dc3LHf2qro48uSNpfF9FlGHLLAQa7TKQROqTJBSbIq8bp2ZEzHwf5FFlHRmQ
X-ME-Proxy: <xmx:LZOdanjrIA5J1kIHooh06pGa095HZIazTxvh7fM4JLpJl7Zw3F1_pQ>
    <xmx:LZOdakfI08tZ3z_leKNiocrHkzOF1EIQ_V7ruboM370Y96390HQjtA>
    <xmx:LZOdanwMlwteqEeU7FxECYna2Uhmq9xzcQmWBaM7SslS-JOwQ2WPOQ>
    <xmx:LZOdar2foyZAql3RmTUim29g9uFIVB8yKeTEd5a0lvpxVxSWP_baqg>
    <xmx:LZOdalwKERFXsbOk4mq158NdJMDdgj8OIKBx3gxSBQbE6ZII4IDBYz14>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id A37757811F0; Sun,  6 Sep 2026 12:22:05 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AgpFG2YqzZmg
Date: Sun, 06 Sep 2026 12:21:43 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Tim Menninger" <tmenninger@everpuredata.com>
Cc: "Trond Myklebust" <trondmy@kernel.org>,
 "Anna Schumaker" <anna@kernel.org>, "Tejun Heo" <tj@kernel.org>,
 "Lai Jiangshan" <jiangshanlai@gmail.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, "Eric Badger" <ebadger@everpuredata.com>,
 "Jon Curley" <jcurley@everpuredata.com>
Message-Id: <425864a2-3276-4c16-a861-32defe5e04e2@slotpi15m67>
In-Reply-To: <20260904232342.1907377-1-tmenninger@everpuredata.com>
References: <336623df-ead4-4802-91c5-aa3e785f2971@slotpi15m67>
 <20260904232342.1907377-1-tmenninger@everpuredata.com>
Subject: Re: [PATCH RFC 6/8] SUNRPC: Reduce rpciod workqueue contention
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Fri, 4 Sep 2026, Tim Menninger wrote:
> With your v2 applied, all-local windows fall to roughly 24-28 GB/s while
> split windows sustain ~46 GB/s.

So on your system the interrupt pinning I suggested would put every
mount into the "slow" placement.

(Pinning completion vectors to the local node still helps where the
dominant cost is cross-socket reply traffic, but your data says that
on your configuration, with this series applied, spreading the CQ
handlers across both sockets matters more than keeping them local).

> So the CQ allocation determines whether the regression is exposed, but
> mainline is insensitive to that placement. The series introduces the
> performance sensitivity.

Agreed. What it does not yet tell us is which part of the series.

Now that you have a reliable way to force an all-local window,
would you run these on top of 940de590b839, each in the all-local
placement:

1. Patches 1-2 only (the XID and recv_lock changes).

2. Patches 3-8 only (WQ_SYSFS, workqueue_set_affn_scope, and the
   three scope changes).

3. The full v2 series, with all three workqueues set to
   cache_shard at once:

     for wq in rpciod xprtiod nfsiod; do
         echo cache_shard > /sys/bus/workqueue/devices/$wq/affinity_scope
     done

If 1 reproduces the slow state on its own, the scope patches are
not the cause and the question becomes why removing queue_lock
contention makes node 0 concentration visible. If only 2
reproduces it, the scope change is the cause and 3 should recover
it.

Also: per-node CPU utilization in a good run and a bad run, e.g.
mpstat -P ALL 1 for a few seconds, or the per-CPU lines from
/proc/stat. Your perf capture showed a lot of idle CPU, so I
would like to know whether node 0 is saturated while node 1
sleeps, or whether both are idle but completions are serializing.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
