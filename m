Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=209.85.222.227
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793898447;
	b=jOtWVRS10gGOEoiV40HyroX3/wXzsMleJhuQiYPdEsS1dqDfO+3K93nIUPn5ZWnSqWrA
	 fioIsJeCvNOuZoGOTv8uoeS2mn2e3XzlFj73atfCinbFW1svijla3Evhx8lX8uD+n9Xnl
	 sn9NtQoKJ7/yI0Zjxp/wZspb5auZL+LPQP3+RuRoNTFPbuh/dpGAx84AjXdDRjecin5ya
	 yvtif8ukRklmVHbcIM8eU5gMXmI7/W6tihwN3qxIxyagzAphFFr0wQVksz5NEQ/dAv4V1
	 nqy46PFZFhw2gmxaJXrOU9IcR3KSgrjQXrhbRtjYhMj8Lb4r8pehbSQphGQdWVZmIXQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793898447;
	h=DMARC-Filter:Received:DKIM-Signature:X-Google-DKIM-Signature:
	 X-Forwarded-Encrypted:X-Gm-Message-State:X-Gm-Gg:X-Received:Received:
	 X-Relaying-Domain:Received:From:To:Cc:Subject:Date:Message-ID:
	 X-Mailer:In-Reply-To:References:MIME-Version:
	 Content-Transfer-Encoding;
	bh=RDOVG3cpKCfgE6B6tnKo2t7K+1619D3zF9SRV6224FU=;
	b=0gQAsD6abmH/kZLXf2L7k0xFItAO4NkFYf1pBLdAX3ItlwMMSyygGl6pRMhUd4bm8645
	 E+tXGw1dfn5MnCJ0vTD1Lvfn6TCG1umDaIyOmb47trYLOENvi4n34dZwSquwQcnf7p2kN
	 vNTJFPb9M0pc5dfQ19oK+Fbi7eUHBiHfnR1VtPFwViBPRTm5+FRi6IjfyOSg+7RWmt0yj
	 k5EgAAeLD6i6mUjLrUOblZa9N+QJ8zxVXRrzmoj40usKZtaMaWadWOaS71zhvSdM1MCf6
	 ZsbfsgmO+uS/RfqyRKAnuUS+d5p7Id5GEKUERy2XQKUVUSKEfB7Zz4heIRRH5/uHyjA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=everpuredata.com;
	spf=pass smtp.mailfrom=everpuredata.com;
	arc=none smtp.remote-ip=209.85.222.227
Received: from mail-qk1-f227.google.com (mail-qk1-f227.google.com [209.85.222.227])
	(using TLSv1.3 with cipher TLS_AES_128_GCM_SHA256 (128/128 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5984D606A328
	for <linux-nfs@vger.kernel.org>; Thu,  5 Nov 2026 17:07:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 5984D606A328
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=reject dis=none) header.from=everpuredata.com
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=everpuredata.com
Received: by mail-qk1-f227.google.com with SMTP id af79cd13be357-93f22a8515eso196522285a.2
        for <linux-nfs@vger.kernel.org>; Thu, 05 Nov 2026 09:07:26 -0800 (PST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=everpuredata.com; s=google; t=1793898445; x=1794503245; darn=vger.kernel.org;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:from:to:cc:subject:date
         :message-id:reply-to:content-type;
        bh=RDOVG3cpKCfgE6B6tnKo2t7K+1619D3zF9SRV6224FU=;
        b=R0jQ0Mv6Tt2wdQgfQpY4Zah4vKPlzSzNJeN9VLU3IwbWi6Tcfu5CXaOZEoxhGURNKF
         GwBiFgy5HZ0UDyGkFGiV0uExMbWDeQ6kRLLM9opqnAJN/v6+isOSn+Cpz50n7j0Zv79D
         goEZ6DW0JlEZtSH4X5UjsXPlyNvtrpQxqQ6HdqposZjEAumTpcyWQEtjaM2E3HW2I3n9
         ZP7OySFjoFhIZtP4uclXe7kEosPYpdbI/+H+ih/1WXRzFnSZYipuXtPZeV+hC5nHcFYr
         9bdSfIQZrxVwpZXlwWF5iGbVc6cbDQXE7WUQG/TKAuIkgganFCp4/+40SckGG0/fD6at
         3Qmw==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20260707; t=1793898445; x=1794503245;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:x-gm-gg:x-gm-message-state:from
         :to:cc:subject:date:message-id:reply-to:content-type;
        bh=RDOVG3cpKCfgE6B6tnKo2t7K+1619D3zF9SRV6224FU=;
        b=A0sIGdn2WAz5KNyaqeoeOXSuZSXHDnQ6OPZCjT7y7METE6QxQjBOWYOE5KA0A2WL0O
         n/kjdVPMhb8sK3GX5D7zgb7NWxlHY1LYjMKqBBQTlaiYx6ba6MCrC6ezGzU5KqCd7xtl
         yMaVNmu2EW72LQwarx+HE0OnYrvlKE9cpw0jYRbQIE7snoIA+TcLFdsjUkEcF1snXbdt
         Nd1ZkGCCDerdaSFGZdHYGTvTWK5TGE2wFCmyVU4aUnLfSckSQ+C0og5rDKcaDL+3Yfat
         ze/WH0Yv+br5LvJakDyzN/pIdvBqpcxZHM9qxlTJXwKe5Uly6kXR5pD9t6Db0K8yakFn
         h16A==
X-Forwarded-Encrypted: i=1; AKwUvBwBeViOnVIiO+3Hk/ajCXBurel6qZ4KWcBFHNeMDbewkLsa3zZ41mSL5Ej3czo/egDtpEvZWoEm+aA=@vger.kernel.org
X-Gm-Message-State: APuU4Z9gJZI32RywIpbNVuR1ywjva5n2voxPEYPsm4pPTEl7+ME+AHdr
	T5ivQW/Hq6P9/S0o46wXDDtn3bPKb/jIx6rU51wwGeCrHiErH+CcaLqnjwcnEivrjkAe2MSXLv8
	BX+P8Np9ejXl0RKY9+9rLZNZPvkxV+hUcJggk
X-Gm-Gg: AYBFou2zXcxwYt6i4FWbxxzT/NkHBB4Lin9ANP5gfwApfnPL+vsuqP1h/wZiVisFZpS
	xUCVo1tROdURoPRnK1bDDPgV6ePM4Xf/O+9nijLIl34rfSz1/24oZ90JZf3bEKHWIK3EcdMPeJT
	Jie1YL3dJTCxPXRZ4yRfXuqKj4Upn9CJjUZYKXfYPDdMxPPtFcg3+zuBixwkv2bLL4OKCrDOZgx
	EQH7JDAS3SI0mruuFGcUJKaU4vLVixatUhVNoaXBNBk2UpG4mH1ZkJkMNlFdf2pzuPprXqsrpq5
	mlKpjSkm/b2fQNFz2nGzienQvvxtXJ89U9w2Jgb1kK8LGJYn8/rrs+RfqIKjvGJdF0qkF9OO1kV
	L+VkgsVha3I/kR8cKqljAGeKMBxZJ6uSRwkuA/i0=
X-Received: by 2002:a05:620a:2987:b0:93e:623d:99ec with SMTP id af79cd13be357-94421744cc9mr3322483085a.13.1793898444949;
        Thu, 05 Nov 2026 09:07:24 -0800 (PST)
Received: from c14-smtp-2023.dev.purestorage.com ([208.88.158.129])
        by smtp-relay.gmail.com with ESMTPS id af79cd13be357-945d47853ddsm65531985a.8.2026.11.05.09.07.23
        (version=TLS1_3 cipher=TLS_AES_256_GCM_SHA384 bits=256/256);
        Thu, 05 Nov 2026 09:07:24 -0800 (PST)
X-Relaying-Domain: everpuredata.com
Received: from irdv-tmenninger.dev.purestorage.com (irdv-tmenninger.dev.purestorage.com [10.32.149.15])
	by c14-smtp-2023.dev.purestorage.com (Postfix) with ESMTPS id 41BC634039C;
	Thu,  5 Nov 2026 09:06:53 -0800 (PST)
From: Tim Menninger <tmenninger@everpuredata.com>
To: trondmy@kernel.org
Cc: anna@kernel.org,
	cel@kernel.org,
	ebadger@everpuredata.com,
	jcurley@everpuredata.com,
	jlayton@kernel.org,
	linux-kernel@vger.kernel.org,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	slingappa@everpuredata.com
Subject: Re: [PATCH v2 1/2] SUNRPC: add request-scoped disconnects when cancelling tasks
Date: Thu,  5 Nov 2026 17:06:53 +0000
Message-ID: <20261105170653.3200815-1-tmenninger@everpuredata.com>
X-Mailer: git-send-email 2.53.0
In-Reply-To: <b9ed2a8b5f687d7f581d4867a7867c5c012bb2cc.camel@kernel.org>
References: <b9ed2a8b5f687d7f581d4867a7867c5c012bb2cc.camel@kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit

> I'm all for optimising where it makes sense, however this is adding
> another spinlock protected section in xprt_release() for something that
> is clearly a rare corner case.

I agree about avoiding the additional lock acquisition in
xprt_release(). I should rework that part.

> So how about something like the following change instead?

I tested it with the same reproducer, but I still see the reconnect
behavior, without a noticeable improvement.

I think there are two separate issues here. Counting only successful
cancellations avoids triggering another disconnect merely because an
already-cancelled task still matches. Cancelling untransmitted tasks
separately also avoids disconnecting solely because of those tasks.

However, when cancellation of a transmitted task succeeds, we still call
rpc_clnt_disconnect(), which disconnects every connected transport on
that client. That can affect another transport which carried no matching
requests, or a replacement connection generation established since the
cancelled request was transmitted. Neither RPC_WAS_SENT() nor a
successful cancellation status update tells us whether those connections
carried the affected request.

What I'm trying to do is limit that blast radius. For a request with
rq_xprt == X and rq_connect_cookie == C, cancellation should not
disconnect X if its current cookie no longer matches C, nor disconnect
an unrelated transport Y on the same client.

Would retaining the request/connection-generation scope, while removing
the additional unconditional lock acquisition from xprt_release(), be a
reasonable direction?
