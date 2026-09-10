Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4A97C52B1C4
	for <linux-nfs@vger.kernel.org>; Thu, 10 Sep 2026 17:25:41 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789061154; cv=none; b=b6g7aOdlbkhSmb3XnOGLc50iWtWdoxrHDFweJ3KoI1kpmiEYEWf9sMQ1qGGzNbkZhpToP2hDYdxijpR3qICWqlJS0w5MzPZDpfEoRuIIqcYrlf/tjKkrG3cMntTCd++ZWrmD29rU6h/iLoorR6EwklBRWpzRYIVivqPWOuPCeFY=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789061154; c=relaxed/simple;
	bh=9ZJVHYyvz+pKG7dAH7pqvqBLb3vn3FnLaKsDRrUu2/M=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=a5YASYpnxS91/oG1ppo/hakH79jF5PLX43sZmaw9x4M8bJ//jR/gg5WBkz1g1AlOKNc/R46AnKnuuWw2S23FvxD4r5LtkGT7o4dQIWmXD4GO4cHEAYlm161Gvk7IuhbSrqPdKUkSFp+AKJOVjK9qdNa5+TJakvDLptoyW7pwT8I=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lab7ax1U; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lab7ax1U"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 5B4DF1F000FF;
	Thu, 10 Sep 2026 17:25:38 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1789061139;
	bh=ozE0/uTgwltuTBr2jHI3bdbKtCX/2ZVqrDU3RU8fdzI=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lab7ax1UUet0k8K9W3ZHtIhtKbjy0or2RjQvG+1t8a3gnOPMlVE7yiCcwpPt9vnHt
	 D/k4dPky5RY4WmUCH2VCqk9BxUG+4cLm/dPgib3DzPq4yFmF6pH1TcUYczT3PrvNUE
	 XAw7TofPr0er1ysd2p7akpJGvSs6sOLeZiIboKhwyj1MxnYHNkIebuchO7CvHSzgzd
	 Aa0r22B5NDRqghvhH+W3f11xLstzuHiEj5RG6WEXPhgsoFJzBIt14wGMsE3fxBZEs2
	 q0ptKsl5zOs65FxR7QnnB8FineyuNS5LSLdCf83PjG72j9DsJt/ypkWY52mF5xhWsj
	 Dd5n9PHl7pMNA==
Message-ID: <bf2256fabd3190f08232033561f2ec374440a1bd.camel@kernel.org>
Subject: Re: [PATCH v3 00/12] Improve the scalability of NFSD's classic DRC
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Date: Thu, 10 Sep 2026 13:25:36 -0400
In-Reply-To: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
References: <20260910-duplicate-reply-cache-v3-0-31532a4c7449@kernel.org>
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

On Thu, 2026-09-10 at 09:54 -0400, Chuck Lever wrote:
> A completed DRC entry currently stays in its bucket for 120 seconds
> whether or not the client already holds the reply. On a busy server
> those entries lengthen every bucket walk, and under pressure they
> crowd out entries a retransmit could still hit.
>=20
> This series modifies the DRC to retire an entry once there is reason
> to believe its reply was delivered.
>=20
> 1. The transport reports delivery outright where it can. TCP now
>    reports when snd_una passes the reply's sequence number, and RDMA
>    reports on each Send completion.
> 2. Where no report will come, a later request on the same connection
>    stands in as an implied ACK, since a client on a live TCP or RDMA
>    connection does not retransmit within it (RFC 1813 Section 4.5).
>=20
> UDP continues to use a traditional time-based eviction mechanism.
>=20
> The first mechanism is the more reliable of the two, and the backup
> mechanism is more of an informed guess. A pipelined client sends its
> next request before the previous reply lands, and an entry evicted
> in that window is lost if the connection then drops and the client
> retransmits. In the current NFSD code, memory pressure and RC_EXPIRE
> already open this same window. For instance, on a server with fast
> networking and storage, pressure eviction already evicts entries far
> younger than 120 seconds.
>=20
> Two DRC capacity guards that were sized for a cache full of stale
> replies can be removed, now that reply delivery reports keep the DRC
> small. The commit messages for those patches explain the rationale
> in detail.
>=20
> v2 of this series (implied ACK only) was profiled with "perf record
> -e cycles -e cpu-clock -e LLC-load-misses -e branch-misses" during
> an NFSv3/RDMA 4KB random-write workload. v3 has not been re-profiled.
> nfsd_cache_lookup overhead dropped from 1.53% to 0.76% of CPU
> cycles during this test. The rb-tree operations (rb_erase,
> rb_insert_color) that dominated LLC cache misses fell from a
> combined 13.2% to 1.1% of all LLC-load-misses, because shorter-lived
> entries keep the per-bucket trees small.
>=20
> ---
> Changes in v3:
> - Add the reply-acknowledged callback and its TCP and RDMA reporters
>   ahead of implied ACK, which now defers to a pending report.
> - Split the prune-loop restructure into its own patch.
> - Move the eviction tracepoints ahead of the ack patches; the
>   implied-ACK event now lands with implied ACK.
> - Keep err local to the pmap_register block in svc_setup_socket()
>   (per Jeff's review).
> - Never move xpt_last_recv backwards when nfsd threads race.
> - Fold the XPT_ORDERED patch into its consumer (per Jeff's review).
> - State the re-execution exposure of implied-ACK eviction instead of
>   calling the DRC advisory (per Jeff's review).
> - New patch: remove the DRC request checksum and payload_misses stat.
> - New patch: remove the 256k-entry cap on the DRC size.
> - Link to v2: https://patch.msgid.link/20260828-duplicate-reply-cache-v2-=
0-25069e660a7b@kernel.org
>=20
> Changes in v2:
> - Print the DRC eviction tracepoints' age field as unsigned.
> - Link to v1: https://patch.msgid.link/20260826-duplicate-reply-cache-v1-=
0-b1d51e1af5c7@kernel.org
>=20
> ---
> Chuck Lever (12):
>       SUNRPC: Assign a unique identifier to each svc_xprt
>       NFSD: Track transport in DRC entries
>       NFSD: Prepare bucket pruning for out-of-order eviction
>       NFSD: Add tracepoints for DRC entry eviction
>       NFSD: Record DRC population in lookup tracepoints
>       NFSD: Add reply-acknowledged callback infrastructure
>       SUNRPC: Add TCP sequence-number ACK tracking for reply delivery
>       svcrdma: Fire reply-acknowledged callback on Send completion
>       SUNRPC: Record last-request timestamp on svc_xprt
>       NFSD: Evict unacknowledged DRC entries via implied ACK
>       NFSD: Remove DRC checksum and payload_misses stat
>       NFSD: Remove hard cap on duplicate reply cache size
>=20
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +-
>  fs/nfsd/cache.h                                    |  20 +-
>  fs/nfsd/netns.h                                    |   2 -
>  fs/nfsd/nfscache.c                                 | 310 +++++++++++++--=
------
>  fs/nfsd/nfssvc.c                                   |  20 +-
>  fs/nfsd/stats.h                                    |   5 -
>  fs/nfsd/trace.h                                    |  81 +++++-
>  include/linux/sunrpc/svc.h                         |  51 ++++
>  include/linux/sunrpc/svc_rdma.h                    |   1 +
>  include/linux/sunrpc/svc_xprt.h                    |   6 +-
>  include/linux/sunrpc/svcsock.h                     |  10 +
>  include/trace/events/sunrpc.h                      |  10 +-
>  net/sunrpc/netns.h                                 |   4 +
>  net/sunrpc/sunrpc_syms.c                           |   2 +
>  net/sunrpc/svc.c                                   |   1 +
>  net/sunrpc/svc_xprt.c                              |  53 +++-
>  net/sunrpc/svcsock.c                               | 119 +++++++-
>  net/sunrpc/xprtrdma/svc_rdma_sendto.c              |  14 +
>  net/sunrpc/xprtrdma/svc_rdma_transport.c           |   7 +-
>  19 files changed, 541 insertions(+), 186 deletions(-)
> ---
> base-commit: abf2077ee32058e60d3f49ecab265d3c4bd953d9
> change-id: 20260325-duplicate-reply-cache-f0fe7c7b740c
>=20
> Best regards,
> -- =20
> Chuck Lever <cel@kernel.org>

I like the idea overall. I'm still a bit nervous that might see a non-
idempotent operations fail occasionally, since this is aggressively
expiring them, but let's see how it does.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
