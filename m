Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 373675335B3
	for <linux-nfs@vger.kernel.org>; Wed, 23 Sep 2026 14:56:06 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790175367; cv=none; b=beNeGowicO6/72gRgWI/GuaqYdpdFNhZkqgfvxTCTkUBYNhoCW3daZr+320g1TAfoEkQmH4An5Q6sXcAzKwNqLsJ78CHKrMmLKl04oHRQSevebkJJaTQMQdhnsNDO/jEqSCRAaSpc32dL4Ies17hJKf8VUVynpwwki/ChTM4Lk4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790175367; c=relaxed/simple;
	bh=coWXABGVuBNDPIepeDNnXg0SyC65J5GmPp/fG7njvNI=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=fyMWJMQJzaI6OLoJMP90ctuXUqqqOvJeqvvjMezQjc1dnNYkSIqZfH7sF5AKQOVEzQLlWx8UMoz2VWrNqJGCdt4h0YErQRuzqHM7J0meIL64v7K4mOPiVfKe1PrngcIM8VOsv0JUPBqKttXgn/hl0rM7bZx/fBSGf2dWpWdb0rY=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=DNo0CGtc; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="DNo0CGtc"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 7E2101F00893;
	Wed, 23 Sep 2026 14:56:05 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1790175366;
	bh=Ydp2xa5qmw7YDJ8P5Q9GXGXRbVHNnNLdwbibFYvtRSk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=DNo0CGtcUFT8jbp1ZTSNyKNt6zcr0Cth6QTdAf6kdGCWphFiQlCPNkcwdLjEgvxpQ
	 3HcZB+UEaNr6pN206qXkkXgW0SynDkGLygq6xlYtIWA9fP5f5TVRnitxrgxGfg9pTE
	 B8g+oG2rPwAVWbi/RBCs44m6ySEePsEqb1qRxbq8yxogk7nh9+TdgHYrsxL9Z4pkzp
	 GcwaJAaZOo52FB6pVrhUP1KOzKSZZSOgweNDseUvYWPVW8jHqXb8Q9hKkWJ0rIjn0R
	 HwT79RtZF5wOS0UNXCd4N4SMojgJS1dh3+N0/SWXtMIbvTt5FMI7/h7fqUyHyD5GyR
	 J1EMy2SIpdfLA==
Message-ID: <4fe822079c7154ba9f712ca9f7432d345dbc0783.camel@kernel.org>
Subject: Re: [PATCH v6 12/12] NFSD: Remove DRC checksum and payload_misses
 stat
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Date: Wed, 23 Sep 2026 10:56:03 -0400
In-Reply-To: <20260921-duplicate-reply-cache-v6-12-db5e13fd9944@kernel.org>
References: <20260921-duplicate-reply-cache-v6-0-db5e13fd9944@kernel.org>
	 <20260921-duplicate-reply-cache-v6-12-db5e13fd9944@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
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

On Mon, 2026-09-21 at 09:22 -0400, Chuck Lever wrote:
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
> A call whose XID matches an entry sent on the same connection is
> therefore a retransmit. TCP and RDMA deliver the queued reply or
> drop the connection, so drop the call as though the entry were
> still in progress rather than replaying it. A match from another
> connection, or from UDP, is replayed as before.
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
>  .../ABI/testing/procfs-nfsd-reply_cache_stats      | 11 +--
>  fs/nfsd/cache.h                                    |  9 +-
>  fs/nfsd/netns.h                                    |  2 -
>  fs/nfsd/nfscache.c                                 | 96 ++++------------=
------
>  fs/nfsd/nfssvc.c                                   | 10 +--
>  fs/nfsd/stats.h                                    |  5 --
>  fs/nfsd/trace.h                                    | 24 ------
>  7 files changed, 23 insertions(+), 134 deletions(-)
>=20
> diff --git a/Documentation/ABI/testing/procfs-nfsd-reply_cache_stats b/Do=
cumentation/ABI/testing/procfs-nfsd-reply_cache_stats
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
>  		=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =
 =3D=3D=3D=3D=3D=3D  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D
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
> index 2f324c2ed0c4..b1aa873e3493 100644
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
> @@ -90,8 +88,7 @@ nfsd_hashsize(unsigned int limit)
>  }
> =20
>  static struct nfsd_cacherep *
> -nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
> -		    struct nfsd_net *nn)
> +nfsd_cacherep_alloc(struct svc_rqst *rqstp, struct nfsd_net *nn)
>  {
>  	struct nfsd_cacherep *rp;
> =20
> @@ -110,7 +107,6 @@ nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum cs=
um,
>  		rp->c_key.k_prot =3D rqstp->rq_prot;
>  		rp->c_key.k_vers =3D rqstp->rq_vers;
>  		rp->c_key.k_len =3D rqstp->rq_arg.len;
> -		rp->c_key.k_csum =3D csum;
>  		rp->c_xprt =3D rqstp->rq_xprt->xpt_id;
>  		rp->c_inflight =3D 0;
>  		rp->c_pos =3D 0;
> @@ -376,68 +372,10 @@ nfsd_reply_cache_scan(struct shrinker *shrink, stru=
ct shrink_control *sc)
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
> @@ -461,7 +399,7 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct n=
fsd_cacherep *key,
>  		parent =3D *p;
>  		rp =3D rb_entry(parent, struct nfsd_cacherep, c_node);
> =20
> -		cmp =3D nfsd_cache_key_cmp(key, rp, nn);
> +		cmp =3D nfsd_cache_key_cmp(key, rp);
>  		if (cmp < 0)
>  			p =3D &parent->rb_left;
>  		else if (cmp > 0)
> @@ -490,28 +428,23 @@ nfsd_cache_insert(struct nfsd_drc_bucket *b, struct=
 nfsd_cacherep *key,
>  /**
>   * nfsd_cache_lookup - Find an entry in the duplicate reply cache
>   * @rqstp: Incoming Call to find
> - * @start: starting byte in @rqstp->rq_arg of the NFS Call header
> - * @len: size of the NFS Call header, in bytes
>   * @cacherep: OUT: DRC entry for this request
>   *
> - * Try to find an entry matching the current call in the cache. When non=
e
> - * is found, we try to grab the oldest expired entry off the LRU list. I=
f
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
> @@ -523,13 +456,11 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsig=
ned int start,
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
> @@ -561,6 +492,13 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsign=
ed int start,
>  	if (rp->c_state =3D=3D RC_INPROG)
>  		goto out_trace;
> =20
> +	/*
> +	 * The connection that carried the reply delivers it, so a
> +	 * retransmit on that connection needs no replay.
> +	 */
> +	if (rp->c_pos && rp->c_xprt =3D=3D rqstp->rq_xprt->xpt_id)
> +		goto out_trace;
> +

This patch seems to break pynfs RPLY14, which does a mkdir and then a
replay of it later.

The test is arguably broken though, since it does the replay over the
same connection as the original request. I'm looking into fixing that
(and will check for others that might be similarly problematic).

>  	/* From the hall of fame of impractical attacks:
>  	 * Is this a user who tries to snoop on the cache? */
>  	rtn =3D RC_DOIT;
> @@ -736,8 +674,6 @@ int nfsd_reply_cache_stats_show(struct seq_file *m, v=
oid *v)
>  		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_MISSES]));
>  	seq_printf(m, "not cached:            %lld\n",
>  		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_RC_NOCACHE]));
> -	seq_printf(m, "payload misses:        %lld\n",
> -		   percpu_counter_sum_positive(&nn->counter[NFSD_STATS_PAYLOAD_MISSES]=
));
>  	seq_printf(m, "longest chain len:     %u\n", nn->longest_chain);
>  	seq_printf(m, "cachesize at longest:  %u\n", nn->longest_chain_cachesiz=
e);
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
>  	smp_store_release(&rqstp->rq_status_counter, rqstp->rq_status_counter |=
 1);
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
> @@ -97,11 +97,6 @@ static inline void nfsd_stats_io_write_add(struct nfsd=
_net *nn,
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
> -	TP_printk("boot_time=3D%16llx xid=3D0x%08x cached-csum=3D0x%08x ingress=
-csum=3D0x%08x",
> -		__entry->boot_time, __entry->xid, __entry->cached,
> -		__entry->ingress)
> -);
> -
>  DECLARE_EVENT_CLASS(nfsd_drc_entry_class,
>  	TP_PROTO(
>  		const struct nfsd_net *nn,

--=20
Jeff Layton <jlayton@kernel.org>
