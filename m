Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8827D47F2F6;
	Tue, 14 Jul 2026 14:37:11 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784039838; cv=none; b=Hxhg/VG5StMeRPGf3glVx4uoAqoHjrFLY6Be/z/mf2MPgsTby1aKkMCzZ8gmj4C3L5ug95FIF+Z0TKwxzitA+jvMYxZhsVw5YyCuFMa0FWYNhAiqjJ1H+CtJnzFt1CRzwg+k+52Q351mcV+yGl4YWhsGDiYrxVht3w20kYgNzL0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784039838; c=relaxed/simple;
	bh=PdVB8NgStSUmCyhI+hVIdN1jQb/NJGvzW2PY8KcsZW0=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=uffvQpCUvasMNqgAmauFyip0aAdmHzlm9h73qb8B6o9hLFrlwKspGDi6O+RMFePW0qxauvZkZ4z450a49KNXZ2VcLFWrFysiFoyWDJ+4JsUCMHCz6OC80Apllr55+GHj8xsdQ+nTI6xLOmiz7L2FtkbY1cJ4ZVYUYK+V+t3ECjQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=dtG9ZaLD; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="dtG9ZaLD"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 0BD781F000E9;
	Tue, 14 Jul 2026 14:37:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784039829;
	bh=LQZIyv0ZtAKxxL/9+Fp0LyJNcqg5cviSmk1e6E/ATPc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=dtG9ZaLDqslGV3c+pK8dSYZh2iBxeQdKyPXVNIbG/IE5Q5igzMGzkOk7RK7lPDe8w
	 fL5pSsNxroGyzTNfE6OSdKoKi8auRk9l7XX8Fdt/mb823bb3yAjgNHnYV9EW3ZCDL4
	 NSGTBzmQH3TRAA7TCvhdv5ytnVom9y+hdHrvMnJKPx/G1kTyFmD1B28lpU1Dcb6Wum
	 XS9L7rtgOL9JjiXVw3Aovn6J5/2IhePElH7TI5OT414i1ai5Cngllba1pBoESJYt51
	 rsH5lQsuc14dOP/V2OqcLhQSoDM1QV6yqrSMji9zf6BhKCYJgCcQlNv4UpDNRWVyHj
	 aqlG6v8/tUDDw==
Message-ID: <f5705b41fd63260c5b84343531f139fa72dfa57c.camel@kernel.org>
Subject: Re: [PATCH] pnfs/blocklayout: reject zero chunk_size and
 volumes_count in GETDEVICEINFO
From: Trond Myklebust <trondmy@kernel.org>
To: Michael Bommarito <michael.bommarito@gmail.com>, Anna Schumaker
	 <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, 
	stable@vger.kernel.org
Date: Tue, 14 Jul 2026 10:37:07 -0400
In-Reply-To: <20260711150547.2912006-1-michael.bommarito@gmail.com>
References: <20260711150547.2912006-1-michael.bommarito@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Sat, 2026-07-11 at 11:05 -0400, Michael Bommarito wrote:
> nfs4_block_decode_volume() in fs/nfs/blocklayout/dev.c decodes stripe
> parameters from GETDEVICEINFO XDR without checking for zero values.
> A malicious pNFS server returning chunk_size=3D0 causes a division-by-
> zero panic in bl_map_stripe() via div_u64(offset, dev->chunk_size).
> Separately, volumes_count=3D0 passes the existing upper-bound check
> and causes a second division-by-zero via div_u64_rem(chunk,
> dev->nr_children=3D0).
>=20
> Impact: a malicious or compromised pNFS blocklayout server can panic
> an
> affected Linux NFS client after the client mounts/uses the server and
> maps
> I/O through the poisoned blocklayout. An in-kernel parser/mapper
> KUnit
> reproducer is available privately.
>=20
> Reject both zero values at decode time with -EIO.
>=20
> Fixes: 5c83746a0cf2 ("pnfs/blocklayout: in-kernel GETDEVICEINFO XDR
> parsing")
> Cc: stable@vger.kernel.org
> Assisted-by: Claude:claude-opus-4-7
> Signed-off-by: Michael Bommarito <michael.bommarito@gmail.com>
> ---
> =C2=A0fs/nfs/blocklayout/dev.c | 5 ++++-
> =C2=A01 file changed, 4 insertions(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/blocklayout/dev.c b/fs/nfs/blocklayout/dev.c
> index cc6327d97a91a..fc60669db3ec4 100644
> --- a/fs/nfs/blocklayout/dev.c
> +++ b/fs/nfs/blocklayout/dev.c
> @@ -183,8 +183,11 @@ nfs4_block_decode_volume(struct xdr_stream *xdr,
> struct pnfs_block_volume *b)
> =C2=A0			return -EIO;
> =C2=A0
> =C2=A0		p =3D xdr_decode_hyper(p, &b->stripe.chunk_size);
> +		if (!b->stripe.chunk_size)
> +			return -EIO;
> =C2=A0		b->stripe.volumes_count =3D be32_to_cpup(p++);
> -		if (b->stripe.volumes_count >
> PNFS_BLOCK_MAX_DEVICES) {
> +		if (!b->stripe.volumes_count ||
> +		=C2=A0=C2=A0=C2=A0 b->stripe.volumes_count >
> PNFS_BLOCK_MAX_DEVICES) {
> =C2=A0			dprintk("Too many volumes: %d\n", b-
> >stripe.volumes_count);
> =C2=A0			return -EIO;
> =C2=A0		}

NACK to this, and all further patches with the words "malicious server"
as their justification. It's time to stop this incessant flood of
worthless AI slop...

This is storage, not grandma's email server. If you have a "malicious
server" then it's game over. Your attempts to detect 0 length fields is
going to be pointless security theatre because a real malicious actor
will just corrupt the data.
If a server is sending this kind of thing due to a bug, then you
shouldn't trust it with your data. Just find a server that follows the
spec.

So no, we're not going to waste more time on this kind of junk
--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
