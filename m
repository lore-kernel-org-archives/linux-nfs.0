Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B3B5659C990;
	Tue,  8 Sep 2026 18:25:55 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1788891958; cv=none; b=CHTftp2BVhqUNbmik6anF+tz90+TOvsPBWeFw02XgGiHOGbSPZq4dNhcMEN2OFdjAbVSkliVjnua6FHJoLaDjHDBJgBBDGmGNWATYgVTWkV7T575ZB8Otihjw3tk1WJef7KSoZPcpWO32dA0Q9QfhxSJbr1R0Uwke2nsJOSb5/c=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1788891958; c=relaxed/simple;
	bh=dFvKo2wgimjoi6v8qrBvNdwiJV+aaDYxtnGgRwN9Mzo=;
	h=MIME-Version:Date:From:To:Cc:Message-Id:In-Reply-To:References:
	 Subject:Content-Type; b=rbJQS8iyuhyTVc2zQtXDm8frRrccpkH4cIJkY7ipOKh4uz7wMKAcl7cguP4OsXNYkVNS3+07TsiO/yKZMASNyCh9qoawMZi7X4iI49D35Z2dgXmfF0l/wQ1yYhhWgK4yHPl2uOxDMQI7PMB2jFLYoYRRBTW+9KH2ym5tnb5f4aI=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=FtUJWXMk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="FtUJWXMk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id BD2091F00A3A;
	Tue,  8 Sep 2026 18:25:54 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1788891955;
	bh=ggXtq3bunUbLmKM1huLP9AkpZpdVTn5E2T4t//Tpijs=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=FtUJWXMkcN/8Yt3EIZSbJoEWJoNUlzZUpdcMoDGa0s0EPSmrU/ylUey8BPdu4fHEo
	 FOEkLxr1amnwYKi8v5hwe+ghRqSo9Ja60ZbztVEGLu4l1zMpa+op2i2ZiB9mJ4D69L
	 c7sT4sK12bC6vgJ0Ene+f3K/WSKugbdKjTzEOhgchm8QZWBFoxt+bTbte7Vrq8PbQH
	 BzPAfOZ2jImmE6/p6HNa24Oez+KBP6u5IHhqOOEJnXZTxOCQ0oizEFQULzYMPZy09U
	 KAZPQmA99BunlgD9V8dMLWpVDbtVM7xGERMB/I2U8jMExJW4jenViShb4kxElJ0ngM
	 /ij8qmjOGlg0Q==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id E801CF40066;
	Tue,  8 Sep 2026 14:25:53 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Tue, 08 Sep 2026 14:25:53 -0400
X-ME-Sender: <xms:MVOgarF9JbAShygp14cmukJWB6jYu45ZSVwYGy7JwyqfoeL1QvlDtg>
    <xme:MVOgajJenudN_tOWA8F9mqK24RpAWIBYtPMsN_ZsraEgapma8arrDIevHiMNK8DX_
    3JHgQUn4mCwsLgwLZhnFbfwuAv8z4ktOyAUEJiejlfsjyiVviZb1sT1>
X-ME-Proxy-Cause: dmFkZTFD74QV18d/sk8xPd+vfyUwpFmtrlQTCQuFGStRknzlodZhUrafwOgYulpo79eDuD
    YwmB0ZhBeYhgCbLZCc+YMIYhevY+yJzhnzzesJmbUa0tAGi26e698vnskJhznhE4WvBgXo
    acxz7uvcNifYzXJelBCKRn+DVzwgGuProSmFO+pgS44QzRB49U45GNOyRL3hBfseuxXgJT
    /TfKW3Or6Vq+kYLn6o9HzP7ZnUTH31TpveCdLJ2hXlTTu5p/bAuIbmcrnJ4PoTCd81JVKK
    31TtTjnx9WTL0aTSiLpPVSDJpnHAprgjoBDHyQepDqXfF6RDtlTHYzjPX4SIhhM4nkVZGO
    69Spj3N8wJKssRnZeXBICQ/Fl67KWDrFEhpErPkPrH/yKpdzLtUhafF8Vgt4wQvacU0rr3
    F2ZjWox2dBF4be/TMtlDrZFU8YFaqPKVzN3osjq5PW6jAUDrWVpqiVls+/M+0dMfEU9UCz
    YFANAma/ut1mB0cf5yR6L1i1KwdyikYa57FAvkSVNOTlzzhxxIveyssz3xr4gdAyJH3nMH
    kGEC9VmdD+hNlVl9QIRD4psKh3SXNhg67E+JJqKTkDj81835UPw5tCOBOBw38//5B+5gMQ
    /J5HXC19UrJcsjD7tmMPiqchVLMyfFXHP43J82mmQz99bs5f6nB8kPty5m4A
X-ME-Proxy: <xmx:MVOganplPVK3rq69OMb44nQhIGah1YC-Et2WS2UU428JL7HBxNXBmQ>
    <xmx:MVOgagvMMBQmtkgTTladCnxqfFNPywTepoGBBOrwQgniTS1Eay83sg>
    <xmx:MVOgaqaAyaf0kaiygW1wxJUsdiceOhr3sWDfvE2NfIz_tpQcJs8_1w>
    <xmx:MVOganYIUnxCwzBzWcs4MvyjTRmZmhC00sHGPWg0By5plDwU6ZRb2g>
    <xmx:MVOgarksjuuEMCGc1HhUw8HIGvjN0GM-gLJdVU_IX_4Z7QS0x9l6Fwnc>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id C649A7811F5; Tue,  8 Sep 2026 14:25:53 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
X-ThreadId: AvkNhIlgtVI3
Date: Tue, 08 Sep 2026 14:25:32 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: linux-nfs@vger.kernel.org, linux-block@vger.kernel.org,
 dm-devel@lists.linux.dev, axboe@kernel.dk, jlayton@kernel.org,
 david.flynn@hammerspace.com
Message-Id: <995a853c-2c54-4bd0-9708-f6e0c1be7fd5@slotpi15m67>
In-Reply-To: <20260908163448.30841-5-snitzer@kernel.org>
References: <20260908163232.30774-1-snitzer@kernel.org>
 <20260908163448.30841-1-snitzer@kernel.org>
 <20260908163448.30841-5-snitzer@kernel.org>
Subject: Re: [PATCH 4/4] nfsd: fall back to buffered I/O when a direct write gets
 -EINVAL
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On 9/8/26 12:34 PM, Mike Snitzer wrote:
> nfsd_dio_iter_is_aligned() approves a write iterator against the
> file's STATX_DIOALIGN attributes (a whole-iterator iov_iter_alignment()
> test against dio_mem_align), but the block stack applies stricter
> geometry tests at bio split time: bio_split_io_at() checks each bvec's
> offset and length against the queue's dma_alignment and may find no
> valid block-size-aligned split at all. An ITER_BVEC WRITE payload can
> pass the former and fail the latter: bio_iov_bvec_set() hands nfsd's
> bvec array to the queue as-is, and the payload's first fragment starts
> mid-page (the RPC header precedes it in the receive buffer), so the
> iterator's interior page boundaries need not be logical-block aligned
> and a bio the queue must split may have no valid split point. When
> that happens, nfsd_direct_write() returned the -EINVAL to the client
> as a failed WRITE (NFS4ERR_INVAL) -- for a perfectly valid request.
>
> Observed against a brd-backed nvme-loop XFS export (dio_mem_align=4)
> with 1 MiB WRITEs, e.g. arriving as 65 bvecs with bv0=(408,15976):
> the gate admits the iterator, the block layer rejects it, and every
> large write on the affected connection errors out (dd: Invalid
> argument).

Thanks for chasing this down. The bv0 numbers make the gate defect
clear: 15976 is not a multiple of the logical block size, so the
direct segment's first interior bvec boundary lands mid-sector. The
boundaries after that are page boundaries, which are fine.

A small correction for the commit message: nfsd_dio_iter_is_aligned()
doesn't exist. The gate is the first-bvec offset test in
nfsd_write_dio_iters_init(), and it checks only that one offset
against nf_dio_mem_align. Likewise bio_iov_bvec_set() is now
bio_iov_iter_set().

> Treat -EINVAL from the direct attempt as "not direct-able": restore the
> segment's iterator and retry it as (uncached when FOP_DONTCACHE)
> buffered I/O, the same fallback nfsd_write_dio_iters_init() picks for
> geometries it rejects itself.

[ ... ]

> @@ -1467,6 +1469,33 @@ nfsd_direct_write(struct svc_rqst *rqstp, struct svc_fh *fhp,
>  		expected = iov_iter_count(&segments[i].iter);
>
>  		host_err = vfs_iocb_iter_write(file, kiocb, &segments[i].iter);
> +		if (unlikely(host_err == -EINVAL &&
> +			     (kiocb->ki_flags & IOCB_DIRECT))) {

[ ... ]

> +			segments[i].iter = saved_iter;
> +			kiocb->ki_flags &= ~IOCB_DIRECT;
> +			if (file->f_op->fop_flags & FOP_DONTCACHE)
> +				kiocb->ki_flags |= IOCB_DONTCACHE;
> +			trace_nfsd_write_vector(rqstp, fhp, kiocb->ki_pos,
> +						segments[i].iter.count);
> +			host_err = vfs_iocb_iter_write(file, kiocb,
> +						       &segments[i].iter);
> +		}

Per our discussion last October:

  https://lore.kernel.org/linux-nfs/aPXihwGTiA7bqTsN@infradead.org/

The conclusion then was that -EINVAL from ->write_iter can come from
a number of conditions in the filesystem, so NFSD can't treat it as
meaning only that the I/O was misaligned. That still holds, so I'd
rather not use -EINVAL to signal a retry. An -EINVAL that really is
the filesystem rejecting the request would now cost a second full
write attempt before surfacing anyway.

nfsd_write_dio_iters_init() already has the segment start and
nf_dio_offset_align, and after the first bvec every boundary is
page-aligned. If it also requires the first bvec's remaining length
(from the segment start) to be a multiple of offset_align and takes
the no_dio path otherwise, that rejects bv0=(408,15976) up front
using only data NFSD already has.

What would help me understand the failure even better:

- Which -EINVAL in bio_split_io_at() fired: the per-bvec dma_alignment
  test, or the zero-length result after ALIGN_DOWN()?

- On the reproducer, how does stx_dio_offset_align compare with the
  queue's logical_block_size?

If there turn out to be cases the gate can't predict from the statx
data, that seems like a question for the block and fs folks about
what error the filesystem should surface, rather than something to
work around in NFSD.


-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
