Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=202.12.124.151
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793312609;
	b=hFDPK+KRzPjVfrzOLIVFPHpNN8LW0CLzPgFmVN4NOQts2yxMmtWQa/BQBwb5WycwXUom
	 LKADtQS32DnChzS4Lqh0QdYARSKgATFMbqE/yPfxtiYvmpOox1DZzJRURDW3+QKq+prI6
	 tU6tw1Jr54XWb3IcsRKfezuIzK1Dq/rOHiwNulY+RKEhuYsCzBfLEibebpM6f6X4XBxUE
	 DdVjR5ov1PNAZk13QdvQqfeTf4J7KBHQ2kkMfyVQ8clNUJgIif0BaJsUuHlYSkMvxINTC
	 31x71WH6jpSTHNIrplECz9cnu5MitESZ/rTPOaq4VGe4h3HJTTBez94XEnDZ6n+QMMw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793312609;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=ZvSqu33VwzN9N6NrqP0yeIbdJwaFf2DGli8QvsjzCCM=;
	b=lzLyvhjfS2aE++3/A8/WAz/sXGcAIeBlexhcvKmMkj3SKobMvUjdkIxuJrkfhJY9c9z1
	 mGCztCHNwp0QM7398Z8Ly/dEwaHDPhXpREM+g1vnOo1ArlQnhpKS9TQSoUeIazysL2SaS
	 CqoF9UAR3EnkgGmzpJY2zWr4R3UDShAQkWPjcaS70zy4ckNEKFXi8RS/QtGzxL7JZc8+L
	 rLVKoKM3vTD8Gw9uUlCh2LdEOOacVwXq7m/HyU2itRjZJUZ8m94w5fgKlSBYAZ6AemoQV
	 6OGmlTl9Ap60lk3clAFETNEE8KoH0GXix6D0Ss56NU0brwT89lQEdEbWUxtyC7EmsAA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=VedKNd8g;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=tF00iBdP;
	arc=none smtp.remote-ip=202.12.124.151
Received: from fout-b8-smtp.messagingengine.com (fout-b8-smtp.messagingengine.com [202.12.124.151])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1) server-digest SHA256)
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 341DC606A31A
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 22:23:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 341DC606A31A
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=VedKNd8g;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=tF00iBdP
Received: from phl-compute-01.internal (phl-compute-01.internal [10.202.2.41])
	by mailfout.stl.internal (Postfix) with ESMTP id 4EE5B1D000B4
	for <linux-nfs@vger.kernel.org>; Thu, 29 Oct 2026 18:23:28 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-01.internal (MEProxy); Thu, 29 Oct 2026 18:23:28 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793312608; x=1793399008; bh=ZvSqu33VwzN9N6NrqP0yeIbdJwaFf2DGli8
	QvsjzCCM=; b=VedKNd8gqxVo2N0oqk0oDxszhCNQHyDIzKPBeE05wxY2RCWMPVV
	OkOuKq8I+kLpifWQTgEEDMDyZ23ZzPNSjaaY5AxuoSrnmEHIk0U3l7QA2wtdkT3g
	KLmybRSpivOoQwGSdaq11ZhwgL7wJiwzxtkwa5rIICWoGB/JHBERVVWtZWWJfFA5
	qDuRnH5QEtxFg2uxkaSGMxh9GqGF8J7GP1XNo9+zCvbANfubMA1eYeg10OJIYERE
	fDXE3BoAuv+etXWgjWC+kJfZmn3smXGmW4IxPj5c3yTqsJzhKinHwZYTB9cB4y+/
	QAJDt59TCGzKLvCl023Zmi8UHOP3ORUkxeA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793312608; x=
	1793399008; bh=ZvSqu33VwzN9N6NrqP0yeIbdJwaFf2DGli8QvsjzCCM=; b=t
	F00iBdPTsY8WqmUbnu0lR2CYgL5G2GJHaxtwSdHwWk2pVZVQ04n+rLfhgwXG7mwO
	6O81mNP2N/h8gOu1cUF0zvwzJvvDcWg1UOHIERS3/KRQobwox1jy2ZBE89MCDjFK
	N8eu1YGU4R1HDAsBv6RvIFymXuOXWRK70r2NRjDRaUePoAl7VNLde3zbmSGf8LEu
	gUx1B/mVCF2rYOsq/IrULbEd6f5jnNOJ+x35p4n2+EA5UIpqone+on8mPt0ZnpVV
	Mx8giMzpOdBMxL+eGDJTewNBMvQbI7uEPoxGm5vecCfhAsYX3EZU1qV8hyicQ/xA
	dJcPPnHiLqZVLI9Ua9TqQ==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793312608; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:Bg13hii7zub8XT9GPMQosy+Cq2E2N1MUoXiWkn+28VL2bFh
	l9vshcrnhonaPyVxyNPBgkOJU9xmlFp7aYuHBpopg9oedeTLwiNNjO/0S0QiH/FF
	3ohwGMOAF/PEAsV/q10CBU+dFVhPVwVAQx7tmDpwX+p5vIwVF9fOnMW20qDMNEMJ
	8v1ir+mdaj3DAU1Ih6+LLacV+i9arB40JSdzihkp6Ts5wW3AiTCfJzP5dfB1N+h1
	ZC4j9wQz5932BF3rv45Ct/yBrOiSI1zjOq2kmANgcwSw87K1884l7YvbzJrHjdtP
	EtBlJfQvnWRGtKa9miLJg760kZ8r50cOE5XoRUg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:PJaC5ePuITNYs3Isdew3ZWP9oM6BkaNc+LgFBktKDNE=:9Xhi+KkqG3inG8QmyT83XzAcRCxsLosfwTCzc/SAnY8=;
X-ME-Sender: <xms:X8fjatBuNNa9YkDZoQag2LXy8D1i1HBxcA7ARNCnweq2ewERMU7K5Q>
    <xme:X8fjan6OghgqlatZqDH-_fJuyGVP51QKTgxF7Pc3mX2bfOz85U9jCkIcRl4-NBQQH
    RMdfDpTqy6_sqrCVspYtVKhztUM_F1h63hWrwTgjngZK-Fqv_g>
X-ME-Received: <xmr:X8fjatBwf56tcDq6ETSv4Kjr5iSk2JW2GOnSw4Uy-MwmzPDUpvw6WCr3ReP6kV6wnIqE70ZKFiyFbl4sV1WcONKcq0dqZqQ>
X-ME-Proxy-Cause: dmFkZTE5nlQ15e2vVjI800vPsKIFX6u6l/cv1Dtj+ZXc0iB6zB9GRyFRt/uKLv1NH/wSMx
    S4LF9sRWFHcc1nsXe8iGnS3+pVlVSlS3OYcHuOyLd+rlWe6wBoUcItYFVYlmSIowbVxcPF
    HjilRmmynrLdTFnIW6yBeoqShnhHSFsb8VZFH9DgjH6vGFjTfsIYiyEFdNFnwwblVH+7PB
    bzZbg9usoCZuRpF+TU7J4vy7pdeMyoedEUKnjjq8VIL+5hzenYTzvK0/Veh8Mqg1YZvrey
    TYEJmc2eH5UDb895p6A2qnME+wCsHv+htHQ8NvTrJChc0Z304KtqLVMHsmIoyl++IZEgj4
    uhiLO/mPZaJuPKPw7IdTyH4ePihavxwIdb4ScnUmnlva3oa7EhC7Tt+kayGonByBOkll2X
    qf8GhEKaWVQTZPvQjqFnDMsIxfxxrsh0JQkDW4RcOimq7U7olkKhkWdhFovoToxiFu6aqB
    eZHG300koFyNyg5WV2X710VmSQLPibyci01I4vXTP2dt9v5p9OCfdAzITA/R+eZdTlxnzw
    z4Boh2/6wQUZoPWGBVPEnSrI5rD6y5C8c1rVpHReQ5/QHLunmfp9c+dcU70FepXJaXeq7D
    z9h4UqbElM1MKe1O4VjTKd0ABZUb03tAVCjolSfabOVhNqCCqK8KXN2MzneA
X-ME-Proxy: <xmx:X8fjal79kuLBe0RyjtRsMqJ7sHKuCZK9J545xcYm1Muec0ZRrQmefA>
    <xmx:X8fjauv0pkuQtHdE67mYG7ICvM9dDG4RnyvJLPQ6wcauADXUlBkC8g>
    <xmx:X8fjai6OLORBk8sM7gFQ86lWvOTgdZkNaAhG7zr_ULiBKkhOIYO1ew>
    <xmx:X8fjaq3iSLlWbhImoR1vlmQyRHyfwRksaZ2MfpoUHE4YzNSSvFVPwA>
    <xmx:YMfjavnv8THOTMqOWgrX7D3pNpkrpLV_g-hNtBQjb0RlHkz2CtMLolci>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Thu,
 29 Oct 2026 18:23:23 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jonathan Flynn" <jonathan.flynn@hammerspace.com>
Cc: "Alexander Viro" <viro@zeniv.linux.org.uk>,
 "Christian Brauner" <brauner@kernel.org>,
 "Trond Myklebust" <trondmy@kernel.org>, "Anna Schumaker" <anna@kernel.org>,
 "Jeff Layton" <jlayton@kernel.org>, "Chuck Lever" <cel@kernel.org>,
 "Jan Kara" <jack@suse.cz>, "Jonathan Corbet" <corbet@lwn.net>,
 linux-doc@vger.kernel.org, linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH RFC 03/12] nfs: tell the VFS when two names can be one
 entry on the server
In-reply-to: <20261029180957.387138-4-jonathan.flynn@hammerspace.com>
References: <20261028041023.3738553-1-neilb@ownmail.net>
  <20261029180957.387138-1-jonathan.flynn@hammerspace.com>
  <20261029180957.387138-4-jonathan.flynn@hammerspace.com>
Date: Fri, 30 Oct 2026 09:23:21 +1100
Message-id: <179331260192.1157394.6210237718575047017@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Fri, 30 Oct 2026, Jonathan Flynn wrote:
> A server that reports itself case-insensitive, or as not preserving
> case, can make one entry of two names that the client caches apart,
> because the client compares names byte for byte.  Mark the filesystem
> on such a server with SB_I_NAMES_COLLIDE, from "vfs: allow the parent
> lock to be shared for O_CREAT", so that the VFS keeps the exclusive
> directory lock for creates there: the per-name exclusion that replaces
> the lock for a create made with it held shared covers one byte string,
> not the names the server treats as equal.  The client learns this when
> it reads the server's capabilities, which it does again on remount, on
> migration and when a later mount reuses the filesystem, and it updates
> the mark each time.
>=20
> This is a conservative fallback.  A server that declares itself
> case-insensitive should itself treat the two names as one, but one that
> did not was seen making two files of one name when such creates arrived
> together.  No filesystem relies on the mark yet, so nothing changes.

We don't normally work around server bugs in the client.  We tell the
server maintainers to fix their server.

But we *certainly* don't work around them in the VFS with
SB_I_NAMES_COLLIDE.  That sort of fs behaviour might be tolerable for
files but it is a real problem for directories!

Once we move directory locking into the filesystem, the NFS client code
might choose to add extra locking for servers that might be problematic.
It would then be entirely in the NFS code then, and up to the NFS
maintainers to decide what to do.
But this logic does not, I think, belong in the VFS layer at all.

This just confirms me in my preference to continue on the path I have
planned.

Hopefully next week I'll put together an RFC for the next steps, and
we pursue the prep patches that haven't been acked yet.

Thanks,
NeilBrown


>=20
> Signed-off-by: Jonathan Flynn <jonathan.flynn@hammerspace.com>
> ---
>  fs/nfs/client.c   |  1 +
>  fs/nfs/internal.h | 35 +++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs4proc.c |  1 +
>  fs/nfs/super.c    |  2 ++
>  4 files changed, 39 insertions(+)
>=20
> diff --git a/fs/nfs/client.c b/fs/nfs/client.c
> index ea99b3c105..30206b309c 100644
> --- a/fs/nfs/client.c
> +++ b/fs/nfs/client.c
> @@ -975,6 +975,7 @@ static int nfs_probe_fsinfo(struct nfs_server *server, =
struct nfs_fh *mntfh, str
>  			server->caps &=3D ~(NFS_CAP_CASE_INSENSITIVE |
>  					  NFS_CAP_CASE_NONPRESERVING);
>  		}
> +		nfs_server_publish_name_caps(server);
>  	}
> =20
>  	if (clp->rpc_ops->discover_trunking !=3D NULL &&
> diff --git a/fs/nfs/internal.h b/fs/nfs/internal.h
> index 5af6a032f1..34b8aff4e0 100644
> --- a/fs/nfs/internal.h
> +++ b/fs/nfs/internal.h
> @@ -224,6 +224,41 @@ int nfs_init_server_rpcclient(struct nfs_server *, con=
st struct rpc_timeout *t,
>  struct nfs_server *nfs_alloc_server(void);
>  void nfs_server_copy_userdata(struct nfs_server *, struct nfs_server *);
> =20
> +/*
> + * Tell the VFS whether this server can make one directory entry of two na=
mes
> + * that differ as byte strings.  NFS installs no ->d_hash or ->d_compare, =
so
> + * the dcache compares names byte for byte, while a server that is
> + * case-insensitive, or does not preserve case, makes "foo" and "FOO" one
> + * entry.  On such a server SB_I_NAMES_COLLIDE keeps the parent of an O_CR=
EAT
> + * open locked exclusive; see atomic_open_create_shared() in fs/namei.c.
> + *
> + * server->caps is derived again on every probe of the server: at mount, at
> + * remount, on migration, and when a later mount reuses this superblock
> + * (nfs4_proc_get_root()).  So this is called wherever the case bits of
> + * server->caps are written, once they have their final value, and when the
> + * superblock is set up, because the first probe runs before it exists.  T=
he
> + * value is what the probed file handle reported, normally the mount root'=
s;
> + * the homogeneous attribute is not fetched, so a server whose answer diff=
ers
> + * below the root is described by the root.  Migration runs the probe from
> + * the state manager without ->s_umount, so the update is atomic, and it is
> + * made only when the value changes.  Two probes of one server at once can
> + * leave the bit as the earlier of them derived it; that needs the server's
> + * answer to change between them, and server->caps has the same race.
> + */
> +static inline void nfs_server_publish_name_caps(struct nfs_server *server)
> +{
> +	struct super_block *sb =3D server->super;
> +	unsigned long bits =3D 0;
> +
> +	if (!sb)
> +		return;
> +	if (READ_ONCE(server->caps) & (NFS_CAP_CASE_INSENSITIVE |
> +				       NFS_CAP_CASE_NONPRESERVING))
> +		bits =3D SB_I_NAMES_COLLIDE;
> +	if ((READ_ONCE(sb->s_iflags) & SB_I_NAMES_COLLIDE) !=3D bits)
> +		set_mask_bits(&sb->s_iflags, SB_I_NAMES_COLLIDE, bits);
> +}
> +
>  extern void nfs_put_client(struct nfs_client *);
>  extern void nfs_free_client(struct nfs_client *);
>  void nfs_cb_idr_remove(struct nfs_client *clp);
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 113c199a6f..fac8450b65 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -4020,6 +4020,7 @@ static int _nfs4_server_capabilities(struct nfs_serve=
r *server, struct nfs_fh *f
>  		if (nfs4_server_delegtime_capable(&res))
>  			caps |=3D NFS_CAP_DELEGTIME;
>  		WRITE_ONCE(server->caps, caps);
> +		nfs_server_publish_name_caps(server);
> =20
>  		memcpy(server->cache_consistency_bitmask, res.attr_bitmask, sizeof(serve=
r->cache_consistency_bitmask));
>  		server->cache_consistency_bitmask[0] &=3D FATTR4_WORD0_CHANGE|FATTR4_WOR=
D0_SIZE;
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 23292680ad..e70cef88fb 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1082,6 +1082,8 @@ static void nfs_fill_super(struct super_block *sb, st=
ruct nfs_fs_context *ctx)
>  			sb->s_export_op =3D &nfs_export_ops;
>  		break;
>  	}
> +	/* The first probe of the caps ran before this superblock existed */
> +	nfs_server_publish_name_caps(server);
> =20
>  	sb->s_magic =3D NFS_SUPER_MAGIC;
> =20
> --=20
> 2.43.0
>=20
>=20

