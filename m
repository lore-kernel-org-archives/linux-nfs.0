Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=103.168.172.145
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793569150;
	b=3BRv5sRd3TtunpDhqPfNT2yH5wDcsZryZBNFbhAwWqq8yNDeHDHcSOmvopqL5pC33F1G
	 kenq6XmIje9jHjLRm1CjgJHpAyj+hHwSiHYJ3PfKAvhkmxN7YQKigkhkloWQ0Da8WFt+f
	 qmbS9QVViFe0uAaTr3+1DaZy2XytMtCgq55D0/o1WFdnlDXFxKRku9ZA4B7h+cfyA5/db
	 aOt2f2ZIP9aU85f74+xpKebZaGyjn/H/zfWtZrVonZkBtPi1GzBMGU5784s2u+IbkOjeJ
	 VrDwbos7BqZsm2oVakumMHEQifQVb0T9zFmMgKjXucIv/zt3/+DKM6MA4+HJYzaTKZQ==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793569150;
	h=DMARC-Filter:Received:Received:DKIM-Signature:DKIM-Signature:
	 X-DKIM2-Info:DKIM2-Signature:X-DKIM2-Info:Message-Instance:
	 X-ME-Sender:X-ME-Received:X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:
	 Received:Content-Type:Content-Transfer-Encoding:MIME-Version:From:To:
	 Cc:Subject:In-reply-to:References:Date:Message-id:Reply-To;
	bh=lwP8ycQo5PTTc/dYVB1SqGpgCjq4Sjj5i8p0oHH++Fw=;
	b=p0nde1Qs3Wnz71P5kp6I5FK16er/h+iCxdNzr+uF/TlMcWq6nAPXWOkwiazyjKm+4cgA
	 vLeLUYjlRoZR3fd1btKdDmPmGn0vhx5flPtCYYSoxg/Ubpz8T3Sx75hoq5oluNBRclhLo
	 OZuaJfaynFIVrPXq5sSUIQWsnYRhYYt0+NmziwlL6+MuibR5fDe2p/bkYJgycwuhWGkIw
	 t+/WGGyb2rpa+do/9V/vu33eSduGaUgAF8uJ1xA3Voqoyz/LgQkrNzdpsgaDMngBNO2af
	 xkLITkbi45ZE3v2SIJ2h7hGqWWZHgctyarkEUJItcdreKfoWYRT7uMLAZ0Zswxb+VTw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dmarc=pass header.from=ownmail.net;
	spf=pass smtp.mailfrom=ownmail.net;
	dkim=pass header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QPQwCMeP;
	dkim=pass header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b="D/wsx+xp";
	arc=none smtp.remote-ip=103.168.172.145
Received: from fout-a2-smtp.messagingengine.com (fout-a2-smtp.messagingengine.com [103.168.172.145])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4DDF3606A326
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 21:39:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.4.2 smtp.subspace.kernel.org 4DDF3606A326
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=ownmail.net header.i=@ownmail.net header.a=rsa-sha256 header.s=fm2 header.b=QPQwCMeP;
	dkim=pass (2048-bit key, unprotected) header.d=messagingengine.com header.i=@messagingengine.com header.a=rsa-sha256 header.s=fm2 header.b=D/wsx+xp
Received: from phl-compute-07.internal (phl-compute-07.internal [10.202.2.47])
	by mailfout.phl.internal (Postfix) with ESMTP id 5F944EC01DD
	for <linux-nfs@vger.kernel.org>; Sun,  1 Nov 2026 16:39:09 -0500 (EST)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-07.internal (MEProxy); Sun, 01 Nov 2026 16:39:09 -0500
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm2; t=
	1793569149; x=1793655549; bh=lwP8ycQo5PTTc/dYVB1SqGpgCjq4Sjj5i8p
	0oHH++Fw=; b=QPQwCMePetFFUPwt8j8EJD+0IvJrJMn8ExRukMKNL8ETLYPgcXZ
	8eAfOmYulwMIUSHg59wrjdVQU+e0zjT4DU16JBK0YnMVC63vXYPjWSa6c7bG+Oa5
	64gCHrSThjd36lTpk5oDdFydDrwtjqWzTPn+0wUW0QkQ1s/EpXRe2m4b8bEVM+bg
	lohN+m6eKlBcp16ufl6eq4WO2AB6cgr5AOn+uo/TavBaX6R0seutjBt4mwXuP+z+
	H7iUiwV1bOz6VBbjlK/+pPJZCXaQsnDp1qsjLPCwhWL9GW53P6BrSoEQQoio0Ef8
	ENukQmzWRSwbrnSAHejTcwHHWufiG5xtF5w==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm2; t=1793569149; x=
	1793655549; bh=lwP8ycQo5PTTc/dYVB1SqGpgCjq4Sjj5i8p0oHH++Fw=; b=D
	/wsx+xpbN/A1Hyp2FDjyolI/Tt89QO+D03+5p6Fjo5stIp8l7Jt0UDmwxWB8LhqI
	2pPMqQ+MeEQNgtdIUnJcZdWDlHBICte3Uiemlz5rnav5Ew2ayhRg5Niab7R7D4iB
	S/oJlxZrQT5kAewXS7nBJi38iw7JiEAE52jKTTTnDQ+zST0EuyqXBBld/7gch5WB
	vm4b6rH8fU7GYryCiDN1D+J2hJcGDohkMx9FZAUJ01te9J36HPblQlsY9DT1Vs1i
	o3Zz9XHw7wjbYQR+ZvPe67rx1lQMt4oMGYQ9eVCD7Q/HdO49Dc+OKDA6dwG23esC
	mCow/aA0iVLH185DTNdkA==
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=sign d=ownmail.net a=rsa-sha256;
DKIM2-Signature: i=1; m=1; t=1793569149; d=ownmail.net;
	mf=PG5laWxiQG93bm1haWwubmV0Pg==;
	rt=PGxpbnV4LW5mc0B2Z2VyLmtlcm5lbC5vcmc+;
	s=fm2:rsa-sha256:KGppGhyc1MXAMeVgcQw02qxROBwMLMmz0i9M6klxjsSrRPe
	6IfxOFMTGjbd1e6oRyO7HvPQgdiLFgL5RaRg88aZIJlPyQ6u+Gpu6FvX5FJypKxc
	Z059P+UrFGfVvzePHIb7pC/kGw1WOQzokFo2k6u3o6RCTZnM99PCMo/nZOizxNxv
	nFzansZGIKrWdsK9kUU8rvV4SYeR4JextJlyrWUyfb12UTyVt0LerL6zK+qsg3Ys
	bakaPbzYsobzj6fruIfrmhECrkSl9m/C6hz7zzUlou52oaiJU0Zfzlin9x7iA3LD
	bouMKBCfg20JlknfnP6F6X1sTJzrEgM0hIxqMmg==;
X-DKIM2-Info: draft=ietf-dkim-dkim2-spec-08;
	repo=github.com/dkim2wg/interop; date=2026-10-28; sw=lmtpprox;
	action=mi-m=1; hc=13;
	hn=cc,content-transfer-encoding,content-type,date,feedback-id,
	from,in-reply-to,message-id,mime-version,references,reply-to,
	subject,to;
Message-Instance: m=1; h=sha256:9miFjryQHO1KmqzSrqIhkMbNW6nxCHsBOp5thbTaWQg=:cVtjZT3UUBze5Ok+wlc4VpICLbO+9PQl2PYbEIz6XNI=;
X-ME-Sender: <xms:fbHnamBcdk5IoTi85oEiGKd0tlnW7a_EkC3nrQ-Rl0cqdje5-W0IWA>
    <xme:fbHnaqiyzJyutcOX2c4OFfzck5YeDxbQwRJRmmvCSL4wbWNOf5Xai1ZsMbHqV1yU5
    X59bxWJ_8zVnw7oYenWjVXSVM_DDeCKYYKOzmdLGchALYMFubU>
X-ME-Received: <xmr:fbHnagOQyTZ55ZHBED1uFuYCejOkxEVNjVDOtyVas4rge2dCqszyG5kD6mj-g17sYa2cJIYXrdSus5WQMQ9gZnBpoB_MD34>
X-ME-Proxy-Cause: dmFkZTESt4xrVf4fNQ+NzKwfZGCmBFrlLRZWF+jX8JvRcuA+iW0T2FQSJ53rsW2kVCVHb4
    Mc0Ewjf5XrUIBSRzZ9auFDECcQv7OsP6xoWhjWZT6TB0+QcsutEAKRe4kNkZ08lvF9peXt
    jUU/beKrbBGvU53pvV8MCySR9Tn2vd/A/L+tqLMfrMfcptkIaOtKPtHQnA9hBHZm0uquFh
    3ELqV+ppbI//yPqcoDQNyDvA5oy1sjOUpcsjtzk0TGBa+BchYzEzKNvJf4MOVqTXFd8aZg
    yXvZqL5/wej2wCq4lVsmgJ+3YvbPh/umrtmOsgrIT78iVepVGwcLBgXYOHch9l2C9JnRQD
    16YZ6G94fXrN/N73eClUCAgxHRjb3t035iZfX3KBm+5TOFTsoB27srPum4rM5eptzMHqTR
    cQ/PPo9FahCl/oJHbp6DvcJ3S/DwirCWvUUe3ax+D0xIpbQ+oIE+KpwyDD2VqFOvETM/SD
    ygRNZVoaX7oUgaXlHg3w4RYNg7KOEtBhrDn/NQCLcgNQ7GIEis5NybxYpd85cGGkAVQDWQ
    aI2HYCSOja3iTs1yE9oR+FetLUfDFtv2XXvoz9mApytjnimXF/kRZPHdxFuNTOCOJoSJ1K
    mCvyPdXTLIeir5p9XEa1IUe99gZpeRmTkqwzkdNtJtTj/xafBwvGI37ZEb8A
X-ME-Proxy: <xmx:fbHnai8BsaiK-sfQpl9AfP5jDUbGQDy2L-BqbpovSTco0tC4WZDt4g>
    <xmx:fbHnapcLhTbZPwmB1yevVuqTzmex5eDKhtiayrre5HBkX0xWtw-EEA>
    <xmx:fbHnapx595Kuj4dWEy7B12uoYtRqqbgoniJjT6VrbhlY4E8JHRK9-A>
    <xmx:fbHnamLEjtUTvZ0d6dr7rffeTI3GAw070hf5bh6ZkZiz3B0xwPUh7A>
    <xmx:fbHnaiSeF-yV2U0g4CT3tIDI9S0kZYhkfV46YrXnSvKR1ke08ksSOmww>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Sun,
 1 Nov 2026 16:39:06 -0500 (EST)
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
To: "Haruka Kuze" <harukak@zohomail.eu>
Cc: "Chuck Lever" <cel@kernel.org>, "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org
Subject: Re: [PATCH] nfsd: don't access freed memory when cannot grant a write
 delegation
In-reply-to: <20261101212135.1231222-1-harukak@zohomail.eu>
References: <20261101212135.1231222-1-harukak@zohomail.eu>
Date: Mon, 02 Nov 2026 08:39:03 +1100
Message-id: <179356914391.547122.3246865716471741922@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Mon, 02 Nov 2026, Haruka Kuze wrote:
> From: Haruka Kuze <harukak@zohomail.eu>
>=20
> nfs4_open_delegation() hashes the delegation before the call to
> nfsd4_add_rdaccess_to_wrdeleg() and nfs4_delegation_stat(), both of which
> can sleep, and it calls destroy_delegation() from the error path after
> dropping the caller's reference.
>=20
> Moreover, a DELEGRETURN from same client can unhash the delegation and
> drop the hash reference in this window, so nfs4_put_stid() frees it and
> destroy_delegation() then reads freed memory.
>=20
> Call destroy_delegation() before dropping the caller reference.
>=20
> Fixes: c5967721e106 ("NFSD: handle GETATTR conflict with write delegation")
> Cc: stable@vger.kernel.org
> Signed-off-by: Haruka Kuze <harukak@zohomail.eu>
> ---
>  fs/nfsd/nfs4state.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index 1de6c6d757c3..b13d05fe8993 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -7300,8 +7300,8 @@ nfs4_open_delegation(struct svc_rqst *rqstp, struct n=
fsd4_open *open,
>  		f =3D rcu_dereference_protected(dp->dl_stid.sc_file->fi_deleg_file, 1)->=
nf_file;
>  		if (!nfsd4_add_rdaccess_to_wrdeleg(rqstp, open, fh, stp) ||
>  				!nfs4_delegation_stat(dp, currentfh, &stat)) {
> -			nfs4_put_stid(&dp->dl_stid);
>  			destroy_delegation(dp);
> +			nfs4_put_stid(&dp->dl_stid);

So it seems strange to access the delegation after it has been
"destroyed", but I can see that this change does fix a real problem.

Maybe "destroy_delegation" isn't a good name for the function.
Maybe "deactivate_delegation" or something like that.

That is a separate problem those.  This patch is good.  The one other
use of destroy_delegation() is correctly followed by a nfs4_put_stid().

Reviewed-by: NeilBrown <neil@brown.name>

Thanks,
NeilBrown


>  			goto out_no_deleg;
>  		}
>  		open->op_delegate_type =3D deleg_ts ? OPEN_DELEGATE_WRITE_ATTRS_DELEG :
> --=20
> 2.55.0
>=20
>=20

