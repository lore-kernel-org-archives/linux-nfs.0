Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id C916A3B6C15
	for <linux-nfs@vger.kernel.org>; Fri, 16 Oct 2026 11:18:17 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1792149499; cv=none; b=VQMXmCjBi6Yk5ZWtzUy9lmX3radBhgfgOrHrHhozZFd/fGW9fqgJJNz2/LjL2HD5vH+31yGYgvU5zAzE5X2y0dXh+qkYRM/g9scJhtio0iPO5jjxG2nLz21lPEt+SrHVf9QYG55xexnTps+cdVayQ8vLNcKZub536qnxGHvZD+M=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1792149499; c=relaxed/simple;
	bh=G2feSMjmmvFgFba/626eVKnxJau39YEFGdcxjGZOfdI=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=ZEqaVwlBAkeAEHQniJ7p5QDj2WVUsxcw9Bf3EfcYtWdHMCF1k0+W+fGiYV7/LzMY7b0GvIy54vRw7GUiB6KJkjoSklotWN76NXfERAGDHbDIuBnkTOdMwd+zma7Ed4lcuBFedHQzFJ84l7T3aSX0qMoUnQ5iaZrFe0Hn6MiCVDw=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=lGun4XNF; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="lGun4XNF"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 887B51F000C4;
	Fri, 16 Oct 2026 11:18:16 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792149497;
	bh=aQmVzZIVo4Cy0sgPzXllYD8IK37O7VSIcN/u0dlrwMg=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lGun4XNFnUSytMvv4V3VHsZlLlnPY2nQJPm8i8Ukvi4yKZwFX3EwZI7U8jBNJ6yaT
	 iyKM3XA3nbK99GFd1bBFLjIwP6y8jeOmUWDDVp+r7bxUJaULB1yBO+Ol8wY8Lp6HeX
	 /wTdfC0UB5PXhh+QW5olgD1O6+1Zq9VCQIlGfH3QJQMZYepjq1RZdbHHEhdo4B3K/R
	 ZkPUmZ0890ZZEP2owXaIUnbOa73MtWTq4F/ZmgG+98PWGNR123oc481BrHWHDbMHk1
	 pVoRVjvUSWXsJEzl3CR+7D2EwI8b5U6D2N3Pz7yzcOmdm7mozYfxva/T4jtr0DFGYl
	 HaSFoqXrNnTWA==
Message-ID: <224b94f6797ab29cde44f37b4145778829bc41c8.camel@kernel.org>
Subject: Re: [PATCH v4 00/10] NFSD: keep direct-mode I/O out of the page
 cache
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>, 	linux-mm@kvack.org
Date: Fri, 16 Oct 2026 07:18:13 -0400
In-Reply-To: <20261015233309.42999-1-snitzer@kernel.org>
References: <20261015233309.42999-1-snitzer@kernel.org>
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

On Thu, 2026-10-15 at 19:32 -0400, Mike Snitzer wrote:
> Hi,
>=20
> This series refines the heuristics NFSD_IO_DIRECT already uses, mostly
> on the WRITE path and in one corner of the READ path: the io_cache_write
> and io_cache_read modes where an aligned request goes to the filesystem
> as O_DIRECT, with DONTCACHE for the parts a misaligned WRITE cannot issue
> directly.
>=20
> It does not knowingly undercut anything the existing upstream code is
> built on.  An aligned WRITE is still one O_DIRECT write and an aligned
> READ is still one O_DIRECT read.  A misaligned WRITE is still split into
> a direct middle and buffered ends, and by default those ends are still
> DONTCACHE where the filesystem supports it.  io_cache_read and
> io_cache_write mean what they did, and nothing new is asked of the
> filesystem.  What changes is where the split is cut and when it is worth
> making, which READs are worth expanding, how often a synchronous WRITE
> is persisted, and what happens to the page two misaligned WRITEs share.
>=20
> 1/10 is a stable fix.  A misaligned WRITE is split into a direct middle
> and buffered ends, and the middle was cut at the filesystem's DIO offset
> alignment.  Where the page is larger than that alignment (16 and 64 KiB
> pages over 4096-byte blocks, or 4 KiB pages over 512-byte blocks) the
> middle then starts or stops inside the page a buffered end writes, its
> invalidation drops that page, and whichever of the two neighbouring
> WRITEs comes second reads it back from the device.  A misaligned end is
> now cut at a multiple of the larger of the alignment and the page size.
> An end that is already DIO-aligned gets no buffered segment and stays
> where it is, so a DIO-aligned WRITE is still issued direct on every page
> size.  Such an end can share its page with a buffered neighbour, but
> NFSD's direct WRITEs are synchronous and XFS holds its IOLOCK across
> iomap_dio_rw(), the page cache invalidation after the write included,
> so the neighbour cannot dirty that page in between and make the
> invalidation fail.
>=20
> 2/10 also marks the direct middle IOCB_DONTCACHE, for when XFS
> re-issues it as buffered I/O (-ENOTBLK) because something else has
> dirtied page cache in its range, such as a local process writing the
> exported file through mmap, which XFS's IOLOCK does not keep out.
>=20
> 3/10 splits a misaligned WRITE only for a direct middle of at least
> direct_misaligned_min_bytes (debugfs, default 8192), and moves the
> segment flag decisions into nfsd_write_dio_iters_init(), both from
> Christoph's suggested diff.  The threshold counts bytes: with 1/10 a
> split WRITE's middle is whole pages, and a threshold of two pages would
> demand a 32 KiB middle on 16 KiB pages and 128 KiB on 64 KiB pages.
>=20
> 4/10 (Jonathan) adds direct_misaligned_dontcache (default Y), which
> selects whether the parts that are not O_DIRECT are DONTCACHE or
> cached.
>=20
> 5/10 stops expanding a READ smaller than its alignment into one or two
> whole aligned device reads.  The check sits in nfsd_direct_read_ok(),
> beside the last-operation-in-COMPOUND check now in nfsd-testing.
>=20
> 6/10 persists a FILE_SYNC or DATA_SYNC WRITE that is split, or issued
> buffered, once after all of its segments, instead of once per segment:
> one fsync where there were up to three.  A WRITE issued whole as
> O_DIRECT keeps IOCB_DSYNC, so iomap can still complete a DATA_SYNC
> overwrite with FUA writes.
>=20
> 7/10 is an mm patch: folio_mark_dropbehind() marks an existing folio
> dropbehind and keeps WB_DONTCACHE_DIRTY balanced when the folio is
> already dirty, as folio_mark_dirty() does for PG_dirty where
> folio_set_dirty() only sets the flag.  Marking an already dirty folio
> with folio_set_dropbehind() instead drives the counter negative, and
> the DONTCACHE writeback kick then stops writing anything back for every
> writer on that bdi_writeback.
>=20
> 8/10 is also mm: it reports WB_DONTCACHE_DIRTY in the bdi debugfs stats,
> as BdiDontcacheDirty and per bdi_writeback as WbDontcacheDirty, summed
> over the per-cpu batches since the flusher targets the summed value.
> The counter drives the DONTCACHE writeback kick but was not reported
> anywhere; this is how the balance 7/10 keeps was observed.  It carries
> Fixes: for the commit that added the counter.
>=20
> 7/10 and 8/10 are Cc'd to linux-mm and need an mm ack.
>=20
> 9/10 calls folio_mark_dropbehind() to keep the page two misaligned
> WRITEs share until both have written it, with no state in NFSD: 704
> device reads for 42895 WRITEs where there were 45144 for 45664
> (47008-byte records, 32 interleaved writers, 4 KiB pages), and on a
> four-server pNFS flexfiles rig 0.003 device reads per record instead of
> 0.014-0.015, about 2.9 GiB of page-cache growth instead of 11 GiB, and
> 2.4% to 4.9% more write throughput.
>=20
> 10/10 adds tracepoints for how each direct-mode READ and WRITE was
> serviced, and why a WRITE was not issued direct.
>=20
> The series applies to cel/nfsd-testing (78c334bc5ae6) and each patch
> builds with W=3D1 with no warnings.
>=20
> Changes since v3:
> - Dropped "NFSD: Enable return of an updated stable_how to NFS
>   clients" and "NFSD: add direct-mode WRITE settings that persist each
>   WRITE" (v3 8/9 and 9/9).  The rest of the series does not depend on
>   them.
> - New 1/10, NFSD: cut a misaligned direct-mode WRITE at page
>   boundaries (Cc: stable).  v3 cut the direct middle where the DIO
>   offset alignment falls, which is a page boundary only when that
>   alignment is the page size.
> - Rebased onto the current cel/nfsd-testing.  5/10's size check moved
>   into nfsd_direct_read_ok().
> - Descriptions, comments and nfsd-io-modes.rst corrected throughout,
>   among them: 2/10 says what can still make XFS re-issue the middle
>   buffered once 1/10 keeps it off the pages the buffered ends share;
>   3/10 says why a WRITE misaligned in memory is not split; 4/10 no
>   longer misstates what the split threshold decides.
> - 3/10: the threshold is direct_misaligned_min_bytes (default 8192)
>   instead of direct_misaligned_num_pages (default 2).  On 4 KiB pages
>   the default is unchanged.  The debugfs file is renamed with its unit,
>   so a value written to the old name is not read as bytes.
> - 6/10: a WRITE issued whole as O_DIRECT keeps IOCB_DSYNC; v3 turned a
>   DATA_SYNC overwrite into a plain write plus an fsync.
> - New 7/10, mm: add folio_mark_dropbehind().  v3 marked an already
>   dirty folio dropbehind directly; the clean that follows subtracts it
>   from WB_DONTCACHE_DIRTY, which never counted it, so the counter
>   drifted negative and stopped the DONTCACHE writeback kick for the
>   whole bdi_writeback.
> - New 8/10, mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats.  Reports
>   the counter 7/10 keeps balanced; Fixes: Jeff's commit that added it.
> - 9/10: claims a page only where a buffered segment covers it partly, at
>   either end of any segment, so a multi-page start or end segment and a
>   sub-page WRITE are handled; claims for a split WRITE at any DIO offset
>   alignment, since 1/10 keeps the direct middle out of the claimed
>   pages; does not claim when the mapping's minimum folio is larger than
>   a page; allocates with __GFP_WRITE; does not mark a page a short
>   write did not reach; a FILE_SYNC or DATA_SYNC WRITE marks its shared
>   pages after its own fsync, when they are clean, so they are not
>   counted as DONTCACHE dirty and do not wake the writeback kick.  The
>   description no longer says marking must not be accounted or that the
>   kick targets marked folios.
> - 10/10: the DONTCACHE state is its own tracepoint argument instead of a
>   bit ORed into the disposition (nsegs is dropped; it follows from the
>   segment sizes); the redundant #include "vfs.h" is gone;
>   NFSD_WRITE_DIO_NO_ALIGN is renamed NFSD_WRITE_DIO_NO_ALIGNMENT to
>   match its string; mem_offset is 0 for a WRITE with no payload.
>=20
> v3: https://lore.kernel.org/linux-nfs/20261001045502.48381-1-snitzer@kern=
el.org/
> v2: https://lore.kernel.org/linux-nfs/20260929231329.22018-1-snitzer@kern=
el.org/
> v1: https://lore.kernel.org/linux-nfs/20260929173423.16149-1-snitzer@kern=
el.org/
>=20
> Thanks,
> Mike
>=20
> Jonathan Flynn (1):
>   NFSD: add direct_misaligned_dontcache debugfs knob
>=20
> Mike Snitzer (9):
>   NFSD: cut a misaligned direct-mode WRITE at page boundaries
>   NFSD: mark the direct middle of a split WRITE IOCB_DONTCACHE as well
>   NFSD: only split a direct-mode WRITE for a worthwhile direct middle
>   NFSD: do not use direct I/O for a READ smaller than its alignment
>   NFSD: persist a synchronous direct-mode WRITE once, after all of its se=
gments
>   mm: add folio_mark_dropbehind() to mark a folio dropbehind and account =
it
>   mm: expose WB_DONTCACHE_DIRTY in bdi debugfs stats
>   NFSD: keep boundary page of a split direct-mode WRITE until both writer=
s complete
>   NFSD: add tracing for how direct-mode READ and WRITE are serviced
>=20
>  .../filesystems/nfs/nfsd-io-modes.rst         |  93 +++++-
>  fs/nfsd/debugfs.c                             |  25 ++
>  fs/nfsd/nfsd.h                                |   2 +
>  fs/nfsd/trace.h                               |  77 +++++
>  fs/nfsd/vfs.c                                 | 265 +++++++++++++++---
>  fs/nfsd/vfs.h                                 |   9 +
>  include/linux/pagemap.h                       |   1 +
>  mm/backing-dev.c                              |  11 +
>  mm/filemap.c                                  |  31 ++
>  9 files changed, 473 insertions(+), 41 deletions(-)
>=20
>=20
> base-commit: 78c334bc5ae61d23ca1cc2e43079c620f1d40866

I think this all looks good and should be good optimizations.

I take back what I said earlier about splitting the mm: patches out --
you do need the new helper for the later patches in the series. It's
fairly self-contained though so maybe it's not a big deal to carry #7
in the nfsd tree. Note that sashiko has some comments about a potential
race there too. #8 seems like it should go via mm tree though.

The other thing we should consider is whether to make the new controls
you're adding to debugfs into netlink controls instead. I see no reason
not to do that and it'll save us from having to convert them later.
--=20
Jeff Layton <jlayton@kernel.org>
