Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8DAE94A8FD1;
	Fri, 16 Oct 2026 15:08:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792163302; cv=none; b=WWmbkZbnTHpHBP2SMrUChl1P85GvsWFZH1bSXWLSVQb+h3IEsNXS7NPbkvrND66hzuaNm5QckDES8AGjHGfSilygfn+u3dmnHiptDZKqxv6pkEQ3h2pRl104aRZRhcFwGr3MEY5i9tUBOfxd1qGVhdvjbHmxsPQGIKwN+oB3jxg=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792163302; c=relaxed/simple;
	bh=GvvOyamDNwcAhPTr6UHXuLJz0G870Qo8uj/3PgPHTBk=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Fkd8jF49BWANOCKeYoglt8ufR0HFotN1ef2AgCR4kQEMKlmXfz+SnoXRulv9ZdUoYD1nkgh6QHX7OzLeYV3JALuRYn71qklSnIVj2SM5sIC1rQxnOj5i8sZQrMFtlwETQo6u/DbFBVLetsPg/Jp226M4zp36tc4UTz65a9wtL2U=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=hr/VjZWY; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="hr/VjZWY"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 9BFF11F000C4;
	Fri, 16 Oct 2026 15:08:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792163301;
	bh=6qEhMqsggKfNooDymEP6wz/N7ygWxzGYI7MjV/a3tBc=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=hr/VjZWYyQDV6KP9I4IiJ1QG0a2Wmoe3MlFFqwKvZiPu0B1f/6j0FAtNc4GPFQ4tz
	 cgCuopfpNf7ZepzkAfPOtki4ENMjqwpwznmc6nXnkFmqp9+UIpxtGhB+q9uAfGt/2V
	 jIvQjAPe/unGMb2ZNrjqHkokPoINkYGrbkHe4N6l4BYpUOI+oTChyFUQib/DhB8HYy
	 xmLMrilZ2P5OHneZOG6X2Mv4nRt57Ap0seiSys+Gmib9d5+p0NMvTVN9PMZPnoXeB4
	 NbfPhyaLFDCBxjYbzu/6/o7SniuDOp3UeEEzXJpvbYK1arOXqLYxT9Br1kbYCMUOdN
	 Vr9E9UcvgQsog==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Jiwoong Wi <dwdnlzj@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	bobtobabz@gmail.com
Subject: Re: [PATCH] svcrdma: account for inline bytes in Read chunk page budget
Date: Fri, 16 Oct 2026 11:08:17 -0400
Message-ID: <179216322004.3259068.2699387517465524714.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20261015135832.67889-1-dwdnlzj@gmail.com>
References: <20261015135832.67889-1-dwdnlzj@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Thu, 15 Oct 2026 22:58:32 +0900, Jiwoong Wi wrote:
> The Read-list check limits Read bytes to the request page budget. With
> multiple data item Read chunks, svc_rdma_read_multiple_chunks() copies
> the inline RPC body into those same pages. The reconstructed message
> can overflow the budget even when its Read bytes alone fit.
> 
> A short final Read segment escapes the existing page-overrun check
> because that check runs only if len remains nonzero. The inflated
> rc_page_count then makes svc_rdma_clear_rqst_pages() write past
> rc_pages, followed by an out-of-bounds read during cleanup.
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] svcrdma: account for inline bytes in Read chunk page budget
      commit: 4e84914d70a0194e18bba6d814cfe71b340aadc8

--
Chuck Lever

