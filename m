Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792494467;
	b=WO7Q+Gk5+ZXw/pST53Na70n4KcjiytZqXF48YVE1lQT72ervvvlSBY4C4dSWZmm+/6m3
	 Z+dF0ZbGFfpBHCrLJLCO7dzWMnunTIIbcrtCYl/FK0yiW/VXPJjt995eEYTfbn6lcEOb5
	 XIdNV6aE5/fn/XJxJBJxs93NBJl7z3O3xPL0PXyT4NxfKA+O4YowIY9D16TlrgdasagjE
	 Qi5DW5Ld61LtmvTByPqI24qCfDUB7BI9XxQF1sQf7h+4UkA2l9QU4LVHHuL/ROaz5LZbJ
	 xE6t4wEVyUMMNy8Zgh2Gfutp+IijHXwyi5AlUrMSR7z9OPPmN3PyaHkLj5phFqb8hsA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792494467;
	h=Received:DKIM-Signature:Message-ID:Subject:From:To:Cc:Date:
	 In-Reply-To:References:Autocrypt:Content-Type:
	 Content-Transfer-Encoding:User-Agent:MIME-Version;
	bh=oZQLgCuJulD2aVY0I2LoRWU6Y5Nf/0Zb4P/CsQXIHvU=;
	b=Sl0Ejg372mvq4XJ/GxIgkg4CDl2cd9BFImGgAWQDew4YBXJsLrz/ilkPBe6cGwi8pSdf
	 cibu8M21oH7W1ygICXuTqpa1P7HuBAMHMUBPqUfa+eiJCGm3ZMcGZKz1RpWKml1I8z6FS
	 yfldpxUpVtwk/lPXrz5/yHS4tY/f7c6z5C5FN4mPimZ5G9Mov/7zERnpTfxAlH6AkWC7w
	 yA8EDScVx4a6tHVDS+xq1o6osxKaiBhZHXdQkRJuuYpqn2SNn0salRB/C0KFlCFa4GwsR
	 Hk35GmZPcAGxjLJuCdqlQh8spGtrQu0wmeiUn9WHvub/nuj7lLmq8cAbOCiH7nGMKeQ==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lbG2ed6j;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id D1876606A324;
	Tue, 20 Oct 2026 11:07:46 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=lbG2ed6j
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 6021E1F000C4;
	Tue, 20 Oct 2026 11:07:45 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792494466;
	bh=oZQLgCuJulD2aVY0I2LoRWU6Y5Nf/0Zb4P/CsQXIHvU=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=lbG2ed6jJ9jctSH8b7yM3FwODCZpnGH7BxbiOea5zjgTwhqc90H/JeDW7NUizd6r/
	 95KUuVmiyrX6h/sDsKXqwumkKPtRc2pUWIC0dGB5XT0xgWpo8UvfFUY3OjdmakJCTO
	 asHGwFIaViELw5Yhh4EKn8HY6kjc7iZQjYL2f+AX4rkovkO0qBma6CwdJJdeLk1y1w
	 sWebjZANt1SZ8/s68NML0wiub4gwpC7vmaREEGUlDhUSfPJk1MRhXK9SmZbyo93uYW
	 cLyVQ2aOLKbsLdeBoscYaAQn3Rs4trNbwvBJMNojXc/bYzABaDwHPaouVAewISy+7D
	 r33TGBPY9xrtg==
Message-ID: <67e8332fe738444495c2c6fdd447b585aebdb833.camel@kernel.org>
Subject: Re: [PATCH draft-v6 1/6] NFSD: add tracing for how direct-mode READ
 and WRITE are serviced
From: Jeff Layton <jlayton@kernel.org>
To: Mike Snitzer <snitzer@kernel.org>, Chuck Lever <cel@kernel.org>
Cc: linux-nfs@vger.kernel.org, NeilBrown <neil@brown.name>, Olga
 Kornievskaia	 <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>,  Christoph Hellwig	 <hch@lst.de>, Jens Axboe
 <axboe@kernel.dk>, Matthew Wilcox <willy@infradead.org>, 
	linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Date: Tue, 20 Oct 2026 07:07:43 -0400
In-Reply-To: <atbfEbgMU6UGkn2X@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
	 <20261019150725.1507-2-snitzer@kernel.org>
	 <f39bfe92-8676-4241-bb4e-bccd838ab99b@slotpi15m67>
	 <atbfEbgMU6UGkn2X@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
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

On Mon, 2026-10-19 at 23:25 -0400, Mike Snitzer wrote:
> On Mon, Oct 19, 2026 at 02:33:47PM -0400, Chuck Lever wrote:
> > On Mon, Oct 19, 2026, at 11:07 AM, Mike Snitzer wrote:
> > > Add:
> > >=20
> > >  - nfsd_write_dio_split, emitted once per direct-mode WRITE before an=
y
> > >    segment is issued.  It records the advertised offset and memory
> > >    alignments, the payload's offset within its first page, the start,
> > >    middle and end segment sizes, a disposition naming the path taken
> > >    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
> > >    whether buffered segments are issued IOCB_DONTCACHE.
> >=20
> > Let's define a single event class and then use DEFINE_EVENT per outcome=
,
> > rather than one event with a disposition field. You'll notice this
> > pattern is used elsewhere in trace.h.
> >=20
> > So nfsd_write_dio_class with the alignment and segment-size fields, and
> > nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle,
> > _mem_misaligned fired at the site that makes each decision. An admin
> > chasing "why isn't this direct" then enables only the decline events.
> >=20
> > Also, let's give the READ side the same treatment so admins can see
> > the decisions that prevent reads from going direct.
>=20
> Done for v6.  nfsd_write_dio_class has the alignment and segment-size
> fields, and nfsd_write_dio_direct, _no_alignment, _too_small,
> _no_middle and _mem_misaligned each fire where that decision is made.
> For READs, nfsd_read_dio_class has nfsd_read_dio_no_alignment,
> _too_small, _pages_in_use and _not_last_op, one for each way
> nfsd_direct_read_ok() can decline; a READ that does go direct is
> already reported by nfsd_read_direct.  The disposition enum is gone,
> so nothing from vfs.h ends up in a TP_PROTO.
> =20
> > With the per-outcome events in place, the dontcache field on the
> > per-WRITE event is redundant: nfsd_write_direct/_dontcache/_vector
> > already say how each segment was issued. As it stands it also
> > misreports the direct middle, which carries dontcache_flags
> > regardless of direct_misaligned_dontcache. Consider dropping that
> > field.
>=20
> Dropped.
>=20
> > A few less critical items:
> >=20
> > - nfsd_write_dontcache and nfsd_write_vector are emitted only from
> >   nfsd_direct_write(). The io_cache_write=3Ddontcache and =3Dbuffered
> >   paths in nfsd_vfs_write() emit neither, so the new DONTCACHE event
> >   never fires in DONTCACHE mode and the commit message's "now fires
> >   only for normal buffered I/O" isn't right either. nfsd_iter_read()
> >   covers all three modes; please make the WRITE side match.
>=20
> nfsd_vfs_write() now emits them for io_cache_write=3Ddontcache and
> =3Dbuffered too, so the WRITE side matches nfsd_iter_read(), and the
> commit message no longer says "only for normal buffered I/O".
>=20
> > - mem_offset records bvec[0].bv_offset, but the mem_misaligned test
> >   is on bv_offset + prefix. With prefix=3D100 the event shows
> >   mem_offset=3D0 next to a mem_misaligned verdict. Record the quantity
> >   that was actually tested.
>=20
> It now records the offset that the test checks: for a WRITE whose
> payload starts 132 bytes into its page with a 2144-byte start, the
> event shows mem_offset=3D2276.  A decision made before the middle is
> placed records the offset of the payload's start.
> =20
> > - The doc says iomap_dio_invalidate_fail "reports an O_DIRECT middle
> >   segment that the filesystem serviced with buffered IO instead". It
> >   reports one cause of that, on iomap filesystems only. ext4's
> >   fallbacks are silent. Let's narrow the wording.
>=20
> Narrowed: it reports one reason for that, page cache over the segment
> that could not be invalidated, and only filesystems that use iomap for
> direct I/O emit it; other fallbacks, such as ext4's, are not traced.
>=20
> > - The doc talks about start/middle/end segments while the event
> >   prints prefix/middle/suffix. Let's pick one vocabulary.
>=20
> The events now print start, middle and end, as the doc says.
>=20
> > Jeff's comment about the ki_flags test in the hot path stands on its
> > own. I'll leave that between you and Jeff.
>=20
> Thanks to both of you for the review.
>=20
> Please see the revised 1/6 below, which I would like to pre-check with
> you and Jeff before posting the patchset in full again as v6 (with
> this 1/6 applied, 2/6 to 5/6 are unchanged, and 6/6 only differs in
> context, from its rebase on the new 1/6).  Feel free to pick it up it
> looks good, either way I'll wait to hear back before posting v6.
>=20
> I was curious about the resulting tracing output so I tested with 3
> 47008 IOs in NFSD io_cache_write modes 0, 1 and 2; here is the result:
>=20
> io_cache_write=3D0 (buffered):
> nfsd_write_start: xid=3D0xaf6f21f3 fh_hash=3D0xbb2b802f offset=3D0 len=3D=
47008
> nfsd_write_opened: xid=3D0xaf6f21f3 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_vector: xid=3D0xaf6f21f3 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_io_done: xid=3D0xaf6f21f3 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_done: xid=3D0xaf6f21f3 fh_hash=3D0xbb2b802f offset=3D0 len=3D4=
7008
> nfsd_write_start: xid=3D0xb06f21f3 fh_hash=3D0xbb2b802f offset=3D47008 le=
n=3D47008
> nfsd_write_opened: xid=3D0xb06f21f3 fh_hash=3D0xbb2b802f offset=3D47008 l=
en=3D47008
> nfsd_write_vector: xid=3D0xb06f21f3 fh_hash=3D0xbb2b802f offset=3D47008 l=
en=3D47008
> nfsd_write_io_done: xid=3D0xb06f21f3 fh_hash=3D0xbb2b802f offset=3D47008 =
len=3D47008
> nfsd_write_done: xid=3D0xb06f21f3 fh_hash=3D0xbb2b802f offset=3D47008 len=
=3D47008
> nfsd_write_start: xid=3D0xb16f21f3 fh_hash=3D0xbb2b802f offset=3D94016 le=
n=3D47008
> nfsd_write_opened: xid=3D0xb16f21f3 fh_hash=3D0xbb2b802f offset=3D94016 l=
en=3D47008
> nfsd_write_vector: xid=3D0xb16f21f3 fh_hash=3D0xbb2b802f offset=3D94016 l=
en=3D47008
> nfsd_write_io_done: xid=3D0xb16f21f3 fh_hash=3D0xbb2b802f offset=3D94016 =
len=3D47008
> nfsd_write_done: xid=3D0xb16f21f3 fh_hash=3D0xbb2b802f offset=3D94016 len=
=3D47008
>=20
> io_cache_write=3D1 (DONTCACHE):
> nfsd_write_start: xid=3D0xddf0249b fh_hash=3D0xbb2b802f offset=3D0 len=3D=
47008
> nfsd_write_opened: xid=3D0xddf0249b fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_dontcache: xid=3D0xddf0249b fh_hash=3D0xbb2b802f offset=3D0 le=
n=3D47008
> nfsd_write_io_done: xid=3D0xddf0249b fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_done: xid=3D0xddf0249b fh_hash=3D0xbb2b802f offset=3D0 len=3D4=
7008
> nfsd_write_start: xid=3D0xdef0249b fh_hash=3D0xbb2b802f offset=3D47008 le=
n=3D47008
> nfsd_write_opened: xid=3D0xdef0249b fh_hash=3D0xbb2b802f offset=3D47008 l=
en=3D47008
> nfsd_write_dontcache: xid=3D0xdef0249b fh_hash=3D0xbb2b802f offset=3D4700=
8 len=3D47008
> nfsd_write_io_done: xid=3D0xdef0249b fh_hash=3D0xbb2b802f offset=3D47008 =
len=3D47008
> nfsd_write_done: xid=3D0xdef0249b fh_hash=3D0xbb2b802f offset=3D47008 len=
=3D47008
> nfsd_write_start: xid=3D0xdff0249b fh_hash=3D0xbb2b802f offset=3D94016 le=
n=3D47008
> nfsd_write_opened: xid=3D0xdff0249b fh_hash=3D0xbb2b802f offset=3D94016 l=
en=3D47008
> nfsd_write_dontcache: xid=3D0xdff0249b fh_hash=3D0xbb2b802f offset=3D9401=
6 len=3D47008
> nfsd_write_io_done: xid=3D0xdff0249b fh_hash=3D0xbb2b802f offset=3D94016 =
len=3D47008
> nfsd_write_done: xid=3D0xdff0249b fh_hash=3D0xbb2b802f offset=3D94016 len=
=3D47008
>=20
> io_cache_write=3D2 (DIRECT):
> nfsd_write_start: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 len=3D=
47008
> nfsd_write_opened: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_dio_direct: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 l=
en=3D47008 offset_align=3D4096 mem_align=3D4 mem_offset=3D132 start=3D0 mid=
dle=3D45056 end=3D1952
> nfsd_write_direct: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D45056
> nfsd_write_dontcache: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D4505=
6 len=3D1952
> nfsd_write_io_done: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 len=
=3D47008
> nfsd_write_done: xid=3D0x86990005 fh_hash=3D0xbb2b802f offset=3D0 len=3D4=
7008
> nfsd_write_start: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D47008 le=
n=3D47008
> nfsd_write_opened: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D47008 l=
en=3D47008
> nfsd_write_dio_direct: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D470=
08 len=3D47008 offset_align=3D4096 mem_align=3D4 mem_offset=3D2276 start=3D=
2144 middle=3D40960 end=3D3904
> nfsd_write_dontcache: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D4700=
8 len=3D2144
> nfsd_write_direct: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D49152 l=
en=3D40960
> nfsd_write_dontcache: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D9011=
2 len=3D3904
> nfsd_write_io_done: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D47008 =
len=3D47008
> nfsd_write_done: xid=3D0x87990005 fh_hash=3D0xbb2b802f offset=3D47008 len=
=3D47008
> nfsd_write_start: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D94016 le=
n=3D47008
> nfsd_write_opened: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D94016 l=
en=3D47008
> nfsd_write_dio_direct: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D940=
16 len=3D47008 offset_align=3D4096 mem_align=3D4 mem_offset=3D324 start=3D1=
92 middle=3D45056 end=3D1760
> nfsd_write_dontcache: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D9401=
6 len=3D192
> nfsd_write_direct: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D94208 l=
en=3D45056
> nfsd_write_dontcache: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D1392=
64 len=3D1760
> nfsd_write_io_done: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D94016 =
len=3D47008
> nfsd_write_done: xid=3D0x88990005 fh_hash=3D0xbb2b802f offset=3D94016 len=
=3D47008
>=20
> In DIRECT mode, mem_offset is where the middle starts within its
> page: the payload starts 132 bytes in, so 132, 132 + 2144 =3D 2276 and
> 132 + 192 =3D 324.
>=20
> Changes since v5:
> - 1/6: the per-I/O events (nfsd_read_vector, nfsd_read_dontcache,
>   nfsd_write_direct, nfsd_write_dontcache, nfsd_write_vector) take the
>   kiocb flags and test them in TP_CONDITION(), so the flags are tested
>   only while an event is enabled (Jeff Layton).
> - 1/6: nfsd_write_dio_split, with its disposition and dontcache fields,
>   is replaced by an event class with one event per direct-mode WRITE
>   decision, emitted where the decision is made: nfsd_write_dio_direct,
>   _no_alignment, _too_small, _no_middle and _mem_misaligned.  READs get
>   the same: nfsd_read_dio_no_alignment, _too_small, _pages_in_use and
>   _not_last_op.  The WRITE events now also fire for
>   io_cache_write=3Ddontcache and =3Dbuffered, mem_offset is the offset th=
e
>   memory alignment test checks, the events print start, middle and end
>   as the documentation says, and the documentation of
>   iomap_dio_invalidate_fail is narrowed to what it reports (Chuck
>   Lever).
> - 2/6 to 5/6: unchanged.
> - 6/6: no change of its own; its context differs from the rebase on
>   the new 1/6.
>=20
> Thanks,
> Mike
>=20
> From: Mike Snitzer <snitzer@kernel.org>
> Date: Thu, 17 Sep 2026 18:06:39 -0400
> Subject: [PATCH draft-v6 1/6] NFSD: add tracing for how direct-mode READ =
and WRITE are serviced
>=20
> In a direct I/O mode, a READ or a WRITE segment may still be issued
> with DONTCACHE or normal buffered I/O.  nfsd_{read,write}_direct and
> nfsd_{read,write}_vector neither tell those two apart nor say why a
> request did not go direct.
>=20
> Add:
>=20
>  - nfsd_read_dontcache and nfsd_write_dontcache.
>    nfsd_{read,write}_vector now report normal buffered I/O only, and
>    the WRITE events fire in every io_cache_write mode, as the READ
>    events do.  These events test the kiocb flags in TP_CONDITION(), so
>    only while they are enabled.
>=20
>  - An event per direct-mode WRITE decision, emitted where it is made:
>    nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle and
>    _mem_misaligned.  Each records the alignments, the start, middle and
>    end segment sizes, and the memory offset the alignment test checks.
>=20
>  - An event per reason a direct-mode READ is not issued as O_DIRECT:
>    nfsd_read_dio_no_alignment, _too_small, _pages_in_use and
>    _not_last_op.
>=20
> Document them in nfsd-io-modes.rst, along with iomap's
> iomap_dio_invalidate_fail.
>=20
> Assisted-by: LLM
> Signed-off-by: Mike Snitzer <snitzer@kernel.org>
> ---
>  .../filesystems/nfs/nfsd-io-modes.rst         |  73 +++++++-
>  fs/nfsd/trace.h                               | 174 +++++++++++++++++-
>  fs/nfsd/vfs.c                                 |  91 ++++++---
>  3 files changed, 307 insertions(+), 31 deletions(-)
>=20
> diff --git a/Documentation/filesystems/nfs/nfsd-io-modes.rst b/Documentat=
ion/filesystems/nfs/nfsd-io-modes.rst
> index 0a5f4ef14a8a..0eef646a2423 100644
> --- a/Documentation/filesystems/nfs/nfsd-io-modes.rst
> +++ b/Documentation/filesystems/nfs/nfsd-io-modes.rst
> @@ -143,10 +143,9 @@ Misaligned WRITE:
>      direct_misaligned_dontcache is N (below). The flag has no effect on
>      the O_DIRECT segment unless the filesystem services it with buffered
>      IO instead, as XFS does when it cannot invalidate page cache that
> -    overlaps the segment. The iomap_dio_invalidate_fail trace event
> -    reports such a fallback. A split FILE_SYNC or DATA_SYNC WRITE is
> -    persisted once, after all of its segments are written, not once per
> -    segment.
> +    overlaps the segment (see iomap_dio_invalidate_fail under Tracing).
> +    A split FILE_SYNC or DATA_SYNC WRITE is persisted once, after all of
> +    its segments are written, not once per segment.
> =20
>      If NFSD does not split a WRITE, it issues the whole WRITE
>      as a single DONTCACHE buffered IO (normal buffered IO if the
> @@ -171,21 +170,81 @@ Misaligned WRITE:
>  Tracing:
>      The nfsd_read_direct trace event shows how NFSD expands any
>      misaligned READ to the next DIO-aligned block (on either end of the
> -    original READ, as needed).
> +    original READ, as needed). A READ that is serviced with buffered IO
> +    instead emits nfsd_read_dontcache (DONTCACHE buffered IO) or
> +    nfsd_read_vector (normal buffered IO), in any IO mode.
> +
> +    In NFSD_IO_DIRECT mode, a READ that is not issued as O_DIRECT also
> +    emits an event, where NFSD makes that decision, naming the reason::
> +
> +      nfsd_read_dio_no_alignment  the filesystem advertises no DIO read
> +                                  alignment
> +      nfsd_read_dio_too_small     smaller than the DIO read offset
> +                                  alignment
> +      nfsd_read_dio_pages_in_use  an earlier operation in the same
> +                                  COMPOUND already put data in the
> +                                  reply's pages
> +      nfsd_read_dio_not_last_op   an NFSv4 READ that is not the last
> +                                  operation of its COMPOUND
> =20
>      This combination of trace events is useful for READs::
> =20
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_vector/enable
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_dontcache/enabl=
e
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_direct/enable
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_io_done/enable
>        echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_read/enabl=
e
> +      for e in /sys/kernel/tracing/events/nfsd/nfsd_read_dio_*; do
> +              echo 1 > $e/enable
> +      done
> =20
> -    The nfsd_write_direct trace event shows how NFSD splits a given
> -    misaligned WRITE into a DIO-aligned middle segment.
> +    In NFSD_IO_DIRECT mode, each WRITE emits one event, where NFSD
> +    decides whether to split it, naming the outcome. Each records the
> +    alignments the filesystem advertised, the sizes of the start,
> +    middle and end segments (zero where not yet computed), and the
> +    offset within its page at which the middle segment starts, which is
> +    what the memory alignment test checks (for a decision made before
> +    the middle is placed, the offset at which the payload starts)::
> +
> +      nfsd_write_dio_direct          split: the aligned middle segment
> +                                     uses O_DIRECT
> +      nfsd_write_dio_no_alignment    the filesystem advertises no DIO
> +                                     alignment; not split
> +      nfsd_write_dio_too_small       smaller than the larger of the
> +                                     offset and memory alignments; not
> +                                     split
> +      nfsd_write_dio_no_middle       no aligned middle, or a misaligned
> +                                     start or end with a middle smaller
> +                                     than direct_misaligned_min_bytes
> +                                     bytes; not split
> +      nfsd_write_dio_mem_misaligned  the middle does not start at a
> +                                     memory address aligned to the
> +                                     block device's dma_alignment; not
> +                                     split
> +
> +    Enabling all of them but nfsd_write_dio_direct shows only the WRITEs
> +    that are not split, and why.
> +
> +    Each segment of a WRITE in NFSD_IO_DIRECT mode, and each WRITE in
> +    the other modes, emits nfsd_write_direct (O_DIRECT),
> +    nfsd_write_dontcache (DONTCACHE buffered IO) or nfsd_write_vector
> +    (normal buffered IO).
> =20
>      This combination of trace events is useful for WRITEs::
> =20
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_opened/enable
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_direct/enable
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_dontcache/enab=
le
> +      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_vector/enable
>        echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_io_done/enable
>        echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_write/enab=
le
> +      echo 1 > /sys/kernel/tracing/events/iomap/iomap_dio_invalidate_fai=
l/enable
> +      for e in /sys/kernel/tracing/events/nfsd/nfsd_write_dio_*; do
> +              echo 1 > $e/enable
> +      done
> +
> +    iomap_dio_invalidate_fail reports one reason a filesystem services
> +    an O_DIRECT segment with buffered IO instead: page cache over the
> +    segment that it could not invalidate. Only a filesystem that uses
> +    iomap for direct IO emits it, and other fallbacks, such as ext4's
> +    own, are not traced.
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index e0908cb21c4e..d41832e49a74 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -500,19 +500,187 @@ DEFINE_EVENT(nfsd_io_class, nfsd_##name,	\
> =20
>  DEFINE_NFSD_IO_EVENT(read_start);
>  DEFINE_NFSD_IO_EVENT(read_splice);
> -DEFINE_NFSD_IO_EVENT(read_vector);
>  DEFINE_NFSD_IO_EVENT(read_direct);
>  DEFINE_NFSD_IO_EVENT(read_io_done);
>  DEFINE_NFSD_IO_EVENT(read_done);
>  DEFINE_NFSD_IO_EVENT(write_start);
>  DEFINE_NFSD_IO_EVENT(write_opened);
> -DEFINE_NFSD_IO_EVENT(write_direct);
> -DEFINE_NFSD_IO_EVENT(write_vector);
>  DEFINE_NFSD_IO_EVENT(write_io_done);
>  DEFINE_NFSD_IO_EVENT(write_done);
> +
> +/*
> + * How a READ or a WRITE segment is issued, told apart by the kiocb flag=
s it
> + * is issued with.  Each event's condition is evaluated only while that
> + * event is enabled.
> + */
> +DECLARE_EVENT_CLASS(nfsd_io_kiocb_class,
> +	TP_PROTO(struct svc_rqst *rqstp,
> +		 struct svc_fh	*fhp,
> +		 u64		offset,
> +		 u32		len,
> +		 int		ki_flags),
> +	TP_ARGS(rqstp, fhp, offset, len, ki_flags),
> +	TP_STRUCT__entry(
> +		__field(u32, xid)
> +		__field(u32, fh_hash)
> +		__field(u64, offset)
> +		__field(u32, len)
> +	),
> +	TP_fast_assign(
> +		__entry->xid =3D be32_to_cpu(rqstp->rq_xid);
> +		__entry->fh_hash =3D knfsd_fh_hash(&fhp->fh_handle);
> +		__entry->offset =3D offset;
> +		__entry->len =3D len;
> +	),
> +	TP_printk("xid=3D0x%08x fh_hash=3D0x%08x offset=3D%llu len=3D%u",
> +		  __entry->xid, __entry->fh_hash,
> +		  __entry->offset, __entry->len)
> +)
> +
> +#define DEFINE_NFSD_IO_KIOCB_EVENT(name, cond)			\
> +DEFINE_EVENT_CONDITION(nfsd_io_kiocb_class, nfsd_##name,	\
> +	TP_PROTO(struct svc_rqst *rqstp,			\
> +		 struct svc_fh	*fhp,				\
> +		 u64		offset,				\
> +		 u32		len,				\
> +		 int		ki_flags),			\
> +	TP_ARGS(rqstp, fhp, offset, len, ki_flags),		\
> +	TP_CONDITION(cond))
> +
> +DEFINE_NFSD_IO_KIOCB_EVENT(read_vector, !(ki_flags & IOCB_DONTCACHE));
> +DEFINE_NFSD_IO_KIOCB_EVENT(read_dontcache, ki_flags & IOCB_DONTCACHE);
> +DEFINE_NFSD_IO_KIOCB_EVENT(write_direct, ki_flags & IOCB_DIRECT);
> +DEFINE_NFSD_IO_KIOCB_EVENT(write_dontcache,
> +			   (ki_flags & (IOCB_DIRECT | IOCB_DONTCACHE)) =3D=3D
> +			   IOCB_DONTCACHE);
> +DEFINE_NFSD_IO_KIOCB_EVENT(write_vector,
> +			   !(ki_flags & (IOCB_DIRECT | IOCB_DONTCACHE)));
>  DEFINE_NFSD_IO_EVENT(commit_start);
>  DEFINE_NFSD_IO_EVENT(commit_done);
> =20
> +/*
> + * Whether a direct-mode WRITE is split to issue its aligned middle
> + * O_DIRECT, and if not, why not: one event per outcome, each emitted wh=
ere
> + * that decision is made.  start, middle and end are the sizes of the
> + * segments, zero where not yet computed.  mem_offset is the offset with=
in
> + * its page at which the middle segment starts, which is what the memory
> + * alignment test checks; for a decision made before the middle is place=
d,
> + * the offset of the payload's start.
> + */
> +DECLARE_EVENT_CLASS(nfsd_write_dio_class,
> +	TP_PROTO(struct svc_rqst *rqstp,
> +		 struct svc_fh *fhp,
> +		 u64 offset,
> +		 u32 len,
> +		 u32 offset_align,
> +		 u32 mem_align,
> +		 u32 mem_offset,
> +		 u32 start,
> +		 u32 middle,
> +		 u32 end),
> +	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align, mem_offset,
> +		start, middle, end),
> +	TP_STRUCT__entry(
> +		__field(u32, xid)
> +		__field(u32, fh_hash)
> +		__field(u64, offset)
> +		__field(u32, len)
> +		__field(u32, offset_align)
> +		__field(u32, mem_align)
> +		__field(u32, mem_offset)
> +		__field(u32, start)
> +		__field(u32, middle)
> +		__field(u32, end)
> +	),
> +	TP_fast_assign(
> +		__entry->xid =3D be32_to_cpu(rqstp->rq_xid);
> +		__entry->fh_hash =3D knfsd_fh_hash(&fhp->fh_handle);
> +		__entry->offset =3D offset;
> +		__entry->len =3D len;
> +		__entry->offset_align =3D offset_align;
> +		__entry->mem_align =3D mem_align;
> +		__entry->mem_offset =3D mem_offset;
> +		__entry->start =3D start;
> +		__entry->middle =3D middle;
> +		__entry->end =3D end;
> +	),
> +	TP_printk("xid=3D0x%08x fh_hash=3D0x%08x offset=3D%llu len=3D%u "
> +		  "offset_align=3D%u mem_align=3D%u mem_offset=3D%u "
> +		  "start=3D%u middle=3D%u end=3D%u",
> +		  __entry->xid, __entry->fh_hash,
> +		  __entry->offset, __entry->len,
> +		  __entry->offset_align, __entry->mem_align,
> +		  __entry->mem_offset,
> +		  __entry->start, __entry->middle, __entry->end)
> +);
> +
> +#define DEFINE_NFSD_WRITE_DIO_EVENT(name)				\
> +DEFINE_EVENT(nfsd_write_dio_class, nfsd_write_dio_##name,		\
> +	TP_PROTO(struct svc_rqst *rqstp,				\
> +		 struct svc_fh *fhp,					\
> +		 u64 offset,						\
> +		 u32 len,						\
> +		 u32 offset_align,					\
> +		 u32 mem_align,						\
> +		 u32 mem_offset,					\
> +		 u32 start,						\
> +		 u32 middle,						\
> +		 u32 end),						\
> +	TP_ARGS(rqstp, fhp, offset, len, offset_align, mem_align,	\
> +		mem_offset, start, middle, end))
> +
> +DEFINE_NFSD_WRITE_DIO_EVENT(direct);
> +DEFINE_NFSD_WRITE_DIO_EVENT(no_alignment);
> +DEFINE_NFSD_WRITE_DIO_EVENT(too_small);
> +DEFINE_NFSD_WRITE_DIO_EVENT(no_middle);
> +DEFINE_NFSD_WRITE_DIO_EVENT(mem_misaligned);
> +
> +/*
> + * Why a direct-mode READ is not issued O_DIRECT: one event per reason,
> + * each emitted where that decision is made.  A READ that is issued
> + * O_DIRECT is reported by nfsd_read_direct.
> + */
> +DECLARE_EVENT_CLASS(nfsd_read_dio_class,
> +	TP_PROTO(struct svc_rqst *rqstp,
> +		 struct svc_fh *fhp,
> +		 u64 offset,
> +		 u32 len,
> +		 u32 offset_align),
> +	TP_ARGS(rqstp, fhp, offset, len, offset_align),
> +	TP_STRUCT__entry(
> +		__field(u32, xid)
> +		__field(u32, fh_hash)
> +		__field(u64, offset)
> +		__field(u32, len)
> +		__field(u32, offset_align)
> +	),
> +	TP_fast_assign(
> +		__entry->xid =3D be32_to_cpu(rqstp->rq_xid);
> +		__entry->fh_hash =3D knfsd_fh_hash(&fhp->fh_handle);
> +		__entry->offset =3D offset;
> +		__entry->len =3D len;
> +		__entry->offset_align =3D offset_align;
> +	),
> +	TP_printk("xid=3D0x%08x fh_hash=3D0x%08x offset=3D%llu len=3D%u "
> +		  "offset_align=3D%u",
> +		  __entry->xid, __entry->fh_hash,
> +		  __entry->offset, __entry->len, __entry->offset_align)
> +);
> +
> +#define DEFINE_NFSD_READ_DIO_EVENT(name)				\
> +DEFINE_EVENT(nfsd_read_dio_class, nfsd_read_dio_##name,		\
> +	TP_PROTO(struct svc_rqst *rqstp,				\
> +		 struct svc_fh *fhp,					\
> +		 u64 offset,						\
> +		 u32 len,						\
> +		 u32 offset_align),					\
> +	TP_ARGS(rqstp, fhp, offset, len, offset_align))
> +
> +DEFINE_NFSD_READ_DIO_EVENT(no_alignment);
> +DEFINE_NFSD_READ_DIO_EVENT(too_small);
> +DEFINE_NFSD_READ_DIO_EVENT(pages_in_use);
> +DEFINE_NFSD_READ_DIO_EVENT(not_last_op);
> +
>  DECLARE_EVENT_CLASS(nfsd_err_class,
>  	TP_PROTO(struct svc_rqst *rqstp,
>  		 struct svc_fh	*fhp,
> diff --git a/fs/nfsd/vfs.c b/fs/nfsd/vfs.c
> index 32136cd32af9..9219f8eb386d 100644
> --- a/fs/nfsd/vfs.c
> +++ b/fs/nfsd/vfs.c
> @@ -1238,24 +1238,39 @@ nfsd_direct_read(struct svc_rqst *rqstp, struct s=
vc_fh *fhp,
>  				eof, host_err);
>  }
> =20
> -static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct nfsd_file=
 *nf,
> +static bool nfsd_direct_read_ok(struct svc_rqst *rqstp, struct svc_fh *f=
hp,
> +				struct nfsd_file *nf, loff_t offset,
>  				unsigned long count)
>  {
> +	u32 offset_align =3D nf->nf_dio_read_offset_align;
> +
>  	/* When dio_read_offset_align is zero, dio is not supported */
> -	if (!nf->nf_dio_read_offset_align)
> +	if (!offset_align) {
> +		trace_nfsd_read_dio_no_alignment(rqstp, fhp, offset, count,
> +						 offset_align);
>  		return false;
> +	}
>  	/* Not worth rounding a READ this small out to whole alignment units */
> -	if (count < nf->nf_dio_read_offset_align)
> +	if (count < offset_align) {
> +		trace_nfsd_read_dio_too_small(rqstp, fhp, offset, count,
> +					      offset_align);
>  		return false;
> -	if (rqstp->rq_res.page_len)
> +	}
> +	if (rqstp->rq_res.page_len) {
> +		trace_nfsd_read_dio_pages_in_use(rqstp, fhp, offset, count,
> +						 offset_align);
>  		return false;
> +	}
>  #ifdef CONFIG_NFSD_V4
>  	/*
>  	 * The xdr_stream encoder ignores rq_res.page_base, so an operation
>  	 * encoded after a direct read would overwrite the payload's tail.
>  	 */
> -	if (rqstp->rq_vers =3D=3D 4 && !nfsd4_last_compound_op(rqstp))
> +	if (rqstp->rq_vers =3D=3D 4 && !nfsd4_last_compound_op(rqstp)) {
> +		trace_nfsd_read_dio_not_last_op(rqstp, fhp, offset, count,
> +						offset_align);
>  		return false;
> +	}
>  #endif
>  	return true;
>  }
> @@ -1298,7 +1313,7 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, struc=
t svc_fh *fhp,
>  	case NFSD_IO_BUFFERED:
>  		break;
>  	case NFSD_IO_DIRECT:
> -		if (nfsd_direct_read_ok(rqstp, nf, *count))
> +		if (nfsd_direct_read_ok(rqstp, fhp, nf, offset, *count))
>  			return nfsd_direct_read(rqstp, fhp, nf, offset,
>  						count, page, eof);
>  		fallthrough;
> @@ -1323,7 +1338,10 @@ __be32 nfsd_iter_read(struct svc_rqst *rqstp, stru=
ct svc_fh *fhp,
>  	}
>  	rqstp->rq_next_page =3D page;
> =20
> -	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total);
> +	trace_nfsd_read_vector(rqstp, fhp, offset, *count - total,
> +			       kiocb.ki_flags);
> +	trace_nfsd_read_dontcache(rqstp, fhp, offset, *count - total,
> +				  kiocb.ki_flags);
>  	iov_iter_bvec(&iter, ITER_DEST, rqstp->rq_bvec, v, *count - total);
>  	host_err =3D vfs_iocb_iter_read(file, &kiocb, &iter);
>  	return nfsd_finish_read(rqstp, fhp, file, offset, count, eof, host_err)=
;
> @@ -1391,7 +1409,8 @@ nfsd_write_dio_seg_init(struct nfsd_write_dio_seg *=
segment,
>  }
> =20
>  static unsigned int
> -nfsd_write_dio_iters_init(struct nfsd_file *nf, struct bio_vec *bvec,
> +nfsd_write_dio_iters_init(struct svc_rqst *rqstp, struct svc_fh *fhp,
> +			  struct nfsd_file *nf, struct bio_vec *bvec,
>  			  unsigned int nvecs, struct kiocb *iocb,
>  			  unsigned long total,
>  			  struct nfsd_write_dio_seg segments[3])
> @@ -1399,6 +1418,7 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, str=
uct bio_vec *bvec,
>  	u32 offset_align =3D nf->nf_dio_offset_align;
>  	loff_t prefix_end, orig_end, middle_end;
>  	u32 mem_align =3D nf->nf_dio_mem_align;
> +	u32 mem_offset =3D nvecs ? bvec->bv_offset : 0;
>  	size_t prefix, middle, suffix;
>  	loff_t offset =3D iocb->ki_pos;
>  	unsigned int dontcache_flags =3D 0;
> @@ -1415,9 +1435,18 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, st=
ruct bio_vec *bvec,
>  	 * If alignments are not available, the write is too small,
>  	 * or no alignment can be found, fall back to buffered I/O.
>  	 */
> -	if (unlikely(!mem_align || !offset_align) ||
> -	    unlikely(total < max(offset_align, mem_align)))
> +	if (unlikely(!mem_align || !offset_align)) {
> +		trace_nfsd_write_dio_no_alignment(rqstp, fhp, offset, total,
> +						  offset_align, mem_align,
> +						  mem_offset, 0, 0, 0);
>  		goto no_dio;
> +	}
> +	if (unlikely(total < max(offset_align, mem_align))) {
> +		trace_nfsd_write_dio_too_small(rqstp, fhp, offset, total,
> +					       offset_align, mem_align,
> +					       mem_offset, 0, 0, 0);
> +		goto no_dio;
> +	}
> =20
>  	orig_end =3D offset + total;
> =20
> @@ -1443,8 +1472,13 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, st=
ruct bio_vec *bvec,
> =20
>  	if (!middle ||
>  	    ((prefix || suffix) &&
> -	     middle < nfsd_direct_misaligned_min_bytes))
> +	     middle < nfsd_direct_misaligned_min_bytes)) {
> +		trace_nfsd_write_dio_no_middle(rqstp, fhp, offset, total,
> +					       offset_align, mem_align,
> +					       mem_offset, prefix, middle,
> +					       suffix);
>  		goto no_dio;
> +	}
> =20
>  	if (prefix) {
>  		nfsd_write_dio_seg_init(&segments[nsegs], bvec,
> @@ -1462,20 +1496,28 @@ nfsd_write_dio_iters_init(struct nfsd_file *nf, s=
truct bio_vec *bvec,
>  	 * the first bvec, all subsequent bvecs start at bv_offset zero
>  	 * (page-aligned). Therefore, only the first bvec is checked.
>  	 */
> -	if (iov_iter_bvec_offset(&segments[nsegs].iter) & (mem_align - 1))
> +	mem_offset =3D iov_iter_bvec_offset(&segments[nsegs].iter);
> +	if (mem_offset & (mem_align - 1)) {
> +		trace_nfsd_write_dio_mem_misaligned(rqstp, fhp, offset, total,
> +						    offset_align, mem_align,
> +						    mem_offset, prefix, middle,
> +						    suffix);
>  		goto no_dio;
> +	}
>  	/*
>  	 * IOCB_DONTCACHE matters only if the file system falls back to
>  	 * buffered I/O (-ENOTBLK).
>  	 */
>  	segments[nsegs++].flags |=3D IOCB_DIRECT | dontcache_flags;
> +	trace_nfsd_write_dio_direct(rqstp, fhp, offset, total, offset_align,
> +				    mem_align, mem_offset, prefix, middle,
> +				    suffix);
> =20
>  	if (suffix) {
>  		nfsd_write_dio_seg_init(&segments[nsegs], bvec, nvecs, total,
>  					prefix + middle, suffix, iocb);
>  		segments[nsegs++].flags |=3D buffered_flags;
>  	}
> -
>  	return nsegs;
> =20
>  no_dio:
> @@ -1499,8 +1541,8 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct sv=
c_fh *fhp,
>  	ssize_t host_err;
>  	size_t expected;
> =20
> -	nsegs =3D nfsd_write_dio_iters_init(nf, rqstp->rq_bvec, nvecs,
> -					  kiocb, *cnt, segments);
> +	nsegs =3D nfsd_write_dio_iters_init(rqstp, fhp, nf, rqstp->rq_bvec,
> +					  nvecs, kiocb, *cnt, segments);
> =20
>  	/*
>  	 * Persist a split synchronous WRITE once, after all of its
> @@ -1514,12 +1556,15 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct =
svc_fh *fhp,
>  	*cnt =3D 0;
>  	for (i =3D 0; i < nsegs; i++) {
>  		kiocb->ki_flags =3D segments[i].flags & ~sync_flags;
> -		if (kiocb->ki_flags & IOCB_DIRECT)
> -			trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
> -						segments[i].iter.count);
> -		else
> -			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
> -						segments[i].iter.count);
> +		trace_nfsd_write_direct(rqstp, fhp, kiocb->ki_pos,
> +					segments[i].iter.count,
> +					kiocb->ki_flags);
> +		trace_nfsd_write_dontcache(rqstp, fhp, kiocb->ki_pos,
> +					   segments[i].iter.count,
> +					   kiocb->ki_flags);
> +		trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
> +					segments[i].iter.count,
> +					kiocb->ki_flags);
> =20
>  		expected =3D iov_iter_count(&segments[i].iter);
> =20
> @@ -1628,6 +1673,10 @@ nfsd_vfs_write(struct svc_rqst *rqstp, struct svc_=
fh *fhp,
>  			kiocb.ki_flags |=3D IOCB_DONTCACHE;
>  		fallthrough;
>  	case NFSD_IO_BUFFERED:
> +		trace_nfsd_write_dontcache(rqstp, fhp, offset, *cnt,
> +					   kiocb.ki_flags);
> +		trace_nfsd_write_vector(rqstp, fhp, offset, *cnt,
> +					kiocb.ki_flags);
>  		iov_iter_bvec(&iter, ITER_SOURCE, rqstp->rq_bvec, nvecs, *cnt);
>  		host_err =3D vfs_iocb_iter_write(file, &kiocb, &iter);
>  		if (host_err < 0)

New version looks good to me.

Reviewed-by: Jeff Layton <jlayton@kernel.org>
