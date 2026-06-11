Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 66E0A279329;
	Thu, 11 Jun 2026 17:36:56 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1781199417; cv=none; b=NvTqUKNFIQ0e+mUOd+P0o9HDPcS4SXsDEjUMvQfDYu3viS3wBWk1bR5tjrPmgDwj4s9VHJQs/YHdA0dtsaUSPJZUP9CdxTaG9gkeLm2mVKE58J9q9RvF3xqsFCJtWgqQZ6tW+0Ll1/9PYqcFlNAP1hJqNZPIarO0gV/KRMgcf8Y=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1781199417; c=relaxed/simple;
	bh=wfGP2RdSlvkde6gwEfLSMenPaIi8cg7Cob7YhrGwLIs=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=rpjF6fl1gRWQN9SgD7RJ5vRRGkqkDaCtuj3cqrdITIHpuJEmU0gXlaDnpttZsqJ/pBs7ccgEWKolppc/xFGn+aq+fTcbdnoQWMQLpUHlhPrmp/kr7pDWkxWYY0P7ZG+mkMMp3kLQsWgQ9S01JttQel3Ke1Ugczk2JgCYD84lVwM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=XQVbXdUL; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="XQVbXdUL"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 96D651F00893;
	Thu, 11 Jun 2026 17:36:55 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1781199416;
	bh=7uJf1KWAZ07eRdULf62uTEfXmSe8P4z5DXy6/o8rLx4=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=XQVbXdULFkOreztsGFSZeAilZy6FXL9t70QIBCSJrdPAIzTYmOzWtpxLMXFYYA90Y
	 k+H/mCqbYW3JidfiCrh2i1UpmzwH7ovbkOSmH/D35pT8KQHnQ05F91nT6vzEawkCFg
	 onCq9Jl1++beOCZ5aZKVGX/Pg28TloFHSw6uaruxDbDZZppMfw5qQoeUSsdHOZidIX
	 Vkw0nwnMqR+PItDFUKOfeUkMiA0PjFBRiklxRGdsiOP9ZVhIrZHheOdK+Pn9VCm+W/
	 Cg+N58Psa7xTg6+pK3K+7Q9pm13QYrZiHIxCmuXYflOWIUf907OmxoUs4oVMum0qOw
	 RfX1RiTlAV4iA==
Message-ID: <9a42893cb1c829b943bd40dbb55151e97499916a.camel@kernel.org>
Subject: Re: [PATCH] pnfs: fix refcount leak in pnfs_report_layoutstat()
From: Trond Myklebust <trondmy@kernel.org>
To: WenTao Liang <vulab@iscas.ac.cn>, anna@kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	stable@vger.kernel.org
Date: Thu, 11 Jun 2026 13:36:54 -0400
In-Reply-To: <20260611154747.94154-1-vulab@iscas.ac.cn>
References: <20260611154747.94154-1-vulab@iscas.ac.cn>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Thu, 2026-06-11 at 23:47 +0800, WenTao Liang wrote:
> When pnfs_report_layoutstat() calls pnfs_get_layout_hdr() and passes
> the reference through the inode field of the layoutstats data to
> nfs42_proc_layoutstats_generic(), if rpc_run_task() in that function
> fails (IS_ERR), nfs42_proc_layoutstats_generic() returns immediately
> without releasing the reference.=C2=A0 This leaks the layout header
> reference, leaks the allocated data, and leaves the
> NFS_INO_LAYOUTSTATS flag stuck on the inode, preventing further
> layoutstat reporting.
>=20
> Fix by calling nfs42_layoutstat_release(data) before returning on
> rpc_run_task() error, matching the existing error handling for a
> missing inode.
>=20
> Cc: stable@vger.kernel.org
> Fixes: be3a5d233922 ("NFSv.2/pnfs Add a LAYOUTSTATS rpc function")
> Signed-off-by: WenTao Liang <vulab@iscas.ac.cn>
> ---
> =C2=A0fs/nfs/nfs42proc.c | 4 +++-
> =C2=A01 file changed, 3 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/nfs42proc.c b/fs/nfs/nfs42proc.c
> index 7602ede6f75f..7637ad894563 100644
> --- a/fs/nfs/nfs42proc.c
> +++ b/fs/nfs/nfs42proc.c
> @@ -1076,8 +1076,10 @@ int nfs42_proc_layoutstats_generic(struct
> nfs_server *server,
> =C2=A0	nfs4_init_sequence(server->nfs_client, &data->args.seq_args,
> =C2=A0			=C2=A0=C2=A0 &data->res.seq_res, 0, 0);
> =C2=A0	task =3D rpc_run_task(&task_setup);
> -	if (IS_ERR(task))
> +	if (IS_ERR(task)) {
> +		nfs42_layoutstat_release(data);
> =C2=A0		return PTR_ERR(task);

NACK! If you'd bothered to read the code, you would have found that
rpc_run_task() already cleans up on failure. This patch just introduces
a massive use-after-free.

> +	}
> =C2=A0	rpc_put_task(task);
> =C2=A0	return 0;
> =C2=A0}

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
