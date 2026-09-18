Received: from fhigh-b2-smtp.messagingengine.com (fhigh-b2-smtp.messagingengine.com [202.12.124.153])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 7CF7940B6E0
	for <linux-nfs@vger.kernel.org>; Fri, 18 Sep 2026 23:39:22 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=202.12.124.153
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1789774765; cv=none; b=Ip3U+mnoekWoaASismqY8llNoDtk7MnMcvNJiMhUpYdppjjgTXGlUwYLoWnpVWfq2an7oWIQivIfAVezoxfamSppCyyPcoBTlNI2Z786arQF3ud4LbfPEXCuUdwpsZR0ijsWLwx/sNKhAsRMMPRuY0A9Rxc4Jrg58cwsX5JTzcw=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1789774765; c=relaxed/simple;
	bh=JWC9GaiTLAAyNmcw3Hyd6K3/M24bqKRKSVMr9vKfLec=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=KkjjJ49BGu08cg3i4JG8zGzYn7+A+VKBzAtPviZ4V54eondKLAOzjtc9gZgfC0NAIaNgRO829UtkX7z0uP2MUtxtDyUeMM3v3hb38yoHQcQOmvjL47JgwdWyRvyAXgJwRE7p99TIkAUJ7VPKM5S56Rt0PBxe1u+IxgY++w+O7Fc=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=Bif2WGYf; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=anuqA7Xh; arc=none smtp.client-ip=202.12.124.153
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="Bif2WGYf";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="anuqA7Xh"
Received: from phl-compute-05.internal (phl-compute-05.internal [10.202.2.45])
	by mailfhigh.stl.internal (Postfix) with ESMTP id 6A8697A00B7;
	Fri, 18 Sep 2026 19:39:21 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-05.internal (MEProxy); Fri, 18 Sep 2026 19:39:21 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1789774761; x=1789861161; bh=5RhoIQ9kyxIbLRTEV4wtktcFc+YyN0e8yDz
	Wch96Q74=; b=Bif2WGYf9UA2keNvFuC/b6/khsjrRsIw1Iv+A95rlGtZVnkkwZH
	P/DWsVYQvqRXFbJmg0Z3lfrattAhZ+NH0xBbxWvkuM4gyHavEqkgRlXX7Z64+FFN
	QBK3vIzsmBCly9OjLd65MZgtIqesd/hMqZnJG7c7wTFXQRUOMsZ0j1Py7LXNKbmJ
	QTxWnY7/ftnKqpuRwtD15BYkKVBoYeh0V3cqSA/91p4OvNn1FnzxLOWH/+T7Fnzt
	putKKJG6YRQgX1SJCzK6JrLzViG4UlxOb3bovrZQgRl2m4deOf88M03VUcUKkiEz
	PAbN/wOdyyz04Gy50/MHq1YAzYp9T7pWjRA==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1789774761; x=
	1789861161; bh=5RhoIQ9kyxIbLRTEV4wtktcFc+YyN0e8yDzWch96Q74=; b=a
	nuqA7XhBQVBbsy3vxam2Ril/0/WdppbUyMI52T1/Mjs09pPwvMTtCn4uT7z2xsss
	zX0D5EC4xRlVznbBD8NPOJLZC72fIYPt+2DTW1wJEQCkvgMytYozXbKDIZpHnPby
	pnX7v1CogSn+lCkdGSeCyHj8s4pFdZSp2WhqMiozsxnMU6yMgHXxG8lFaDJs7z3I
	7m83I+tQyY2mWDrOB3LsR3/eRvhp4j5ydFPmPYiXm1Yad4AhGhtZxmE4lAsIMWQo
	PxM7pGXpKnokh7/CSm6Yg81af2z0/cQhGLqFfVrJw4wNRAtD3jxsEvUHH2AENaNo
	WkY2u41Vvw014kEMsvvcw==
X-ME-Sender: <xms:qMutavybpY0yaBrivPx_nwDRp_YbDHl9HAC5UqTTuR8X2v5eD2DeRw>
    <xme:qMutapjWxWzuqxqkgEGHg3OyxU_c2Sf-6XefkOX1mFf63m5uLH8q-9FEubClIidOQ
    XlxL767MoiWgmQx8ioJ11UClUfM5PkhvNiX-Z2LLjGyEBSD8vo>
X-ME-Received: <xmr:qMutarnKbJ6iODhbmj6FxzilPekhIpm3eMPEnDT0og2IVEzI6ZCPLL5cc6Rd0N0atw>
X-ME-Proxy-Cause: dmFkZTFsDCCikMIWnPixvVSCV9GI6XLfB61jiJkulsqnifesMGZSCLroN4YaWyRzjjWsEK
    0vhryt55bvfvxFFcrN+7bFT6LZoNWKVhFXrJDLAOsAZd/xCv84ayKvW4Yaj6WBRsKUSJ5o
    OZ3vDkFk8v/HTmnguXThKyEQ13oNvxAEIDWXqXq2r8Xztb7C7FZwlG20IdIU3hyohkp+aF
    3HhwitgUmf7s66lVctKP7thf3OkJ7F3Z7i8rp1IsMgRr41IzSg6yGCTyCl3FvF/zre5hE1
    WdExoICEspPG2SeijP49iUlPe6xrSU0Y2c89SEmrN8RVzEFJetytANg1rwuqPbms6r32Oe
    moJdJQ18dKUaPVOcDsD9gT0d2eleLd4+wELVQVx0o9aY7n7BodBSd5jmooH52DbTn0/ZuS
    lu4mk0GCYzTkf1JyctIOWQfuPD+rukDtd5LO6vsc/AqVD9DkGYlDHWSawqMV8ObPXEDfKH
    YpXg3oMgsE3S5Xu54UGwzjZqTPpiBTY06Ks331w9K6h+rIsU6FCS0znWnayLkpe6S/ko7q
    GjFMk5+B8unbsiMKvr3ppCVVN+W90pV7YOAIcFB2LNfs7nO+eJtc/aQCw95w+8HjeGCIFs
    9swbc31N2gxxHf8qXsXraSk0a0TxKttdZ39BSnASmbIcBOIFx8xVf5ylqJDg
X-ME-Proxy: <xmx:qMutavj0rxEtI2mKXnxhchICZTn63fypVh2OmkCmkAyY6oobO0b4FQ>
    <xmx:qMutav3xVsp80jeb6qHm0MP-S7frUPT99LxDSHf7eQqcgAE0_t3wpA>
    <xmx:qMutaoK29xHR5whBUEpNxxsMISjgEI8DQD0RW2iD_VwGkTn0uXtiNg>
    <xmx:qMutavzcI6TJiipsW9a-O0A9GF7zh4gnFP1WoeBP36zc0CobHjTH0w>
    <xmx:qcutarN5WnxxTWdstSteuTBwIbh0E_s-8LEbOoXREJCAbznkStoZeiS4>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Fri,
 18 Sep 2026 19:39:18 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Chuck Lever" <cel@kernel.org>
Cc: "Jeff Layton" <jlayton@kernel.org>,
 "Olga Kornievskaia" <okorniev@redhat.com>, "Dai Ngo" <Dai.Ngo@oracle.com>,
 "Tom Talpey" <tom@talpey.com>, "Rick Macklem" <rmacklem@uoguelph.ca>,
 linux-nfs@vger.kernel.org, "Chuck Lever" <cel@kernel.org>
Subject:
 Re: [PATCH v5 11/11] NFSD: Remove DRC checksum and payload_misses stat
In-reply-to: <20260918-duplicate-reply-cache-v5-11-b6aba9ebf2f4@kernel.org>
References: <20260918-duplicate-reply-cache-v5-0-b6aba9ebf2f4@kernel.org>
  <20260918-duplicate-reply-cache-v5-11-b6aba9ebf2f4@kernel.org>
Date: Sat, 19 Sep 2026 09:39:14 +1000
Message-id: <178977475436.207413.9806283444174908649@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Sat, 19 Sep 2026, Chuck Lever wrote:
> nfsd_cache_csum() costs CPU on every non-idempotent request. It also
> prevents the use of zero-copy RDMA receives for WRITE and SYMLINK
> because the payload must be in the server's memory before the DRC
> lookup can run.
>=20
> Commit 01a7decf7593 ("nfsd: keep a checksum of the first 256 bytes
> of request") added the checksum when a growing cache made XID
> collisions easier to hit. It is the only guard against a reused
> XID: two calls with the same procedure and equal-length arguments
> match on every other key field.
>=20
> Acknowledgment-based eviction retires a TCP or RDMA entry once the
> transport confirms delivery and a later request from the same
> connection visits its bucket. Three kinds of entry outlast that: the
> entries a connection has issued since it last visited each bucket,
> entries from a connection the client has since closed, which no
> later request can evict because their transport is gone, and UDP
> entries. Those wait out RC_EXPIRE. A collision needs the same XID
> from the same address and port within that window. The Linux NFS
> client's XIDs are sequential from a seed drawn with
> get_random_u32(), so an XID recurs only after 2^32 calls, and a
> rebooted client does not replay its previous sequence. A client that
> restarts its sequence from a fixed value and rebinds its previous
> source port within RC_EXPIRE is unguarded, but a client that repeats
> a live XID cannot reliably match replies to its own calls anyway.
>=20
> An acknowledged entry stays in its bucket until the next prune
> visits it, and a lookup matches it in the meantime. The client
> already holds that reply, so treat a call carrying its XID as a
> miss: evict the entry and insert the new one in its place.

I don't follow the logic here.
If we get a request on a particular transport and it is a good match
for a request that we recently replied to on the same transport, then
the chance of it being a timed-out retransmit is 100%.  A client that
re-uses xids that quickly is buggy, isn't it?
So if nfsd_cacherep_acked() then I think we can ignore the request.
In fact if the "found" reply was sent on the same xprt that we received
a new request on, I think we can ignore the new request even if the
reply hasn't been acked yet.

Everything else in the series is good and I really appreciate how
thoroughly you have explained the logic in a lot of places.

Thanks,
NeilBrown


>=20
> Remove the checksum, the nfsd_drc_mismatch tracepoint, and the
> payload_misses stat that counted checksum-detected collisions.
> nfsd_dispatch() no longer snapshots the argument stream before
> decoding, and with k_csum gone, struct nfsd_cacherep shrinks to 136
> bytes.
>=20
> The "payload misses" line disappears from
> /proc/fs/nfsd/reply_cache_stats. No known userspace tool parses it.
>=20
> Assisted-by: LLM
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      |  11 +--
>  fs/nfsd/cache.h                                    |   9 +-
>  fs/nfsd/netns.h                                    |   2 -
>  fs/nfsd/nfscache.c                                 | 103 +++++------------=
----
>  fs/nfsd/nfssvc.c                                   |  10 +-
>  fs/nfsd/stats.h                                    |   5 -
>  fs/nfsd/trace.h                                    |  24 -----
>  7 files changed, 28 insertions(+), 136 deletions(-)
>=20
> diff --git a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats b/Docu=
mentation/ABI/testing/procfs-nfsd-reply_cache_stats
> index 57ed5f8e6597..7a22ac7c1ccd 100644
> --- a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
> +++ b/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats
> @@ -19,19 +19,16 @@ Description:
>  		cache misses             s64     Requests not found in cache
>  		not cached               s64     Idempotent requests that
>  		                                 bypass the cache
> -		payload misses           s64     XID matched but request
> -		                                 checksum did not
>  		longest chain len        u32     Longest hash chain observed
>  		cachesize at longest     u32     Cache size when longest
>  		                                 chain was recorded
>  		=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D  =
=3D=3D=3D=3D=3D=3D  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D
> =20
>  		Counter fields (cache hits, cache misses, not cached,
> -		payload misses, mem usage) are maintained with per-cpu
> -		counters and may briefly show stale values under
> -		concurrent load. There is no way to reset these
> -		counters; consumers should compute rates by sampling
> -		over time.
> +		mem usage) are maintained with per-cpu counters and
> +		may briefly show stale values under concurrent load.
> +		There is no way to reset these counters; consumers
> +		should compute rates by sampling over time.
> =20
>  		New fields may be appended in future kernels. Parsers
>  		should match on field name, not line position.
> diff --git a/fs/nfsd/cache.h b/fs/nfsd/cache.h
> index 894e0b61cbfc..3491a10524d7 100644
> --- a/fs/nfsd/cache.h
> +++ b/fs/nfsd/cache.h
> @@ -22,9 +22,7 @@ struct nfsd_net;
>   */
>  struct nfsd_cacherep {
>  	struct {
> -		/* Keep often-read xid, csum in the same cache line: */
>  		__be32			k_xid;
> -		__wsum			k_csum;
>  		u32			k_proc;
>  		u32			k_prot;
>  		u32			k_vers;
> @@ -80,15 +78,12 @@ enum {
>  /* Cache entries expire after this time period */
>  #define RC_EXPIRE		(120 * HZ)
> =20
> -/* Checksum this amount of the request */
> -#define RC_CSUMLEN		(256U)
> -
>  int	nfsd_drc_slab_create(void);
>  void	nfsd_drc_slab_free(void);
>  int	nfsd_reply_cache_init(struct nfsd_net *);
>  void	nfsd_reply_cache_shutdown(struct nfsd_net *);
> -int	nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
> -			  unsigned int len, struct nfsd_cacherep **cacherep);
> +int	nfsd_cache_lookup(struct svc_rqst *rqstp,
> +			  struct nfsd_cacherep **cacherep);
>  void	nfsd_cache_update(struct svc_rqst *rqstp, struct nfsd_cacherep *rp,
>  			  int cachetype, __be32 *statp);
>  void	nfsd_cache_reply_sent(struct svc_rqst *rqstp);
> diff --git a/fs/nfsd/netns.h b/fs/nfsd/netns.h
> index 0ce7da20aba3..30231b9027dd 100644
> --- a/fs/nfsd/netns.h
> +++ b/fs/nfsd/netns.h
> @@ -39,8 +39,6 @@ enum nfsd_net_flag {
>  };
> =20
>  enum {
> -	/* cache misses due only to checksum comparison failures */
> -	NFSD_STATS_PAYLOAD_MISSES,
>  	/* amount of memory (in bytes) currently consumed by the DRC */
>  	NFSD_STATS_DRC_MEM_USAGE,
>  	NFSD_STATS_RC_HITS,		/* repcache hits */
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index 41b8098d3528..f5bc29cd8eee 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -13,10 +13,8 @@
>  #include <linux/slab.h>
>  #include <linux/vmalloc.h>
>  #include <linux/sunrpc/addr.h>
> -#include <linux/highmem.h>
>  #include <linux/log2.h>
>  #include <linux/hash.h>
> -#include <net/checksum.h>
> =20
>  #include "nfsd.h"
>  #include "nfserr.h"
> @@ -91,8 +89,7 @@ nfsd_hashsize(unsigned int limit)
>  }
> =20
>  static struct nfsd_cacherep *
> -nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
> -		    struct nfsd_net *nn)
> +nfsd_cacherep_alloc(struct svc_rqst *rqstp, struct nfsd_net *nn)
>  {
>  	struct nfsd_cacherep *rp;
> =20
> @@ -111,7 +108,6 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
>  		rp->c_key.k_prot =3D rqstp->rq_prot;
>  		rp->c_key.k_vers =3D rqstp->rq_vers;
>  		rp->c_key.k_len =3D rqstp->rq_arg.len;
> -		rp->c_key.k_csum =3D csum;
>  		rp->c_xprt =3D rqstp->rq_xprt->xpt_id;
>  		rp->c_inflight =3D 0;
>  		rp->c_pos =3D 0;
> @@ -377,68 +373,10 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct=
 shrink_control *sc)
>  	return freed;
>  }
> =20
> -/**
> - * nfsd_cache_csum - Checksum incoming NFS Call arguments
> - * @buf: buffer containing a whole RPC Call message
> - * @start: starting byte of the NFS Call header
> - * @remaining: size of the NFS Call header, in bytes
> - *
> - * Compute a weak checksum of the leading bytes of an NFS procedure
> - * call header to help verify that a retransmitted Call matches an
> - * entry in the duplicate reply cache.
> - *
> - * To avoid assumptions about how the RPC message is laid out in
> - * @buf and what else it might contain (eg, a GSS MIC suffix), the
> - * caller passes us the exact location and length of the NFS Call
> - * header.
> - *
> - * Returns a 32-bit checksum value, as defined in RFC 793.
> - */
> -static __wsum nfsd_cache_csum(struct xdr_buf *buf, unsigned int start,
> -			      unsigned int remaining)
> -{
> -	unsigned int base, len;
> -	struct xdr_buf subbuf;
> -	__wsum csum =3D 0;
> -	void *p;
> -	int idx;
> -
> -	if (remaining > RC_CSUMLEN)
> -		remaining =3D RC_CSUMLEN;
> -	if (xdr_buf_subsegment(buf, &subbuf, start, remaining))
> -		return csum;
> -
> -	/* rq_arg.head first */
> -	if (subbuf.head[0].iov_len) {
> -		len =3D min_t(unsigned int, subbuf.head[0].iov_len, remaining);
> -		csum =3D csum_partial(subbuf.head[0].iov_base, len, csum);
> -		remaining -=3D len;
> -	}
> -
> -	/* Continue into page array */
> -	idx =3D subbuf.page_base / PAGE_SIZE;
> -	base =3D subbuf.page_base & ~PAGE_MASK;
> -	while (remaining) {
> -		p =3D page_address(subbuf.pages[idx]) + base;
> -		len =3D min_t(unsigned int, PAGE_SIZE - base, remaining);
> -		csum =3D csum_partial(p, len, csum);
> -		remaining -=3D len;
> -		base =3D 0;
> -		++idx;
> -	}
> -	return csum;
> -}
> -
>  static int
>  nfsd_cache_key_cmp(const struct nfsd_cacherep *key,
> -		   const struct nfsd_cacherep *rp, struct nfsd_net *nn)
> +		   const struct nfsd_cacherep *rp)
>  {
> -	if (key->c_key.k_xid =3D=3D rp->c_key.k_xid &&
> -	    key->c_key.k_csum !=3D rp->c_key.k_csum) {
> -		nfsd_stats_payload_misses_inc(nn);
> -		trace_nfsd_drc_mismatch(nn, key, rp);
> -	}
> -
>  	return memcmp(&key->c_key, &rp->c_key, sizeof(key->c_key));
>  }
> =20
> @@ -462,7 +400,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct nfs=
d_cacherep *key,
>  		parent =3D *p;
>  		rp =3D rb_entry(parent, struct nfsd_cacherep, c_node);
> =20
> -		cmp =3D nfsd_cache_key_cmp(key, rp, nn);
> +		cmp =3D nfsd_cache_key_cmp(key, rp);
>  		if (cmp < 0)
>  			p =3D &parent->rb_left;
>  		else if (cmp > 0)
> @@ -491,28 +429,23 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct n=
fsd_cacherep *key,
>  /**
>   * nfsd_cache_lookup - Find an entry in the duplicate reply cache
>   * @rqstp: Incoming Call to find
> - * @start: starting byte in @rqstp->rq_arg of the NFS Call header
> - * @len: size of the NFS Call header, in bytes
>   * @cacherep: OUT: DRC entry for this request
>   *
> - * Try to find an entry matching the current call in the cache. When none
> - * is found, we try to grab the oldest expired entry off the LRU list. If
> - * a suitable one isn't there, then drop the cache_lock and allocate a
> - * new one, then search again in case one got inserted while this thread
> - * didn't hold the lock.
> + * On a miss, the entry created for this call is returned in
> + * @cacherep. On a hit, the cached reply is encoded into @rqstp's
> + * response.
>   *
>   * Return values:
>   *   %RC_DOIT: Process the request normally
>   *   %RC_REPLY: Reply from cache
>   *   %RC_DROPIT: Do not process the request further
>   */
> -int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigned int start,
> -		      unsigned int len, struct nfsd_cacherep **cacherep)
> +int nfsd_cache_lookup(struct svc_rqst *rqstp,
> +		      struct nfsd_cacherep **cacherep)
>  {
>  	struct nfsd_net		*nn =3D net_generic(SVC_NET(rqstp), nfsd_net_id);
>  	struct nfsd_thread_local_info *ntli =3D rqstp->rq_private;
>  	struct nfsd_cacherep	*rp, *found;
> -	__wsum			csum;
>  	struct nfsd_drc_bucket	*b;
>  	int type =3D ntli->ntli_cachetype;
>  	LIST_HEAD(dispose);
> @@ -524,21 +457,29 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigne=
d int start,
>  		goto out;
>  	}
> =20
> -	csum =3D nfsd_cache_csum(&rqstp->rq_arg, start, len);
> -
>  	/*
>  	 * Since the common case is a cache miss followed by an insert,
>  	 * preallocate an entry.
>  	 */
> -	rp =3D nfsd_cacherep_alloc(rqstp, csum, nn);
> +	rp =3D nfsd_cacherep_alloc(rqstp, nn);
>  	if (!rp)
>  		goto out;
> =20
>  	b =3D nfsd_cache_bucket_find(rqstp->rq_xid, nn);
>  	spin_lock(&b->cache_lock);
>  	found =3D nfsd_cache_insert(b, rp, nn);
> -	if (found !=3D rp)
> -		goto found_entry;
> +	if (found !=3D rp) {
> +		/*
> +		 * The client already holds the reply for an acknowledged
> +		 * entry, so a call carrying its XID is a new call.
> +		 */
> +		if (!nfsd_cacherep_acked(found, rqstp->rq_xprt))
> +			goto found_entry;
> +		trace_nfsd_drc_evict_acked(nn, found);
> +		nfsd_cacherep_unlink_locked(nn, b, found);
> +		list_add(&found->c_lru, &dispose);
> +		nfsd_cache_insert(b, rp, nn);
> +	}
>  	*cacherep =3D rp;
>  	rp->c_state =3D RC_INPROG;
>  	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
> @@ -737,8 +678,6 @@ int nfsd_reply_cache_stats_show(struct seq_file *m, voi=
d *v)
>  		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]));
>  	seq_printf(m, "not cached:            %lld\n",
>  		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]));
> -	seq_printf(m, "payload misses:        %lld\n",
> -		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]));
>  	seq_printf(m, "longest chain len:     %u\n", nn->longest_chain);
>  	seq_printf(m, "cachesize at longest:  %u\n", nn->longest_chain_cachesize);
>  	return 0;
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 6fc54399cb90..07e5e8549f6d 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -1005,7 +1005,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
>  	const struct svc_procedure *proc =3D rqstp->rq_procinfo;
>  	__be32 *statp =3D rqstp->rq_accept_statp;
>  	struct nfsd_cacherep *rp;
> -	unsigned int start, len;
>  	__be32 *nfs_reply;
> =20
>  	/*
> @@ -1014,13 +1013,6 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
>  	 */
>  	ntli->ntli_cachetype =3D proc->pc_cachetype;
> =20
> -	/*
> -	 * ->pc_decode advances the argument stream past the NFS
> -	 * Call header, so grab the header's starting location and
> -	 * size now for the call to nfsd_cache_lookup().
> -	 */
> -	start =3D xdr_stream_pos(&rqstp->rq_arg_stream);
> -	len =3D xdr_stream_remaining(&rqstp->rq_arg_stream);
>  	if (!proc->pc_decode(rqstp, &rqstp->rq_arg_stream))
>  		goto out_decode_err;
> =20
> @@ -1034,7 +1026,7 @@ int nfsd_dispatch(struct svc_rqst *rqstp)
>  	smp_store_release(&rqstp->rq_status_counter, rqstp->rq_status_counter | 1=
);
> =20
>  	rp =3D NULL;
> -	switch (nfsd_cache_lookup(rqstp, start, len, &rp)) {
> +	switch (nfsd_cache_lookup(rqstp, &rp)) {
>  	case RC_DOIT:
>  		break;
>  	case RC_REPLY:
> diff --git a/fs/nfsd/stats.h b/fs/nfsd/stats.h
> index aabfbb1a9c71..4a556dfbf64a 100644
> --- a/fs/nfsd/stats.h
> +++ b/fs/nfsd/stats.h
> @@ -97,11 +97,6 @@ static inline void nfsd_stats_io_write_add(struct nfsd_n=
et *nn,
>  					 amount);
>  }
> =20
> -static inline void nfsd_stats_payload_misses_inc(struct nfsd_net *nn)
> -{
> -	percpu_counter_inc(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]);
> -}
> -
>  /**
>   * nfsd_stats_drc_mem_usage_add - Add memory used by a cache item
>   * @nn: target network namespace
> diff --git a/fs/nfsd/trace.h b/fs/nfsd/trace.h
> index 7abd46e8a752..1febb42a008f 100644
> --- a/fs/nfsd/trace.h
> +++ b/fs/nfsd/trace.h
> @@ -1536,30 +1536,6 @@ TRACE_EVENT(nfsd_drc_found,
> =20
>  );
> =20
> -TRACE_EVENT(nfsd_drc_mismatch,
> -	TP_PROTO(
> -		const struct nfsd_net *nn,
> -		const struct nfsd_cacherep *key,
> -		const struct nfsd_cacherep *rp
> -	),
> -	TP_ARGS(nn, key, rp),
> -	TP_STRUCT__entry(
> -		__field(unsigned long long, boot_time)
> -		__field(u32, xid)
> -		__field(u32, cached)
> -		__field(u32, ingress)
> -	),
> -	TP_fast_assign(
> -		__entry->boot_time =3D nn->boot_time;
> -		__entry->xid =3D be32_to_cpu(key->c_key.k_xid);
> -		__entry->cached =3D (__force u32)key->c_key.k_csum;
> -		__entry->ingress =3D (__force u32)rp->c_key.k_csum;
> -	),
> -	TP_printk("boot_time=3D%16llx xid=3D0x%08x cached-csum=3D0x%08x ingress-c=
sum=3D0x%08x",
> -		__entry->boot_time, __entry->xid, __entry->cached,
> -		__entry->ingress)
> -);
> -
>  DECLARE_EVENT_CLASS(nfsd_drc_entry_class,
>  	TP_PROTO(
>  		const struct nfsd_net *nn,
>=20
> --=20
> 2.55.0
>=20
>=20
>=20

