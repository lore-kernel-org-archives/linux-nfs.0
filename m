Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 046BE47CA9F;
	Tue, 18 Aug 2026 18:24:26 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787077468; cv=none; b=d15o4w9tCOpSSAoqkUXthDU06Ot9XIJlxWARjTdLSc7PoAAtOSxLFg5XwySn/u9hCKJivXRaey2F7xBPnQqEDwAGIgZUsgZE3zne2eNWjzI1/h8uXgSKl3owHvc4oaaO0TtZiIKcDMq0o6KKGXdshAmykEMvtm/lyk4jjKrSgwU=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787077468; c=relaxed/simple;
	bh=2ZYwJj5Pp1OasQ/RZ9xj/Lxt5ktS+DkP8DoidSGPcoE=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ESulXztRBw6XGXoTdFM5sV91m4i48ejyHYRiPlBwhPwFJ5P4wv/gPiYTDFSbP/5/N+9LAVKL18ASL+tHbcCbM074bPlQQkELq7f8VxNyCBA/WAFOQvQvUYusLVB4JMws4y3p1HCWJ8p617GHWMch4zn1+CURXbVHQQBblT+mPPM=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VIQxLos8; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VIQxLos8"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4E1F21F000E9;
	Tue, 18 Aug 2026 18:24:26 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787077466;
	bh=8SbxZ9C8jVnvB68hbDobz6/mhfcCJuqo6DY6mioYgIg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=VIQxLos8vYO3QtdOxkyCkJR0y7x0oOEhvEN4+fzUm+GKb9KC1O1tEWkeFlI26R4cH
	 GZktxLdXFlK/GelU0HiGpMb9VKV4V5VfJsV5RyCnHzgZAJsQivSasw6s9tI3h6smtv
	 tPTPvujMqrMo6oWW+6ZYh7Jn+Updv9MQlhGyzPq6hj/WVVEbltUK38FPUT6ggDYKfs
	 rRJIi239CTezovS6McXlWfZjAZkDjyTgVsY2ryQGWDb5rz7TgwVAsLTQJwzVTPcMiR
	 99R4mHcaeppCHudG/Gf36xHtVgZu0A0zSSfOPVaq4XUqZj0vjKLPuxxjgF4xPNvdzt
	 6N3EOj0iC9IpA==
Message-ID: <ee8f174933d00fc58e2f54fd2fdd98d67919884b.camel@kernel.org>
Subject: Re: [PATCH] pNFS: Fix EBUSY check in pnfs_layout_need_return
From: Trond Myklebust <trondmy@kernel.org>
To: tmenninger@purestorage.com, anna@kernel.org
Cc: jlayton@kernel.org, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org,  Tim Menninger <tmenninger@everpuredata.com>
Date: Tue, 18 Aug 2026 11:24:25 -0700
In-Reply-To: <20260817154044.1799634-1-tmenninger@purestorage.com>
References: <20260817154044.1799634-1-tmenninger@purestorage.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-08-17 at 15:40 +0000, tmenninger@purestorage.com wrote:
> From: Tim Menninger <tmenninger@everpuredata.com>
>=20
> Commit 41d0a8ead9720 ("NFSv4/pnfs: Add support for the
> PNFS_LAYOUT_FILE_BULK_RETURN flag") changed pnfs_layout_need_return()
> to
> check whether pnfs_mark_layout_stateid_return() returns -EBUSY.
>=20
> However, the new check compares the return value against EBUSY rather
> than -EBUSY. Since pnfs_mark_layout_stateid_return() returns negative
> errno values, the -EBUSY case is never detected.
>=20
> But pnfs_layout_need_return() calls pnfs_mark_layout_stateid_return()
> calls pnfs_mark_matching_lsegs_return(), which returns 0 if a
> layoutreturn needs to be scheduled.
>=20
> Fix the comparison in pnfs_layout_need_return() to check for 0, i.e.
> a
> layoutreturn needs to be scheduled.
>=20
> Fixes: 41d0a8ead9720 ("NFSv4/pnfs: Add support for the
> PNFS_LAYOUT_FILE_BULK_RETURN flag")
> Signed-off-by: Tim Menninger <tmenninger@everpuredata.com>
> ---
> =C2=A0fs/nfs/pnfs.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 9f32dd7c4c63..fb141cef4d54 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1389,7 +1389,7 @@ pnfs_layout_need_return(struct pnfs_layout_hdr
> *lo)
> =C2=A0		return false;
> =C2=A0	return pnfs_mark_layout_stateid_return(lo, &lo-
> >plh_return_segs,
> =C2=A0					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lo-
> >plh_return_iomode,
> -					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lo->plh_return_seq)
> !=3D EBUSY;
> +					=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0 lo->plh_return_seq)
> =3D=3D 0;
> =C2=A0}
> =C2=A0
> =C2=A0static void pnfs_layoutreturn_before_put_layout_hdr(struct
> pnfs_layout_hdr *lo)

This breaks the ability of the client to respond to layout recalls even
when it does not think it holds a layout. That's a situation that can
occur when using soft or softerr mounts.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
