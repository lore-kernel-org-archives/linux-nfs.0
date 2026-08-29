Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8114B238159;
	Sat, 29 Aug 2026 15:54:01 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788018843; cv=none; b=LrC8cUYhVopY0mNPDDVWEiJaJOi0gN36o7cvjVT7PM7VAuHBjlV0CQFN+oWxsJ4Nw6KqhDh8J82Cz8vFxxchxAxpFl2Yd64itilQCsxZHL1YvDkwRg3ssbggmszLNk0Ra0ovaLtucRrasT1sCzXE27Jo98JtmCiXLEDctHhwwkY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788018843; c=relaxed/simple;
	bh=es4CFdV1k/X97tHxNiATXfqAEgr1SPtU1HfyhMG1eFc=;
	h=From:To:Cc:Subject:Date:Message-ID:In-Reply-To:References:
	 MIME-Version:Content-Type; b=Pvaa9ASKjtFwW8vLJJ9TYlz4BC918M8ydJcaiYsNfowSsRanOcmpGYLqs22abtf4qH1r+0qgjaZXIzp/JC3XkpcEfaVmaS7Q5DUAawWFLLedsLzSeWmNfJ0eelWEIX7Zg3+1vKbMmQbgCjDOBmFHK1YCPgxuKBrKciFM+fHxnX4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=b46Gvk5r; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="b46Gvk5r"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8ABE61F000E9;
	Sat, 29 Aug 2026 15:54:00 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788018841;
	bh=CcRwYGlFyyQc/kABNJ9tcz+R2dfR0kHZZcaxRgW1KGI=;
	h=From:To:Cc:Subject:Date:In-Reply-To:References;
	b=b46Gvk5rF0VnPyFPyLmHG6954mBhOIqbN+Z4aVa/xl3dQE/TDL95q1geAj6FzoRfL
	 nE1Nhsj+DFsK/nYDV0ZDWr946TaTpVHTyuY9w7ilfzDp6vTlX9RT4tKMC9iQ6y1OVd
	 wgt7iDRos13un4nsB5ZoApS4CeeqwYzVsbXDMwQhY8fkWioVrXkf3O2sA8ENm8JTrw
	 vg1RZgielyYzWkm+B+Ng1O64pOqfzNksiV9wF6KK15IeY1AwHxnWtY3ToPyJTKKJTh
	 Y5M5YsefA9srZGn3h6lNduPgrJSw0L/UH+FuDa02q+nNjDxfRchYjADPdCtquZTzkZ
	 VSiqFIkj9L5cg==
From: Chuck Lever <cel@kernel.org>
To: jlayton@kernel.org,
	"Cen Zhang (Microsoft Security FORGE Labs)" <blbllhy@gmail.com>
Cc: neil@brown.name,
	okorniev@redhat.com,
	Dai.Ngo@oracle.com,
	tom@talpey.com,
	bfields@fieldses.org,
	linux-nfs@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	stable@vger.kernel.org,
	AutonomousCodeSecurity@microsoft.com,
	xmei5@asu.edu,
	tgopinath@linux.microsoft.com,
	kys@microsoft.com
Subject: Re: [PATCH] nfsd: hold cl_lock in client_has_state()
Date: Sat, 29 Aug 2026 11:53:57 -0400
Message-ID: <178801882864.2077660.2011534008442729318.b4-ty@b4>
X-Mailer: git-send-email 2.54.0
In-Reply-To: <20260828041925.36758-1-blbllhy@gmail.com>
References: <20260828041925.36758-1-blbllhy@gmail.com>
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit

On Fri, 28 Aug 2026 00:19:25 -0400, Cen Zhang (Microsoft Security FORGE Labs) wrote:
> client_has_openowners() walks clp->cl_openowners and reads so_stateids
> without clp->cl_lock. nfs4_put_stateowner() unhashes that openowner under
> cl_lock and then frees it, so a concurrent EXCHANGE_ID with mismatched
> creds can use-after-free the nfs4_openowner.
> 
> BUG: KASAN: slab-use-after-free in client_has_state+0x10a/0x140
>   fs/nfsd/nfs4state.c:3718 client_has_openowners()
>   nfsd4_exchange_id
>   nfsd4_proc_compound
>   nfsd_dispatch
>   svc_process
> 
> [...]

Applied to nfsd-testing, thanks!

[1/1] nfsd: hold cl_lock in client_has_state()
      commit: 6882aca9f9cabfaec5ea23d1512f345fbd288b65

--
Chuck Lever

