Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D51D44C752A;
	Fri, 25 Sep 2026 15:08:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790348918; cv=none; b=YgBySqGFkA4YpWv3kLpLdeyTIXgTc78Nuu+6cwzHaxVfGyjgFjiZFVlmiYsHc2o6fmnk+SNMCuzO3x7ubZA5iPA0j0iv9DxDhA3tXAwfRmnyk6Tj5q4M/gH2EJI0/lbGTrST9/QnSAmWjRJX1wB4f76QUHc3nNcS+xg4Jjs+Bv8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790348918; c=relaxed/simple;
	bh=v/PvEbTePpbB1XtPqNVoHyAePyfA19GLalGLQ4/MlSo=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=dFuTVJHNo1ONLyUsl0gl9kdMcmxExAM5oJlPOIjW7ueWwJ+PTGtkT9rtJTlR8SszjmAU4/6qMNTYZmDbspXHCkOSLxxuYXlBy2Ba2dHlZ2HQCBtUuY62Ob1hDqXYtmGPvLGbJiPCJbA6svGjbxReijcIphSb0kSLBNXx4GNKxuU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=gasY7Ibk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="gasY7Ibk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 78F8B1F000FF;
	Fri, 25 Sep 2026 15:08:30 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790348912;
	bh=iw54jWQC5m4+Sdq5NBTlFxYC8c6xEldv+zltAWn2zi0=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=gasY7Ibkp1hQCi+A7WFzaTKCZzAWoRetX/c7U468AoLwmnweHL56NQy6IYVr6klUb
	 PK1XCREqWMEAtxfPbeIZm+xhv9hm/ttevO0QU85gwmS4cMzi1mqlNk0Kmb3L7ePmkn
	 pjptC5iPSgslEgHDVvttFbjlD7Dcc6dq/VEYMf//gLqieVkRlGHcqqKs6rV9SNX0bH
	 GPKLAFuZMTqL0+27drb7lNLKu0bvp+5o4G72oFrFvebzMaJpCNdhejg0ckrzHY//7J
	 YyMOeQXGSXPd7MS4fkt3uqe2XB/ZmcaWdbUy+qxM4VymMBr/s8JnZDj9xaN6Ud472W
	 uFpwlrhXNXa7g==
From: Chuck Lever <cel@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>,
	Anna Schumaker <anna@kernel.org>,
	Jeff Layton <jlayton@kernel.org>,
	"Cen Zhang (Microsoft)" <cenzhang@linux.microsoft.com>
Cc: NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Jakub Kicinski <kuba@kernel.org>,
	Paolo Abeni <pabeni@redhat.com>,
	Simon Horman <horms@kernel.org>,
	linux-nfs@vger.kernel.org,
	netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	AutonomousCodeSecurity@microsoft.com,
	Francis Perron <francis@akrites.dev>,
	tgopinath@linux.microsoft.com,
	kys@microsoft.com
Subject: Re: [PATCH] sunrpc: reject AUTH_TLS on backchannel to prevent NULL-deref in svcauth_tls_accept
Date: Fri, 25 Sep 2026 11:08:26 -0400
Message-ID: <179034889150.511047.410064411360925786.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260925015251.21168-1-cenzhang@linux.microsoft.com>
References: <20260925015251.21168-1-cenzhang@linux.microsoft.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 24 Sep 2026 21:52:51 -0400, Cen Zhang (Microsoft) wrote:
> svcauth_tls_accept() dereferences rqstp->rq_xprt unconditionally when
> it tests xprt->xpt_ops->xpo_handshake, but on the NFSv4.1 backchannel
> path (svc_process_bc), rq_xprt is NULL because no server-side transport
> exists. A malicious NFS server can send AUTH_TLS (flavor 7) on the
> backchannel to trigger a NULL pointer dereference in the client kernel.
> 
>   general protection fault, probably for non-canonical address
>    0xdffffc0000000001
>   KASAN: null-ptr-deref in range [0x0000000000000008-0x000000000000000f]
>   RIP: 0010:svcauth_tls_accept+0x258/0x820
>   svc_authenticate+0x2ab/0x3e0
>   svc_process_common+0x8ff/0x1cf0
>   svc_process_bc+0x5a8/0xbb0
>   nfs4_callback_svc+0xcf/0x170
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] sunrpc: reject AUTH_TLS on backchannel to prevent NULL-deref in svcauth_tls_accept
      commit: 32eb1a60b456980761cf7a9cee8f907fdc08afb8

--
Chuck Lever

