Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 253614EDCB4;
	Wed, 14 Oct 2026 11:26:05 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1791977167; cv=none; b=KlMsRPqP7RW6Q25Nvy701ZxAT9gj4iip2KJW9wCoiGlaiyQ326WUPYf3bsjF8cToWgPKt2HJXpq8wXKsJ5ZAXptPvAdF7NZ9AEtRb79tB5oK9dU06nehtnVtawFU8nCbv28Dum/sBvPgsi6RhqVR+Tny2b7jMElAaGCLhwV2h7E=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1791977167; c=relaxed/simple;
	bh=YM0QLmHOHv68iWT/ucsOW41QugkXxNqt+swXCQpJdFw=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=bEz/AZtPNSlv18lqQZR+11elMXFdwK6ZWD67lbks55nsXGDRorDBr/EB9cku9DFtxATckiK/fz0nOz6wjue/hpcsyNO31Zu3ncKA6QkFjN1F1yQZKHHmZfZlzeFKhDPCc+RPymKpSsDkie6xU23HmPc2/L5WXjZr4eK4pqV+ulk=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=aVNdZC1p; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="aVNdZC1p"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id B7BB31F000FF;
	Wed, 14 Oct 2026 11:26:04 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1791977165;
	bh=EZqe6c5DrlYLBj/9E9OHSmL6TAlCKdu/psU51snTZFk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=aVNdZC1pD2dMjCdz9f0S+mF0ogbVKgdg8K27qlCT6JIPyEMWVWlFcv/6dsgw+REBz
	 dXSNKtMIT8zNAyDB9dR8Mk+gTk7PNG+bYdjcCqZofSaHYs4iU3kQ7ylqx4TJLRdyu/
	 r1669E2iKWlSBcRuQbRGz66qjj27Z+ayRwL0kSVJVPok+e0PHcmjPpc3lvIFS80vWE
	 g5t8ssQiX1tZckr8Posm8pf6WJ99L+E2NhEbYGCAN/GdEbIxblWby6gCUz02AZ7SaK
	 jM6Sf2bGcBM936+v3aKSVmMEZQXjt8bDIx7N4v4CQnj0OaiqqeXf0jLI1M9aduxUdG
	 PJPkfsnJtmf0A==
Message-ID: <46ba944d8dcb989c60c276813339dcb8564a823f.camel@kernel.org>
Subject: Re: [PATCH v2 0/7] nfsd: layout recall and lease break fixes
From: Jeff Layton <jlayton@kernel.org>
To: daejun7.park@samsung.com, Chuck Lever <cel@kernel.org>, NeilBrown
	 <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>, Dai Ngo
	 <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: Christoph Hellwig <hch@lst.de>, Benjamin Coddington
 <bcodding@redhat.com>,  Trond Myklebust <trondmy@kernel.org>, Anna
 Schumaker <anna@kernel.org>, linux-nfs@vger.kernel.org, 
	linux-kernel@vger.kernel.org
Date: Wed, 14 Oct 2026 07:26:03 -0400
In-Reply-To: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
References: <20261014-nfsd-layout-recall-v2-0-764462bddfd1@samsung.com>
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
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0

On Wed, 2026-10-14 at 16:29 +0900, Daejun Park via B4 Relay wrote:
> nfsd polls a client that has accepted a CB_LAYOUTRECALL by sending the
> callback again every 10 ms, with the stateid of the first callback. A
> Linux client from v6.8 on answers the repeat with NFS4ERR_OLD_STATEID,
> and nfsd takes that as a failed recall. So a client that needs more
> than 10 ms to return a layout has the layout revoked and the fence path
> run. With the block layout that client loses data it has written and
> synced, with the SCSI layout it is cut off from the device. Patch 5
> lets nfsd keep polling instead.
>=20
> A recall that takes longer makes the operation that started it wait
> longer. When that operation is a WRITE, a SETATTR that changes the
> size, an ALLOCATE, a DEALLOCATE, a CLONE or a COPY, the nfsd thread
> serving it waits in XFS until the layouts are returned or the lease
> break times out. As Chuck pointed out on v1, a few such requests can
> take every nfsd thread, and the server then cannot serve the
> LAYOUTRETURN that would release them. Patch 2 recalls the layouts
> before the operation without waiting, gives the layouts of other
> clients 30 ms to come back when it starts their recall, and otherwise
> answers NFS4ERR_DELAY.
>=20
> The cost of patch 2: a client that writes to a file through its layout
> and, for writes that are not aligned, through the server recalls its
> own layout with each such WRITE and has its LAYOUTGETs fail with
> NFS4ERR_RECALLCONFLICT meanwhile. In test 2 it wrote 48, 46 and 4 1 MiB
> blocks through its layout in 30 seconds instead of 534, 537 and 505;
> before, 6 of 7, 4 of 4 and 17 of 20 recalls ended in the failure path
> and 7, 4 and 20 blocks were lost. The series on top of this one, with
> the NFS client fix it needs, brings that to 193, 192 and 184 blocks.
>=20
> Patches 3 and 4 are the other two that patch 5 needs. Patch 3: the
> limit of two lease periods on the poll has never triggered, and without
> it the poll would have no end. Patch 4: for the block layout a lease
> break gives up after fs.lease-break-time (45 s) without running
> /sbin/nfsd-recall-failed. Until now the recall had failed long before
> that; with patch 5 it is polled for two lease periods (180 s). Patch 4
> fences the client at fs.lease-break-time, as the SCSI layout does since
> v7.1; by default that is shorter than the one lease period RFC 8881
> section 12.5.5 has the server wait after a recall.
>=20
> Patch 1 fixes a lease break that hits a LAYOUTGET in progress and then
> waits for a layout that is never recalled. It comes first because
> patch 2 makes that common: the break of patch 2 runs outside the XFS
> iolock, so it can land between the allocation of a layout stateid and
> the insertion of its first layout.
>=20
> Patches 6 and 7 deal with two answers that the polls handle badly. A
> client that a LAYOUTRETURN has moved past the seqid of the recall
> answers every poll NFS4ERR_OLD_STATEID and is never asked for the
> layouts it still holds; patch 6 polls such a client, one that has not
> answered NFS4_OK, with a new seqid. A client that answers
> NFS4ERR_BAD_STATEID after returning its last layout is fenced; patch 7
> looks for layouts first.
>=20
> Patches 1 to 5 have to go together, also to stable kernels. Patch 6
> builds on patches 1 and 5, and patch 7 stands on its own. If patch 2
> should not go to stable, patches 3 to 5 should not either; patches 1
> and 7 can go alone. Kernels before v7.1 do not have the lease break
> timeout that patch 4 fixes; there an operation on the server that does
> not come from nfsd waits for the recall for up to two lease periods, as
> it already does, without a limit, for a client that keeps answering
> NFS4ERR_DELAY. Patch 2 uses nfsd_thread_local_info and needs adapting
> where that is missing.
>=20
> Tests. QEMU guests on one host: an nvmet-tcp target, the server (nfsd,
> XFS on the nvmet namespace, pnfs export) and up to three clients, all
> on the same kernel with KASAN and lockdep, NFS v4.2, block layout
> unless noted, O_DIRECT I/O. "v2" is this series on nfsd-testing
> 56589cdb5881, "v1" is v1 on it, and "before" is that commit unless
> noted. No KASAN or lockdep report on the server in any run, nor on the
> clients and the target in tests 2, 3 and 5, where they were checked.
>=20
> 1. nfsd threads (patch 2), 4 nfsd threads. A client holds a layout of
>    a file and its path to the device is cut for 70 s. Another client,
>    without pNFS, sends 4 KiB WRITEs to the file through the server, all
>    at once, and reads 4 KiB of another file every second:
>=20
>                                             before     v1        v2
>    8 WRITEs, NFSv4.0: the WRITEs take       46.7 s     -         45.2 s
>      longest read of the other file         46.7 s     -         0.031 s
>    64 WRITEs, NFSv4.0: the WRITEs take      -          49.2 s    45.4 s
>      longest read of the other file         -          49.1 s    0.22 s
>    8 WRITEs, NFSv3: the WRITEs take         47.0 s     -         51.2 s
>      longest read of the other file         46.9 s     -         0.021 s
>=20
>    The WRITEs wait for the lease break, which ends with
>    /sbin/nfsd-recall-failed (patch 4). NFSv3 WRITEs take longer with
>    v2 because the client waits 5 s after NFS3ERR_JUKEBOX. In the run
>    with 64 WRITEs before this series, the recall failed after 10 ms, as
>    described above, and the WRITEs were done in 0.5 s.
>=20
> 2. What patch 2 costs. Two clients write 1 MiB blocks to a new file for
>    30 s, one through its layout and one (NFSv4.0) through the server,
>    three runs. "+ follow-up" adds the nfsd series that goes on top of
>    this one and an NFS client fix that it needs.
>=20
>                       through the     of those, read      through the
>                       layout          back as zeroes      server
>    before             416/200/186     28/131/111          120/325/323
>    v2                 174/176/170     0/0/0               184/203/220
>    v2 + follow-up     170/175/176     0/0/0               284/223/207
>=20
>    The 30 ms wait is what keeps the writer through the server going:
>    two earlier revisions of v2 + follow-up that differ only in it gave
>    79/79/80 blocks through the server without the wait and 238/230/137
>    with it.
>=20
>    One client doing both, 1 MiB blocks through its layout and 512 byte
>    writes through the server:
>=20
>                       through the     of those, read      writes through
>                       layout          back as zeroes      the server
>    before             534/537/505     7/4/20              32/21/87
>    v2                 48/46/4         0/0/0               3600/3262/4917
>    v2 + follow-up     193/192/184     0/0/0               1082/1488/1669
>=20
>    With v2 alone, each WRITE of that client through the server recalls
>    its layout. About half of its LAYOUTGETs then meet that recall and
>    get NFS4ERR_RECALLCONFLICT, as before; the other half are in
>    progress when the WRITE breaks the lease, and patch 1 fails them.
>    The Linux client waits up to 15 s between LAYOUTGETs that fail with
>    NFS4ERR_RECALLCONFLICT. The follow-up hands out the layout of such a
>    LAYOUTGET and recalls it at once. That needs the referring call the
>    follow-up adds to CB_LAYOUTRECALL: tried in this series, the recall
>    overtook the LAYOUTGET reply, and in all three runs 92 to 104 of
>    about 260 blocks read back as zeroes.
>=20
>    On 214e388464bf, before and v2 gave the same picture, except that in
>    one of three runs of the one-client case with v2 one block read back
>    as zeroes, through the recall race described under "Not changed".
>=20
>    The series applies to nfsd-testing c32fef6c476d unchanged, and there
>    before and v2 gave the same picture again, also for NFSv3, whose
>    replies now come from xdrgen. In test 1 the longest read of the
>    other file was 47.8 s before and 0.036 s with v2 over NFSv4.0, and
>    48.3 s and 0.019 s over NFSv3, where the WRITEs took 48.4 s and
>    51.3 s. In this test, with two clients, 48, 94 and 90 of 180, 185
>    and 181 blocks through the layout read back as zeroes before, and
>    none of 161, 177 and 172 with v2; with one client, 8, 0 and 3
>    before and none with v2.
>=20
>    Writes to a file without leases: fio, NFSv4.0, no KASAN or lockdep,
>    10 runs of 30 s, medians without and with an earlier revision of v2
>    (the same path for such a file): 1 MiB sequential 65.8 and 67.5
>    MiB/s, 4 KiB random 262 and 263 IOPS.
>=20
> 3. Recall polling (patches 3 to 6). With v2 no recall ended in the
>    failure path (0 of 9, 9, 63 and 277 in the arms of patch 5) and no
>    block written to a new file was lost (0 of 545, 511, 477, 577 and
>    36). Patch 5 has the runs before.
>    On c32fef6c476d, four of those arms lost 4, 2, 18 and 9 blocks
>    before, with 46 recall failures logged, and none with v2, with no
>    recall failure.
>=20
> 4. One client writing through a block layout whose path to the device
>    is cut while it can still talk to the server, and a 4 KiB write to
>    the file on the server ("before" of the 15 s case is 32eb1a60b456).
>    The client's write that is in flight stays stuck until the path is
>    back.
>=20
>                                                    before      v2
>    path cut for 15 s: the server write takes       0.05 s      15.6 s
>      the recall                                    fails       completes
>      /sbin/nfsd-recall-failed is run               at once     no
>    path cut for 70 s: the server write takes       0.05 s      47.2 s
>      /sbin/nfsd-recall-failed is run               at once     at 47.1 s
>=20
>    The same 70 s case with a script that expires the client it fences
>    through /proc/fs/nfsd/clients/<clid>/ctl: with v1's fence worker,
>    which runs the script itself, the script never finished and the
>    server write went on only after the path was back, after 93 s. With
>    v2 the script was done 36 ms after it started, and the server write
>    took 46.1 s. With a lease time of 15 s, the recall reaches its limit
>    (patch 3) after 30 s, before the lease break times out, and the
>    recall failure path runs the script: there it hangs with v2 as well,
>    the script in nfsd4_shutdown_callback() and rpciod in
>    call_usermodehelper_exec().
>=20
> 5. A lease break during a LAYOUTGET (patch 1). With v2 the longest of
>    424 writes on the server took 55 ms, and 108 ms with a delay of
>    100 ms added to LAYOUTGET for the test. Patch 1 has the runs without
>    it.
>=20
> 6. SCSI layout. The target runs a kernel with "nvmet: fix preempt of
>    another registrant by the reservation holder" [1], so that the
>    preempt removes the registration. With v2, the path of a client cut
>    for 15 s: the server write takes 15.2 s and the client is not
>    fenced; cut for 70 s: 47.6 s, and the fence worker fences the client
>    (registrants 2 -> 1).
>=20
> pynfs BLOCK1, BLOCK2, BLOCK4 and BLOCK5 pass before and with v2 (BLOCK3
> fails in both with a TypeError in the test). The commit messages of
> patches 6 and 7 have pynfs clients that answer as described there.
>=20
> Not changed by these patches:
>=20
> - A layout granted between the check of patch 2 and the break in XFS
>   still makes the nfsd thread wait. No new layout lease is granted
>   while a break is pending, so that needs a LAYOUTGET for a file that
>   had no layout at the check. An asynchronous COPY runs in its own
>   kthread and still waits there.
>=20
> - The recall failure path still runs /sbin/nfsd-recall-failed from
>   nfsd4_cb_layout_done(), in rpciod, while the callback is in flight.
>   A script that expires the client it fences hangs there, because the
>   teardown waits for that callback in nfsd4_shutdown_callback(); test 4
>   shows it. Neither path looks at the exit status of the script, and
>   the recall failure path does not look at the result of
>   ->fence_client(): a fence that fails is taken as done there, and the
>   layouts it drops end the retries of a fence worker that a lease break
>   has started (patch 3 says so).
>=20
> - nfsd still polls a client that has answered NFS4_OK with the seqid it
>   has used, where RFC 8881 section 12.5.3 has the server increment the
>   seqid in each request. Patch 5 only makes nfsd bear the answer
>   (patch 6 gives a new seqid only to a client that has not answered
>   NFS4_OK), and while it polls, nfsd sends a callback every 10 ms for
>   up to two lease periods.
>=20
> - CB_LAYOUTRECALL carries no referring call, as CB_RECALL does since
>   "NFSD: Send referring calls with CB_RECALL". When a recall overtakes
>   the reply to the LAYOUTGET that created the layout stateid, the Linux
>   client answers NFS4ERR_NOMATCHING_LAYOUT, nfsd drops the layout and
>   the client uses it afterwards. nfsd also trusts
>   NFS4ERR_NOMATCHING_LAYOUT while it still has layouts on the layout
>   stateid. The series on top of this one adds the referring call and
>   resends the recall once before it trusts that answer, and with it
>   recalls a layout handed out by a LAYOUTGET that a lease break met,
>   instead of failing that LAYOUTGET (see test 2).
>=20
> - Which client makes progress when several clients use one file: the
>   client that holds a layout now keeps it while it does I/O through
>   it, where before its layout was revoked after 10 ms. Nothing here
>   limits how long one client can keep others out.
>=20
> [1] https://lore.kernel.org/r/20261002065931epcms2p1cb2c16f98cf3b05f8c859=
ad92b0ad465@epcms2p1
>=20
> ---
> Changes in v2:
> - New patch 2, which recalls the layouts without waiting before an
>   operation that modifies the file and answers NFS4ERR_DELAY, as Chuck
>   asked:
>   https://lore.kernel.org/r/63ef8d7c-086f-4cc8-84bb-72c1b23bf596@slotpi15=
m67
> - v1 4/6 is now patch 1, ahead of patch 2, which makes its case common.
>   v1 1/6 to 3/6 are patches 3 to 5, v1 5/6 and 6/6 are patches 6 and 7.
> - Sashiko on v1:
>   - 2/6, the fence script waiting for itself when it expires the client
>     through /proc/fs/nfsd/clients/<clid>/ctl: patch 4 runs the script
>     in a work item on a new workqueue, nfsd4_fence, and the fence
>     worker checks every 100 ms whether it is done. Teardown waits only
>     for the fence worker, which no longer waits for the script.
>   - 2/6, sleeping fence workers filling system_dfl_wq: the same change;
>     a script that runs long occupies nfsd4_fence.
>   - 3/6, ktime_get() stops during suspend: patch 3 takes the time with
>     ktime_get_boottime().
>   - 5/6, si_generation written under sc_lock in ->done and read under
>     ls_mutex only: patch 6 reads it under sc_lock in
>     nfsd4_preprocess_layout_stateid() as well.
>   - 1/6, the result of ->fence_client() not looked at on the recall
>     failure path, which also ends the retries of the fence worker: not
>     changed, said in patch 3. Patch 3 makes the path reachable after two
>     lease periods for a client that keeps answering; before, a client
>     from v6.8 on reached it after 10 ms.
>   - 2/6, the exit status of the script not looked at: not changed.
>     Retrying a failed script would block the file for good on a server
>     that has no /sbin/nfsd-recall-failed. Said in patch 4.
>   - 6/6, NFS4ERR_NOMATCHING_LAYOUT trusted while layouts are left:
>     preexisting, not changed here (see the list above).
> - Rebased onto nfsd-testing c32fef6c476d without changes, and tests 1
>   to 3 run again there.
> - Test numbers in the cover from v2; the commit messages of patches 1,
>   4 and 5 keep their runs on nfsd-testing 32eb1a60b456 for the side
>   without the patch. Commit messages with one space after a period.
> - Link to v1: https://lore.kernel.org/r/20261006-nfsd-layout-recall-v1-0-=
b59b31caf342@samsung.com
>=20
> ---
> Daejun Park (7):
>       nfsd: fail a LAYOUTGET in progress when the layout lease is broken
>       nfsd: answer NFS4ERR_DELAY instead of waiting for a layout recall
>       nfsd: make the time limit of a layout recall work
>       nfsd: run the fence script when a block layout lease break times ou=
t
>       nfsd: keep polling a layout recall answered with NFS4ERR_OLD_STATEI=
D
>       nfsd: poll a layout recall with a new seqid when the client is past=
 it
>       nfsd: do not fence a client for a layout recall with no layouts lef=
t
>=20
>  fs/nfsd/nfs4layouts.c | 301 ++++++++++++++++++++++++++++++++++++++++++++=
++----
>  fs/nfsd/nfs4proc.c    |   8 ++
>  fs/nfsd/pnfs.h        |  15 +++
>  fs/nfsd/state.h       |   8 ++
>  fs/nfsd/trace.h       |   2 +
>  fs/nfsd/vfs.c         |  81 +++++++++++++-
>  fs/nfsd/vfs.h         |   1 +
>  7 files changed, 391 insertions(+), 25 deletions(-)
> ---
> base-commit: c32fef6c476daa5830f600614657baee59c83339
> change-id: 20261006-nfsd-layout-recall-ba868d33371e
>=20
> Best regards,

I think 5 and 6 should be squashed together, but the series itself
looks fine. Nice work!

Reviewed-by: Jeff Layton <jlayton@kernel.org>
