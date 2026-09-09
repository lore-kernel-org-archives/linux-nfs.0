Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 20941560AD1;
	Wed,  9 Sep 2026 14:04:34 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788962675; cv=none; b=Hagdf1zMoPm70LBOJo5y5RbmxzDP1dqmoZQhBVLWHOnZqtpMEJorqr3KhpNkcalrhOy1UWhm11NynZYsZ9a4eDN55XGeFMKXgGhUGhLfI9thC32Xk+eTj6dFUlJiAgvwNpjHRUwVJxPcarcU2ZnbajsO6AfciiPBuOl6FhGQVfY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788962675; c=relaxed/simple;
	bh=OJD87lMkLHMi6HkTdkYnT32+c3WlOXdiUwjXZ9pd1LA=;
	h=Message-ID:Subject:From:To:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=OVt0FAI9lZpBEMCYdg8CGCi7HfqD+MLq30fYdTTGDsc2hFlBl01gzb/JNQSJgEymN9tdboMcUdrY2ZVpdp7p56ufqAaGImz4Fkv0RCXSgHuufMkzCTSOfgFXB0SP9efjkHoRRVVzz4txZT0WnkUl7dBg+iipUArO08kYNuAacQ0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=EBZYD+Zt; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="EBZYD+Zt"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6BAC61F00A3A;
	Wed,  9 Sep 2026 14:04:33 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788962674;
	bh=J5CYiXhnzzWfqnVyuOqYfQ2GCCsXntkBBPpvhU0KG9U=;
	h=Subject:From:To:Date:In-Reply-To:References;
	b=EBZYD+ZtOU7lMsSmSTLz3bh9TnVBlUVqkxGZ7wbKXipbdA82N1RH27rqP6A38FWRU
	 t68vXYIJRKRxlA8HZnYFeE8aavPtMrhDe4BwS2cKShEgLhsWkQ18NTtGcQg2kEbmnp
	 3V/SQ7bg6GPmj5pSyDxXSHvTNVdmRhbugnz8nihGCKRLwSf3mt54FgHorYDtHP/Ohx
	 5gZOq8HaM/unool5vBlwtTsWQeB/0AX15/YTtGO34zIxMqSWSC8RxrOICdaHZjFQgW
	 x+gwY2VUK50Sg4D30RTzvyNN6e4TjAsKOIkeQKtDqV+RbC/v3riNLaT1xwL/2OOJXp
	 lUnqSHpqkSpbw==
Message-ID: <af38d347c93f00a5524de00dddef5ba54f692b87.camel@kernel.org>
Subject: Re: [PATCH] NFS: replace sprintf() with snprintf() in nfs_root_setup
From: Trond Myklebust <trondmy@kernel.org>
To: Lalit Shankar Chowdhury <lalitshankarch@gmail.com>, Anna Schumaker
	 <anna@kernel.org>, "open list:NFS, SUNRPC, AND LOCKD CLIENTS"
	 <linux-nfs@vger.kernel.org>, open list <linux-kernel@vger.kernel.org>
Date: Wed, 09 Sep 2026 10:04:32 -0400
In-Reply-To: <20260908183444.183687-1-lalitshankarch@gmail.com>
References: <20260908183444.183687-1-lalitshankarch@gmail.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Tue, 2026-09-08 at 18:34 +0000, Lalit Shankar Chowdhury wrote:
> Replace sprintf() with snprintf() to perform bounds checking when
> formatting.
>=20
> Signed-off-by: Lalit Shankar Chowdhury <lalitshankarch@gmail.com>
> ---
> =C2=A0fs/nfs/nfsroot.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfs/nfsroot.c b/fs/nfs/nfsroot.c
> index 432612d22437..d2c26d5378a6 100644
> --- a/fs/nfs/nfsroot.c
> +++ b/fs/nfs/nfsroot.c
> @@ -144,7 +144,7 @@ static int __init nfs_root_setup(char *line)
> =C2=A0		size_t n =3D strlen(line) + sizeof(NFS_ROOT) - 1;
> =C2=A0		if (n >=3D sizeof(nfs_root_parms))
> =C2=A0			line[sizeof(nfs_root_parms) -
> sizeof(NFS_ROOT) - 2] =3D '\0';
> -		sprintf(nfs_root_parms, NFS_ROOT, line);
> +		snprintf(nfs_root_parms, sizeof(nfs_root_parms),
> NFS_ROOT, line);
> =C2=A0	}
> =C2=A0
> =C2=A0	/*

Please see the two lines immediately above the one you're replacing.
--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
