Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f170.google.com ([209.85.216.170]:34910 "EHLO
        mail-qt0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965082AbcIPUmY (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 16 Sep 2016 16:42:24 -0400
Received: by mail-qt0-f170.google.com with SMTP id 93so48580055qtg.2
        for <linux-nfs@vger.kernel.org>; Fri, 16 Sep 2016 13:42:19 -0700 (PDT)
Message-ID: <1474058535.13386.6.camel@redhat.com>
Subject: Re: [PATCH] sunrpc: include gid in the rpc_cred_cache hash
From: Jeff Layton <jlayton@redhat.com>
To: Frank Sorenson <sorenson@redhat.com>, linux-nfs@vger.kernel.org
Date: Fri, 16 Sep 2016 16:42:15 -0400
In-Reply-To: <1474056735-4008-1-git-send-email-sorenson@redhat.com>
References: <1474056735-4008-1-git-send-email-sorenson@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2016-09-16 at 15:12 -0500, Frank Sorenson wrote:
> The current rpc_cred_cache hashtable uses only the uid in the hash
> computation.  rpc_creds created with the same uid but different
> gids will all go on the same hash chain.
> 
> In certain usage patterns, such as the following, this can lead to
> extremely long hash chains for these uids, while the rest of the
> hashtable remains nearly empty. This causes very high cpu usage
> in rpcauth_lookup_credcache, and slow performance for that uid.
> 
>     for (i = 0 ; i < 100000 ; i++) {
>         setregid(-1, i);
>         stat(path, &st);
>     }
> 
> Add the gid to the hash algorithm to distribute the rpc_creds
> throughout the cache to avoid long individual hash chains.
> 
> > Signed-off-by: Frank Sorenson <sorenson@redhat.com>
> 
> diff --git a/net/sunrpc/auth.c b/net/sunrpc/auth.c
> index a7e42f9..2260e58 100644
> --- a/net/sunrpc/auth.c
> +++ b/net/sunrpc/auth.c
> @@ -538,6 +538,14 @@ rpcauth_cache_enforce_limit(void)
> >  	rpcauth_cache_do_shrink(nr_to_scan);
>  }
>  
> +static unsigned int
> +rpcauth_hash_acred(struct auth_cred *acred, unsigned int hashbits)
> +{
> > +	return hash_64(from_kgid(&init_user_ns, acred->gid) |
> > +		(from_kuid(&init_user_ns, acred->uid) << (sizeof(gid_t) * 8)),
> > +		hashbits);
> +}
> +
>  /*
>   * Look up a process' credentials in the authentication cache
>   */
> @@ -551,7 +559,7 @@ rpcauth_lookup_credcache(struct rpc_auth *auth, struct auth_cred * acred,
> >  			*entry, *new;
> >  	unsigned int nr;
>  
> > -	nr = hash_long(from_kuid(&init_user_ns, acred->uid), cache->hashbits);
> > +	nr = rpcauth_hash_acred(acred, cache->hashbits);
>  
> >  	rcu_read_lock();
> >  	hlist_for_each_entry_rcu(entry, &cache->hashtable[nr], cr_hash) {
> 

Nice work.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
