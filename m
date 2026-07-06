Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 83C8F420863
	for <linux-nfs@vger.kernel.org>; Mon,  6 Jul 2026 23:17:15 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1783379837; cv=none; b=ghF3R43SoFk9Eu8iyKHafYyZNfN6PMrYUF1jhBReSpmwpS6RUbzxdkifjtphH/CsGzcwahtSGYmVm7HiHPV9IWk3Dr283aofrrFsMAarTHHAwbwnuzKzPMLdbPpgOY9cQwyGL5mbHy8ljwNEZzHgzi9Joh8yErAUUcMEtOXAgDY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1783379837; c=relaxed/simple;
	bh=GX2rp75D+kmwDWIwY+tUVgX6zOlTBq+9Kb2YgQe3rvo=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=rcsCvzbsnIeXrY90YHYd0UOoDCANUmcdLmYvucPzbdIPIRVu52soYiZCkkU4cmPcUVkmdGFPSKhpKHbpzYxYCWiL1Xz2juCp6RDv9VeyTjH3rmTgtxFM/+Oel7Xh+x7nG/Md3cNSeK0Dx+dJPXd6N+4famggBSzO5KwANi4TI24=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=W6fLfDdr; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="W6fLfDdr"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 82DC21F000E9;
	Mon,  6 Jul 2026 23:17:15 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1783379835;
	bh=GX2rp75D+kmwDWIwY+tUVgX6zOlTBq+9Kb2YgQe3rvo=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=W6fLfDdrxYjtJfpncKejRHvWMCMP5SoXrKx2LKBuQkvH+wVaFCW9S20MuiKvK7PiK
	 kD32FLfMK05PxKX5Nt29ldoEH5gbwYCjf8+5eHEqGPYC+LXK56hNHYdDtPsBY8dhVq
	 EQAP3Ys1+yikGK4m0fOOe7TctcygE9dOJ6iJIrZ8O2xxW2RwP6BgErq9UxOkgYS+hf
	 9jRbY3FzAGg0CD1Zk4U83MO8hkCtw4HjgMvbynx6QceTTFUKDR5EBtfebMeGO7VYZl
	 tjVGUeYuuQiYkPonjIB7+AdQHX02y5PJjBzvZJ7UKR5nu2HuxmjtG8O3lB8+Pxa+oi
	 MnLljxSqteOVQ==
Message-ID: <122c658755fcb4b2d1264a7fd62fa8eda571f67b.camel@kernel.org>
Subject: Re: nfs: opening a file with O_WRONLY|O_CREAT flags can result in
 permission denied error
From: Trond Myklebust <trondmy@kernel.org>
To: Tian Lan <tilan@janestreet.com>, linux-nfs@vger.kernel.org
Cc: Anna Schumaker <anna@kernel.org>
Date: Mon, 06 Jul 2026 19:17:14 -0400
In-Reply-To: <20260706213435.659381-1-tilan@janestreet.com>
References: <20260706213435.659381-1-tilan@janestreet.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-07-06 at 17:34 -0400, Tian Lan wrote:
> Hello,
>=20
> We recently noticed there is a behavior change w.r.t opening a file=20
> with the O_WRONLY|O_CREAT flags over the NFSv3 protocol after
> upgrading
> the kernel from 6.1 LTS to 6.12 LTS. From the packets capturing, it
> seems
> like the kernel would now issue an additional CREATE rpc call to the
> remote NFS server regardless if the target file pre-exists or not.
> The CREATE rpc request could return an EACCES error if the client
> only has=20
> the write permission to the pre-existing file but no write permission
> on=20
> the directory containing the pre-existing file. This causes the
> openat=20
> syscall to fail with permission denied error which is not expected.
>=20
> After doing some code tracing, it seems like the new behavior was
> introduced as part of 7c6c5249f061 ("NFS: add atomic_open for NFSv3
> to
> handle O_TRUNC correctly."). We would like to confirm if the current=20
> behavior that we are observing with the 6.12 kernel is expected given
> that the new behavior breaks existing user's application code. We=20
> currently have a workaround by explicitly remove the O_CREAT flag
> when=20
> opening a pre-existing file for write, but would still prefer not
> have
> to apply this workaround when upgrading to the newer kernel.

NFSv3 CREATE is supposed to ignore the directory permissions if the
file already exists. That is required in order to support basic POSIX
open(O_CREAT) behaviour. Even with the old code, which did a lookup
before deciding to send the CREATE, there was a potential for races
that could have caused the client to send it against an existing file.

What server are you using?

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
