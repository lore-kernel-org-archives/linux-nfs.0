Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 96B1F3939AE
	for <linux-nfs@vger.kernel.org>; Fri,  9 Oct 2026 03:20:23 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791516041; cv=none; b=J/pZtLvCG2by1ZFitmubLWTm7qzVQ2gdBVm4hHFBsjaaScSvdu4Ql+4LKybFs9kRCiYt35TCySp7E2G1HmbxU/ZwmOrOIArKAy0nJbnjcBdc1oCoWS4eVbLmuJ56+Td7zSqaw4PQxjGOvG+eI4EpbuAfXKs4UirCjwNd79N8/9A=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791516041; c=relaxed/simple;
	bh=Cht1M2l+Vdk6kE6Y7FPZSovcL8SyLax7MQwwdXT0ooA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=dPeU6LyOaXxspoQHj02FwTWlOFmhC+hSFx2Y4/fEKaA3LxpI1t1wAI9RJZoflSCbS2QXtqTWBjbf2rcOwmvnQv8TGTsRoWQICq7LL8juHZ71RXUz3XxMMpxmgw73zJuNxHwcs1ikvSwAPkTlJTFmzsWRueJgGu778jxCfT6YjR0=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=MhwCpclS; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="MhwCpclS"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id AE1511F00923;
	Fri,  9 Oct 2026 03:20:22 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791516023;
	bh=rCUbLTwtZlqJca4oHVsgG87PNWgtRG1nz8CL4l9I7Y4=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=MhwCpclSVbIW6AFiD6PVh4Jp2XVGeszkJgTbmSiC31yAKY8jT/v4WFXuAR4xcPgjo
	 7VRL7h5cEFYI9Z9RZdRfZrwTHBOoQCt3D39BFBaGBFOlcwxe9W33lZr7/uZ8VC/c0w
	 U57aAFbumPuexxIzP+aMTD+NuNtdDlYIuKk4WuMDteXp9jBu1eUSaOgHBqyigCNqk6
	 mDcdI/hQO25cP2KspeDHJAMalbjJG6InZ6XbOgZfKLqu62jMYmNA8wRxz5/6WG/i4E
	 THJ4C13DSS2WGKkBVglXiU+i+8hADX6wn5bqZvBIT6OqMuipWUvlv8rPQnnvSwQ2Qc
	 rJiwW44tppHtQ==
Message-ID: <10b9a614cff017245e865c9c46a863d556e274b8.camel@kernel.org>
Subject: Re: [PATCH] NFSv4/flexfiles: fix infinite retry loop on data server
 version mismatch
From: Trond Myklebust <trondmy@kernel.org>
To: Anthony Iliopoulos <ailiop@suse.com>, Anna Schumaker <anna@kernel.org>
Cc: linux-nfs@vger.kernel.org
Date: Thu, 08 Oct 2026 23:20:21 -0400
In-Reply-To: <20261008224544.79469-1-ailiop@suse.com>
References: <20261008224544.79469-1-ailiop@suse.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Fri, 2026-10-09 at 00:45 +0200, Anthony Iliopoulos wrote:
> When a flexfiles layout disallows fallback to the MDS via
> FF_FLAGS_NO_IO_THRU_MDS and sets the ffdv_version in GETDEVINFO
> response
> to NFSv3, it can cause an infinite retry loop in the client when the
> server is not configured to handle NFSv3 protocol connections.
>=20
> Specifically, the server will return a PROG_MISMATCH RPC along with
> the
> minimum protocol version supported, and the client will keep retrying
> as
> the EPROTONOSUPPORT error is not currently handled as a fatal error.=C2=
=A0
> At
> the same time the client is not allowed to fallback to the MDS where
> it
> could proceed with NFSv4.
>=20
> Given that a DS version mismatch is usually a permanent error, it
> makes
> little sense to keep retrying. Fix this by explicitly checking for
> the
> specific error, return immediately when the MDS fallback is disabled,
> and allow an error to be propagated back to user space.
>=20
> Signed-off-by: Anthony Iliopoulos <ailiop@suse.com>
> ---
> =C2=A0fs/nfs/flexfilelayout/flexfilelayout.c | 10 ++++++++++
> =C2=A01 file changed, 10 insertions(+)
>=20
> diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c
> b/fs/nfs/flexfilelayout/flexfilelayout.c
> index 7fe8b91fa47c..52018039c9a4 100644
> --- a/fs/nfs/flexfilelayout/flexfilelayout.c
> +++ b/fs/nfs/flexfilelayout/flexfilelayout.c
> @@ -1060,6 +1060,11 @@ ff_layout_pg_init_read(struct
> nfs_pageio_descriptor *pgio,
> =C2=A0	if (IS_ERR(ds)) {
> =C2=A0		if (!ff_layout_no_fallback_to_mds(pgio->pg_lseg))
> =C2=A0			goto out_mds;
> +		if (PTR_ERR(ds) =3D=3D -EPROTONOSUPPORT) {
> +			pgio->pg_error =3D -EIO;
> +			pnfs_generic_pg_cleanup(pgio);
> +			return;
> +		}
> =C2=A0		pnfs_generic_pg_cleanup(pgio);
> =C2=A0		/* Sleep for 1 second before retrying */
> =C2=A0		ssleep(1);
> @@ -1139,6 +1144,11 @@ ff_layout_pg_init_write(struct
> nfs_pageio_descriptor *pgio,
> =C2=A0		if (IS_ERR(ds)) {
> =C2=A0			if (!ff_layout_no_fallback_to_mds(pgio-
> >pg_lseg))
> =C2=A0				goto out_mds;
> +			if (PTR_ERR(ds) =3D=3D -EPROTONOSUPPORT) {
> +				pgio->pg_error =3D -EIO;
> +				pnfs_generic_pg_cleanup(pgio);
> +				return;
> +			}
> =C2=A0			pnfs_generic_pg_cleanup(pgio);
> =C2=A0			/* Sleep for 1 second before retrying */
> =C2=A0			ssleep(1);

NACK. Errors returned by data servers are never fatal in the flex files
pNFS protocol.
Data server errors get reported back to the metadata server either
through a LAYOUTERROR or through LAYOUTRETURN. The metadata server then
decides how to handle matters either by returning a fatal error on the
next LAYOUTGET, or by fixing the problem.

--=20
Trond Myklebust
Linux NFS client maintainer, Hammerspace
trondmy@kernel.org, trond.myklebust@hammerspace.com
