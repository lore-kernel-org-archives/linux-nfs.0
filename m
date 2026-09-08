Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D9E76559CBF;
	Tue,  8 Sep 2026 15:21:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788880925; cv=none; b=EgG0AjyvEX0BaktWw4iALeqpum02mR+pRbzKanqhdPbtrXzS/ZQjZDmalZ8QUHFRY333YHEDU0Ud7hkdGBI8YMBPTS5T8nQMvKJCgJEOxOsNcgc5Be2ZcL8C3sJpr79KY+kJ7uS7kM0H5eC1osch0jnOX5S5d97CrVaV/zuqEBo=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788880925; c=relaxed/simple;
	bh=rbfmehDEFzg/ycRTgJBA3rdTQM7ssLuLHm8jEY9EJ4c=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=fudgoYSn52/8YZ0PWI0sE95GDCgclzNHLrsrT01/atWgkgYKFySmbLi0IMtHKHSQqHgv7R4tRGnhOSYvZ/24Emm60IWZKGE1Y4YrqqH9XVtrtlfL33P0WgXu5O8uadUM6vOm34lbjKx1U1rr5J2Qi2aOXB/Y7LH/JM+VcBgYamQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=GW9jjMAs; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="GW9jjMAs"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id C8B2A1F00A3A;
	Tue,  8 Sep 2026 15:21:49 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788880910;
	bh=2QHkLoRC32cvs9UQOAOacyMx5Mxt/hDh/1zoxM4kHmo=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=GW9jjMAsulzD31AxJhp56UlQypaS0cZMoFOaZLI/2FBulHMFL9CnEDNYdxeb6aDcU
	 2rU/Crrh44bLOjHoUL4AKYeogyWeukL8tM7hXLt9VgDR9zaOPsn6aWlNPeQqMyaaoW
	 qlA/y0s6MnPDkNS9YiGBJAanpvZMbvj8cFe5+VHhOx2FOrQJYu59ATrvVBftdZtC5K
	 q6eWihYpBOx/RmjKQouSplsEXRVVLRqhHocWkQgyIrWCil2TmTGQ3ylE54ZG7izpYy
	 Aov2cLGkdu5hlX2kKFyqd0u+HV0YCNinTKR0GqL8nvYiOqmtidqVxGjsRH7wx3/4x4
	 sG1HVGm/TEbTw==
From: Chuck Lever <cel@kernel.org>
To: Jeff Layton <jlayton@kernel.org>,
	NeilBrown <neil@brown.name>,
	Olga Kornievskaia <okorniev@redhat.com>,
	Dai Ngo <Dai.Ngo@oracle.com>,
	Tom Talpey <tom@talpey.com>,
	Zijing Yin <yzjaurora@gmail.com>
Cc: linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org
Subject: Re: [PATCH] SUNRPC: fix netns use-after-free in write_gssp()
Date: Tue,  8 Sep 2026 11:21:45 -0400
Message-ID: <178888089920.3705723.2420109779573308650.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260907085435.644076-1-yzjaurora@gmail.com>
References: <20260907085435.644076-1-yzjaurora@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Mon, 07 Sep 2026 01:54:35 -0700, Zijing Yin wrote:
> While fuzzing with a customized syzkaller, I hit a refcount warning in
> xprt_alloc(), reached from a write to /proc/net/rpc/use-gss-proxy:
> 
>   refcount_t: addition on 0; use-after-free.
>   WARNING: lib/refcount.c:25 at refcount_warn_saturate+0xf8/0x120
>   CPU: 0 PID: 10404 Comm: syz.0.17 Not tainted 7.3.0-rc1-00096-gcfebfd3db73d
>   Call Trace:
>    <TASK>
>    xprt_alloc+0x83f/0x9d0
>    xs_setup_xprt+0xaf/0x3c0
>    xs_setup_local+0x47/0x7f0
>    xprt_create_transport+0x16c/0x730
>    rpc_create+0x38e/0x7f0
>    gssp_rpc_create+0xe2/0x180
>    set_gssp_clnt+0xba/0x1b0
>    write_gssp+0x200/0x310
>    proc_reg_write+0x240/0x330
>    vfs_write+0x2aa/0x1050
>    ksys_write+0x12a/0x250
>    do_syscall_64+0x117/0x750
>    entry_SYSCALL_64_after_hwframe+0x77/0x7f
>    </TASK>
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] SUNRPC: fix netns use-after-free in write_gssp()
      commit: 85b91a0bdc1c38c97fb17449e6c0990104ebf66f

--
Chuck Lever

