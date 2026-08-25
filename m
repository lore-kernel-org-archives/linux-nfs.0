Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 41CDE397920;
	Tue, 25 Aug 2026 12:10:35 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787659837; cv=none; b=JzIDpRx7LtzQho577icl4MO7EzfnICivjYDpx/9oLi8GD9vbNucIpFPVxr/ywbgteZnL48JJqBezCB7wKLip3FAimVK3lvUP+jP1GDRBS1HAYdJBopAFM307jnvI1T+TWZ0zv71Yl2oA/O0H02B/DypOp8gbqTFz6ZZlJBXT9k0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787659837; c=relaxed/simple;
	bh=HWX3BM3fsg0CcS4Fwfcym8SQKp/T8MZf0lxpIJkbT9s=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=FRL496fYeq6yXQPBBIwhfGR+8BJJiuB9vRL2pyh+RIhX09/GHsQgyIpsYlG9eLv0F1EEA5LCWrblHLpBefoIEqIH+zDQlBLZHVM6zUK9JS9aK7w5ECld2NH1N/S7NkzmRGREK8t7XyXyRhIsUtfsTQvFtSCS9wAxV7NwakqyxjU=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=jvVZR9JK; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="jvVZR9JK"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E6DEE1F000E9;
	Tue, 25 Aug 2026 12:10:34 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787659835;
	bh=2fOHfaamDHwrP03QUVghU7iVUhTOne/SHfVrG8jYrwk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=jvVZR9JKOniRQx+UU1M76GWalda/F/DFlKogS7joxF5EHsDgiZlSJfqQSMUPXxiYt
	 NcdT97iwwzXYxe+MoPtyRIcnuI7gARaUOjAAKYIMTv6XwPHji4JB5JMEnRj+5FSpq+
	 qOiozD2c/0g9ssDhD5N52xEuGIfPGTIBWPA5pqtVw8ZTms0Zj8feQOJzEzj/dn32oF
	 VIOztXCNpmMlxynGawen6uAZgSGiM+dE67HVoaeQ0lUydfTRnUEDnBI3+OYveXCS1J
	 9D6ce1B3s75MH00+ZmSQAYn1QJ+fKHYrsHfNkbccb4TSsgTBSkCCeCS/wIQTP9sRs3
	 1muZ9nlQ0Vp7w==
Message-ID: <1046756851d9d7d688ac612a7f175e48745d2b84.camel@kernel.org>
Subject: Re: [PATCH v1 1/3] nfsd: report NFSv4 grace state through Netlink
From: Jeff Layton <jlayton@kernel.org>
To: Prabhakar Pujeri <prabhakar.pujeri@dell.com>, cel@kernel.org
Cc: neil@brown.name, okorniev@redhat.com, Dai.Ngo@oracle.com,
 tom@talpey.com, 	donald.hunter@gmail.com, kuba@kernel.org,
 linux-nfs@vger.kernel.org, 	linux-kernel@vger.kernel.org
Date: Tue, 25 Aug 2026 08:10:33 -0400
In-Reply-To: <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com>
References: <cover.1787638668.git.prabhakar.pujeri@dell.com>
	 <3fd25e2178458fbb44f57f1b0e068c12a6503d17.1787638668.git.prabhakar.pujeri@dell.com>
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

On Tue, 2026-08-25 at 06:51 +0000, Prabhakar Pujeri wrote:
> Operational tooling needs to distinguish a server that is accepting
> normal NFSv4 state operations from one that is still accepting only
> recovery requests. The existing Netlink threads query reports
> server-wide configuration, but recovery state is available only through
> the nfsd filesystem.
>=20
> Add an in-grace value to the threads-get reply. Return it in every reply
> so user space can distinguish a server that is not in grace from an older
> kernel that does not provide the attribute.
>=20
> Signed-off-by: Prabhakar Pujeri <prabhakar.pujeri@dell.com>
> ---
>  Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst | 3 +++
>  Documentation/netlink/specs/nfsd.yaml                   | 6 ++++++
>  fs/nfsd/nfsctl.c                                        | 9 ++++++++-
>  include/uapi/linux/nfsd_netlink.h                       | 1 +
>  4 files changed, 18 insertions(+), 1 deletion(-)
>=20
> diff --git a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst b/Do=
cumentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> index c05926f79054..35c174000ab3 100644
> --- a/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> +++ b/Documentation/admin-guide/nfs/nfsd-admin-interfaces.rst
> @@ -25,6 +25,9 @@ udp and one tcp listener at port 2049 (see nfsd_init_so=
cks).
>  On startup, nfsd and lockd grace periods start. nfsd is shut down by a w=
rite of
>  0 to nfsd/threads.  All locks and state are thrown away at that point.
> =20
> +The ``in-grace`` value in the ``threads-get`` Generic Netlink reply repo=
rts
> +whether the NFSv4 server's recovery grace period is still active.
> +
>  Between startup and shutdown, the number of threads may be adjusted up
>  or down by additional writes to nfsd/threads or by writes to
>  nfsd/pool_threads.
> diff --git a/Documentation/netlink/specs/nfsd.yaml b/Documentation/netlin=
k/specs/nfsd.yaml
> index 642268819c6f..d01d93f39392 100644
> --- a/Documentation/netlink/specs/nfsd.yaml
> +++ b/Documentation/netlink/specs/nfsd.yaml
> @@ -130,6 +130,11 @@ attribute-sets:
>          type: binary
>          checks:
>              exact-len: 16
> +      -
> +        name: in-grace
> +        type: u8
> +        doc: One while the NFSv4 server is in its recovery grace period,
> +             otherwise zero.
>    -
>      name: version
>      attributes:
> @@ -464,6 +469,7 @@ operations:
>              - leasetime
>              - scope
>              - min-threads
> +            - in-grace
>      -
>        name: version-set
>        doc: set nfs enabled versions
> diff --git a/fs/nfsd/nfsctl.c b/fs/nfsd/nfsctl.c
> index 6e63950a99e1..7ea865b372cc 100644
> --- a/fs/nfsd/nfsctl.c
> +++ b/fs/nfsd/nfsctl.c
> @@ -1775,6 +1775,7 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, s=
truct genl_info *info)
>  {
>  	struct net *net =3D genl_info_net(info);
>  	struct nfsd_net *nn =3D net_generic(net, nfsd_net_id);
> +	bool in_grace =3D false;
>  	void *hdr;
>  	int err;
> =20
> @@ -1790,6 +1791,11 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, =
struct genl_info *info)
> =20
>  	mutex_lock(&nfsd_mutex);
> =20
> +#ifdef CONFIG_NFSD_V4
> +	in_grace =3D nfsd_vers(nn, 4, NFSD_TEST) &&
> +		test_bit(NFSD_NET_UP, &nn->flags) &&
> +		!test_bit(NFSD_NET_GRACE_ENDED, &nn->flags);
> +#endif


What's your interest in reporting this info?

Just because the v4 recovery is done does not mean that you will be
able to access files. The overall system grace period is a union of
both the NLM and v4 grace periods.

This patch is reporting just the v4 one. If the goal is for the admin
to reliably tell when the grace period has been lifted, then this won't
tell us that.

Maybe this should just return the result of locks_in_grace() instead?

Or, do you plan to add similar functionality to lockd? Then you can
just do the union in userland to figure out if it has been lifted.

>  	err =3D nla_put_u32(skb, NFSD_A_SERVER_GRACETIME,
>  			  nn->nfsd4_grace) ||
>  	      nla_put_u32(skb, NFSD_A_SERVER_LEASETIME,
> @@ -1797,7 +1803,8 @@ int nfsd_nl_threads_get_doit(struct sk_buff *skb, s=
truct genl_info *info)
>  	      nla_put_u32(skb, NFSD_A_SERVER_MIN_THREADS,
>  			  nn->min_threads) ||
>  	      nla_put_string(skb, NFSD_A_SERVER_SCOPE,
> -			  nn->nfsd_name);
> +			  nn->nfsd_name) ||
> +	      nla_put_u8(skb, NFSD_A_SERVER_IN_GRACE, in_grace);
>  	if (err)
>  		goto err_unlock;
> =20
> diff --git a/include/uapi/linux/nfsd_netlink.h b/include/uapi/linux/nfsd_=
netlink.h
> index 87da1d0bb21e..e1fc2db00046 100644
> --- a/include/uapi/linux/nfsd_netlink.h
> +++ b/include/uapi/linux/nfsd_netlink.h
> @@ -84,6 +84,7 @@ enum {
>  	NFSD_A_SERVER_SCOPE,
>  	NFSD_A_SERVER_MIN_THREADS,
>  	NFSD_A_SERVER_FH_KEY,
> +	NFSD_A_SERVER_IN_GRACE,
> =20
>  	__NFSD_A_SERVER_MAX,
>  	NFSD_A_SERVER_MAX =3D (__NFSD_A_SERVER_MAX - 1)

--=20
Jeff Layton <jlayton@kernel.org>
