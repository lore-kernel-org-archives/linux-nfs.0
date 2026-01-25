Received: from smtp.kernel.org (aws-us-west-2-korg-mail-1.web.codeaurora.org [10.30.226.201])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8E9CB10F2
	for <linux-nfs@vger.kernel.org>; Sun, 25 Jan 2026 03:21:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=10.30.226.201
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1769311270; cv=none; b=BfBjYr7jHWF1SkUXnJCUBhy/048zjROSKeFroQDJ8kNTjo5qNoAanU8w8cLJWh9YSZiX0Zzo7R3/DR00cPnWvGe+9PnAOmr29LnTrLrmZPwl+1RNcsJ4K2t+BFAiG2YcU+HNhHGUkrFIyQRsTXnAOlg1dKdiOLa/+s/S+scV4JU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1769311270; c=relaxed/simple;
	bh=QJx6WaQoR46fvHJckKYhJOjWhXB4wAxardRrcgCiRi8=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=EoKLIdOeinOIQrKdNL+gzr9z0pHwStcd0VEj3tllSbASZqoXlJsSbEswZoPuFTSJiqNeTNWPa2qbz3bdTcVwyXpTCoWshYJ6qcR3A4xcAE0HhZKFgtg1yI750Z3ndFi80T8+1OL2s6mP46oIPCLAtkHvHYC1EuBnaOa44U7kXTw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lH6IuSt0; arc=none smtp.client-ip=10.30.226.201
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lH6IuSt0"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7008AC116D0;
	Sun, 25 Jan 2026 03:21:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=kernel.org;
	s=k20201202; t=1769311270;
	bh=QJx6WaQoR46fvHJckKYhJOjWhXB4wAxardRrcgCiRi8=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References:From;
	b=lH6IuSt0ySNBVHp5zvC9/OWagtddZE3NvNsdRVDDlRvNgL1tm+y3I5ktfo8lpT9Yk
	 XrwrLSEkJ91yLHjZMZrLCkWoPrh77R9jqVqzGz6h3+yKC0wKJ+2F8wD6Ak0McCg1Uz
	 I2HCymeyzTEIlVUfh6UoDq3YvXA0ChmS+g6ZrD23az2N0366HW6OZCFMGic04Oo6de
	 qGo0UWRKpmT1+LdJ9/B7csyXKuwT62A24qWxWM4Whsm82hKifJw/8z5+IKiT+NU6nc
	 tv6sY3x3ygBudKI1A467fI2PY4DtO+9xk21qOC4CpNlWGm8Pi/rLN/jSaU6hEvakoE
	 /65vZ4B47O6ZQ==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	Kuniyuki Iwashima <kuniyu@google.com>
Cc: Chuck Lever <chuck.lever@oracle.com>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Lorenzo Bianconi <lorenzo@kernel.org>,
	linux-nfs@vger.kernel.org
Subject: Re: [PATCH v1 0/2] nfsd: Fix cred refcount leak.
Date: Sat, 24 Jan 2026 22:21:05 -0500
Message-ID: <176931125800.30355.7451399373487878151.b4-ty@oracle.com>
X-Mailer: git-send-email 2.52.0
In-Reply-To: <20260124041902.548904-1-kuniyu@google.com>
References: <20260124041902.548904-1-kuniyu@google.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

From: Chuck Lever <chuck.lever@oracle.com>

On Sat, 24 Jan 2026 04:18:39 +0000, Kuniyuki Iwashima wrote:
> get_current_cred() is misused in nfsd_nl_listener_set_doit()
> and nfsd_nl_threads_set_doit(), leaking the cred refcount.
> 
> Patch 1 & 2 fixes the leak in each function.
> 
> 
> Kuniyuki Iwashima (2):
>   nfsd: Fix cred ref leak in nfsd_nl_threads_set_doit().
>   nfsd: Fix cred ref leak in nfsd_nl_listener_set_doit().
> 
> [...]

Applied to nfsd-testing, thanks!

[1/2] nfsd: Fix cred ref leak in nfsd_nl_threads_set_doit().
      commit: c14b0c3b5966a1e2cf6a7f219c4f4b3fafeb89d0
[2/2] nfsd: Fix cred ref leak in nfsd_nl_listener_set_doit().
      commit: 687b9b69fcda9de606e998fd2edccb8a14406e19

--
Chuck Lever

