Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7032542376D
	for <linux-nfs@vger.kernel.org>; Thu, 16 Jul 2026 13:29:43 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784208584; cv=none; b=RBEt+ag/vbmBraCRh524G46fHDe7UFMECdNjiO5wBpN9j1wMRC9F+SYT2hZ39mbPKLd/Kfa1vi7fmF1cabf7irYu2Egx3JlmwrrswvlU+1/OaQSE5xL6T4anIfaokQCQZ6BHneKBO4K6/gEswJqxxYqbOOYzIO69v/CVGq7hwnk=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784208584; c=relaxed/simple;
	bh=nJji+JUsV3FNEsDaGC7aKciguPR8IpLDyN2m5CBvkOA=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=pFPRy3zjNEjEwZIhRV6FLkpdQbV+hRrWC8DbthRLnytLT+TdmKRpKk3cbSGEEWtK/fUFY2PF3hm0r8FRS1v4T9+yAa/lpABNnJ1vGaGDiUwzUPOZQ2sEbSGupD4WH5STvbxcGvH7dfBvXtE5JlBC4soQBgBfXYjBKTARWnPbOx4=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mMkF3tdj; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mMkF3tdj"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 8DA9A1F000E9;
	Thu, 16 Jul 2026 13:29:42 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784208583;
	bh=XZ8nj2YL0mqMVIYNdkj3miB9N0JevEXB/T1TxAUzg/U=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=mMkF3tdjOtpXwt6rWzD95twrULP5/cTyhyt57myCKt5o7pVYe21Wmg/Dn/9TrxkLF
	 wpvsdDBBHUdOouXP8FR0FShmBguPYXghKPzSBDm25ec9Nd+Y5ObmUT9xpihcXbMeQ4
	 hBebdCtWqT3marqGizwXHPERUsvecAnPR1zZ1YPLt/ZCe8VnDwnnyRHC7A5G/i//0S
	 ApXXyGe40wvFNJJB5qo60WIdsoilTGiMftd+icXHgkJikeL+26JBYzV9thmqkVHf/1
	 PP6XXy1RPJPBpRRXw8B4V/nL7BDzKimyyrsS4HLM0G0SLhIZkVL/cxO+E0tpHU3Cof
	 M5HuUTbuES0Zw==
Message-ID: <9ab523157c18bb8968ae965dbc5aca76178ff2ac.camel@kernel.org>
Subject: Re: [PATCH v3 00/17] nfsd: refactor nfs4_create_file()
From: Jeff Layton <jlayton@kernel.org>
To: NeilBrown <neil@brown.name>, Chuck Lever <chuck.lever@oracle.com>
Cc: Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, 
 Tom Talpey <tom@talpey.com>, linux-nfs@vger.kernel.org
Date: Thu, 16 Jul 2026 09:29:40 -0400
In-Reply-To: <20260713062219.6399-1-neilb@ownmail.net>
References: <20260713062219.6399-1-neilb@ownmail.net>
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
User-Agent: Evolution 3.60.2 (3.60.2-1.fc44) 
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Mon, 2026-07-13 at 16:15 +1000, NeilBrown wrote:
> This v2 incorporates fixes for issues Chuck reported from "Codex
> review".  These changes are distributed around the patches a bit, but
> 02/17 is an interesting new bugfix.
>=20
> This is against nfs-testing (5f5dc3d855cf).
>=20
> Thanks,
> NeilBrown
>=20
>  [PATCH v3 01/17] nfsd: honour client-provided attributes for
>  [PATCH v3 02/17] nfsd: correctly handle CREATE of mounted-on files
>  [PATCH v3 03/17] nfsd: replace fh_fill_both_attrs() with
>  [PATCH v3 04/17] nfsd: move fh_want_write() after preamble in
>  [PATCH v3 05/17] nfsd: move more nfs-specific code into preamble of
>  [PATCH v3 06/17] nfsd: remove subtlety from nfsd4_create_file()
>  [PATCH v3 07/17] nfsd: in nfsd4_create_file() let VFS report if file
>  [PATCH v3 08/17] nfsd: nfsd4_create_file(): Move NFSD_MAY_CREATE
>  [PATCH v3 09/17] nfsd: fh_want_write) failure need not be immediately
>  [PATCH v3 10/17] nfsd: (almost) always open file in
>  [PATCH v3 11/17] nfsd: reduce range of directory lock in
>  [PATCH v3 12/17] nfsd: open-code nfsd4_vfs_create() into
>  [PATCH v3 13/17] nfsd: move some code out of the
>  [PATCH v3 14/17] nfsd: reduce want-write range in nfsd4_create_file()
>  [PATCH v3 15/17] nfsd: move v0 checking out of nfsd_check_obj_isreg()
>  [PATCH v3 16/17] nfsd: separate out VFS-specific code from
>  [PATCH v3 17/17] nfsd: use do_lookup_open() for non-creating open

I ran a review pass over this with an LLM and it found a few issues.
Let me know if you want the more detailed inline reviews:

Regressions found
-----------------
[high] 850097d914d3 "always open file in nfsd4_create_file()"
  dentry_open() now runs on any positive dentry the client name resolves
  to, before the nfsd_check_obj_isreg() type check in do_open_lookup().
  For an existing fifo, the default O_RDONLY (no O_NONBLOCK) open blocks in
  fifo_open() waiting for a writer, and does so while the parent directory
  i_rwsem is held (start_creating..end_creating) - an nfsd thread stall
  with the directory locked. Device nodes invoke the driver ->open. The
  ordering persists to the series head (do_lookup_open). Detail:
  series-review/850097d914d3/review-inline.txt.

[medium] 90a149d88abc "reduce want-write range in nfsd4_create_file()"
  Issue 1: For a write-mode create the setattr now runs without
  sb_start_write() freeze protection. The reduced want_write is dropped
  after end_creating(); only the O_RDONLY branch reacquires fh_want_write()
  around nfsd_create_setattr(). A write-mode open holds the mnt writer
  reference but not freeze protection, and nfsd_setattr() does not take its
  own (resfhp->fh_dentry is set, so get_write_count is false). A concurrent
  freeze_super() can complete in the window, after which notify_change()
  modifies a frozen filesystem.
  Issue 2 (low): commit message says "we add a call to dentry_open()" for
  the already-exists case, but that call pre-exists; only the comment is
  reworded. Detail: series-review/90a149d88abc/review-inline.txt.

[medium] f467dd742c2d "separate out VFS-specific ... do_lookup_open()"
  Issue 1: "if (status =3D=3D NFSERR_NOENT && create_status)" compares a __=
be32
  status against the raw host enum NFSERR_NOENT (2). status holds
  nfserr_noent =3D=3D cpu_to_be32(2) =3D=3D 0x02000000 on little-endian, so=
 the
  branch never fires and the create-permission error (create_status) is
  masked by NFS4ERR_NOENT. Should be nfserr_noent. Persists to commit 14.
  Issue 2 (trivial): duplicated word in the subject ("from from").
  Detail: series-review/f467dd742c2d/review-inline.txt.

[high] b4f1a9d54d0f "use do_lookup_open() for non-creating open requests to=
o."
  Issue 1: do_lookup_open() begins with an unconditional mnt_want_write().
  Now that non-creating OPEN is routed through it (previously nfsd_lookup()=
,
  which needs no write access), a plain read-only OPEN of an existing file
  returns NFS4ERR_ROFS when the exported filesystem is mounted read-only or
  has a read-only superblock (squashfs, iso9660, erofs, ro-mounted
  ext4/xfs). mnt_want_write() also calls sb_start_write(), so a read OPEN
  now blocks while the filesystem is frozen.
  Issue 2 (medium/perf): do_lookup_open() uses start_creating(), taking the
  parent i_rwsem exclusively for every non-creating OPEN; nfsd_lookup()
  previously used lookup_one_unlocked() (shared, or none on a dcache hit),
  so concurrent opens in one directory are now serialised.
  Detail: series-review/b4f1a9d54d0f/review-inline.txt.

--=20
Jeff Layton <jlayton@kernel.org>
