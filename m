Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1794867692;
	b=aoE6azPcP8R3APpBH+1rZWXCMu2YIPBo/rek9CYoSiI0/MsBZ9bpm9Wik+DmhDUBpVCs
	 DnXKDr9lZ6BxwaUyAbnaN7rfmuiWt8YDQdfb5BklDOiarxUErHyEe9NEkjoc62sqvTRza
	 Fp349RCIR+nxgWRbU9ekzjjfDbg1X87r8NzMGB0mEzD/WEphskn02JugFT15NaMqURCcx
	 c4hNmMOLo/pSRMQx0bSEOrZaPy/U54VRAC7kfCxMd8O4Udkk45O21HZ9oCctldozyTAWN
	 zalp948q5Ze+fSIZjigDGX0m4XOhTORgZ+c8jDMjyUH0nTvjFydw0SaHWc3rC/9f+EA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1794867692;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=u1O9fu5I1msXQiIm7JAbWQEFUOg7poqyrFThnd36lnI=;
	b=wZB+ea1H0TsPWZ4HA9yZ2EOjb2ithMEdEsfNgq34GyWxo0zoX+ncJa2iaFQItEWt1dEK
	 8SZ0ygUUUMAnnQyQgYWFy8jxPnPfxrARL91XKlTpsgzxdpyJrpFGDBWLMA8DE8vkVX0//
	 tchoGvW1n0zujYWRu+Vxwgw07yTeqv4OVwp289G7a+HFjbgxjFUOIveNmGCojeZ4fV6hl
	 Qx8AYcYVVFuQQ8AQg+UQhatBjfzR2vwI5heyUWAyq9zohu8zankulG8zqIXMg4f1Rxidb
	 c3ICvU3F4YZfAVVPB4cDauEV4BfsCtwmL63+5Ik+pv8a58tAQrAC+TX8f6GaTs2ei7g==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BCapUv0J;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 1D4E4606A32C
	for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2026 22:21:32 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=BCapUv0J
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BB1D61F000C4;
	Mon, 16 Nov 2026 22:21:31 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1794867691;
	bh=u1O9fu5I1msXQiIm7JAbWQEFUOg7poqyrFThnd36lnI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=BCapUv0JCZWRrtGtkD0Egaqw2Ia0g53IGlrLomNCVQJ0qkIMBiBaq4Ch+J83jV6QL
	 wWpbDKOf2ckcEo+UAp3s3k0HOaFjtlNqRulx42Ar/JyuIHZ+ehN0PlstO5CehB5FvP
	 vrQZZ1r+ZfqyE3TeyAaroizu7xicjx/vze/yVPY+GRT2O9taiqNYVp/45c+sq8BdHF
	 9cbROSf/S2SllzEuV9uL9bMDDyiFROdeKOKkYy99zhl9kZ0IHN2SmB5LXixU/J5Nl4
	 NgmxhDViWISkNO8gc8J0YVqRYpnJM9n5PxzOp23+fNZc7KQz3u/yWhLdC62LFDxX/F
	 EYvgLDYzpgL4Q==
Message-ID: <7e3535c7b018e205cb34d463890720916797e169.camel@kernel.org>
Subject: Re: [PATCH] nfsdctl: bound the rpcbind calls to one 1s attempt
From: Jeff Layton <jlayton@kernel.org>
To: Benjamin Coddington <ben.coddington@hammerspace.com>, Steve Dickson
	 <steved@redhat.com>
Cc: linux-nfs@vger.kernel.org
Date: Mon, 16 Nov 2026 14:21:31 -0800
In-Reply-To: <2221871feaf9ae6ec4970238fe11805abd2496c6.1794862543.git.bcodding@hammerspace.com>
References: 
	<2221871feaf9ae6ec4970238fe11805abd2496c6.1794862543.git.bcodding@hammerspace.com>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=mQINBE6V0TwBEADXhJg7s8wFDwBMEvn0qyhAnzFLTOCHooMZyx7XO7dAiIhDSi7G1NPxw
 n8jdFUQMCR/GlpozMFlSFiZXiObE7sef9rTtM68ukUyZM4pJ9l0KjQNgDJ6Fr342Htkjxu/kFV1Wv
 egyjnSsFt7EGoDjdKqr1TS9syJYFjagYtvWk/UfHlW09X+jOh4vYtfX7iYSx/NfqV3W1D7EDi0PqV
 T2h6v8i8YqsATFPwO4nuiTmL6I40ZofxVd+9wdRI4Db8yUNA4ZSP2nqLcLtFjClYRBoJvRWvsv4lm
 0OX6MYPtv76hka8lW4mnRmZqqx3UtfHX/hF/zH24Gj7A6sYKYLCU3YrI2Ogiu7/ksKcl7goQjpvtV
 YrOOI5VGLHge0awt7bhMCTM9KAfPc+xL/ZxAMVWd3NCk5SamL2cE99UWgtvNOIYU8m6EjTLhsj8sn
 VluJH0/RcxEeFbnSaswVChNSGa7mXJrTR22lRL6ZPjdMgS2Km90haWPRc8Wolcz07Y2se0xpGVLEQ
 cDEsvv5IMmeMe1/qLZ6NaVkNuL3WOXvxaVT9USW1+/SGipO2IpKJjeDZfehlB/kpfF24+RrK+seQf
 CBYyUE8QJpvTZyfUHNYldXlrjO6n5MdOempLqWpfOmcGkwnyNRBR46g/jf8KnPRwXs509yAqDB6sE
 LZH+yWr9LQZEwARAQABtCVKZWZmIExheXRvbiA8amxheXRvbkBwb29jaGllcmVkcy5uZXQ+iQI7BB
 MBAgAlAhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAUCTpXWPAIZAQAKCRAADmhBGVaCFc65D/4
 gBLNMHopQYgG/9RIM3kgFCCQV0pLv0hcg1cjr+bPI5f1PzJoOVi9s0wBDHwp8+vtHgYhM54yt43uI
 7Htij0RHFL5eFqoVT4TSfAg2qlvNemJEOY0e4daljjmZM7UtmpGs9NN0r9r50W82eb5Kw5bc/r0km
 R/arUS2st+ecRsCnwAOj6HiURwIgfDMHGPtSkoPpu3DDp/cjcYUg3HaOJuTjtGHFH963B+f+hyQ2B
 rQZBBE76ErgTDJ2Db9Ey0kw7VEZ4I2nnVUY9B5dE2pJFVO5HJBMp30fUGKvwaKqYCU2iAKxdmJXRI
 ONb7dSde8LqZahuunPDMZyMA5+mkQl7kpIpR6kVDIiqmxzRuPeiMP7O2FCUlS2DnJnRVrHmCljLkZ
 Wf7ZUA22wJpepBligemtSRSbqCyZ3B48zJ8g5B8xLEntPo/NknSJaYRvfEQqGxgk5kkNWMIMDkfQO
 lDSXZvoxqU9wFH/9jTv1/6p8dHeGM0BsbBLMqQaqnWiVt5mG92E1zkOW69LnoozE6Le+12DsNW7Rj
 iR5K+27MObjXEYIW7FIvNN/TQ6U1EOsdxwB8o//Yfc3p2QqPr5uS93SDDan5ehH59BnHpguTc27Xi
 QQZ9EGiieCUx6Zh2ze3X2UW9YNzE15uKwkkuEIj60NvQRmEDfweYfOfPVOueC+iFifbQgSmVmZiBM
 YXl0b24gPGpsYXl0b25AcmVkaGF0LmNvbT6JAjgEEwECACIFAk6V0q0CGwMGCwkIBwMCBhUIAgkKC
 wQWAgMBAh4BAheAAAoJEAAOaEEZVoIViKUQALpvsacTMWWOd7SlPFzIYy2/fjvKlfB/Xs4YdNcf9q
 LqF+lk2RBUHdR/dGwZpvw/OLmnZ8TryDo2zXVJNWEEUFNc7wQpl3i78r6UU/GUY/RQmOgPhs3epQC
 3PMJj4xFx+VuVcf/MXgDDdBUHaCTT793hyBeDbQuciARDJAW24Q1RCmjcwWIV/pgrlFa4lAXsmhoa
 c8UPc82Ijrs6ivlTweFf16VBc4nSLX5FB3ls7S5noRhm5/Zsd4PGPgIHgCZcPgkAnU1S/A/rSqf3F
 LpU+CbVBDvlVAnOq9gfNF+QiTlOHdZVIe4gEYAU3CUjbleywQqV02BKxPVM0C5/oVjMVx3bri75n1
 TkBYGmqAXy9usCkHIsG5CBHmphv9MHmqMZQVsxvCzfnI5IO1+7MoloeeW/lxuyd0pU88dZsV/riHw
 87i2GJUJtVlMl5IGBNFpqoNUoqmvRfEMeXhy/kUX4Xc03I1coZIgmwLmCSXwx9MaCPFzV/dOOrju2
 xjO+2sYyB5BNtxRqUEyXglpujFZqJxxau7E0eXoYgoY9gtFGsspzFkVNntamVXEWVVgzJJr/EWW0y
 +jNd54MfPRqH+eCGuqlnNLktSAVz1MvVRY1dxUltSlDZT7P2bUoMorIPu8p7ZCg9dyX1+9T6Muc5d
 Hxf/BBP/ir+3e8JTFQBFOiLNdFtB9KZWZmIExheXRvbiA8amxheXRvbkBzYW1iYS5vcmc+iQI4BBM
 BAgAiBQJOldK9AhsDBgsJCAcDAgYVCAIJCgsEFgIDAQIeAQIXgAAKCRAADmhBGVaCFWgWD/0ZRi4h
 N9FK2BdQs9RwNnFZUr7JidAWfCrs37XrA/56olQl3ojn0fQtrP4DbTmCuh0SfMijB24psy1GnkPep
 naQ6VRf7Dxg/Y8muZELSOtsv2CKt3/02J1BBitrkkqmHyni5fLLYYg6fub0T/8Kwo1qGPdu1hx2BQ
 RERYtQ/S5d/T0cACdlzi6w8rs5f09hU9Tu4qV1JLKmBTgUWKN969HPRkxiojLQziHVyM/weR5Reu6
 FZVNuVBGqBD+sfk/c98VJHjsQhYJijcsmgMb1NohAzwrBKcSGKOWJToGEO/1RkIN8tqGnYNp2G+aR
 685D0chgTl1WzPRM6mFG1+n2b2RR95DxumKVpwBwdLPoCkI24JkeDJ7lXSe3uFWISstFGt0HL8Eew
 P8RuGC8s5h7Ct91HMNQTbjgA+Vi1foWUVXpEintAKgoywaIDlJfTZIl6Ew8ETN/7DLy8bXYgq0Xzh
 aKg3CnOUuGQV5/nl4OAX/3jocT5Cz/OtAiNYj5mLPeL5z2ZszjoCAH6caqsF2oLyAnLqRgDgR+wTQ
 T6gMhr2IRsl+cp8gPHBwQ4uZMb+X00c/Amm9VfviT+BI7B66cnC7Zv6Gvmtu2rEjWDGWPqUgccB7h
 dMKnKDthkA227/82tYoFiFMb/NwtgGrn5n2vwJyKN6SEoygGrNt0SI84y6hEVbQlSmVmZiBMYXl0b
 24gPGpsYXl0b25AcHJpbWFyeWRhdGEuY29tPokCOQQTAQIAIwUCU4xmKQIbAwcLCQgHAwIBBhUIAg
 kKCwQWAgMBAh4BAheAAAoJEAAOaEEZVoIV1H0P/j4OUTwFd7BBbpoSp695qb6HqCzWMuExsp8nZjr
 uymMaeZbGr3OWMNEXRI1FWNHMtcMHWLP/RaDqCJil28proO+PQ/yPhsr2QqJcW4nr91tBrv/MqItu
 AXLYlsgXqp4BxLP67bzRJ1Bd2x0bWXurpEXY//VBOLnODqThGEcL7jouwjmnRh9FTKZfBDpFRaEfD
 FOXIfAkMKBa/c9TQwRpx2DPsl3eFWVCNuNGKeGsirLqCxUg5kWTxEorROppz9oU4HPicL6rRH22Ce
 6nOAON2vHvhkUuO3GbffhrcsPD4DaYup4ic+DxWm+DaSSRJ+e1yJvwi6NmQ9P9UAuLG93S2MdNNbo
 sZ9P8k2mTOVKMc+GooI9Ve/vH8unwitwo7ORMVXhJeU6Q0X7zf3SjwDq2lBhn1DSuTsn2DbsNTiDv
 qrAaCvbsTsw+SZRwF85eG67eAwouYk+dnKmp1q57LDKMyzysij2oDKbcBlwB/TeX16p8+LxECv51a
 sjS9TInnipssssUDrHIvoTTXWcz7Y5wIngxDFwT8rPY3EggzLGfK5Zx2Q5S/N0FfmADmKknG/D8qG
 IcJE574D956tiUDKN4I+/g125ORR1v7bP+OIaayAvq17RP+qcAqkxc0x8iCYVCYDouDyNvWPGRhbL
 UO7mlBpjW9jK9e2fvZY9iw3QzIPGKtClKZWZmIExheXRvbiA8amVmZi5sYXl0b25AcHJpbWFyeWRh
 dGEuY29tPokCOQQTAQIAIwUCU4xmUAIbAwcLCQgHAwIBBhUIAgkKCwQWAgMBAh4BAheAAAoJEAAOa
 EEZVoIVzJoQALFCS6n/FHQS+hIzHIb56JbokhK0AFqoLVzLKzrnaeXhE5isWcVg0eoV2oTScIwUSU
 apy94if69tnUo4Q7YNt8/6yFM6hwZAxFjOXR0ciGE3Q+Z1zi49Ox51yjGMQGxlakV9ep4sV/d5a50
 M+LFTmYSAFp6HY23JN9PkjVJC4PUv5DYRbOZ6Y1+TfXKBAewMVqtwT1Y+LPlfmI8dbbbuUX/kKZ5d
 dhV2736fgyfpslvJKYl0YifUOVy4D1G/oSycyHkJG78OvX4JKcf2kKzVvg7/Rnv+AueCfFQ6nGwPn
 0P91I7TEOC4XfZ6a1K3uTp4fPPs1Wn75X7K8lzJP/p8lme40uqwAyBjk+IA5VGd+CVRiyJTpGZwA0
 jwSYLyXboX+Dqm9pSYzmC9+/AE7lIgpWj+3iNisp1SWtHc4pdtQ5EU2SEz8yKvDbD0lNDbv4ljI7e
 flPsvN6vOrxz24mCliEco5DwhpaaSnzWnbAPXhQDWb/lUgs/JNk8dtwmvWnqCwRqElMLVisAbJmC0
 BhZ/Ab4sph3EaiZfdXKhiQqSGdK4La3OTJOJYZphPdGgnkvDV9Pl1QZ0ijXQrVIy3zd6VCNaKYq7B
 AKidn5g/2Q8oio9Tf4XfdZ9dtwcB+bwDJFgvvDYaZ5bI3ln4V3EyW5i2NfXazz/GA/I/ZtbsigCFc
 8ftCBKZWZmIExheXRvbiA8amxheXRvbkBrZXJuZWwub3JnPokCOAQTAQIAIgUCWe8u6AIbAwYLCQg
 HAwIGFQgCCQoLBBYCAwECHgECF4AACgkQAA5oQRlWghUuCg/+Lb/xGxZD2Q1oJVAE37uW308UpVSD
 2tAMJUvFTdDbfe3zKlPDTuVsyNsALBGclPLagJ5ZTP+Vp2irAN9uwBuacBOTtmOdz4ZN2tdvNgozz
 uxp4CHBDVzAslUi2idy+xpsp47DWPxYFIRP3M8QG/aNW052LaPc0cedYxp8+9eiVUNpxF4SiU4i9J
 DfX/sn9XcfoVZIxMpCRE750zvJvcCUz9HojsrMQ1NFc7MFT1z3MOW2/RlzPcog7xvR5ENPH19ojRD
 CHqumUHRry+RF0lH00clzX/W8OrQJZtoBPXv9ahka/Vp7kEulcBJr1cH5Wz/WprhsIM7U9pse1f1g
 Yy9YbXtWctUz8uvDR7shsQxAhX3qO7DilMtuGo1v97I/Kx4gXQ52syh/w6EBny71CZrOgD6kJwPVV
 AaM1LRC28muq91WCFhs/nzHozpbzcheyGtMUI2Ao4K6mnY+3zIuXPygZMFr9KXE6fF7HzKxKuZMJO
 aEZCiDOq0anx6FmOzs5E6Jqdpo/mtI8beK+BE7Va6ni7YrQlnT0i3vaTVMTiCThbqsB20VrbMjlhp
 f8lfK1XVNbRq/R7GZ9zHESlsa35ha60yd/j3pu5hT2xyy8krV8vGhHvnJ1XRMJBAB/UYb6FyC7S+m
 QZIQXVeAA+smfTT0tDrisj1U5x6ZB9b3nBg65kc=
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
User-Agent: Evolution 3.60.2 (3.60.2-3.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Mon, 2026-11-16 at 15:58 -0500, Benjamin Coddington wrote:
> libtirpc's rpcb_set() and rpcb_unset() create a client for every call
> and wait 60s for each reply. A local rpcbind that accepts the connection
> and never answers stalls nfsdctl for a minute per call: five UNSETs when
> the threads stop, and five UNSETs plus one SET per listener netid and
> program when they start. libtirpc's setter for that timeout is private.
>=20
> Make the SET and UNSET calls on a client of nfsdctl's own, built with
> nfs_get_rpcclient(): AF_LOCAL on _PATH_RPCBINDSOCK first, then TCP to
> 127.0.0.1 port 111, as libtirpc's local_rpcb() orders them. Each pass
> uses one client, and each call is one attempt of 1s, matching
> 17ceb2fecc7c ("SUNRPC: bound the local rpcbind client timeout to 1s"):
> "The local rpcbind is on loopback or on an AF_LOCAL socket, and it
> answers in microseconds."
>=20
> A call that gets no answer ends the pass with one warning, as
> ba8c47f04942 and df1ff8e4e275 do for the kernel's svc_register() and
> svc_unregister() sweep. A registration pass whose opening UNSET sweep
> gets no answer makes no SET. A reply of FALSE is logged and the pass
> continues, as before.
>=20
> nfs_svc_unregister() is unchanged, and a build without TI-RPC keeps
> using it.
>=20
> With the local rpcbind SIGSTOPped, on a kernel that leaves the nfsd
> registration to nfsdctl, "nfsdctl threads 0" returned after 3.4s, where
> it took 302.7s before. lockd's own registration in the kernel accounts
> for 2s of that. "nfsdctl autostart" now ends its registration pass after
> 1s. The THREADS_SET that follows still fails with EIO, because lockd
> cannot register.
>=20
> Signed-off-by: Benjamin Coddington <bcodding@hammerspace.com>
> ---
>  utils/nfsdctl/rpcbind.c | 199 +++++++++++++++++++++++++++++++++++-----
>  1 file changed, 178 insertions(+), 21 deletions(-)
>=20
> diff --git a/utils/nfsdctl/rpcbind.c b/utils/nfsdctl/rpcbind.c
> index 23034097b485..a705c54d8f40 100644
> --- a/utils/nfsdctl/rpcbind.c
> +++ b/utils/nfsdctl/rpcbind.c
> @@ -15,17 +15,23 @@
> =20
>  #include <errno.h>
>  #include <netinet/in.h>
> +#include <stdio.h>
> +#include <stdlib.h>
>  #include <string.h>
>  #include <sys/socket.h>
> +#include <sys/un.h>
> +#include <unistd.h>
> =20
>  #include <rpc/rpc.h>
> =20
>  #ifdef HAVE_LIBTIRPC
>  #include <rpc/rpcb_clnt.h>
> +#include <rpc/rpcb_prot.h>
>  #include <netconfig.h>
>  #endif	/* HAVE_LIBTIRPC */
> =20
>  #include "nfslib.h"
> +#include "nfsrpc.h"
>  #include "rpcmisc.h"
>  #include "sockaddr.h"
>  #include "xlog.h"
> @@ -43,7 +49,7 @@
> =20
>  /*
>   * Programs to clear at shutdown. There is no reply to read at that poin=
t,
> - * so clear a superset. rpcb_unset() of an absent entry does nothing.
> + * so clear a superset. An UNSET of an absent entry does nothing.
>   */
>  static const struct {
>  	rpcprog_t	program;
> @@ -56,24 +62,135 @@ static const struct {
>  	{ NFS_ACL_PROGRAM,	3 },
>  };
> =20
> +#ifdef HAVE_LIBTIRPC
> +
> +/*
> + * libtirpc's rpcb_set() and rpcb_unset() wait 60s for each call, and it=
s
> + * setter for that timeout is not exported. The local rpcbind answers in
> + * microseconds, so make the calls on a client of our own with one attem=
pt
> + * of 1s, as the kernel's own rpcbind client does.
> + */
> +static const struct timeval nfsd_rpcb_timeout =3D { 1, 0 };
> +
> +enum nfsd_rpcb_status {
> +	NFSD_RPCB_OK,
> +	NFSD_RPCB_DECLINED,
> +	NFSD_RPCB_NO_ANSWER,
> +};
> +
> +/* AF_LOCAL first, then loopback TCP, as libtirpc's local_rpcb() does. *=
/
> +static CLIENT *nfsd_rpcb_client(void)
> +{
> +	const struct sockaddr_un sun =3D {
> +		.sun_family	=3D AF_LOCAL,
> +		.sun_path	=3D _PATH_RPCBINDSOCK,
> +	};
> +	const struct sockaddr_in sin =3D {
> +		.sin_family	=3D AF_INET,
> +		.sin_port	=3D htons(111),
> +		.sin_addr.s_addr =3D htonl(INADDR_LOOPBACK),
> +	};
> +	struct timeval timeout =3D nfsd_rpcb_timeout;
> +	CLIENT *clnt;
> +
> +	clnt =3D nfs_get_rpcclient((const struct sockaddr *)&sun, SUN_LEN(&sun)=
,
> +				 0, RPCBPROG, RPCBVERS, &timeout);
> +	if (clnt) {
> +		xlog(D_GENERAL, "rpcbind: using %s", _PATH_RPCBINDSOCK);
> +		return clnt;
> +	}
> +
> +	timeout =3D nfsd_rpcb_timeout;
> +	clnt =3D nfs_get_rpcclient((const struct sockaddr *)&sin, sizeof(sin),
> +				 IPPROTO_TCP, RPCBPROG, RPCBVERS, &timeout);
> +	if (clnt)
> +		xlog(D_GENERAL, "rpcbind: using 127.0.0.1 port 111 over TCP");
> +	return clnt;
> +}
> +
> +/*
> + * A transport error means rpcbind accepted the connection and did not
> + * answer. Every later call on this pass would wait the same, so the cal=
ler
> + * stops.
> + */
> +static enum nfsd_rpcb_status nfsd_rpcb_call(CLIENT *clnt, rpcproc_t proc=
,
> +					    struct rpcb *parms)
> +{
> +	enum clnt_stat stat;
> +	bool_t rslt =3D FALSE;
> +
> +	stat =3D CLNT_CALL(clnt, proc, (xdrproc_t)xdr_rpcb, (char *)parms,
> +			 (xdrproc_t)xdr_bool, (char *)&rslt, nfsd_rpcb_timeout);
> +	switch (stat) {
> +	case RPC_SUCCESS:
> +		return rslt ? NFSD_RPCB_OK : NFSD_RPCB_DECLINED;
> +	case RPC_TIMEDOUT:
> +	case RPC_CANTRECV:
> +	case RPC_CANTSEND:
> +		xlog(L_WARNING,
> +		     "rpcbind did not answer %s of program %u version %u: %s. Skipping=
 the remaining rpcbind calls.",
> +		     proc =3D=3D RPCBPROC_SET ? "SET" : "UNSET",
> +		     parms->r_prog, parms->r_vers, clnt_sperrno(stat));
> +		return NFSD_RPCB_NO_ANSWER;
> +	default:
> +		xlog(D_GENERAL, "rpcbind call failed: %s", clnt_sperrno(stat));
> +		return NFSD_RPCB_DECLINED;
> +	}
> +}
> +
> +/*
> + * An empty netid and address unset every netid of [program, version], a=
s
> + * rpcb_unset() with no netconfig does.
> + */
> +static enum nfsd_rpcb_status nfsd_rpcb_unset_sweep(CLIENT *clnt)
> +{
> +	char empty[] =3D "";
> +	char owner[16];
> +	struct rpcb parms =3D {
> +		.r_netid	=3D empty,
> +		.r_addr		=3D empty,
> +		.r_owner	=3D owner,
> +	};
> +	enum nfsd_rpcb_status status;
> +	unsigned int i;
> +
> +	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
> +
> +	for (i =3D 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++) {
> +		parms.r_prog =3D nfsd_rpcb_all[i].program;
> +		parms.r_vers =3D nfsd_rpcb_all[i].version;
> +
> +		status =3D nfsd_rpcb_call(clnt, RPCBPROC_UNSET, &parms);
> +		if (status =3D=3D NFSD_RPCB_NO_ANSWER)
> +			return status;
> +		if (status =3D=3D NFSD_RPCB_DECLINED)
> +			xlog(D_GENERAL,
> +			     "Failed to unregister program %u, version %u",
> +			     parms.r_prog, parms.r_vers);
> +	}
> +	return NFSD_RPCB_OK;
> +}
> +
>  /**
>   * nfsd_rpcb_unset_all - remove every nfsd entry from the local rpcbind
>   *
> - * rpcb_unset() matches [program, version, netid] and takes no address, =
so
> - * one call clears every netid. This mirrors the svc_unregister() sweep =
that
> - * svc_rpcb_setup() used to run, which an sv_no_rpcbind serv no longer d=
oes.
> + * This mirrors the svc_unregister() sweep that svc_rpcb_setup() used to
> + * run, which an sv_no_rpcbind serv no longer does.
>   */
>  void nfsd_rpcb_unset_all(void)
>  {
> -	unsigned int i;
> +	CLIENT *clnt;
> =20
> -	for (i =3D 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
> -		nfs_svc_unregister(nfsd_rpcb_all[i].program,
> -				   nfsd_rpcb_all[i].version);
> +	clnt =3D nfsd_rpcb_client();
> +	if (!clnt) {
> +		xlog(D_GENERAL, "cannot reach rpcbind: %s",
> +		     clnt_sperrno(rpc_createerr.cf_stat));
> +		return;
> +	}
> +	nfsd_rpcb_unset_sweep(clnt);
> +	CLNT_DESTROY(clnt);
>  }
> =20
> -#ifdef HAVE_LIBTIRPC
> -
>  /*
>   * Map a transport name and address family to an rpcbind netid.
>   *
> @@ -125,32 +242,47 @@ static bool nfsd_rpcb_wildcard(const struct sockadd=
r_storage *ss,
>  	return false;
>  }
> =20
> -static bool nfsd_rpcb_set_one(rpcprog_t program, rpcvers_t version,
> -			      const char *netid,
> -			      const struct sockaddr_storage *ss)
> +static enum nfsd_rpcb_status nfsd_rpcb_set_one(CLIENT *clnt,
> +					       rpcprog_t program,
> +					       rpcvers_t version,
> +					       const char *netid,
> +					       const struct sockaddr_storage *ss)
>  {
> +	enum nfsd_rpcb_status status;
>  	struct sockaddr_storage wild;
>  	struct netconfig *nconf;
> +	struct rpcb parms;
>  	struct netbuf nb;
> +	char owner[16];
>  	socklen_t len;
> -	bool ok;
> =20
>  	if (!nfsd_rpcb_wildcard(ss, &wild, &len))
> -		return false;
> +		return NFSD_RPCB_DECLINED;
> =20
>  	nconf =3D getnetconfigent(netid);
>  	if (!nconf) {
>  		xlog(L_WARNING, "no netconfig entry for %s", netid);
> -		return false;
> +		return NFSD_RPCB_DECLINED;
>  	}
> =20
>  	nb.buf =3D &wild;
>  	nb.len =3D len;
>  	nb.maxlen =3D len;
> =20
> -	ok =3D (rpcb_set(program, version, nconf, &nb) =3D=3D TRUE);
> +	parms.r_addr =3D taddr2uaddr(nconf, &nb);
>  	freenetconfigent(nconf);
> -	return ok;
> +	if (!parms.r_addr)
> +		return NFSD_RPCB_DECLINED;
> +
> +	snprintf(owner, sizeof(owner), "%d", (int)geteuid());
> +	parms.r_prog =3D program;
> +	parms.r_vers =3D version;
> +	parms.r_netid =3D (char *)netid;
> +	parms.r_owner =3D owner;
> +
> +	status =3D nfsd_rpcb_call(clnt, RPCBPROC_SET, &parms);
> +	free(parms.r_addr);
> +	return status;
>  }
> =20
>  /**
> @@ -167,14 +299,25 @@ static bool nfsd_rpcb_set_one(rpcprog_t program, rp=
cvers_t version,
>  void nfsd_rpcb_register(const struct server_socket *listeners, int nlist=
eners,
>  			const struct nfsd_rpcb_prog *progs, int nprogs)
>  {
> +	enum nfsd_rpcb_status status;
>  	unsigned int failed =3D 0;
> +	CLIENT *clnt;
>  	int i, j, k;
> =20
> +	clnt =3D nfsd_rpcb_client();
> +	if (!clnt) {
> +		xlog(L_WARNING,
> +		     "cannot reach rpcbind: %s. Clients that look up the server in rpc=
bind cannot find it.",
> +		     clnt_sperrno(rpc_createerr.cf_stat));
> +		return;
> +	}
> +
>  	/*
>  	 * Clear first. rpcbind cannot express "drop one of two TCP ports",
>  	 * and the kernel no longer sweeps stale entries at serv creation.
>  	 */
> -	nfsd_rpcb_unset_all();
> +	if (nfsd_rpcb_unset_sweep(clnt) =3D=3D NFSD_RPCB_NO_ANSWER)
> +		goto out;
> =20
>  	for (i =3D 0; i < nlisteners; i++) {
>  		const struct server_socket *l =3D &listeners[i];
> @@ -215,9 +358,12 @@ void nfsd_rpcb_register(const struct server_socket *=
listeners, int nlisteners,
>  			    !strncmp(netid, "udp", 3))
>  				continue;
> =20
> -			if (nfsd_rpcb_set_one(p->program, p->version, netid,
> -					      &l->ss))
> +			status =3D nfsd_rpcb_set_one(clnt, p->program,
> +						   p->version, netid, &l->ss);
> +			if (status =3D=3D NFSD_RPCB_OK)
>  				continue;
> +			if (status =3D=3D NFSD_RPCB_NO_ANSWER)
> +				goto out;
> =20
>  			xlog(L_WARNING,
>  			     "cannot register program %u version %u on %s port %u",
> @@ -230,10 +376,21 @@ void nfsd_rpcb_register(const struct server_socket =
*listeners, int nlisteners,
>  	if (failed)
>  		xlog(L_WARNING,
>  		     "some rpcbind registrations failed. Clients that look up the serv=
er in rpcbind cannot find it.");
> +out:
> +	CLNT_DESTROY(clnt);
>  }
> =20
>  #else	/* !HAVE_LIBTIRPC */
> =20
> +void nfsd_rpcb_unset_all(void)
> +{
> +	unsigned int i;
> +
> +	for (i =3D 0; i < ARRAY_SIZE(nfsd_rpcb_all); i++)
> +		nfs_svc_unregister(nfsd_rpcb_all[i].program,
> +				   nfsd_rpcb_all[i].version);
> +}
> +
>  /*
>   * rpcb_set() and the netconfig database are TI-RPC only, so a build
>   * without it cannot own the registration. userspace_rpcbind_supported()


Reviewed-by: Jeff Layton <jlayton@kernel.org>
