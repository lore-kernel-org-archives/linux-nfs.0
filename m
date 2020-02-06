Return-Path: <SRS0=PiW2=32=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.2 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0BC6DC33CAC
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Feb 2020 16:33:25 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id DB939217F4
	for <linux-nfs@archiver.kernel.org>; Thu,  6 Feb 2020 16:33:24 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727514AbgBFQdX (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Thu, 6 Feb 2020 11:33:23 -0500
Received: from fieldses.org ([173.255.197.46]:55356 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727390AbgBFQdX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 6 Feb 2020 11:33:23 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id E030C709; Thu,  6 Feb 2020 11:33:22 -0500 (EST)
Date:   Thu, 6 Feb 2020 11:33:22 -0500
To:     Trond Myklebust <trondmy@gmail.com>
Cc:     "J. Bruce Fields" <bfields@redhat.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH] SUNRPC/cache: Allow garbage collection of invalid cache
 entries
Message-ID: <20200206163322.GB2244@fieldses.org>
References: <20200114165738.922961-1-trond.myklebust@hammerspace.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200114165738.922961-1-trond.myklebust@hammerspace.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
From:   bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Tue, Jan 14, 2020 at 11:57:38AM -0500, Trond Myklebust wrote:
> If the cache entry never gets initialised, we want the garbage
> collector to be able to evict it. Otherwise if the upcall daemon
> fails to initialise the entry, we end up never expiring it.

Could you tell us more about what motivated this?

It's causing failures on pynfs server-reboot tests.  I haven't pinned
down the cause yet, but it looks like it could be a regression to the
behavior Kinglong Mee describes in detail in his original patch.

Dropping for the time being.

--b.

> 
> Fixes: d6fc8821c2d2 ("SUNRPC/Cache: Always treat the invalid cache as unexpired")
> Signed-off-by: Trond Myklebust <trond.myklebust@hammerspace.com>
> ---
>  include/linux/sunrpc/cache.h |  3 ---
>  net/sunrpc/cache.c           | 36 +++++++++++++++++++-----------------
>  2 files changed, 19 insertions(+), 20 deletions(-)
> 
> diff --git a/include/linux/sunrpc/cache.h b/include/linux/sunrpc/cache.h
> index f8603724fbee..0428dd23fd79 100644
> --- a/include/linux/sunrpc/cache.h
> +++ b/include/linux/sunrpc/cache.h
> @@ -202,9 +202,6 @@ static inline void cache_put(struct cache_head *h, struct cache_detail *cd)
>  
>  static inline bool cache_is_expired(struct cache_detail *detail, struct cache_head *h)
>  {
> -	if (!test_bit(CACHE_VALID, &h->flags))
> -		return false;
> -
>  	return  (h->expiry_time < seconds_since_boot()) ||
>  		(detail->flush_time >= h->last_refresh);
>  }
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 52d927210d32..99d630150af6 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -65,13 +65,14 @@ static struct cache_head *sunrpc_cache_find_rcu(struct cache_detail *detail,
>  
>  	rcu_read_lock();
>  	hlist_for_each_entry_rcu(tmp, head, cache_list) {
> -		if (detail->match(tmp, key)) {
> -			if (cache_is_expired(detail, tmp))
> -				continue;
> -			tmp = cache_get_rcu(tmp);
> -			rcu_read_unlock();
> -			return tmp;
> -		}
> +		if (!detail->match(tmp, key))
> +			continue;
> +		if (test_bit(CACHE_VALID, &tmp->flags) &&
> +		    cache_is_expired(detail, tmp))
> +			continue;
> +		tmp = cache_get_rcu(tmp);
> +		rcu_read_unlock();
> +		return tmp;
>  	}
>  	rcu_read_unlock();
>  	return NULL;
> @@ -114,17 +115,18 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
>  
>  	/* check if entry appeared while we slept */
>  	hlist_for_each_entry_rcu(tmp, head, cache_list) {
> -		if (detail->match(tmp, key)) {
> -			if (cache_is_expired(detail, tmp)) {
> -				sunrpc_begin_cache_remove_entry(tmp, detail);
> -				freeme = tmp;
> -				break;
> -			}
> -			cache_get(tmp);
> -			spin_unlock(&detail->hash_lock);
> -			cache_put(new, detail);
> -			return tmp;
> +		if (!detail->match(tmp, key))
> +			continue;
> +		if (test_bit(CACHE_VALID, &tmp->flags) &&
> +		    cache_is_expired(detail, tmp)) {
> +			sunrpc_begin_cache_remove_entry(tmp, detail);
> +			freeme = tmp;
> +			break;
>  		}
> +		cache_get(tmp);
> +		spin_unlock(&detail->hash_lock);
> +		cache_put(new, detail);
> +		return tmp;
>  	}
>  
>  	hlist_add_head_rcu(&new->cache_list, head);
> -- 
> 2.24.1
