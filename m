Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 94EDA372B5A
	for <linux-nfs@vger.kernel.org>; Fri, 28 Aug 2026 18:38:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1787942329; cv=none; b=hRm+tcSWkhWT2L52n31ydm/InNSlAMvf00kmBhtybeMTlrMNBVfAo1A1f+P6T6Q0Bs3LXAi+qdjbhtHI4wx900nJzne17nSwMip12Jh5HQJoSPvMuZ7Z4aqe5JFuL3BE+FETce5bYHLZWRsjh+MvvWDwIjIAT+bpy+wgJoXwyG8=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1787942329; c=relaxed/simple;
	bh=BgDO/d3zcvtpT1zAora1NBFZCte4JWwujkl6MUmaLUI=;
	h=Message-ID:Subject:From:To:Cc:Date:In-Reply-To:References:
	 Content-Type:MIME-Version; b=SeEmGjGybBuJnS7+KVm/XToCVIIvRVrgDJjZk6eB8NyEGitNWc8SX+zZHM5IUp2U+G05+O408fh/TMCpOinPYxECTAibgsvEqchkjKhlstQKe3CPZVBpPej8eihM8VCFixcG4zPAqx2jzONS46/t6DVXylp6vW9B8cMORS8cKwo=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=VJAU3Kqk; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="VJAU3Kqk"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 4F5A01F00A3D;
	Fri, 28 Aug 2026 18:38:47 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1787942327;
	bh=/dk0KVKUUFLpAMgvwTDx8hVmfpUujBqV3JWRYjb/uMk=;
	h=Subject:From:To:Cc:Date:In-Reply-To:References;
	b=VJAU3Kqk2VhPwtJTI7OIUZNNIKyrLji7nKP+JqACCCp+VGMJgBgTPW9wxqE1dHLTj
	 4pdj04dUFFeJJml4YiXidXlDnc1ZcCMAuQzujo3vriUDF1ZpK2CR9Bqma/vfc2TEkB
	 xgCw5wU5F2qzIrsEvCp/lxvKD7TblbNMEQV2i9NWioFqKgIoHGgTXpW3fDx3ysOUYA
	 WaLMJhi5dbh+EqRUQwg1L+QRAM1yg79JCliExX3HtG9ArekpxqgRax9SBi7wE/DMOP
	 VcGJCxr3+5RY9rJVl7pYg912fGmJvL3pLWKDAees5/Ij/M3bClNvdn9Vf/ybtXnuH8
	 7+om2SUNwG5rA==
Message-ID: <85acfa01848e5d7829ca18ad8864410fbb5e12b7.camel@kernel.org>
Subject: Re: [PATCH v2 5/7] NFSD: Evict completed DRC entries via implied ACK
From: Jeff Layton <jlayton@kernel.org>
To: Chuck Lever <cel@kernel.org>, NeilBrown <neil@brown.name>, Olga
 Kornievskaia <okorniev@redhat.com>, Dai Ngo <Dai.Ngo@oracle.com>, Tom
 Talpey <tom@talpey.com>
Cc: Rick Macklem <rmacklem@uoguelph.ca>, linux-nfs@vger.kernel.org
Date: Fri, 28 Aug 2026 14:38:45 -0400
In-Reply-To: <20260828-duplicate-reply-cache-v2-5-25069e660a7b@kernel.org>
References: <20260828-duplicate-reply-cache-v2-0-25069e660a7b@kernel.org>
	 <20260828-duplicate-reply-cache-v2-5-25069e660a7b@kernel.org>
Autocrypt: addr=jlayton@kernel.org; prefer-encrypt=mutual;
 keydata=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
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

On Fri, 2026-08-28 at 12:17 -0400, Chuck Lever wrote:
> A completed DRC entry stays in its bucket until RC_EXPIRE elapses or
> the cache exceeds max_drc_entries. Entries whose replies the client
> already holds lengthen the bucket and slow every lookup that hashes
> there.
>=20
> RFC 1813 Section 4.5 observes that on a connection-oriented transport
> a duplicate request arises from reconnection, not from within a live
> connection. A fresh request on a live TCP or RDMA connection therefore
> means the client is not retransmitting an earlier one. UDP clients
> retransmit on timeout over a shared svc_xprt, so eviction is
> restricted to transports marked XPT_ORDERED. Even there the evidence
> is not conclusive, since a client with several requests outstanding
> sends the next before the previous reply arrives. The cache is
> advisory: a premature eviction costs a miss and re-execution, the same
> outcome memory pressure and RC_EXPIRE already produce.
>=20

No, it's not. The DRC is necessary for proper function, and if we drop
non-idempotent requests prematurely, then that could cause spurious
errors.

Or am I misunderstanding what you mean by "The cache" here?

> During bucket pruning, compare each RC_DONE entry's c_timestamp
> against xpt_last_recv on the transport the current request arrived
> on, and evict the entry when a later request has arrived. Only that
> transport is consulted, because it is the one the pruning thread holds
> a reference to. Entries recorded on other transports wait for a later
> lookup or a shrinker pass.
>=20
> Implied ACK does not evict in age order, so the loop can no longer
> stop at the first non-evictable entry. A client controls its XIDs and
> the bucket is chosen by an XID hash, so an unbounded scan lets it pack
> one bucket and turn every miss into a walk of the whole bucket under
> cache_lock. Bound the work per call to four times the eviction limit.
>=20

That said, the basic approach and code itself look OK to me overall
(modulo some nits). I think you mentioned too that BSD already takes
this approach?

> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfscache.c | 78 +++++++++++++++++++++++++++++++++++++++++++++---=
------
>  1 file changed, 66 insertions(+), 12 deletions(-)
>=20
> diff --git a/fs/nfsd/nfscache.c b/fs/nfsd/nfscache.c
> index b25b4f9e92f7..7a09a79a2d6e 100644
> --- a/fs/nfsd/nfscache.c
> +++ b/fs/nfsd/nfscache.c
> @@ -87,6 +87,34 @@ nfsd_hashsize(unsigned int limit)
>  	return roundup_pow_of_two(limit / TARGET_BUCKET_SIZE);
>  }
> =20
> +/*
> + * A later request on @xprt is taken as evidence that the client receive=
d
> + * @rp's reply. Only XPT_ORDERED transports qualify: a client does not
> + * retransmit within a live connection, but a UDP client retransmits on
> + * timeout and shares one svc_xprt with every other UDP peer, so a
> + * datagram from any of them would evict another client's reply.
> + *
> + * The evidence is not conclusive: a pipelined client sends its next
> + * request before @rp's reply arrives. The cache is advisory, so acting
> + * early costs no more than a miss and re-execution.
> + *
> + * c_timestamp is set after xpt_last_recv was recorded for @rp's own
> + * request, so a newer xpt_last_recv means a later request arrived.
> + */
> +static bool nfsd_cacherep_implied_ack(struct svc_xprt *xprt,
> +				      struct nfsd_cacherep *rp)
> +{
> +	unsigned long last_req;
> +
> +	if (!xprt || rp->c_xprt !=3D xprt->xpt_id)
> +		return false;
> +	if (!test_bit(XPT_ORDERED, &xprt->xpt_flags))
> +		return false;
> +
> +	last_req =3D READ_ONCE(xprt->xpt_last_recv);
> +	return time_after(last_req, rp->c_timestamp);
> +}
> +
>  static struct nfsd_cacherep *
>  nfsd_cacherep_alloc(struct svc_rqst *rqstp, __wsum csum,
>  		    struct nfsd_net *nn)
> @@ -257,29 +285,55 @@ nfsd_cache_bucket_find(__be32 xid, struct nfsd_net =
*nn)
>  }
> =20
>  /*
> - * Remove and return no more than @max expired entries in bucket @b.
> - * If @max is zero, do not limit the number of removed entries.
> + * Remove and return no more than @max evictable entries in bucket @b. I=
f
> + * @max is zero, do not limit the number of removed entries.
> + *
> + * @xprt is the transport the current request arrived on, or NULL when t=
he
> + * caller has none.
>   */
>  static void
>  nfsd_prune_bucket_locked(struct nfsd_net *nn, struct nfsd_drc_bucket *b,
> -			 unsigned int max, struct list_head *dispose)
> +			 unsigned int max, struct list_head *dispose,
> +			 struct svc_xprt *xprt)
>  {
>  	unsigned long expiry =3D jiffies - RC_EXPIRE;
>  	struct nfsd_cacherep *rp, *tmp;
> -	unsigned int freed =3D 0;
> +	unsigned int freed =3D 0, visited =3D 0;
> =20
>  	lockdep_assert_held(&b->cache_lock);
> =20
>  	/* The bucket LRU is ordered oldest-first. */
>  	list_for_each_entry_safe(rp, tmp, &b->lru_head, c_lru) {
> -		if (atomic_read(&nn->num_drc_entries) <=3D nn->max_drc_entries &&
> -		    time_before(expiry, rp->c_timestamp))
> +		if (atomic_read(&nn->num_drc_entries) > nn->max_drc_entries)
> +			goto evict;
> +		if (time_before_eq(rp->c_timestamp, expiry))
> +			goto evict;
> +		if (rp->c_state =3D=3D RC_DONE &&
> +		    nfsd_cacherep_implied_ack(xprt, rp))
> +			goto evict;
> +		/*
> +		 * Only implied ACK evicts out of age order, and only on an
> +		 * ordered transport; otherwise the first non-evictable entry
> +		 * ends the scan.
> +		 */
> +		if (!xprt || !test_bit(XPT_ORDERED, &xprt->xpt_flags))
>  			break;
> +		goto next;
> =20
> +evict:
>  		nfsd_cacherep_unlink_locked(nn, b, rp);
>  		list_add(&rp->c_lru, dispose);
> +		freed++;
> =20
> -		if (max && ++freed >=3D max)
> +next:
> +		/*
> +		 * A client controls its XIDs, so it can pack one bucket with
> +		 * entries that are not yet evictable and turn each miss into
> +		 * a full-bucket walk under cache_lock. Cap the work per call;
> +		 * a skipped entry is reclaimed on a later prune, under
> +		 * pressure, or at RC_EXPIRE.
> +		 */
> +		if (max && (freed >=3D max || ++visited >=3D max * 4))
>  			break;
>  	}
>  }
> @@ -307,9 +361,9 @@ nfsd_reply_cache_count(struct shrinker *shrink, struc=
t shrink_control *sc)
>   * @shrink: our registered shrinker context
>   * @sc: garbage collection parameters
>   *
> - * Free expired entries on each bucket's LRU list until we've released
> - * nr_to_scan freed objects. Nothing will be released if the cache
> - * has not exceeded it's max_drc_entries limit.
> + * Free entries on each bucket's LRU list until nr_to_scan objects have =
been
> + * released. Entries are evicted when they have expired or the cache exc=
eeds
> + * its max_drc_entries limit.
>   *
>   * Returns the number of entries released by this call.
>   */
> @@ -328,7 +382,7 @@ nfsd_reply_cache_scan(struct shrinker *shrink, struct=
 shrink_control *sc)
>  			continue;
> =20
>  		spin_lock(&b->cache_lock);
> -		nfsd_prune_bucket_locked(nn, b, 0, &dispose);
> +		nfsd_prune_bucket_locked(nn, b, 0, &dispose, NULL);
>  		spin_unlock(&b->cache_lock);
> =20
>  		freed +=3D nfsd_cacherep_dispose(&dispose);
> @@ -501,7 +555,7 @@ int nfsd_cache_lookup(struct svc_rqst *rqstp, unsigne=
d int start,
>  		goto found_entry;
>  	*cacherep =3D rp;
>  	rp->c_state =3D RC_INPROG;
> -	nfsd_prune_bucket_locked(nn, b, 3, &dispose);
> +	nfsd_prune_bucket_locked(nn, b, 3, &dispose, rqstp->rq_xprt);
>  	spin_unlock(&b->cache_lock);
> =20
>  	nfsd_cacherep_dispose(&dispose);

--=20
Jeff Layton <jlayton@kernel.org>
