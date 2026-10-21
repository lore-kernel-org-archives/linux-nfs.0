Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792593371;
	b=OmDdeb2qLpw6LN5TiC2JsOmCU7TZOp5fQ7c7A6UcpTdeiRfWW6UDXFvyr2gsGvbDxfAz
	 fzBMAXRBxuynObbyHQm/KeB+sIuCw8dx3gcHzdcLXNLweveRFBhhuOriAdXqOlbnn0wlt
	 SOcQmVD7wqw3t2Kjd2dzsnYz+KRNbHtAHRv7wEVLgUx3Ed6zQjeOq2MxdQHQmXkaj3zNJ
	 jFqdNYCvPS69VYL9+E95j0gV3652k1H0ImbeRkgVhim6FMNB6no4coKfmF8sCXwTeg0WO
	 44FeAf6IjaDiXjkbGudJYe83wr4gv2n8DNd1hTXyqdM0SDs6IdSMiAXAg2tdY4mlaUw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792593371;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=0/DZA0XSq4zWQqR92u51BiCE+QM/y2vLsi5z1/3NCwY=;
	b=w6QgpfkUv2GIdhdgHWGmkdfbpHov9ivsCnBEdNrQ5H0gYfD3FLUJmKm+2g69PkkbtXk8
	 30HxxBwJGT4Mpq02b7NogGrANjm88VAHStWSwT//BBk52EUx8+6gSAA748ZzzJb3kTs7S
	 6/O4kGwrBze7QHheVdmv1ZFwaJvxhmyoQrsEqfch2dmVWwVbcIoZkqLs4oBDhGJrtP0SE
	 lQQ3hP3kqLiNlwOF30Cb/2hqSV/FxPkEtMgOj9hEsioC4WT6ovQndibTYTNSGVPblwpBP
	 p8cZh8FT2sHKCQR04FPDLb+Ds3HDBcwDVWdX7Lj1EwkIQyPkW/vd8Cw8SBMh5YxHx9Q==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=V+Mok6uc;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 34D99606A31A;
	Wed, 21 Oct 2026 14:36:10 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=V+Mok6uc
Received: by smtp.kernel.org (Postfix) with ESMTPSA id A83FB1F000C1;
	Wed, 21 Oct 2026 14:36:09 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792593370;
	bh=0/DZA0XSq4zWQqR92u51BiCE+QM/y2vLsi5z1/3NCwY=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=V+Mok6ucfzzQtXkUSDemQyWLpiIB8chSnQn2edncNpTvz73tnOPq/gyXgZXCpxc+B
	 71VEqYOiMs+JDomAwP6farAOge+AM7kKPbiKlnISXHkw+q6eLBItyXfBgh1J2lTjpQ
	 kbCC+zFk7hd/GnUYSY+Ku86LQboRBXGaFXvtEYM0UgydfPfIH4W9hkGgeyIldypEzO
	 vFO62viaHJXrQ2a9kXcKwnNPBjK6l5D7lFj66Zv5kOLNAoTsAR6p6XCBnM0IvZ6Zgw
	 qLqboxHmmnePuG1abV1oVMiLXJba+fyiG6KIxcCJZmVQZCpy6FFOsLSwX4xD9BhltE
	 gZzXBCSBKYKEQ==
Message-ID: <c3842f844845a0c461ed7a895cff3a6d3d3f74c0.camel@kernel.org>
Subject: Re: [PATCH v7 3/5] mm, iomap: keep a partly covered page until an
 uncached write completes it
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@hammerspace.com>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>,  Jonathan Corbet	
 <corbet@lwn.net>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Wed, 21 Oct 2026 10:36:07 -0400
In-Reply-To: <20261020220346.28020-4-snitzer@kernel.org>
References: <20261020220346.28020-1-snitzer@kernel.org>
	 <20261020220346.28020-4-snitzer@kernel.org>
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
User-Agent: Evolution 3.60.2 (3.60.2-2.fc44) 
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0

On Tue, 2026-10-20 at 18:03 -0400, Mike Snitzer wrote:
> An uncached (RWF_DONTCACHE) buffered write marks drop-behind every folio
> it creates, so writeback drops each one as soon as this write's data is
> on disk.  A page the write covers only partly is usually shared with the
> neighbouring write, the one that ends or starts in it.  Once the first
> of the two has been written back, the page is gone, and the second has
> to read the block back from disk before it can write its part: one read
> per misaligned write.
>=20
> Measured locally on XFS (emulated 4Kn NVMe, 4 KiB pages), 32 threads
> writing interleaved records to one file with pwritev2(), 1 GiB per run,
> before and after this patch:
>=20
>   record  flags                     4 KiB device       MiB/s
>   bytes                             reads per write
>                                     before   after     before  after
>   47008   RWF_DONTCACHE             0.97     0.000     831     2281
>   47008   RWF_DONTCACHE|RWF_DSYNC   0.99     0.000     601     1227
>   6000    RWF_DONTCACHE             0.97     0.000     121      488
>   6000    RWF_DONTCACHE|RWF_DSYNC   0.99     0.000      90      206
>=20
> Before this patch every write waited for its read, and because XFS holds
> its IOLOCK exclusively across a buffered write, the other 31 writers
> waited too: both record sizes ran at about 20 thousand writes a second,
> one device read per write; after it nothing is read back.  With
> RWF_DSYNC each write still waits for its own sync, so the gain is
> smaller: the uncached write now runs as fast as the same write without
> RWF_DONTCACHE, 1237 and 209 MiB/s against 1227 and 206 in the table.
> Records of 49152 bytes, which cover only whole pages, read nothing
> before or after.
>=20
> NFSD DIRECT issues the misaligned ends of a WRITE as buffered uncached
> segments and gains the same way.  Without any handling of the shared
> page, 32 interleaved writers of 47008-byte records read 45144 blocks
> for 45664 WRITEs; with this patch, and no NFSD code for the shared page,
> 0.0001 to 0.0008 blocks per WRITE whether each record is sent as one
> FILE_SYNC WRITE, as two one after the other, as two together, or as two
> UNSTABLE.  The page cache then marks the completed page while it is
> still dirty, so each segment of a stable WRITE wakes the DONTCACHE
> writeback kick (23 to 65 thousand rounds a run); the next two patches
> let NFSD mark it after its sync instead.
>=20
> Let the write path say which pages a write covers only partly
> (FGP_DONTCACHE_EDGE, set by iomap when the write starts inside a page or
> ends before its end) and get such a page as a single page.  A folio
> created for it is not marked, so writing back this write's part does not
> drop it.  A folio found uptodate is the neighbour's, already written:
> this write completes it, so mark it, under the folio lock and before its
> own data goes in, and the writeback that cleans both writes' data drops
> it.  The folio lock orders the two writes, so the second always finds
> the first's data in place.
>=20
> A page whose neighbour never writes, such as the last page of a file,
> stays cached until reclaim.  A partly covered page another task had
> cached and that is uptodate is now dropped after the write's writeback,
> where before an uncached write never dropped a page it did not create.
>=20
> Only iomap file systems say which pages a write covers partly so far;
> write_begin_get_folio() users such as ext4 and the NFS client do not.
> With blocks smaller than a page, a write that crosses an extent boundary
> inside a page asks for it as two partly covered halves, so the page,
> though one write covers it whole, stays cached until reclaim.
>=20
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  fs/iomap/buffered-io.c  | 12 +++++++++++-
>  include/linux/pagemap.h |  5 +++++
>  mm/filemap.c            | 19 ++++++++++++++++++-
>  3 files changed, 34 insertions(+), 2 deletions(-)
>=20

The nfsd case typically uses buffered or DONTCACHE for the unaligned
sub-page-sized "ends" when direct is in force, so mostly these ends get
submitted as small (< PAGE_SIZE or folio_size()) buffered I/Os.

Why do we need this special casing instead of just making those
unaligned ends use regular buffered I/O? Isn't it basically the same
thing?
=20
> diff --git a/fs/iomap/buffered-io.c b/fs/iomap/buffered-io.c
> index 0a5ebfda90f1..780a0186045d 100644
> --- a/fs/iomap/buffered-io.c
> +++ b/fs/iomap/buffered-io.c
> @@ -802,8 +802,18 @@ struct folio *iomap_get_folio(struct iomap_iter *ite=
r, loff_t pos, size_t len)
> =20
>  	if (iter->flags & IOMAP_NOWAIT)
>  		fgp |=3D FGP_NOWAIT;
> -	if (iter->flags & IOMAP_DONTCACHE)
> +	if (iter->flags & IOMAP_DONTCACHE) {
>  		fgp |=3D FGP_DONTCACHE;
> +		/*
> +		 * A page this write covers only partly is shared with a
> +		 * neighbouring write: get it as a single page, which is
> +		 * kept until the write that completes it.
> +		 */
> +		if (offset_in_page(pos) || len < PAGE_SIZE) {
> +			fgp |=3D FGP_DONTCACHE_EDGE;
> +			len =3D min_t(size_t, len, PAGE_SIZE - offset_in_page(pos));
> +		}
> +	}
>  	fgp |=3D fgf_set_order(len);
> =20
>  	return __filemap_get_folio(iter->inode->i_mapping, pos >> PAGE_SHIFT,
> diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
> index 3012bd95812a..0c1d6bd09aa0 100644
> --- a/include/linux/pagemap.h
> +++ b/include/linux/pagemap.h
> @@ -701,6 +701,10 @@ pgoff_t page_cache_prev_miss(struct address_space *m=
apping,
>   * * %FGP_NOWAIT - Don't block on the folio lock.
>   * * %FGP_STABLE - Wait for the folio to be stable (finished writeback)
>   * * %FGP_DONTCACHE - Uncached buffered IO
> + * * %FGP_DONTCACHE_EDGE - With %FGP_DONTCACHE: the write covers this pa=
ge
> + *   only partly, and a neighbouring write may complete it.  A folio cre=
ated
> + *   for it is not marked drop-behind; a folio found uptodate is, as the
> + *   write that completes it.
>   * * %FGP_WRITEBEGIN - The flags to use in a filesystem write_begin()
>   *   implementation.
>   */
> @@ -715,6 +719,7 @@ typedef unsigned int __bitwise fgf_t;
>  #define FGP_FOR_MMAP		((__force fgf_t)0x00000040)
>  #define FGP_STABLE		((__force fgf_t)0x00000080)
>  #define FGP_DONTCACHE		((__force fgf_t)0x00000100)
> +#define FGP_DONTCACHE_EDGE	((__force fgf_t)0x00000200)
>  #define FGF_GET_ORDER(fgf)	(((__force unsigned)fgf) >> 26)	/* top 6 bits=
 */
> =20
>  #define FGP_WRITEBEGIN		(FGP_LOCK | FGP_WRITE | FGP_CREAT | FGP_STABLE)
> diff --git a/mm/filemap.c b/mm/filemap.c
> index ed7e4dbea653..0397ec771547 100644
> --- a/mm/filemap.c
> +++ b/mm/filemap.c
> @@ -2016,6 +2016,16 @@ struct folio *__filemap_get_folio_mpol(struct addr=
ess_space *mapping,
> =20
>  	if (fgp_flags & FGP_STABLE)
>  		folio_wait_stable(folio);
> +
> +	/*
> +	 * An uncached write that covers this folio only partly, finding it
> +	 * uptodate, is the write that completes it: the neighbouring write
> +	 * that left it here has written its part.  Mark it now, under the
> +	 * folio lock, so the writeback that cleans both writes' data drops it.
> +	 */
> +	if ((fgp_flags & FGP_DONTCACHE) && (fgp_flags & FGP_DONTCACHE_EDGE) &&
> +	    (fgp_flags & FGP_LOCK) && folio_test_uptodate(folio))
> +		folio_mark_dropbehind(folio);
>  no_page:
>  	if (!folio && (fgp_flags & FGP_CREAT)) {
>  		unsigned int min_order =3D mapping_min_folio_order(mapping);
> @@ -2053,7 +2063,14 @@ struct folio *__filemap_get_folio_mpol(struct addr=
ess_space *mapping,
>  			/* Init accessed so avoid atomic mark_page_accessed later */
>  			if (fgp_flags & FGP_ACCESSED)
>  				__folio_set_referenced(folio);
> -			if (fgp_flags & FGP_DONTCACHE)
> +			/*
> +			 * A folio the write covers only partly is left
> +			 * unmarked, so that writing back this write's part
> +			 * does not drop it before a neighbouring write has
> +			 * written the rest.
> +			 */
> +			if ((fgp_flags & FGP_DONTCACHE) &&
> +			    !(fgp_flags & FGP_DONTCACHE_EDGE))
>  				__folio_set_dropbehind(folio);
> =20
>  			err =3D filemap_add_folio(mapping, folio, index, gfp);

--=20
Jeff Layton <jlayton@kernel.org>
