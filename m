Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795214823;
	b=dCAqQiim6E4SDnxHS4DZUt/OrwUqmqTCWjvZqcWEIVcIPznxpFnvq8IxEFr7WQYH/YTo
	 UAkvwJo6r+OHMBJxBnqLSpG6hHUYsqBRndEHtavG+mOYmwDHcKi6mZHoEL8yBDYVpWM5k
	 PRuASogR3BuwKIhggLhvuwMPoRYYTYcN5cB/YMlQE8ecGDcxGoqLWzRl8EsD2YxkpYQUP
	 jBg5qVHceQCWSdLBhhypZ6uxiWwRSwHoIXd+6xErUv/xOmLzErmAtxolnvUYN4GEq2BMf
	 hQGdKWOTPdbe1qsVcRcNRCBIzdWfbWAJK0X4zl1JU3x7Z1cr8pY19glGA9zWhDGEy6g==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795214823;
	h=Received:DKIM-Signature:From:To:Cc:Subject:Date:Message-ID:X-Mailer:
	 In-Reply-To:References:MIME-Version:Content-Type:
	 Content-Transfer-Encoding;
	bh=UzoHrg8v8r9LhhJH9bPwZ3E0glE79YH9yAGfODT232w=;
	b=hYu7pWjhL7fAgv7SnoknMRldTZXG18Jo4gE+fAgb+2pHQh0ohDnJHOiUsJ77iRAk7IDf
	 3W90SK5O9t7qs97QNeveGKNjNIYpLzwxxCFM41unDQF8IbhOdkThFWKP7IThL8XnmX4EB
	 TmTXr6bXAAdNo19kEGfuMjo8qQUrJujGSIN54t4HyyRY+VPH21yW5isEo84xY01c7DsJB
	 RRVTTCSSLhyoXrJYithi1ruFiP++gfh8eWl0560A9fo/2Qdh+aWpwOYCFZe5tcozddElb
	 +isn0Qmpmb45dvzC9fmAy1cZMQc1ntUw7t+20wo5xW077i42Y3mNcrG1qIuJ+3Kiraw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JKIoNQrD;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A81A3606A68B
	for <linux-nfs@vger.kernel.org>; Fri, 20 Nov 2026 22:47:03 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=JKIoNQrD
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8ED841F000D0;
	Fri, 20 Nov 2026 22:47:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795214822;
	bh=UzoHrg8v8r9LhhJH9bPwZ3E0glE79YH9yAGfODT232w=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=JKIoNQrDgv37bzbzODVPmTqWjfsajTL6O/dd5ZnRakNAvbfvlATJgliy1gbICfpiA
	 PdTw3hPTvhnBf4yC4MRBmFfuPmehLXZ4AnQ1Py6WgO0+BZS1SnD0O71bpzdv3otTnw
	 FglAPZcCt+EWqzG65QzK1ArwwPfDfr9ULkcL57W3n6n+tm9KOSJS4wgT2BSprXA92K
	 2RfvpEpuFEG5Lxy79woeQNzk179d+aLw9BoBK2aKULCZ5fKUKJDKvCJczj9khKbT0E
	 VCizllwRr9fo7h8kRBfoXqOGarXTyIHZ3KOP2OzIvXZLWrlGuE5HkITcV/5XYcUcLK
	 gL4RXAm1kwFhw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Dominik Maier <dmnk@google.com>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	linux-nfs@vger.kernel.org,
	dmnk+artist@google.com
Subject: Re: [PATCH] nfsd: only set NFSD_MAY_BYPASS_GSS for RPC_AUTH_UNIX in nlm_fopen()
Date: Fri, 20 Nov 2026 17:47:00 -0500
Message-ID: <179521481096.62451.7185239326341210292.b4-ty@b4>
X-Mailer: git-send-email 2.56.0
In-Reply-To: <20261119192336.2697518-1-dmnk@google.com>
References: <20261119192336.2697518-1-dmnk@google.com>
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 19 Nov 2026 20:23:36 +0100, Dominik Maier wrote:
> As documented in nlm_fopen(), NFSD_MAY_BYPASS_GSS is intended to let NLM
> clients using AUTH_SYS (RPC_AUTH_UNIX) lock files on Kerberos NFS
> exports, whereas NLM clients using AUTH_NULL (RPC_AUTH_NULL) are only
> meant to bypass authentication when NFSEXP_NOAUTHNLM (no_auth_nlm) is
> enabled via NFSD_MAY_NLM.
> 
> However, nlm_fopen() has historically passed NFSD_MAY_BYPASS_GSS
> unconditionally, and check_security_flavor() accepts both RPC_AUTH_UNIX
> and RPC_AUTH_NULL whenever may_bypass_gss is true on an export with a
> pseudoflavor >= RPC_AUTH_DES. Since commit bb4f07f2409c ("nfsd: Fix
> NFSD_MAY_BYPASS_GSS and NFSD_MAY_BYPASS_GSS_ON_ROOT") restricted
> may_bypass_gss to exports with pseudoflavor >= RPC_AUTH_DES, default
> auth_nlm rejects RPC_AUTH_NULL NLM requests on sec=sys exports with
> nfserr_wrongsec while still accepting RPC_AUTH_NULL NLM requests on
> sec=krb5* exports even when no_auth_nlm is not set.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: only set NFSD_MAY_BYPASS_GSS for RPC_AUTH_UNIX in nlm_fopen()
      commit: 824294e1f20b5dbd8420e77ddb3da230150f96c1

--
Chuck Lever <cel@kernel.org>
