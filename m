Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.remote-ip=100.103.45.18
ARC-Seal: i=1; d=subspace.kernel.org; s=arc20261015; a=rsa-sha256; cv=none;
	t=1792434849;
	b=U7zdzkAO+sNHTzaDPVhJjfkByowTkJn198cxT5RpxOXX047jPyDYX1wVGst61s/S+YUJ
	 Gm/ZO5eI4yMjKo41iGm89I/gf9qwd4NyFrn7mEK8I4kHlUlidCXvCMQyFbnKp9KXgALH1
	 AZzyys3EtjzHYpKdtyzcWLc2PahFsd0Uh6z76vYhAfbsJi17F3zNgox1cEBe8fUgFFaK+
	 /m3208E/pDjVjaNRuQI5ZbQ4zwsQJL3bGYZQEC3hO88zonOGTkshzTxQ/AYBwt81EGBRy
	 IdbqrvSc46coCtS4ZA2qlz9L4PCngzI0rtC21Np9fcsX9F6tRE8TC1+fW4nRB2jVhPA==
ARC-Message-Signature: i=1; d=subspace.kernel.org; s=arc20261015;
	a=rsa-sha256; c=relaxed/relaxed; t=1792434849;
	h=Received:DKIM-Signature:Received:Received:X-ME-Sender:
	 X-ME-Proxy-Cause:X-ME-Proxy:Feedback-ID:Received:X-Mailer:
	 MIME-Version:X-ThreadId:Date:From:To:Cc:Message-Id:In-Reply-To:
	 References:Subject:Content-Type:Content-Transfer-Encoding;
	bh=fpSk/CbNOxgm/YwPtWLbatYprzPLT2PIdzvPIH54y58=;
	b=nnZpJ860R13x4t3fO4G7L1wEA/yWJHge9ot0XUGjtIE34Xvn8wwI3oDESIIX6BPlK4S2
	 ZGW6ZdP5a+yUPBeF6WKfHMC3OeDTn+DVjoZuvoUhZ1YsxjVtw4qPULV5mMt/Bu8dekCuT
	 7OUNp+7pMc5K2gsUFvQPsSvt4iQHg0CNgYelG/9osH70LcfOpyJMtSi0vPaZNe4ykPaj2
	 Y1NQmXN6rEl3KvfZO3eDhUIdovugyu6VqUoVSN1Ibn+JGb1CLiVzO+n8SM8pyA183vCdP
	 Au2QTibT0DwYCDpSknYK5iC/AWE41A8IKbbI4Ts3hLX2sYSrJh+qm1q+hCwdZT/DmSw==
ARC-Authentication-Results: i=1; smtp.subspace.kernel.org; 
	dkim=pass header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mcN3jL0x;
	arc=none smtp.remote-ip=100.103.45.18
Received: from smtp.kernel.org (quasi.space.kernel.org [100.103.45.18])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange X25519 server-signature ECDSA (prime256v1))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id A84FF606A31D
	for <linux-nfs@vger.kernel.org>; Mon, 19 Oct 2026 18:34:09 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key, unprotected) header.d=kernel.org header.i=@kernel.org header.a=rsa-sha256 header.s=k20260515 header.b=mcN3jL0x
Received: by smtp.kernel.org (Postfix) with ESMTPSA id E46431F000C4;
	Mon, 19 Oct 2026 18:34:08 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1792434849;
	bh=fpSk/CbNOxgm/YwPtWLbatYprzPLT2PIdzvPIH54y58=;
	h=Date:From:To:Cc:In-Reply-To:References:Subject;
	b=mcN3jL0x7o07gopqYbe6aQDb3uAGUgaxOQsFsgcY4yYkKSBZUled8S3ng4uax5VRQ
	 Y9ronnjw4+MQOAJ9bcE2XPVTC+D0sSvIDnqGKDIIoCDTO/HgDglU463/FRXUWMyIOl
	 E69fanaXZo4amEpW0sIDvIE7dZ29p4YQTGmgqlH8Y9Q3F3yUyHBPIX/qrx2UehUV5H
	 9nVtpPvCTMSm5twqXn/1Tb/qG6qUozGvtyuLn3/J5tLlNrz5sAjX4XrwemqsZ+4L/b
	 78TxvmfIOzAkm0A0Igc0PpVop3siJ/0JzrnNxWlqiz7gDtTzm+i5tF/yB3WuJrcYRe
	 f3y9qRN7JpvjQ==
Received: from phl-compute-10.internal (phl-compute-10.internal [10.202.2.50])
	by mailfauth.phl.internal (Postfix) with ESMTP id 4D490F4006C;
	Mon, 19 Oct 2026 14:34:08 -0400 (EDT)
Received: from phl-imap-15 ([10.202.2.104])
  by phl-compute-10.internal (MEProxy); Mon, 19 Oct 2026 14:34:08 -0400
X-ME-Sender: <xms:oGLWaiqFvBURSSl0gU0eKj5KT_8cztuwHdKcJzxtN62_DMkj1os5AA>
    <xme:oGLWardCL6tbTZv4_8WDs5ufaImxCQYHhXsOCmshAhUZX4msruc9eO9PKjrOh7H4l
    965XpDX4It-QlSsGFKWqt0ZIfzSMnP77CFjGn8babFZiYpXFAJkSa0>
X-ME-Proxy-Cause: dmFkZTGU9dwEU4XRK5nfGJiAm4glnmpJQKWEZoqJtiBJkpSTPtHDUzcNFeKIV1MVYcCjaB
    efQJ3D5ne3hBoH3g4G+5JTBy2dhL/NzUjEcCd+BKoakAPgCNfsgXVatn7K99IqrxC6wkvh
    f4fbA5ujaLZZuTYe2mCnFgn7FxpCHqpKccrLgc8HDKj5jnv15GFdyQD448mH2wGhK6BKrj
    yMg9Z1NF84Y98QZDVhK8TeJ2DayFiMqv3Tc3085uI9nJS8haoO7AhZVKfxsPTam18dQUX4
    8jIE8Bd4OBWK4W5B+7a89Tju+Lo5PS0G5hg7LtnbEPb46Ao+zMycFo6IGpGotsiACSPPKu
    n0Z3qJ6TLWRoynA1ICgbyIOI7SLHtquS6bEjnt/cfBzzF6PMEDQi1G+3jIuUx/Jb2fVxWv
    UNTS2qjqCGQaMD+Zw5/mw10mpm/+KIDA8WNGtfsdTENCHHLdAfJOmBhYI8GvEHrKBTosCv
    bcttISHXbnuav/VEFCbLqjn8eoZa60VOlJCbA3oB2kOIMYLlm0mFTIXt2HXTS6vUpjTMQt
    n1JR5r+xM0IWuvKj3MXhSqv+gx9bmiCYBWVaEGB/pI7iadcisLm2WuOYQvlKrNAm/ZGoXx
    tvbQsHJ9RW30Hz3VAAr1wWodOp7THzk2LTtEjRffH/gjhMQaXPe8u4finxog
X-ME-Proxy: <xmx:oGLWavga5e8muFHTMT035QeK7vBI_wV2cOpOZB08fRRcN1NMQzB2tQ>
    <xmx:oGLWakIdZhKUF7o5oh9j00VmfqpaThVo1RXc9HEVoJQVKeWPMPOmJA>
    <xmx:oGLWaunONJIGdi-BAwdqq2J-acghmrbjGtT_mgDw7TciE8A3gdkeGQ>
    <xmx:oGLWasPtl9EdzlHrFRNJNN9LJTTq05cjyP6goD9Yjcte01adCvc1NA>
    <xmx:oGLWao6PAYSqOEbEf6Nt5kRINYVMyKxFvGlFOgEvVy6hpj5_u6h6ha4r>
Feedback-ID: ifa6e4810:Fastmail
Received: by mailuser.phl.internal (Postfix, from userid 501)
	id 1A8A0782738; Mon, 19 Oct 2026 14:34:08 -0400 (EDT)
X-Mailer: MessagingEngine.com Webmail Interface
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Post: <mailto:linux-nfs@vger.kernel.org>
List-Help: <mailto:linux-nfs+help@vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
List-Owner: <mailto:linux-nfs+owner@vger.kernel.org>
Precedence: list
MIME-Version: 1.0
X-ThreadId: AS6kSLE8WzSk
Date: Mon, 19 Oct 2026 14:33:47 -0400
From: "Chuck Lever" <cel@kernel.org>
To: "Mike Snitzer" <snitzer@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
 NeilBrown <neil@brown.name>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Christoph Hellwig" <hch@lst.de>, "Jens Axboe" <axboe@kernel.dk>,
 "Matthew Wilcox" <willy@infradead.org>, linux-mm@kvack.org,
 linux-fsdevel@vger.kernel.org
Message-Id: <f39bfe92-8676-4241-bb4e-bccd838ab99b@slotpi15m67>
In-Reply-To: <20261019150725.1507-2-snitzer@kernel.org>
References: <20261019150725.1507-1-snitzer@kernel.org>
 <20261019150725.1507-2-snitzer@kernel.org>
Subject: Re: [PATCH v5 1/6] NFSD: add tracing for how direct-mode READ and WRITE are
 serviced
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Mon, Oct 19, 2026, at 11:07 AM, Mike Snitzer wrote:
> Add:
>
>  - nfsd_write_dio_split, emitted once per direct-mode WRITE before any
>    segment is issued.  It records the advertised offset and memory
>    alignments, the payload's offset within its first page, the start,
>    middle and end segment sizes, a disposition naming the path taken
>    (direct, no_alignment, too_small, no_middle, mem_misaligned), and
>    whether buffered segments are issued IOCB_DONTCACHE.

Let's define a single event class and then use DEFINE_EVENT per outcome,
rather than one event with a disposition field. You'll notice this
pattern is used elsewhere in trace.h.

So nfsd_write_dio_class with the alignment and segment-size fields, and
nfsd_write_dio_direct, _no_alignment, _too_small, _no_middle,
_mem_misaligned fired at the site that makes each decision. An admin
chasing "why isn't this direct" then enables only the decline events.

Also, let's give the READ side the same treatment so admins can see
the decisions that prevent reads from going direct.

With the per-outcome events in place, the dontcache field on the
per-WRITE event is redundant: nfsd_write_direct/_dontcache/_vector
already say how each segment was issued. As it stands it also
misreports the direct middle, which carries dontcache_flags
regardless of direct_misaligned_dontcache. Consider dropping that
field.

A few less critical items:

- nfsd_write_dontcache and nfsd_write_vector are emitted only from
  nfsd_direct_write(). The io_cache_write=dontcache and =buffered
  paths in nfsd_vfs_write() emit neither, so the new DONTCACHE event
  never fires in DONTCACHE mode and the commit message's "now fires
  only for normal buffered I/O" isn't right either. nfsd_iter_read()
  covers all three modes; please make the WRITE side match.

- If any enum from vfs.h ends up in a TP_PROTO, note that trace.h's
  own #include "vfs.h" is after the per-class events. It builds today
  only because xdr4.h pulls vfs.h in first. Move the include up with
  the other headers.

- mem_offset records bvec[0].bv_offset, but the mem_misaligned test
  is on bv_offset + prefix. With prefix=100 the event shows
  mem_offset=0 next to a mem_misaligned verdict. Record the quantity
  that was actually tested.

- The doc says iomap_dio_invalidate_fail "reports an O_DIRECT middle
  segment that the filesystem serviced with buffered IO instead". It
  reports one cause of that, on iomap filesystems only. ext4's
  fallbacks are silent. Let's narrow the wording.

- The doc talks about start/middle/end segments while the event
  prints prefix/middle/suffix. Let's pick one vocabulary.

Jeff's comment about the ki_flags test in the hot path stands on its
own. I'll leave that between you and Jeff.

-- 
Chuck Lever (Come to NFS bake-a-thon! https://nfsv4bat.org)
