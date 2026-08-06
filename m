Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 9A006390CA6
	for <linux-nfs@vger.kernel.org>; Thu,  6 Aug 2026 13:53:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1786024393; cv=none; b=CbcArBHc5k2uHZA5LQzM3Dxnhr3nZRx9yS7V6UXb5sRIPb9ev5Nq+uaN6wu064hlVQn4kWC4czjwIne+HorCtJTgDQgCah86p4ja3l7sQ5EuKFlizVRNZUAQUvInIRpynXNwugGyowSfD4TqEx/Ql19aw+NpnISkIAqDtgmw1iw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1786024393; c=relaxed/simple;
	bh=lu4N1hy1Tw3akjvHoiNm6PmdBBM5xTGFmojGa5ch3/Q=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=LYMe1l6uZ04tmAEVUYia4UKHJ794iN+3+vcwm7AL3Nl7EXkZPUY/ClEMAVzwQV0eTBKPDZMrxd/P2IILcJ78jp0o98QW3E9ipfEzBTvIWShCoETYEEZ1HXPrkjgoG4LqeagAyplLILTgFD9kV4vXDjDfnP8yPc2qHlqWCkOCTjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=X4gI1idt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="X4gI1idt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 014411F00A3D;
	Thu,  6 Aug 2026 13:53:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1786024390;
	bh=GB4AZUIRmL3Fcnxl/7t+ZjAv1enQyqzy2IaxSBuICes=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=X4gI1idtpOMYC0Lvq+4zkf06GkMXwAUP+yuPOR7RZr3iHzB/RMNodxe2+P4f8m58C
	 cXvH5zRHw92O71hS+isqLMQLainRehVdpXw2DnYBeDWiqTNduWg2PVZSDFwByEA3YO
	 KDh2rItoFD9FyYRxXZqk4lbBbbZUlnNpFR/BX1ptAtjFQ7sNhwiXFD0+4pPIt0liw8
	 4E8kmsZ7DtQAH4GkIv9f4Ah1+iMJ5hN8Qbza4U5Sw3TJ/4QL/RoE88bhXHlQs3snGj
	 E1zt+nl6kjsJ+JG32zDlQ8nMDhIjKKqiKLdpBN6rHcEKuUsb082C7zjJvWrV6D/ohm
	 5i98fVcz9iiog==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E7DA6F40069;
	Thu,  6 Aug 2026 09:53:08 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Thu, 06 Aug 2026 09:53:08 -0400
X-ME-Sender: <xms:xJF0atIJdpV8GTyYSBbINRluFW0rp4sAwh1ZprGH9bivWMWJUil9bA>
    <xme:xJF0aj-uO7WmtcjhWtHXY5uALrX_Ly0z25l9EDkKj0oc-UrdSwIoAwTUttEJAJ7s6
    dK97detygV-Xan6kPGXQn4kpELPjODqBWBFrDXOjBT4mG6bTXGIgNFl>
X-ME-Proxy-Cause: dmFkZTFIgW+40EDoq6W30tZ+hqIeKpRJJIL259269s71nD6+MMjDBs9/SOpMKdAUJQCL0W
    YkRNIX6kf/ULdpxJGMncXe3O9qwefnFpCioQD1grvHaZZA1qOwAmkCrWiPW/3wPR2MyxmO
    znZierfMpv3Nk9XmF+rtuzt/n4bc8yw99vGdAkt5xThaMiSft7qKUgREW0F5lGLtBO5udh
    sgXKriiK6IGbQgZfv4lW8ZWa8JqPSOng4dOKXidTK8Y3YJo+Gf4Wt1DryYsGochcLawznZ
    Rz3GZKXwOWdAOtISA7Tf9/LG9pprXJ8pBiBEuNaRpDUVZlbWJqM5uQK2kMbGJY8s5bRIGq
    2fsWWq9UOfmodNXtplT+qThHI8yK1OzkEdyVDBC/fpqBSiE950EC3Dk5kOaBvy//lkeCTr
    LYFtJ8J5KnYAZo/s8vTHnqS7cnA3c+IGllSOEYRu9pKnZsO+YjhqJVn8/oujVKP4hFF6J+
    VWb5gEycGpx3JCELVcRhqSLPw31BlbWGhkmXKvM9/yO3GyBlYTr/f9d/Io/I+QWFWUElET
    NtgSXG/71xhuMOyI5XVUmb5S4UGjQg/EY45PVd/2jm35apQQ6oXa6gvmkDUOhrH573+we8
    5zLklxjgnk1IP9UZ0VBb+QT82Rrv6bck8MQ5Qh2rc8utaE8F+0/lyqk1xqUQ
X-ME-Proxy: <xmx:xJF0auvQpSqlwIjkze3euuQDcDunenOaP6CX_p3y5UQShxeGzzn0PA>
    <xmx:xJF0avXo1XsXU0npvE2OiJfTLCdR_BAeeLHwSrc6mWyS0kcQRhK4Dg>
    <xmx:xJF0amxpB_Hv4K_C6lgjW4_nG-WT1QqHLWWZ1Gu0tG5Q2uh41YqsrA>
    <xmx:xJF0auFVoN39Swtg9rzFTP0kQx-EnLWleOKZWrFEDwzf8hcQ6xp4LA>
    <xmx:xJF0ajvwKXxkRO-Vpk8-IwaT1HzaHQ9EEbFgZiAIb_pMLVvvklGZJTQD>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C8C56780070; Thu,  6 Aug 2026 09:53:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AMugUo73TJ9c
Date: Thu, 06 Aug 2026 09:52:48 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Lai Zewei" <laizewei3@huawei.com>, "Jeff Layton" <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: "Zhihao Cheng" <chengzhihao1@huawei.com>, yi.zhang@huawei.com,
 yangerkun <yangerkun@huawei.com>
Message-Id: <ebaef949-41fc-4a17-807a-9343510e6419@app.fastmail.com>
In-Reply-To: <20260806073714.3513158-1-laizewei3@huawei.com>
References: <20260806073714.3513158-1-laizewei3@huawei.com>
Subject: Re: [PATCH V5] nfsd: fix nfsd4_create_reclaim_record_grace crp null-ptr-deref
 in nfs4recover
Content-Type: text/plain
Content-Transfer-Encoding: 7bit



On Thu, Aug 6, 2026, at 3:37 AM, Lai Zewei wrote:
> nfs4_client_to_reclaim() may return NULL if alloc_reclaim() fails. 
> The caller __nfsd4_create_reclaim_record_grace() then unconditionally
> dereferences the returned pointer via crp->cr_clp = clp, leading to a
> null-ptr-deref crash.
>
> Add a NULL check before assignment. If crp is NULL, just return.
>
> Fixes: 4552f4e3f2c9 ("nfsd: change nfs4_client_to_reclaim() to allocate data")
> Signed-off-by: Lai Zewei <laizewei3@huawei.com>

First a process note: I don't see v1 through v4 on linux-nfs, and this
posting carries no changelog. If those were internal review rounds, you
should post the first public version as v1, or add a changelog saying
what changed between the previous revisions.

The code change is nominally correct. Commit 4552f4e3f2c9 moved the
allocations into nfs4_client_to_reclaim() and removed this caller's
NULL check along with the kfree() that check guarded. Restoring it
keeps this caller consistent with load_recdir() and
__cld_pipe_inprogress_downcall(), and both handle a NULL return.

However, IMO a UAF crash is not reachable. struct nfs4_client_reclaim
is just 48 bytes, and a GFP_KERNEL allocation of that size is almost
guaranteed to succeed 100% of the time on production systems. (I'll
redact the analysis of the allocator code path here).

The Fixes: tag then asks stable maintainers to backport a fix for it,
and I wonder if there's any need to.

Please send a v6 whose description says the check was dropped by
commit 4552f4e3f2c9 and is being restored, removes the Fixes: tag, and
states that the NULL return is not reachable from this caller. If the
defect was found using a static analysis tool or from slab fault
injection rather than observed in production, mention that in the
description too.

In addition, the subject names nfsd4_create_reclaim_record_grace, but
the function is __nfsd4_create_reclaim_record_grace; and "in
nfs4recover" repeats what the "nfsd:" prefix already says. Something
like "nfsd: restore nfs4_client_to_reclaim() error check" would be
more accurate.

Do let me know if I've missed something that makes this patch more
than a clean-up.


-- 
Chuck Lever
