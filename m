Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1795471810;
	b=MiWiyjoEZJCJDGxmL8Vz53Jgh1/7HXGrgQQ9Ot8QhrFRz6Aa0Xv6wiNGX66TSdl+nBUi
	 szRkSvaQxttSApy4nBOXbD0iibXejmJnv91QHkan6feHDq72dfx8XCkpu+5pYFy5K8nTH
	 mXd3+WEqCddtQJWHT23IO4tzqnUeC8KE2E2pPrRA5Y0RdqNfmRbkCBmPts0KlXKKfkMCR
	 sRe8B4i2JjKjzp0sHUe/jYiK3UHIwxxNYywiyzwUxyVedyQxaNCOvpG3YL13oXNHkx5V/
	 LFpTPF3lZM4vUlrf4YvV0U4+LEHDKvrW8zhS938Uopm67QgBo+ovASkmEqC+SkJ/sUw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1795471810;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=CttgDfsmkvvc0a4OqqBKPjtvXFCepgu4FrPPyXiFRRY=;
	b=xgaclPNZTCa5SnInbjuLwMgpYvzuRiMEKWbLYGm/AXXnWlhfGlB7fgcbrDsWAvZ2+4Vk
	 kFTSmc3b668yrWch39wKUjQ1avde1AZqZf0G2P8m7yktvVkHUptM6nUfyxQBiIXSwyqZ6
	 WpbovtdE3IgHZKYS8eEYZiPWSQn1km9Fdw9JuG2heNcuej1wclRUNgH8zfXAbIIYc/tBn
	 a4l5RjWq7uHp0EqIK825QO8+MF+pcOPRxXCiltU8WJENoskfZM2RKIr2C/U4RMxFb1YqO
	 RYZOHsAGl2hyqoT9xgtgwWMXMHJeJ8ONhYxMCI/6xCfuSdLP7x8Yj0iFF5fTO1xrwHQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Lv5nxQ6X;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1C92606A31E;
	Mon, 23 Nov 2026 22:10:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=Lv5nxQ6X
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 55D831F000C0;
	Mon, 23 Nov 2026 22:10:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1795471809;
	bh=CttgDfsmkvvc0a4OqqBKPjtvXFCepgu4FrPPyXiFRRY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=Lv5nxQ6XkBmNWnk15ocXN9GVhgIPakgc9jKdmNXKOmYOQ4hiO2N5tSnBK1MjTIrWD
	 5rr6ZkWl1HmRxTGo4mtogJGLypnqRf4gMCu+42qdarmKEuQ4Q/6T7rnIjTNWG4noeu
	 3n8WY8lpo5paN/vXykkwCiE9F0l/Rwg7ZZ9gDAONEqRqTTxp2UDDs+JJVEWn9NktSy
	 2NjUPHJ/u/Qi+/B3Q9Jy2xFgC71TjVewM+kcHeVgZnZ1D+WcYbUynAV1yqJoCy1R/3
	 BAQSbHoST2bqUjsHPGFVE3o7Kv/IcI1z1ybtdzPJaMqPFHX+LZTnfXdI9HvQ2D+cxo
	 umDc0++9buuBQ==
Message-ID: <1b1da77d55371ccaa07698bc523504e3fc53fca4.camel@kernel.org>
Subject: Re: [PATCH RFC] NFS: don't wait for writeback on close() with a
 write delegation
From: Jeff Layton <jlayton@kernel.org>
To: Trond Myklebust <trondmy@kernel.org>, Anna Schumaker <anna@kernel.org>
Cc: Chuck Lever <cel@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Mon, 23 Nov 2026 17:10:03 -0500
In-Reply-To: <21053572ab2e8743fe4ba47464d21e719ec445b1.camel@kernel.org>
References: <20261116-nfs-space-limit-v1-1-fcc1335169a7@kernel.org>
				 <c9d7a4bf79247d7cfcd23460d351412c343d546c.camel@kernel.org>
			 <7c31f905f202512fb0ef1cb63f0714fffa24640f.camel@kernel.org>
		 <185ae981c8250143bc519151d3d4f937a76b9a92.camel@kernel.org>
	 <21053572ab2e8743fe4ba47464d21e719ec445b1.camel@kernel.org>
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
User-Agent: Evolution 3.62.1 (3.62.1-1.fc45) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Mon, 2026-11-23 at 16:23 -0500, Trond Myklebust wrote:
> On Mon, 2026-11-23 at 16:18 -0500, Trond Myklebust wrote:
> > On Mon, 2026-11-23 at 14:43 -0500, Jeff Layton wrote:
> > > On Fri, 2026-11-20 at 10:04 -0800, Trond Myklebust wrote:
> > > > On Mon, 2026-11-16 at 15:55 -0500, Jeff Layton wrote:
> > > > > Commit 5445b1fbd123 ("NFSv4: Respect the server imposed limit
> > > > > on
> > > > > how
> > > > > many changes we may cache") made close() write back, COMMIT and
> > > > > wait
> > > > > whenever outstanding requests exceed the write delegation's
> > > > > space_limit. Servers that send a limit of 0, knfsd included,
> > > > > therefore
> > > > > get no close() benefit from write delegations, which knfsd now
> > > > > grants
> > > > > even on write-only opens.
> > > > >=20
> > > > > That flush buys nothing:
> > > > >=20
> > > > > - CTO: no other client can open the file until the delegation
> > > > > is
> > > > > =C2=A0 recalled, and the recall writes back our dirty data first.
> > > > > - Error reporting is all that's left, and it's pointless.
> > > > > close()
> > > > > is
> > > > > =C2=A0 not required to flush, and most filesystems don't, so
> > > > > checking
> > > > > for
> > > > > =C2=A0 writeback errors there is unreliable at best: the failing
> > > > > writeback
> > > > > =C2=A0 may not have happened yet. Applications that care must
> > > > > fsync(),
> > > > > =C2=A0 which this doesn't change; errors are still recorded in th=
e
> > > > > mapping
> > > > > =C2=A0 and reported there.
> > > > > - RFC 8881 says only that the client "should" abide by
> > > > > space_limit;
> > > > > =C2=A0 exceeding it leaves the server's behavior undefined, and
> > > > > knfsd
> > > > > just
> > > > > =C2=A0 returns NFS4ERR_NOSPC/NFS4ERR_DQUOT on WRITE or COMMIT.
> > > > >=20
> > > > > Go back to just starting writeback on close() whenever we hold
> > > > > a
> > > > > write
> > > > > delegation. In testing against a knfsd patched to send a
> > > > > nonzero
> > > > > space_limit, single-threaded create/write/close went from ~92
> > > > > to
> > > > > ~1,500 files/s.
> > > > >=20
> > > > > User-visible change: ENOSPC/EDQUOT for data written just before
> > > > > close()
> > > > > now shows up only via fsync(), not close().
> > > > >=20
> > > > > For now, the pagemod_limit is still decoded but unused.
> > > > >=20
> > > > > Signed-off-by: Jeff Layton <jlayton@kernel.org>
> > > > > ---
> > > > > I started looking at wiring up space_limit for nfsd's write
> > > > > delegations,
> > > > > but afrer looking at how the client uses it, I think we're best
> > > > > off
> > > > > just
> > > > > not bothering to respect it at all. Thoughts?
> > > > > ---
> > > > > =C2=A0fs/nfs/delegation.c | 25 -------------------------
> > > > > =C2=A0fs/nfs/delegation.h |=C2=A0 1 -
> > > > > =C2=A0fs/nfs/nfs4file.c=C2=A0=C2=A0 |=C2=A0 7 ++++---
> > > > > =C2=A03 files changed, 4 insertions(+), 29 deletions(-)
> > > > >=20
> > > > > diff --git a/fs/nfs/delegation.c b/fs/nfs/delegation.c
> > > > > index ad774316f716..3a141d5ee0bd 100644
> > > > > --- a/fs/nfs/delegation.c
> > > > > +++ b/fs/nfs/delegation.c
> > > > > @@ -1587,31 +1587,6 @@ bool nfs4_copy_delegation_stateid(struct
> > > > > inode
> > > > > *inode, fmode_t flags,
> > > > > =C2=A0=09return ret;
> > > > > =C2=A0}
> > > > > =C2=A0
> > > > > -/**
> > > > > - * nfs4_delegation_flush_on_close - Check if we must flush
> > > > > file
> > > > > on
> > > > > close
> > > > > - * @inode: inode to check
> > > > > - *
> > > > > - * This function checks the number of outstanding writes to
> > > > > the
> > > > > file
> > > > > - * against the delegation 'space_limit' field to see if
> > > > > - * the spec requires us to flush the file on close.
> > > > > - */
> > > > > -bool nfs4_delegation_flush_on_close(const struct inode *inode)
> > > > > -{
> > > > > -=09struct nfs_inode *nfsi =3D NFS_I(inode);
> > > > > -=09struct nfs_delegation *delegation;
> > > > > -=09bool ret =3D true;
> > > > > -
> > > > > -=09rcu_read_lock();
> > > > > -=09delegation =3D rcu_dereference(nfsi->delegation);
> > > > > -=09if (delegation =3D=3D NULL || !(delegation->type &
> > > > > FMODE_WRITE))
> > > > > -=09=09goto out;
> > > > > -=09if (atomic_long_read(&nfsi->nrequests) < delegation-
> > > > > > pagemod_limit)
> > > > > -=09=09ret =3D false;
> > > > > -out:
> > > > > -=09rcu_read_unlock();
> > > > > -=09return ret;
> > > > > -}
> > > > > -
> > > > > =C2=A0int nfs4_delegation_hash_alloc(struct nfs_server *server)
> > > > > =C2=A0{
> > > > > =C2=A0=09int delegation_buckets, i;
> > > > > diff --git a/fs/nfs/delegation.h b/fs/nfs/delegation.h
> > > > > index fba4699952b8..75f0edde65ea 100644
> > > > > --- a/fs/nfs/delegation.h
> > > > > +++ b/fs/nfs/delegation.h
> > > > > @@ -83,7 +83,6 @@ void nfs_put_delegation(struct nfs_delegation
> > > > > *delegation);
> > > > > =C2=A0void nfs_mark_delegation_referenced(struct nfs_delegation
> > > > > *delegation);
> > > > > =C2=A0int nfs4_have_delegation(struct inode *inode, fmode_t type,
> > > > > int
> > > > > flags);
> > > > > =C2=A0int nfs4_check_delegation(struct inode *inode, fmode_t type=
);
> > > > > -bool nfs4_delegation_flush_on_close(const struct inode
> > > > > *inode);
> > > > > =C2=A0void nfs_inode_find_delegation_state_and_recover(struct ino=
de
> > > > > *inode,
> > > > > =C2=A0=09=09const nfs4_stateid *stateid);
> > > > > =C2=A0void nfs4_inode_make_writeable(struct inode *inode);
> > > > > diff --git a/fs/nfs/nfs4file.c b/fs/nfs/nfs4file.c
> > > > > index 9a434f5dda8d..04f4d8967e5b 100644
> > > > > --- a/fs/nfs/nfs4file.c
> > > > > +++ b/fs/nfs/nfs4file.c
> > > > > @@ -122,10 +122,11 @@ nfs4_file_flush(struct file *file,
> > > > > fl_owner_t
> > > > > id)
> > > > > =C2=A0=09=09return 0;
> > > > > =C2=A0
> > > > > =C2=A0=09/*
> > > > > -=09 * If we're holding a write delegation, then check if
> > > > > we're
> > > > > required
> > > > > -=09 * to flush the i/o on close. If not, then just start
> > > > > the
> > > > > i/o now.
> > > > > +=09 * A write delegation already provides close-to-open
> > > > > consistency:
> > > > > +=09 * no other client can open the file until it is
> > > > > recalled,
> > > > > and the
> > > > > +=09 * recall writes back our dirty data. Just start the
> > > > > i/o.
> > > > > =C2=A0=09 */
> > > > > -=09if (!nfs4_delegation_flush_on_close(inode))
> > > > > +=09if (nfs_have_write_delegation(inode))
> > > > > =C2=A0=09=09return filemap_fdatawrite(file->f_mapping);
> > > > > =C2=A0
> > > > > =C2=A0=09/* Flush writes to the server and return any errors */
> > > > >=20
> > > > > ---
> > > > > base-commit: 9d66f26fefacebfeed15de31c1123451a17ff119
> > > > > change-id: 20261113-nfs-space-limit-025199334e52
> > > > >=20
> > > > > Best regards,
> > > >=20
> > > > Maybe we can call filemap_flush() in order to kick off non-
> > > > blocking
> > > > writes in this situation?
> > >=20
> > > This sounds like a good idea, but agentic review came up with this,
> > > and
> > > it seems to be valid, AFAICT:
> > >=20
> > > ------------8<-------------
> > > - filemap_flush() =E2=86=92 WB_SYNC_NONE: it skips folios already in
> > > flight,
> > > but it can block on server-wide congestion caused by other files.
> > >=20
> > > - filemap_fdatawrite() =E2=86=92 WB_SYNC_ALL: it may wait on this fil=
e's
> > > own
> > > rewritten in-flight folios, which a create/write/close workload
> > > rarely
> > > hits. It never waits on congestion, and a small file gets a
> > > FILE_SYNC
> > > WRITE with no COMMIT.
> > > ------------8<-------------
> > >=20
> > > I think we may want to switch this code back to using
> > > filemap_fdatawrite()
> > > like it did before. Thoughts?
> >=20
> > Urgh...
> >=20
> > OK, I've got to stop and ask why commit 2f1f31042ef0 ("nfs: Block on
> > write congestion") only applies congestion control to the
> > WB_SYNC_NONE
> > case?
> >=20
> > Also, why does it not re-check for congestion in the loops further
> > down
> > in nfs_writepages where it's adding fuel to the congestion fire?
> >=20
> > Put differently: If we're going to apply congestion control, then why
> > are we not doing so consistently here?
>=20
> Another note: this is almost certainly completely borked for the pNFS
> case, since nfss->write_congestion_wait is global to the metadata
> server. In the pNFS case, you can have lots of data servers that have
> completely independent congestion characteristics.

Alrighty, let me take a look at what we can do to clean this up. Stay
tuned. Thanks for the confirmation!

Cheers,
--=20
Jeff Layton <jlayton@kernel.org>
