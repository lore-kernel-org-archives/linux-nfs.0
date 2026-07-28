Received: from fhigh-b7-smtp.messagingengine.com (fhigh-b7-smtp.messagingengine.com [202.12.124.158])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 99D531DCB24
	for <linux-nfs@vger.kernel.org>; Tue, 28 Jul 2026 00:33:44 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.158
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1785198826; cv=none; b=X3EmphsWL3NNFnlcgoKJFWBj2tjpghlLFXqTBPykL99CcuBbBk/IfVAG3dpFDR0r6HRNF50LnwBEFdwWY7668Rak4fincv1ZRjgl7dNJyTQDZ/oUj5MCZh/AauB9oLdjrg4+I22hchioPi1/E+q1SXTLB6rj2EJRu/hbbrobrBk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1785198826; c=relaxed/simple;
	bh=hmNMDMO5lvAMC5Bwev83KTakwezSPLWMlyI2k+yqj6o=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=lyD8b0/pcfWSz8/oKRxbcqHS3Ua7eUxLxHUAOE4SBZweJJCo6YSRjP5a+SDrrZjGeYxMDaWmTeDZPRFli/RRWW1/WIRhf8WGMEfD7Lbr5o1dsElgKdrLYI2IkCXhj/QSHNuJKYXeobuHRhpdnzIn6Y6Ia4fiQdPTWNy0/dNnJWY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Nv13ItqA; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=Rd1OAMo4; arc=none smtp.client-ip=202.12.124.158
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Nv13ItqA";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="Rd1OAMo4"
Received: from phl-compute-04.internal (phl-compute-04.internal [10.202.2.44])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 8A9727A0792;
	Mon, 27 Jul 2026 20:33:43 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-04.internal (MEProxy); Mon, 27 Jul 2026 20:33:43 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1785198823; x=1785285223; bh=HA9g8cKJG/elMjWQv4tSrhh2a9rrOqbih4h
	MxlQ7eaw=; b=Nv13ItqAxV9C5Yyj68vGF4fxguEyiCEHtb7oDcXzM5Q+Ssc+yep
	bAaWalFKSeG1QUubLxeEZIfnsoHhcE77IhbyNL4AWAjbySpJViWus6cTtRX2cBd2
	7kox41TADXVe79IA5j2/wmv1C4U/LjVO4/qeWQvlUuM/MBUY8LqUIhgLpUQNZ71v
	hyh3qhlsWYGCErHIbgrNdHvIm2rV1/ZdT5by0O9lBZ9zcbpKBBzX9oZXuJ3Z23SB
	OvA0E+WWEH6/HaVHJoo67HeUV/oQuxh1qKXvE2FRG7O8NprWgUDdD+3c5my9oMGs
	9nKx2O1Hu0ES2+GrnFrw60IocXDE5I2C0Sg==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1785198823; x=
	1785285223; bh=HA9g8cKJG/elMjWQv4tSrhh2a9rrOqbih4hMxlQ7eaw=; b=R
	d1OAMo49g84rLntdtzbpzc0zH6WQ1HvGK+ePpINWuZ5OZhfluYzWTz70mZHik67+
	fTBQufb2lA7uxf444r5xcKp1LZF9TfOhdzT+tQyXXorLGpr1y+/d7bPKvfxKCMHe
	v5Ily2J2CXTYjwHcM+c7Mdqmvmyg8nBwQEvThEb0iaAJWhe7YmLou6LdYf+EBcSG
	WJfuop1uEnTfzznByVocXF2Pzlz98GofFZn12U8uXkmDDnmAkFaKG2lIucPTyGTw
	gO2GqoSWkQKu/CA3orvz/sQBthb/zhH2hJTja6qXTXpaB99Ok8gN/Y7bkypmYR2N
	l3e5IxZWywGgwExaplhlg==
X-ME-Sender: <xms:5_hnausBJcImBrBU-00KTrOcviR0WzC4O8Ezf1Hr3B7mbWH5ZgOx_A>
    <xme:5_hnanI0kG_MdeuiKvYaxehLLN4BTLqyx4GAYGPfi4CHgXf7xss43Vodvk-Y8WJK3
    6W7B_G1tqwh7rXWgokOcYY0jkc_FpuS9ShOb2hXopmGpWH9gg>
X-ME-Received: <xmr:5_hnajkbYI3ON7kkhH0poMFHjV3dvkKjT3RiHG11XnavemIj2NkTf4ninO_X3FoUUjmKZesZOibkJO69VwRjvWZmgmTONYY>
X-ME-Proxy-Cause: dmFkZTG3YfbJiPU7uQid8B6lIbK0rluy8BeYYHVHiz2gqChE5UASted1rDZRpJQ8kyKE6G
    6CjGIJAPb60TuJ2vMSZFp+IBxi4nskLbYQLUdiOxhfOoa2WUz1h8ivIdSWRX5fL8NEd4Jb
    1iCKk2J4y24GBKrX5kJ7/ckS7WtnCpRiln4yqbTbVEj2F3bUeLAKM6oxC0mXL7dr9XpH5n
    q32xf3QronMpXsATGV5Obouj0pM/x0LxphYLn+0yP35gtBNyqlodjSA6glinB8Dg4P7mzh
    SmQJ+Kqu7ASXvG1Vn/xFi71W4Ihr/ZkgXOyUwhIcWVOTFjDZXflEj0RwALPeYtqOcMK8cY
    Oj8XdifLOJqMxRBmrze1RqnYKG/8JxQGYhKXyLd6954BFIoCr7nmqTc6J/ysYSc6epb9t0
    7Jw7/pVD3C5k4K2xKJPnPmlRoI3yEzvq8AbGC3GODLwrJUY6ep8ApwdhuQmKPIJeh5gyex
    BkW/W2MQ6R4jshzAx3Bxq6ceZWC3G16XfG/v5Uljdxi5qDhwGviHjGeaihIBbUrrZ9MsDw
    Dpfk+UBr3MPewaUwTqudecr9EYQQmCPqAX8oSKk7N4nWhAdwNAFTerSivMSNH2s1MMQbDF
    KWL+O1k/Ou8VEoHTXMB60pAesUERSnpLn1OpAKT8CYwSXQtYkKciVZvUkltQ
X-ME-Proxy: <xmx:5_hnagI92vQVBjm0JuhVXBP98sOt7WMkZEwuQUKzMxla1Id_wb-6NQ>
    <xmx:5_hnag6VCbQgDjAEbzZbA_tRV5mofqW_skBT3QW24wCGwm2260zrZg>
    <xmx:5_hnas0pF2Bs_8XA4IFtp4_ZssTd-sgN2zvT2mMdv0JtM8F_uOFtsQ>
    <xmx:5_hnaudwbxZeV1aSSmFhvDLnQ-p5UJUhzbPVSTURWPR7s4eQMXu4ug>
    <xmx:5_hnasNGX1b66OFLtdJQ_6KPwRM6W8GNVmlg7Eu5cCMZoAr_A7aLZXDZ>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Mon,
 27 Jul 2026 20:33:39 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <dai.ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 3/3] NFSD: Tighten header includes in localio.c
In-reply-to: <20260727130410.14887-4-cel@kernel.org>
References: <20260727130410.14887-1-cel@kernel.org>
  <20260727130410.14887-4-cel@kernel.org>
Date: Tue, 28 Jul 2026 10:33:34 +1000
Message-id: <178519881488.279875.2699137716663899890@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 27 Jul 2026, Chuck Lever wrote:
> As a prerequisite to converting NFSD to use xdrgen more broadly,
> NFSD source files should not depend on NFS client headers.
> fs/nfsd/localio.c is server-side LOCALIO code, yet it pulled in
> three of them: <linux/nfs_fs.h>, the client inode header (struct
> nfs_inode, NFS_I(), writeback helpers), which server code never
> uses; <linux/nfs_xdr.h>, whose only referenced symbol is
> decode_opaque_fixed(), a static inline that exists to remap the
> error return to -EIO for client call sites; and the catch-all
> <linux/nfs.h>.
>=20
> Convert the UUID decoder to call the canonical SUNRPC primitive
> xdr_stream_decode_opaque_fixed() directly. It is shared by client
> and server, performs the identical bounds check, and is already
> reachable through <linux/sunrpc/clnt.h>. With the wrapper gone,
> localio.c references no symbol from <linux/nfs_xdr.h>, and with
> that header gone, none of the NFSv3 definitions its structs embed
> are needed here.
>=20
> Drop all three client includes and add what the file actually
> uses: struct nfs_fh comes from <linux/nfs_fh.h>, included directly
> rather than through nfslocalio.h's conditional re-export, and
> NFS4_FHSIZE from <linux/nfs4.h>. enum nfs_stat and
> nfs_stat_to_errno continue to come from the already-included
> <linux/nfs_common.h>.

I think it would be better to not include nfs4.h because it doesn't seem
particularly relevant to localio.
Instead, replace NFS4_FHSIZE in localio.c with NFS_MAXFHSIZE which is
defined in nfs_fh.h.  I think that macro is a better fit for what is
actually wanted.

Otherwise this all looks good and sensible.

Thanks,
NeilBrown

>=20
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/localio.c | 7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>=20
> diff --git a/fs/nfsd/localio.c b/fs/nfsd/localio.c
> index c458c01e9478..4110be02b750 100644
> --- a/fs/nfsd/localio.c
> +++ b/fs/nfsd/localio.c
> @@ -11,11 +11,10 @@
>  #include <linux/exportfs.h>
>  #include <linux/sunrpc/svcauth.h>
>  #include <linux/sunrpc/clnt.h>
> -#include <linux/nfs.h>
> +#include <linux/nfs4.h>
>  #include <linux/nfs_common.h>
> +#include <linux/nfs_fh.h>
>  #include <linux/nfslocalio.h>
> -#include <linux/nfs_fs.h>
> -#include <linux/nfs_xdr.h>
>  #include <linux/string.h>
> =20
>  #include "nfsd.h"
> @@ -179,7 +178,7 @@ static bool localio_decode_uuidarg(struct svc_rqst *rqs=
tp,
>  	struct localio_uuidarg *argp =3D rqstp->rq_argp;
>  	u8 uuid[UUID_SIZE];
> =20
> -	if (decode_opaque_fixed(xdr, uuid, UUID_SIZE))
> +	if (xdr_stream_decode_opaque_fixed(xdr, uuid, UUID_SIZE) < 0)
>  		return false;
>  	import_uuid(&argp->uuid, uuid);
> =20
> --=20
> 2.54.0
>=20
>=20

