Received: from fout-a5-smtp.messagingengine.com (fout-a5-smtp.messagingengine.com [103.168.172.148])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 646C2485936;
	Tue, 22 Sep 2026 06:37:59 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=103.168.172.148
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1790059082; cv=none; b=jMjvJER8agMP+Zw8muE35A//cNtg9BNrJAx8wCQm5fzHJfr1m+ihK6SkvAdBufjm3ClMB7ZnmKg6tkk6x0YJBLKAwXdRB+v89SpNK8Tw/3tDshzsu0rnkEMTf+NOqaflYutqcuSdfDI9p4hrb8SpT7q6wZYzJcR1u/64aY/mdb0=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1790059082; c=relaxed/simple;
	bh=Z+QfpyS5qDgu38mkp/qyWdSQGLmFDSPC+pg9fTRpY6A=;
	h=Content-Type:MIME-Version:From:To:Cc:Subject:In-reply-to:
	 References:Date:Message-id; b=chbi4nSSZUGRAXHkTpLlIdb0cqYrScM8fD0brQyp9yFB49q+xixVq4oNFIq6hGETzUCxCXZl/0b+GMSh0V0SMEDxxcnNROw6NgBT/PCEB/YAIiwwOrCRM/40N65JFxn2j60+iCuUJwDGG/f1wmhnx70nlV5paJ3knPm3dVc7w2Q=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net; spf=pass smtp.mailfrom=ownmail.net; dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b=T6WzhdIL; dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b=df7m0l4+; arc=none smtp.client-ip=103.168.172.148
Authentication-Results: smtp.subspace.kernel.org; dmarc=pass (p=none dis=none) header.from=ownmail.net
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=ownmail.net
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=ownmail.net header.i=@ownmail.net header.b="T6WzhdIL";
	dkim=pass (2048-bit key) header.d=messagingengine.com header.i=@messagingengine.com header.b="df7m0l4+"
Received: from phl-compute-06.internal (phl-compute-06.internal [10.202.2.46])
	by mailfout.phl.internal (Postfix) with ESMTP id 43445EC025A;
	Tue, 22 Sep 2026 02:37:58 -0400 (EDT)
Received: from phl-frontend-03 ([10.202.2.162])
  by phl-compute-06.internal (MEProxy); Tue, 22 Sep 2026 02:37:58 -0400
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=ownmail.net; h=
	cc:cc:content-transfer-encoding:content-type:content-type:date
	:date:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to; s=fm1; t=
	1790059078; x=1790145478; bh=/FIQoBE8emqVxFEcdiqwkd7zKkcYKY75XVd
	VvZycBrw=; b=T6WzhdIL9UW4tVKCHSd5mUkJXUPsnoxuZEYwI99L7vBC+wThMag
	2wFlYyQPTaLbDpXTg9vE43KE8L4bAPt87AorFS/SsFfKEiQZATz/op6D3SAWEuJW
	bzlaxeUgjxfDTh/OSSnBYo9kiTNMGxxTSV+ri5Anm5zmZ1Rb6zghKFI669EY2fFe
	POA5XKi4iKX3fBYNC+7W9+xqO7pNpeBJlHWIdGXlzRXdsi6l9HSPWBHMC2ehntvB
	TqKx6X5v3xJ/PhM5IsYwdXkEkbaJWum6WImnfII7M0wZg9WSt1757vo/aVSfz1Ys
	E9U23ENBa1mh1ee8xDXaYORPQKvgY9WdmPQ==
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=
	messagingengine.com; h=cc:cc:content-transfer-encoding
	:content-type:content-type:date:date:feedback-id:feedback-id
	:from:from:in-reply-to:in-reply-to:message-id:mime-version
	:references:reply-to:reply-to:subject:subject:to:to:x-me-proxy
	:x-me-sender:x-me-sender:x-sasl-enc; s=fm1; t=1790059078; x=
	1790145478; bh=/FIQoBE8emqVxFEcdiqwkd7zKkcYKY75XVdVvZycBrw=; b=d
	f7m0l4+jx+MCRlMlGstvviltnrlaV1ukmWC5uHaF01UqLhl+D7M31Sa1q6ODCICw
	RttdiW9tS695agRSwAWpkQYQUwIJ3B27O/9VPAMufIz3ejmI4hjFlbCTcCYGfC5k
	t+iVsOlFf+mjXJNEtuI2TgN4q9TYP2WWvbnmYdHNK0oVTARrQfuAF00Jd5snIskg
	ZR5aJaqt5eUra3qHgJ/ZP69fY1x3j7MF4M9D9GjPq/SlnpfCHPCK9mUhIuAKdI25
	QFWXUHZmuYd5j/XoeQQjn/VdRdDG0OMdozYiLDZ2tSP0SkKZC9xrrLTZPOUr8OJC
	RN7uq40Z5Qo7hhz/BhjGQ==
X-ME-Sender: <xms:RSKyatIQ4JkoEj2zrmI1Z6wLzEW1tMwVm_0kc0MeVt8ZRzST6Mm1_w>
    <xme:RSKyapmLvYK2SrJZgIwnGrk26s6_Ghmjt5O3JIWhMmCPuK0AvDXy5PIKNRKASwRm7
    cCjyrR3CCP7OtrdHxYHH8qM7qSeKVNqSyKOkZmnnC4yH7N7gQ>
X-ME-Received: <xmr:RSKyambiMh6IW4TwBXjpYj1dweytL55J386T4sENAS52BR5DV9osYzor3OO8fhRvXvw9QxSo6dXjsh_jJSHGrwyBOMADr3I>
X-ME-Proxy-Cause: dmFkZTE2UsV6fzuS0xZ1a0qIg/rZx9Yr9yus3xrEBXIjhzSHggxp05Fja2/M7LIF1iZ1g+
    EwnVNvjY6xzm/M6XZfEryeeyoQwJBGawfIa8lX/xpYKRJ3kiwW3mvMxxtzvxihD54HP1yh
    uWoeZCxUE4TA1hUDmFwGzejtuBgHx24uArLjxhZTA2yRCNmjOW5TVDljUG0hSkIhmb8uvV
    FeCe9Z0znrAKBuC/zZe34IW3502mQB2rs3gZijMLxYJKCaOcGOEBDEqKebE6dgzUqvAX6m
    DaHyW+nWq+WqhceAQaBoPgnURlPa8kR2U4+OXpcdoMhl3l1qXUNF2xenEbpZWJL3+Fp0dZ
    lapmHbbAdHx7wra7HTLxN3L9XVfGwtnRSEEAYhIhTXZTZfInD2MSqI4cyXDvKUoSG4E4Tv
    krOsg2fqon0iWt+xqLFGtC/4QmaFZ2+Zxlf3ZuSY07oMYeL7F27UqYi4XGFZM+BDvjpdcZ
    REUptd13HXr8OeuHsRlzgGaizHWVvyvf/ZMyCpjTKGJfG+Fxn9h4LihBc/yk6QORe1CCnA
    FL1RzxYoL0jYW4Q4nlA17C93RUZW11YLVdheNezmXsxtn8mWKiomB16Al7k3dRR4FNuQRl
    L/PFIkZ4KzXhYvY2j9SxX28jCpR06cep7HB9OUPzcYnhWVIr64kLEVKsKh2w
X-ME-Proxy: <xmx:RSKyal_w5TSxXj3R15nxCmGjuGpZmxlJV7P6RQy5QMpxVXEkLW5DDQ>
    <xmx:RiKyalbrFokXAZ7ZQskq7LF-Qg6PcGDl66ufkYM0H4FtnnfrgEBjSQ>
    <xmx:RiKyavd47q0qwpk0_xZ7pIavSmviNiai8CM64OAyfippOUB0Sxo_Yw>
    <xmx:RiKyailDCWH7o2l711M13IxQIlUJjjOelX3-3V_nZ7YV-vwnUVIlzA>
    <xmx:RiKyas0b1n6H1REt-oaVnj-sbipoGsXbWw-at165LdMDpuL8HaXTBcdo>
Feedback-ID: i9d664b8f:Fastmail
Received: by mail.messagingengine.com (Postfix) with ESMTPA; Tue,
 22 Sep 2026 02:37:55 -0400 (EDT)
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: quoted-printable
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
From: NeilBrown <neilb@ownmail.net>
To: "Jeff Layton" <jlayton@kernel.org>
Cc: "Chuck Lever" <cel@kernel.org>, "Olga Kornievskaia" <okorniev@redhat.com>,
 "Dai Ngo" <Dai.Ngo@oracle.com>, "Tom Talpey" <tom@talpey.com>,
 "Shuah Khan" <shuah@kernel.org>, linux-nfs@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org,
 "Jeff Layton" <jlayton@kernel.org>
Subject: Re: [PATCH 5/8] nfsd: give the open file cache its own mutex
In-reply-to: <20260921-nfsd-per-net-mutex-v1-5-4a7287f6504c@kernel.org>
References: <20260921-nfsd-per-net-mutex-v1-0-4a7287f6504c@kernel.org>
  <20260921-nfsd-per-net-mutex-v1-5-4a7287f6504c@kernel.org>
Date: Tue, 22 Sep 2026 16:37:51 +1000
Message-id: <179005907144.37859.15558964767750002575@noble.neil.brown.name>
Reply-To: NeilBrown <neil@brown.name>

On Tue, 22 Sep 2026, Jeff Layton wrote:
> nfsd_global_mutex still serializes file cache flushes against server
> start/stop in unrelated namespaces. nfsd_file_cache_purge() is reached from
> expkey_flush() on every "exportfs -f", which makes it the only frequent
> taker of the global lock -- and it has nothing to do with nfsd_users or the
> NFSv4 global tables it would be waiting on.
>=20
> Move NFSD_FILE_CACHE_UP and the objects it covers (rhltable, LRU, slabs,
> shrinker, fsnotify groups) onto a nfsd_file_cache_mutex private to
> filecache.c. nfsd_file_cache_init() and nfsd_file_cache_shutdown() take it
> themselves rather than asserting the caller holds the global one, so
> nfssvc.c no longer needs to know how the cache locks itself.
>=20
> nfsd_global_mutex is left holding only nfsd_users, the notifier count and
> user_recovery_dirname, all of which are touched solely on server
> start/stop.
>=20
> Ordering is nn->nfsd_mutex outside nfsd_global_mutex outside
> nfsd_file_cache_mutex. The cache mutex is reached three ways, all
> consistent with that: from nfsd_startup_generic()/nfsd_shutdown_generic()
> under the global mutex, from nfsd_shutdown_net() under nn->nfsd_mutex, and
> bare from expkey_flush() and the filecache stats file. Nothing called with
> the cache mutex held takes either of the others.
>=20
> Assisted-by: LLM
> Signed-off-by: Jeff Layton <jlayton@kernel.org>
> ---
>  fs/nfsd/filecache.c | 39 ++++++++++++++++++++++++++++-----------
>  fs/nfsd/nfssvc.c    |  9 +++++----
>  2 files changed, 33 insertions(+), 15 deletions(-)
>=20
> diff --git a/fs/nfsd/filecache.c b/fs/nfsd/filecache.c
> index 501772bc8f8d..179362e5394b 100644
> --- a/fs/nfsd/filecache.c
> +++ b/fs/nfsd/filecache.c
> @@ -67,6 +67,17 @@
>   */
>  static DEFINE_SPINLOCK(nfsd_gc_lock);
> =20
> +/*
> + * Guards NFSD_FILE_CACHE_UP and the host-wide objects it covers: the
> + * rhltable, the LRU, the slabs, the shrinker and the fsnotify groups.
> + * Held across cache bring-up and teardown, and by readers and walkers
> + * that need the cache to stay up for the duration (->cache_purge, the
> + * stats file).
> + *
> + * Nests inside nfsd_global_mutex and inside nn->nfsd_mutex.
> + */
> +static DEFINE_MUTEX(nfsd_file_cache_mutex);
> +
>  static DEFINE_PER_CPU(unsigned long, nfsd_file_cache_hits);
>  static DEFINE_PER_CPU(unsigned long, nfsd_file_acquisitions);
>  static DEFINE_PER_CPU(unsigned long, nfsd_file_allocations);
> @@ -869,9 +880,11 @@ nfsd_file_cache_init(void)
>  {
>  	int ret;
> =20
> -	lockdep_assert_held(&nfsd_global_mutex);
> -	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 1)
> +	mutex_lock(&nfsd_file_cache_mutex);

What would you think of making this

   guard(mutex)(&nfsd_file_cache_mutex);

so you don't need to make other changes in this function??

NeilBrown


> +	if (test_and_set_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 1) {
> +		mutex_unlock(&nfsd_file_cache_mutex);
>  		return 0;
> +	}
> =20
>  	ret =3D rhltable_init(&nfsd_file_rhltable, &nfsd_file_rhash_params);
>  	if (ret)
> @@ -937,6 +950,7 @@ nfsd_file_cache_init(void)
>  out:
>  	if (ret)
>  		clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags);
> +	mutex_unlock(&nfsd_file_cache_mutex);
>  	return ret;
>  out_notify_group:
>  	fsnotify_put_group(nfsd_file_fsnotify_group);
> @@ -1011,16 +1025,16 @@ nfsd_file_cache_start_net(struct net *net)
>   * nfsd_file_cache_purge - Remove all cache items associated with @net
>   * @net: target net namespace
>   *
> - * Takes nfsd_global_mutex so the cache cannot be torn down underneath the
> - * walk.  Callers must not already hold it.
> + * Takes nfsd_file_cache_mutex so the cache cannot be torn down underneath
> + * the walk.  Callers must not already hold it.
>   */
>  void
>  nfsd_file_cache_purge(struct net *net)
>  {
> -	mutex_lock(&nfsd_global_mutex);
> +	mutex_lock(&nfsd_file_cache_mutex);
>  	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 1)
>  		__nfsd_file_cache_purge(net);
> -	mutex_unlock(&nfsd_global_mutex);
> +	mutex_unlock(&nfsd_file_cache_mutex);
>  }
> =20
>  void
> @@ -1045,9 +1059,11 @@ nfsd_file_cache_shutdown(void)
>  {
>  	int i;
> =20
> -	lockdep_assert_held(&nfsd_global_mutex);
> -	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 0)
> +	mutex_lock(&nfsd_file_cache_mutex);
> +	if (test_and_clear_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 0) {
> +		mutex_unlock(&nfsd_file_cache_mutex);
>  		return;
> +	}
> =20
>  	lease_unregister_notifier(&nfsd_file_lease_notifier);
>  	shrinker_free(nfsd_file_shrinker);
> @@ -1078,6 +1094,7 @@ nfsd_file_cache_shutdown(void)
>  		per_cpu(nfsd_file_total_age, i) =3D 0;
>  		per_cpu(nfsd_file_evictions, i) =3D 0;
>  	}
> +	mutex_unlock(&nfsd_file_cache_mutex);
>  }
> =20
>  static struct nfsd_file *
> @@ -1476,8 +1493,8 @@ int nfsd_file_cache_stats_show(struct seq_file *m, vo=
id *v)
>  	unsigned int i, count =3D 0, buckets =3D 0;
>  	unsigned long lru =3D 0, total_age =3D 0;
> =20
> -	/* Serialize with server shutdown */
> -	mutex_lock(&nfsd_global_mutex);
> +	/* Serialize with cache teardown */
> +	mutex_lock(&nfsd_file_cache_mutex);
>  	if (test_bit(NFSD_FILE_CACHE_UP, &nfsd_file_flags) =3D=3D 1) {
>  		struct bucket_table *tbl;
>  		struct rhashtable *ht;
> @@ -1491,7 +1508,7 @@ int nfsd_file_cache_stats_show(struct seq_file *m, vo=
id *v)
>  		buckets =3D tbl->size;
>  		rcu_read_unlock();
>  	}
> -	mutex_unlock(&nfsd_global_mutex);
> +	mutex_unlock(&nfsd_file_cache_mutex);
> =20
>  	for_each_possible_cpu(i) {
>  		hits +=3D per_cpu(nfsd_file_cache_hits, i);
> diff --git a/fs/nfsd/nfssvc.c b/fs/nfsd/nfssvc.c
> index 5cb92c3829f9..b2c215775e08 100644
> --- a/fs/nfsd/nfssvc.c
> +++ b/fs/nfsd/nfssvc.c
> @@ -66,11 +66,12 @@ static __be32			nfsd_init_request(struct svc_rqst *,
>   *
>   * nfsd_global_mutex covers only what is genuinely shared between
>   * namespaces: the nfsd_users refcount and the host-wide resources it
> - * brings up and tears down (the open file cache and the NFSv4 global
> - * tables), the address-notifier registration, and user_recovery_dirname.
> + * brings up and tears down (the NFSv4 global tables, and the open file
> + * cache -- which guards its own internals with nfsd_file_cache_mutex),
> + * the address-notifier registration, and user_recovery_dirname.
>   *
> - * Lock ordering is nn->nfsd_mutex outside nfsd_global_mutex.  Nothing tak=
es
> - * two namespaces' nfsd_mutexes.
> + * Lock ordering is nn->nfsd_mutex outside nfsd_global_mutex outside
> + * nfsd_file_cache_mutex.  Nothing takes two namespaces' nfsd_mutexes.
>   */
>  DEFINE_MUTEX(nfsd_global_mutex);
> =20
>=20
> --=20
> 2.55.0
>=20
>=20

