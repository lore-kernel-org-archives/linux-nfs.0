Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1793195883;
	b=cH8EeIznW4Z1Hzpk1PEoqxG2qVogbSn9qPdqHX2qvf4Li1BGbn++SzKmlV/EFDzx+sih
	 hxEW4fh8qnxgKjP2xSwIXcPWI6qmtfeq7jwhoVrHgP5M0htWVQEdlzm+4R/1kSu4K4t2b
	 xFcBl4mclUaKC8mfcvqcYYN2am3ybeNPjzDvEqu3cAcioZ5zOAIYzeYjpoPKNCEuHQwyL
	 /Q/n/DIjE4kJkznqP1e9V6rZDxHX4Ap2JTaW7qkGwpSXMswa0BQUkSYi1hLPX6+JBxveg
	 GNs0dXDGIMA/8ujLXveMNnk97RLni6qjOcpF/sVVmDAxKflEiuCGLgOMoiylflQebIw==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1793195883;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=xxDei/pwqldghsjmR/BnTDVh+RQr86nmUfxm/AdaCGc=;
	b=Ha8op03QiV+TA7JsCasBa7sht9Tt2MohrSOwzZr2kbGPKypWJJSODspMF/6Fj5odGi/p
	 w6lDDmPockKF2Y4vpwNXPveU6wrd5lD8mDo1UmiH8Hh39pUpoRBS3kf3W7Qwg2LVsR2Q5
	 qIslLMadh1GxNDcPzJCE6Cv6qaMd1+HVSl96lkAD9po7xqaNIjL+jOgzKc+kGDsDl/IoG
	 Zku7o670G4IcTsNCCxaOqOhwRXztuISQDz35AkJtj8uFwgCt7UkvIeERRIu3TzYdBbuB2
	 XihvFEWs7K+KkPA+I5ulQdyJdM/qrHB2A8wWkm8/zN48GXKge/Xe836PHT2HXzed4qA==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=j3WUV9f8;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id CDBC4606A31A
	for <linux-nfs@vger.kernel.org>; Wed, 28 Oct 2026 13:58:02 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=j3WUV9f8
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 198AB1F01825;
	Wed, 28 Oct 2026 13:58:02 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1793195882;
	bh=xxDei/pwqldghsjmR/BnTDVh+RQr86nmUfxm/AdaCGc=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=j3WUV9f8dXQ9KIkMkEbGV+PIMzCRZTQTY4nlLOMMfow039znxR1UPTZShcHhKDEbu
	 Ls8tF9NL7B+VSbbt0OpNfKbqnmWltCLZa0ORLZQ6rtGV4UpaXTc/v7ZplexzbIVPRk
	 gSXO/qG4MDXrmnkxwIL1CqNXd9oV27MtKG95FjxAXh3erfC4F4DmXl8LOeQC63JtPp
	 58A0atAXsfQl7xWLJjseJMxM9mHETHnqkuGZOXA2fpn9bum8GbnsW27aHeMsdowDsn
	 f0hOenQWZCnE0D17sQDhylvC5DNP05VqSXc5ynWSVhwkOD1o+8ryXRt9plTeAfGDP3
	 btZozUluwwDXg==
Message-ID: <462ce95bb4f642249a660a73d6f5150ff61adf56.camel@kernel.org>
Subject: Re: [PATCH] nfsd: prevent SAVEFH from bypassing export security
From: Jeff Layton <jlayton@kernel.org>
To: Adolph Zeng <coderzeng@gmail.com>, "cel@kernel.org" <cel@kernel.org>, 
 "neil@brown.name"
	 <neil@brown.name>, "okorniev@redhat.com" <okorniev@redhat.com>, 
 "Dai.Ngo@oracle.com"
	 <Dai.Ngo@oracle.com>, "tom@talpey.com" <tom@talpey.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>
Date: Wed, 28 Oct 2026 09:57:58 -0400
In-Reply-To: <IA1PR12MB662781C8C09627A5CDEBF39DF4602@IA1PR12MB6627.namprd12.prod.outlook.com>
References: 
	<SY9P300MB153090355AAD017CD7216634A6602@SY9P300MB1530.AUSP300.PROD.OUTLOOK.COM>
	 <IA1PR12MB662781C8C09627A5CDEBF39DF4602@IA1PR12MB6627.namprd12.prod.outlook.com>
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

On Tue, 2026-10-27 at 12:44 +0000, Adolph Zeng wrote:
>=20
> Hi,
> I was informed that Hotmail may reject incoming messages from kernel.org,=
 so I am switching to this Gmail address to avoid missing any replies.
> My original patch was sent from coderzeng@hotmail.com. Please use coderze=
ng@gmail.com for any further correspondence.
> Apologies for the inconvenience.
> Best regards,
> Adolph Zeng
> From: Zeng Adolph <coderzeng@hotmail.com>
> Sent: Tuesday, October 27, 2026 8:40 PM
> To: cel@kernel.org <cel@kernel.org>; jlayton@kernel.org <jlayton@kernel.o=
rg>; neil@brown.name <neil@brown.name>; okorniev@redhat.com <okorniev@redha=
t.com>; Dai.Ngo@oracle.com <Dai.Ngo@oracle.com>; tom@talpey.com <tom@talpey=
.com>
> Cc: linux-nfs@vger.kernel.org <linux-nfs@vger.kernel.org>
> Subject: [PATCH] nfsd: prevent SAVEFH from bypassing export security
>=20
> =C2=A0
>=20
>=20
> An AUTH_SYS NFSv4 client can read or write a file on a sec=3Dkrb5p
> export using another client's valid OPEN stateid by inserting
> SAVEFH between PUTFH and READ or WRITE.
>=20
>=20
> PUTFH resolves the handle with NFSD_MAY_BYPASS_GSS, expecting
> a later security check. SAVEFH carries OP_HANDLES_WRONGSEC even though
> it only saves the handle, so PUTFH skips NFS4ERR_WRONGSEC. Stateid I/O
> can then reuse a cached nfsd_file.
>=20
>=20
> The original report exported /srv/nfs-sec to * with these options:
>=20
>=20
> =C2=A0 rw,sync,no_subtree_check,fsid=3D0,sec=3Dkrb5p,secure,root_squash
>=20
>=20
> The 0600, nobody:nogroup file /srv/nfs-sec/secret.txt held 32 random
> bytes. A Kerberos privacy NFSv4.0 client ran SETCLIENTID, OPEN and
> OPEN_CONFIRM, then kept its read/write stateid live. A separate
> AUTH_SYS client used UID/GID 65534 and a reserved source port.
>=20
>=20
> The AUTH_SYS client enumerated a bounded range of nearby clientid
> counters, stateid numbers and seqids to find the live OPEN stateid.
> With it, PUTFH, READ returned NFS4ERR_WRONGSEC, while PUTFH, SAVEFH,
> READ returned the file data and PUTFH, SAVEFH, WRITE changed it. The
> Kerberos client subsequently read the changed contents.
>=20
>=20
> SAVEFH leaves CURRENT_FH in place. When deciding whether PUTFH must
> report NFS4ERR_WRONGSEC, look past SAVEFH to the first operation that
> uses or replaces CURRENT_FH. If another PUTFH replaces it, leave the
> earlier PUTFH unchecked, as required by RFC 8881 Section 2.6.3.1.1.
>=20
>=20
> Local COPY and CLONE consume SAVED_FH as the source. Check the
> saved export with check_nfsd_access() before using its stateid:
> a cached open stateid can otherwise bypass the sec=3D policy. Map
> NFS4ERR_WRONGSEC to NFS4ERR_ACCESS at COPY or CLONE, since neither
> operation permits NFS4ERR_WRONGSEC. The check also applies when
> SECINFO_NO_NAME or RESTOREFH intervenes. LINK and RENAME already
> check their saved handle in their own paths.
>=20
>=20
> An inter-server COPY carries a foreign SAVED_FH. The source server
> validates it; the destination must not apply its own export policy
> to that handle. The destination PUTFH still checks its local export.
>=20
>=20
> KASAN guests reproduced the NFSv4.0 and local NFSv4.2 bypasses on
> d135ab453a74. With this patch, direct READ and SAVEFH READ/WRITE
> returned NFS4ERR_WRONGSEC. Local COPY/CLONE with a protected saved
> source returned NFS4ERR_ACCESS; foreign-handle inter-server COPY
> completed.
>=20
> Fixes: 68d93184352f ("nfsd4: fix wrongsec handling for PUTFH + op cases")
> Assisted-by: LLM
> Signed-off-by: Zeng Adolph <coderzeng@hotmail.com>
> ---
> Testing: two x86_64 guests covered the original NFSv4.0 report,
> six SAVEFH security boundaries, NFSv4.2 local COPY/CLONE, and a
> foreign-handle inter-server COPY. W=3D1 nfs4proc.o built with
> CONFIG_NFSD_V4_2_INTER_SSC enabled and disabled. The ASan/UBSan
> decision harness passed 262 cases. The KASAN guest reported no
> KASAN, Oops, or NFSD warnings.
>=20

This needs to be sent as a proper inline patch. We can't apply this as
it's whitespace-damaged.

Also, some suggestions from Claude below that look valid:


>=20
> =C2=A0fs/nfsd/nfs4proc.c | 36 +++++++++++++++++++-----------------
> =C2=A01 file changed, 19 insertions(+), 17 deletions(-)
>=20
>=20
> diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
> index a50f9dcb3..25fb7fb61 100644
> --- a/fs/nfsd/nfs4proc.c
> +++ b/fs/nfsd/nfs4proc.c
> @@ -1491,6 +1491,11 @@ nfsd4_verify_copy(struct svc_rqst *rqstp, struct n=
fsd4_compound_state *cstate,
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (!cstate->save_fh.f=
h_dentry)
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82=E2=80=82=E2=80=82=E2=80=82return nfserr_nofilehandle;
> =C2=A0
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/* A cached open stateid do=
es not authorize the saved source export. */
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82status =3D check_nfsd_acces=
s(cstate->save_fh.fh_export, rqstp);
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (status)
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82return nfserr_acces;
> +

This is a point fix for the one remaining saved-fh consumer. The common
factor in every variant of this bug is that nfs4_check_file() only
calls nfsd_permission() when it finds a cached nfsd_file. It never
checks the security flavor:

fs/nfsd/nfs4state.c:nfs4_check_file() {
	nf =3D nfs4_find_file(s, flags);
	if (nf) {
		status =3D nfsd_permission(&rqstp->rq_cred,
					 fhp->fh_export, fhp->fh_dentry,
				acc | NFSD_MAY_OWNER_OVERRIDE);

Only the nfsd_file_acquire() path goes through fh_verify(). Would it be
worth also adding a check_nfsd_access() there (mapped to nfserr_acces),
as a backstop in case there are other op orderings that skip the PUTFH
check?

> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82status =3D nfs4_prepro=
cess_stateid_op(rqstp, cstate, &cstate->save_fh,
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=
=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 =C2=A0 =C2=A0src_stateid, RD_=
STATE, src, NULL);
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (status)
> @@ -3237,32 +3242,29 @@ static bool need_wrongsec_check(struct svc_rqst *=
rqstp)
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_compoundr=
es *resp =3D rqstp->rq_resp;
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_compounda=
rgs *argp =3D rqstp->rq_argp;
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *this =
=3D &argp->ops[resp->opcnt - 1];
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *next =3D &=
argp->ops[resp->opcnt];
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82struct nfsd4_op *next;
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82const struct nfsd4_ope=
ration *thisd =3D OPDESC(this);
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82const struct nfsd4_ope=
ration *nextd;
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82unsigned int i;
> =C2=A0
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * Most ops check wronsec o=
n our own; only the putfh-like ops
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * have special rules.
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (!(thisd->op_flags =
& OP_IS_PUTFH_LIKE))
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82=E2=80=82=E2=80=82=E2=80=82return false;
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * rfc 5661 2.6.3.1.1.6: do=
n't bother erroring out a
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * put-filehandle operation=
 if we're not going to use the
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * result:
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (argp->opcnt =3D=3D resp=
->opcnt)
> +
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/* SAVEFH does not consume =
the current filehandle. */
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82for (i =3D resp->opcnt; i <=
 argp->opcnt; i++) {
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82next =3D &argp->ops[i];
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82if (next->opnum !=3D OP_SAVEFH)
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82break;
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82}
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (i =3D=3D argp->opcnt)
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82=E2=80=82=E2=80=82=E2=80=82return false;
> +
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82next =3D &argp->ops[i];

This isn't a bug, but next already points to argp->ops[i] when the loop
breaks early, so isn't this assignment redundant?

> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82if (next->opnum =3D=3D=
 OP_ILLEGAL)
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=
=80=82=E2=80=82=E2=80=82=E2=80=82return false;
> =C2=A0=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82nextd =3D OPDESC(next)=
;
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82/*
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * Rest of 2.6.3.1.1: certa=
in operations will return WRONGSEC
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * errors themselves as nec=
essary; others should check for them
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 * now:
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82 */
> -=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82return !(nextd->op_flags & =
OP_HANDLES_WRONGSEC);
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82return !(nextd->op_flags &
> +=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=E2=80=82=
=E2=80=82=E2=80=82=E2=80=82 =C2=A0(OP_HANDLES_WRONGSEC | OP_IS_PUTFH_LIKE))=
;

This isn't a bug, but the existing comments explaining which RFC rule
each test implements were dropped. The function now encodes three
separate rules (2.6.3.1.1.1 for SAVEFH, 2.6.3.1.1.2 for consecutive
put-filehandle ops, 2.6.3.1.1.6 for end of compound). Could the
comments be kept and updated to cite the RFC 8881 sections instead?

> =C2=A0}
> =C2=A0
> =C2=A0#ifdef CONFIG_NFSD_V4_2_INTER_SSC
> --
> 2.43.0
>=20

--=20
Jeff Layton <jlayton@kernel.org>
