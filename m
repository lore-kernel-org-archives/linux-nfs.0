Received: from relay.yourmailgateway.de (relay.yourmailgateway.de [188.68.63.102])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 574E34C77B3
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 10:24:48 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=188.68.63.102
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784715891; cv=none; b=Vs1D8iuwxQaN/iDvY1JCw5MOEjLwZiOpEgn4CFYtzkTtWJU96Fl8b/ZB9ce1Nx0SJzCtwXgqr1jajNceShIjpRMHzBsG5sEhb5pfkYUE0ohWyjulE+tC1ZHpPRuMri7km6N2UH9+AgAch4mPmkzNEw/1VJMgQgq87SSUlwUWMNE=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784715891; c=relaxed/simple;
	bh=SoGOG7KasSoMZXcsVu2I5ioy5iCefnPe9yZEK1+o7c4=;
	h=Message-ID:Date:MIME-Version:Subject:To:Cc:References:From:
	 In-Reply-To:Content-Type; b=lIyjoGvb0ShQHRKUvHR0JDwoYeBhCt8k/8pPMKD0Z36ctFWY1adBJ6/xjqBRu1qFiNIYcR0CAvIbPExzQca+3WTP83H6EAshbbB6WGPTfB5aPxcfjPMLwAJUCZCtGHMWHy6+PtsNrVIWyHQxOqLQIDQall98nXds3kMsdxbv2PQ=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info; spf=pass smtp.mailfrom=leemhuis.info; dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b=Tb4eujKA; arc=none smtp.client-ip=188.68.63.102
Authentication-Results: smtp.subspace.kernel.org; dmarc=none (p=none dis=none) header.from=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org; spf=pass smtp.mailfrom=leemhuis.info
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=leemhuis.info header.i=@leemhuis.info header.b="Tb4eujKA"
Received: from mors-relay-2502.netcup.net (localhost [127.0.0.1])
	by mors-relay-2502.netcup.net (Postfix) with ESMTPS id 4h4r2p6Z91z68lB;
	Wed, 22 Jul 2026 12:24:18 +0200 (CEST)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/simple; d=leemhuis.info;
	s=key2; t=1784715858;
	bh=SoGOG7KasSoMZXcsVu2I5ioy5iCefnPe9yZEK1+o7c4=;
	h=Date:Subject:To:Cc:References:From:In-Reply-To:From;
	b=Tb4eujKAok0VuWXmjbWpCh3r3P6m2cxdPXcF2vu/K7R7FlhPjB8lssTqhRyhSXxl4
	 qXp2D/D7d6uB+T1kPz1rqQ/excGMrsWkzLFuKsLI/NR2r1n2Q3sGHz++oSxjn30ch6
	 tlEE1EJh/IhPq+LwnLfJ/jzQ3gz4PLEM2Z8sO6fGAKKpUhhNwOYy2Di9Hy54mcGGcF
	 5vtwM5KJD2JehqSd3TBBdJqr83SEj4PeUEbogzKLcdE0oKFEKDIvAodjV/8v2nP+t1
	 W8RDZvWTl0kwW6zwU5vhiV2y/xn9ftUwL5fL8WAbHdZF9kCfUxLYxO7zoTMfqXqUd8
	 fUMMAjDx5gwow==
Received: from policy02-mors.netcup.net (unknown [46.38.225.35])
	by mors-relay-2502.netcup.net (Postfix) with ESMTPS id 4h4r2p5qs0z4xV4;
	Wed, 22 Jul 2026 12:24:18 +0200 (CEST)
Received: from mxe9fb.netcup.net (unknown [10.243.12.53])
	(using TLSv1.3 with cipher TLS_AES_256_GCM_SHA384 (256/256 bits)
	 key-exchange ECDHE (P-256) server-signature RSA-PSS (2048 bits) server-digest SHA256)
	(No client certificate requested)
	by policy02-mors.netcup.net (Postfix) with ESMTPS id 4h4r2n6dfXz8svk;
	Wed, 22 Jul 2026 12:24:17 +0200 (CEST)
Received: from [IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f] (unknown [IPv6:2a02:8108:8984:1d00:a0cf:1912:4be:477f])
	by mxe9fb.netcup.net (Postfix) with ESMTPSA id F36B15FC9C;
	Wed, 22 Jul 2026 12:24:16 +0200 (CEST)
Authentication-Results: mxe9fb;
        spf=pass (sender IP is 2a02:8108:8984:1d00:a0cf:1912:4be:477f) smtp.mailfrom=regressions@leemhuis.info smtp.helo=[IPV6:2a02:8108:8984:1d00:a0cf:1912:4be:477f]
Received-SPF: pass (mxe9fb: connection is authenticated)
Message-ID: <0a0a98af-2004-4926-a7d8-1a0acb78df5a@leemhuis.info>
Date: Wed, 22 Jul 2026 12:24:15 +0200
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
User-Agent: Mozilla Thunderbird
Subject: Re: [PATCH v4 1/9] NFSD: Prevent lock owner use-after-free during
 client teardown
To: Chuck Lever <cel@kernel.org>, Jeff Layton <jlayton@kernel.org>,
 NeilBrown <neil@brown.name>, Olga Kornievskaia <okorniev@redhat.com>,
 Dai Ngo <Dai.Ngo@oracle.com>, Tom Talpey <tom@talpey.com>
Cc: linux-nfs@vger.kernel.org, Wolfgang Walter <linux@stwm.de>,
 Linux kernel regressions list <regressions@lists.linux.dev>
References: <20260709-cel-v4-0-1d519d9be0cb@kernel.org>
 <20260709-cel-v4-1-1d519d9be0cb@kernel.org>
From: Thorsten Leemhuis <regressions@leemhuis.info>
Content-Language: de-DE, en-US
X-Enigmail-Draft-Status: N11222
Autocrypt: addr=linux@leemhuis.info; keydata=
 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 MEK4
In-Reply-To: <20260709-cel-v4-1-1d519d9be0cb@kernel.org>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
X-PPP-Message-ID: <178471585740.645676.8703593283234029971@mxe9fb.netcup.net>
X-NC-CID: zHxlu+1qa8UxL9jCxUyZiEsvpeK6+/z8dMmgksCHWYjBdMMues8=

On 7/9/26 19:40, Chuck Lever wrote:
> __destroy_client() releases a client's open owners, but a lock owner
> whose only reference is a blocked lock (nbl) stays on
> cl_ownerstr_hashtbl.  client_has_state() does not count a bare owner,
> so DESTROY_CLIENTID can reach __destroy_client() with such owners
> present.
>
> [...]
>
> Reported-by: Wolfgang Walter <linux@stwm.de>
> Closes: https://lore.kernel.org/linux-nfs/6eccafaaaa60651ef091257c3439c46b@stwm.de/
> Fixes: 68ef3bc31664 ("nfsd: remove blocked locks on client teardown")

What's the plan to merge this change? From the outside it looks like a
fix for a user reported regression from this merge window, as Wolfgang
afaics blamed commit 516403d4d85607 ("Revert "NFSD: Defer sub-object
cleanup in export put callbacks""), which also made it to various stable
trees.

So shouldn't this change ideally be on it's way to Linus by now? Ideally
with a stable tag to ensure quick backporting? Or is it not a good idea
to have this in without the follow-up patches from this series?

Or did I get something totally wrong (which is easily possible from my
external point)?

Ciao, Thorsten


> Reviewed-by: NeilBrown <neil@brown.name>
> Reviewed-by: Jeff Layton <jlayton@kernel.org>
> Signed-off-by: Chuck Lever <cel@kernel.org>
> ---
>  fs/nfsd/nfs4state.c | 16 +++++++++++++---
>  1 file changed, 13 insertions(+), 3 deletions(-)
> 
> diff --git a/fs/nfsd/nfs4state.c b/fs/nfsd/nfs4state.c
> index a4398dc861a5..e000ed3e96e9 100644
> --- a/fs/nfsd/nfs4state.c
> +++ b/fs/nfsd/nfs4state.c
> @@ -2758,14 +2758,24 @@ __destroy_client(struct nfs4_client *clp)
>  		release_openowner(oo);
>  	}
>  	for (i = 0; i < OWNER_HASH_SIZE; i++) {
> -		struct nfs4_stateowner *so, *tmp;
> +		struct nfs4_stateowner *so;
>  
> -		list_for_each_entry_safe(so, tmp, &clp->cl_ownerstr_hashtbl[i],
> -					 so_strhash) {
> +		spin_lock(&clp->cl_lock);
> +		while (!list_empty(&clp->cl_ownerstr_hashtbl[i])) {
> +			so = list_first_entry(&clp->cl_ownerstr_hashtbl[i],
> +					      struct nfs4_stateowner, so_strhash);
>  			/* Should be no openowners at this point */
>  			WARN_ON_ONCE(so->so_is_open_owner);
> +			nfs4_get_stateowner(so);
> +			unhash_lockowner_locked(lockowner(so));
> +			spin_unlock(&clp->cl_lock);
> +
>  			remove_blocked_locks(lockowner(so));
> +			nfs4_put_stateowner(so);
> +
> +			spin_lock(&clp->cl_lock);
>  		}
> +		spin_unlock(&clp->cl_lock);
>  	}
>  	nfsd4_return_all_client_layouts(clp);
>  	nfsd4_shutdown_copy(clp);
> 

