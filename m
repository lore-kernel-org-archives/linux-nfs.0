Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 5C0BA39D6CC
	for <linux-nfs@vger.kernel.org>; Tue, 21 Jul 2026 11:25:47 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784633153; cv=none; b=A/GMd0wEU6zBG+MYmaBcTYz0AbVxgEQlagKddlH0f82bUUOcQeMEGKdhlATlUBRFQD77DgTbDE3idVdXvGAJ4NAr6uZezIEpVu+M56Uc8DGVHJky3/hYEQUW+4PsrR/MVd0jousEDZO9Vxe6MSKTkBqJR/sdksW05J+uJ4Uba+Q=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784633153; c=relaxed/simple;
	bh=y9sSCfK1YD5juqRjlPYCrPMh1U7muN4uNZVQUKSnb2g=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=EI/KNMlqJsFPbfQQrhs+dpV56oRJWm2/rC3TNR8Kn0w51fJuDNMOBtRqQX00dMT8vIdw5ViyE+uWB67ip1NadrgUrLHXDEj4fj2IBcJ4VEbRwpCd/ROfzPm3s8xejsfOgQin1yBamcibgpwbt4++ND32+HdUTW40eLC4yqvpplo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jXegD8c5; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jXegD8c5"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 3E6EF1F00A3A;
	Tue, 21 Jul 2026 11:25:43 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784633143;
	bh=OuvZWNmbh2bwBRdXFNvFwFIr3hi1+xA0mmVvYzDT3cg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=jXegD8c5vxnyVZyYyRSlggsLf6EFsyTQ9w1zLGn8f5JSa4H0wk8q2TSlIjQNGtg/y
	 3Didk6ZmFL8Nub3gOHStQrL67/6O1L3xnAZyzUCfWDGWYhIrYKX+Pbe3XZLe9Fi1+C
	 Dr5zw9w0RGoTKykjuPqw3d+UaxUh+wuhVt24P4pX9zay2u/UxGqWABm3+GA7B2tfzf
	 JjnhgLEB8eeuv9SB6LOo1sMauoy9VILn6S9cAomy3+DtRVzsieLqQIydboi4dDfCei
	 fkUwRW4HzVUBEW97RRKSYbzCphRduRo6/u82FoQPe/IFYi1evJ0MSLJXPKiEZ64krh
	 m3YyDZO/G+Vyw==
Message-ID: <eff408b69ef6bc3b790d94d356e3abbf382f8ec7.camel@kernel.org>
Subject: Re: [PATCH] NFSD: Map flex file layout IDs through the request's
 user namespace
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <dai.ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, sashiko-bot <sashiko-bot@kernel.org>
Date: Tue, 21 Jul 2026 07:25:41 -0400
In-Reply-To: <20260720163724.810227-1-cel@kernel.org>
References: <20260720163724.810227-1-cel@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-07-20 at 12:37 -0400, Chuck Lever wrote:
> nfsd4_ff_proc_layoutget() and nfsd4_ff_encode_layoutget() translate
> the file's owner and group with init_user_ns, but every other identity
> nfsd places on the wire goes through nfsd_user_namespace(). When the
> transport carries a credential from a non-initial user namespace, the
> flex file layout reports host-global IDs. The client copies those IDs
> into the AUTH_SYS credential it presents to the data server, and
> svcauth_unix_accept() resolves that credential in the transport's
> namespace, so data server I/O runs under an identity unrelated to the
> file's owner.
>=20
> Switching to the request's namespace introduces a second hazard.
> from_kuid() returns (uid_t)-1 when the target namespace has no
> mapping for the owner, and the IOMODE_READ arm adds one to that
> result to derive an identity for which the data server denies
> writes. The addition would wrap to zero, handing the client uid 0
> instead of an identity distinct from the owner.
>=20
> Translate both IDs in nfsd4_ff_proc_layoutget(), which has the
> svc_rqst, and carry the wire values in struct pnfs_ff_layout.
> from_kuid_munged() substitutes overflowuid for an unmapped owner and
> thus never returns (uid_t)-1, so the increment cannot wrap to zero.
>=20
> Fixes: 9b9960a0ca47 ("nfsd: Add a super simple flex file server")
> Reported-by: sashiko-bot <sashiko-bot@kernel.org>
> Closes: https://sashiko.dev/#/patchset/20260720141442.783935-1-cel@kernel=
.org?part=3D3
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
> =C2=A0fs/nfsd/flexfilelayout.c=C2=A0=C2=A0=C2=A0 | 20 ++++++++++++-------=
-
> =C2=A0fs/nfsd/flexfilelayoutxdr.c |=C2=A0 4 ++--
> =C2=A0fs/nfsd/flexfilelayoutxdr.h |=C2=A0 5 +++--
> =C2=A03 files changed, 17 insertions(+), 12 deletions(-)
>=20
> diff --git a/fs/nfsd/flexfilelayout.c b/fs/nfsd/flexfilelayout.c
> index 9f532418cac8..c6e6b9106a83 100644
> --- a/fs/nfsd/flexfilelayout.c
> +++ b/fs/nfsd/flexfilelayout.c
> @@ -15,6 +15,7 @@
> =C2=A0
> =C2=A0#include "nfserr.h"
> =C2=A0#include "flexfilelayoutxdr.h"
> +#include "auth.h"
> =C2=A0#include "pnfs.h"
> =C2=A0#include "vfs.h"
> =C2=A0
> @@ -24,10 +25,10 @@ static __be32
> =C2=A0nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struct inode *inode=
,
> =C2=A0		const struct svc_fh *fhp, struct nfsd4_layoutget *args)
> =C2=A0{
> +	struct user_namespace *userns =3D nfsd_user_namespace(rqstp);
> =C2=A0	struct nfsd4_layout_seg *seg =3D &args->lg_seg;
> =C2=A0	u32 device_generation =3D 0;
> =C2=A0	int error;
> -	uid_t u;
> =C2=A0
> =C2=A0	struct pnfs_ff_layout *fl;
> =C2=A0
> @@ -50,13 +51,16 @@ nfsd4_ff_proc_layoutget(struct svc_rqst *rqstp, struc=
t inode *inode,
> =C2=A0	fl->flags =3D FF_FLAGS_NO_LAYOUTCOMMIT | FF_FLAGS_NO_IO_THRU_MDS |
> =C2=A0		=C2=A0=C2=A0=C2=A0 FF_FLAGS_NO_READ_IO;
> =C2=A0
> -	/* Do not allow a IOMODE_READ segment to have write pemissions */
> -	if (seg->iomode =3D=3D IOMODE_READ) {
> -		u =3D from_kuid(&init_user_ns, inode->i_uid) + 1;
> -		fl->uid =3D make_kuid(&init_user_ns, u);
> -	} else
> -		fl->uid =3D inode->i_uid;
> -	fl->gid =3D inode->i_gid;
> +	fl->uid =3D from_kuid_munged(userns, inode->i_uid);
> +	fl->gid =3D from_kgid_munged(userns, inode->i_gid);
> +
> +	/*
> +	 * Do not allow an IOMODE_READ segment to have write permissions.
> +	 * The group is left intact so group-readable files stay readable;
> +	 * nfsd_setuser() squashes an unmapped uid to the export's anon ID.
> +	 */
> +	if (seg->iomode =3D=3D IOMODE_READ)
> +		fl->uid++;
> =C2=A0
> =C2=A0	error =3D nfsd4_set_deviceid(&fl->deviceid, fhp, device_generation=
);
> =C2=A0	if (error)
> diff --git a/fs/nfsd/flexfilelayoutxdr.c b/fs/nfsd/flexfilelayoutxdr.c
> index 97d8a28dd3a0..c12bb7c371b0 100644
> --- a/fs/nfsd/flexfilelayoutxdr.c
> +++ b/fs/nfsd/flexfilelayoutxdr.c
> @@ -33,8 +33,8 @@ nfsd4_ff_encode_layoutget(struct xdr_stream *xdr,
> =C2=A0
> =C2=A0	fh_len =3D 4 + xdr_align_size(fl->fh.size);
> =C2=A0
> -	uid.len =3D sprintf(uid.buf, "%u", from_kuid(&init_user_ns, fl->uid));
> -	gid.len =3D sprintf(gid.buf, "%u", from_kgid(&init_user_ns, fl->gid));
> +	uid.len =3D sprintf(uid.buf, "%u", fl->uid);
> +	gid.len =3D sprintf(gid.buf, "%u", fl->gid);
> =C2=A0
> =C2=A0	/* data server entry: deviceid + efficiency + stateid + fh list +
> =C2=A0	 * user + group + flags + stats_collect_hint
> diff --git a/fs/nfsd/flexfilelayoutxdr.h b/fs/nfsd/flexfilelayoutxdr.h
> index 6d5a1066a903..3e1876d49db2 100644
> --- a/fs/nfsd/flexfilelayoutxdr.h
> +++ b/fs/nfsd/flexfilelayoutxdr.h
> @@ -35,8 +35,9 @@ struct pnfs_ff_device_addr {
> =C2=A0struct pnfs_ff_layout {
> =C2=A0	u32				flags;
> =C2=A0	u32				stats_collect_hint;
> -	kuid_t				uid;
> -	kgid_t				gid;
> +	/* Values to encode; nfsd4_ff_proc_layoutget() has mapped these */
> +	u32				uid;
> +	u32				gid;
> =C2=A0	struct nfsd4_deviceid		deviceid;
> =C2=A0	stateid_t			stateid;
> =C2=A0	struct nfs_fh			fh;
> --
> 2.54.0

Reviewed-by: Jeff Layton <jlayton@kernel.org>
