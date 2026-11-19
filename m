Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795124001;
	b=kyBKVSjaW0FpIvQHktjETnOKduGjLzQpnk9clVYW0Zk5lJMFsZcKQeq57gMGvZijfkm8
	 HEQ4t6TRSdsrduY+8Sw+CgzI2XHjw1UFZ8M98PStPTfsjd5CIO5ZGirJO5YXD7fX/wTPE
	 ktRbd0ddPUisiQkEVQFU2xPQlwxPmhhDyLm2nhk+Xhx3r9oavtCVXv/3+aye53gRjvqbv
	 qEh5kDfutni2HTtMuMYu0PcFOhv0N5IDCz5n3v9/WbpS1Vkvlw5e96ysJJ0d1cOCylovc
	 ZlH1QzRrz8qHKEUgrMvTYcvQYenLvs6CeCBtEQznT4V3d0U0kmtXI7a1KOFYdlGmfUg==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795124001;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=GntRI6tOBrAhacb25HAQl+V7JQYtYMfqRJJMvNkCZ00=;
	b=hEbPi9uD00JIriPSRH4yliCtf3ExTDB94G4yVFa6fJREQVcf4C40P2CRslqwycv8FZuU
	 lR8smvnEDA6i3b3mXLnISUOok7Tm8SFhzWd/PFLcBI8Ecp/Xg20NKE+A7kyDTPN4Sj2Jt
	 1/0kjcrPyL50WgGyliECNc8QNJCCL+cVo/0fwCx3XXMWoUhSYG9d8A9iw9tLbf0zFt5Dx
	 opNE0ejxV/VQjF1JUttxiDU6wY8yOQrtDykymbzYZNjVcMV3g9/f6ZLaBwT55l2B9pTeN
	 O9FcNSlu0v2xqQS9E+EyleBAOCyKMHe4xFYhZL2YvfxRKzcYW3Ikgy4Dtzt/Y1mOdNA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hORGslzE;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 61131606A324;
	Thu, 19 Nov 2026 21:33:21 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=hORGslzE
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 99A711F000C4;
	Thu, 19 Nov 2026 21:33:20 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795124001;
	bh=GntRI6tOBrAhacb25HAQl+V7JQYtYMfqRJJMvNkCZ00=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=hORGslzEfPnglEGYTeGwNMSOmJXFI4vnJPKl7LTQIu6U3OAB+1BJ8zyz54/2JFWHW
	 8IzcYvIIspyPXWuuG+FVSxX2IKDKG3jeviaS8r1G59Tdpf2dwEh7dHkp4C0VTKzPSp
	 xU39D1sTcGVRDUoasAYN2hvatrOuWn96/gCU/42hT1Buhv7/slwmOxJnShLEKvlM7T
	 CR50NyB7flx0PVno5QiHLbPOSICq+5CqndPCX9A4MQ9hjHCY85q1TH1iMymhLUIfEu
	 ic2rwg1eefJHL/yIOoMC3TgbyajVZsyb9WmJpYFEP68IBaq9Xax9q173rS+QAZjUNw
	 AmTrz8Xdrv+Rg==
Message-ID: <b4c8f20fd76086323f20ce2095d6aa116bbf1d3e.camel@kernel.org>
Subject: Re: [PATCH 2/2] nfsd: enforce cross-export and may_linkat() checks
 in nfsd_link()
From: Jeff Layton <jlayton@kernel.org>
To: Dominik Maier <dmnk@google.com>, Chuck Lever <cel@kernel.org>, Christian
 Brauner <brauner@kernel.org>, Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Jan Kara <jack@suse.cz>, NeilBrown <neil@brown.name>, Olga Kornievskaia	
 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey
 <tom@talpey.com>, 	linux-nfs@vger.kernel.org,
 linux-fsdevel@vger.kernel.org, dmnk+artist@google.com
Date: Thu, 19 Nov 2026 13:33:20 -0800
In-Reply-To: <20261119192311.2684978-2-dmnk@google.com>
References: <20261119192311.2684978-1-dmnk@google.com>
	 <20261119192311.2684978-2-dmnk@google.com>
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

On Thu, 2026-11-19 at 20:23 +0100, Dominik Maier wrote:
> nfsd_link() verifies NFSD_MAY_CREATE on the destination directory
> filehandle (ffhp) and NFSD_MAY_NOP on the source filehandle (tfhp)
> before calling vfs_link() directly, omitting two checks enforced
> elsewhere:
>=20
> 1. Unlike nfsd_rename(), nfsd_link() does not verify that the source and
>    destination filehandles belong to the same export path. In addition,
>    because tfhp is verified second with NFSD_MAY_NOP, if two distinct
>    svc_export entries share ex_path with different read-only or UID
>    squashing options, fh_verify(tfhp, NFSD_MAY_NOP) skips exp_rdonly()
>    and leaves current_cred() set to tfhp->fh_export's credentials.
> 2. Unlike filename_linkat(), nfsd_link() does not call may_linkat()
>    before vfs_link(), allowing remote NFSv3 and NFSv4 clients to bypass
>    fs.protected_hardlinks restrictions and hardlink non-owned restricted
>    files.
>=20
> Require ffhp->fh_export->ex_path and tfhp->fh_export->ex_path to match
> (returning nfserr_xdev on mismatch, matching nfsd_rename()). When
> ffhp->fh_export and tfhp->fh_export differ on the same ex_path, reject
> read-only source exports via exp_rdonly() with nfserr_rofs and restore
> ffhp->fh_export credentials via nfsd_setuser(). Finally, check
> may_linkat() before proceeding with the link, mapping -EOVERFLOW on
> unmapped inode IDs to nfserr_perm to match vfs_link().
>=20
> This issue was discovered by an AI-assisted code review tool (ARTIST)
> and validated in QEMU against an unmodified v7.4-rc3 kernel without
> kernel modifications or error injection. A standalone reproducer is
> available on request. The fix was build-tested with KCFLAGS=3D-Werror and
> checked with checkpatch.pl --strict.
>=20
> Fixes: 800179c9b8a1 ("fs: add link restrictions")
> Cc: stable@vger.kernel.org
> Signed-off-by: Dominik Maier <dmnk@google.com>
> ---
>  fs/nfsd/vfs.c | 34 +++++++++++++++++++++++++++++-----
>  1 file changed, 29 insertions(+), 5 deletions(-)
>=20
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 56c49b5..0c4e052 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -45,6 +45,7 @@
>  #include "netns.h"
>  #include "stats.h"
>  #include "vfs.h"
> +#include "auth.h"
>  #include "filecache.h"
>  #include "trace.h"
> =20
> @@ -1993,6 +1994,11 @@ nfsd_symlink(struct svc_rqst *rqstp, struct svc_fh=
 *fhp,
>  	return err;
>  }
> =20
> +static int exp_rdonly(struct svc_cred *cred, struct svc_export *exp)
> +{
> +	return nfsexp_flags(cred, exp) & NFSEXP_READONLY;
> +}
> +
>  /**
>   * nfsd_link - create a link
>   * @rqstp: RPC transaction context
> @@ -2011,6 +2017,7 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *ff=
hp,
>  {
>  	struct dentry	*ddir, *dnew, *dold;
>  	struct inode	*dirp;
> +	struct path	old_path;
>  	int		type;
>  	__be32		err;
>  	int		host_err;
> @@ -2032,6 +2039,28 @@ nfsd_link(struct svc_rqst *rqstp, struct svc_fh *f=
fhp,
>  	err =3D nfserr_exist;
>  	if (name_is_dot_dotdot(name, len))
>  		goto out;
> +	err =3D nfserr_xdev;
> +	if (!path_equal(&ffhp->fh_export->ex_path, &tfhp->fh_export->ex_path))
> +		goto out;
> +	if (ffhp->fh_export !=3D tfhp->fh_export) {
> +		if (exp_rdonly(&rqstp->rq_cred, tfhp->fh_export)) {
> +			err =3D nfserr_rofs;
> +			goto out;
> +		}
> +		host_err =3D nfsd_setuser(&rqstp->rq_cred, ffhp->fh_export);
> +		if (host_err) {
> +			err =3D nfserrno(host_err);
> +			goto out;
> +		}
> +	}
> +
> +	old_path.mnt =3D tfhp->fh_export->ex_path.mnt;
> +	old_path.dentry =3D tfhp->fh_dentry;
> +	host_err =3D may_linkat(&nop_mnt_idmap, &old_path);
> +	if (host_err) {
> +		err =3D host_err =3D=3D -EOVERFLOW ? nfserr_perm : nfserrno(host_err);
> +		goto out;
> +	}
> =20
>  	err =3D nfs_ok;
>  	type =3D d_inode(tfhp->fh_dentry)->i_mode & S_IFMT;
> @@ -2592,11 +2621,6 @@ nfsd_statfs(struct svc_rqst *rqstp, struct svc_fh =
*fhp, struct kstatfs *stat, in
>  	return err;
>  }
> =20
> -static int exp_rdonly(struct svc_cred *cred, struct svc_export *exp)
> -{
> -	return nfsexp_flags(cred, exp) & NFSEXP_READONLY;
> -}
> -
>  #ifdef CONFIG_NFSD_V4
>  /*
>   * Helper function to translate error numbers. In the case of xattr oper=
ations,

Looks sane, but sashiko has a comment on this about the credentials
being used:

https://sashiko.dev/#/patchset/20261119192311.2684978-1-dmnk%40google.com

Sounds like this may require 2 may_linkat() checks?
--=20
Jeff Layton <jlayton@kernel.org>
