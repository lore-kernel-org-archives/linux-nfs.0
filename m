Return-Path: <SRS0=4THU=SH=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A1F64C282CE
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 23:52:43 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id 78F8F20700
	for <linux-nfs@archiver.kernel.org>; Fri,  5 Apr 2019 23:52:43 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1726397AbfDEXwm (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 5 Apr 2019 19:52:42 -0400
Received: from fieldses.org ([173.255.197.46]:60992 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1726387AbfDEXwm (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 5 Apr 2019 19:52:42 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id B43E0571; Fri,  5 Apr 2019 19:52:41 -0400 (EDT)
Date:   Fri, 5 Apr 2019 19:52:41 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Vasily Averin <vvs@virtuozzo.com>,
        Jeff Layton <jlayton@kernel.org>, linux-nfs@vger.kernel.org,
        Pavel Tikhomirov <ptikhomirov@virtuozzo.com>
Subject: Re: [PATCH 0/1] cache_head leak in sunrpc_cache_lookup()
Message-ID: <20190405235241.GE8397@fieldses.org>
References: <d6bac5b8-9ee9-289c-7e85-0d4b6f55c931@virtuozzo.com>
 <20181128233514.GC24160@fieldses.org>
 <87zhtso38v.fsf@notabene.neil.brown.name>
 <87sguxza1o.fsf@notabene.neil.brown.name>
 <87k1g9z3vj.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87k1g9z3vj.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Fri, Apr 05, 2019 at 11:34:40AM +1100, NeilBrown wrote:
> On Fri, Apr 05 2019, NeilBrown wrote:
> >
> > Unfortunately I was wrong.  See below.
> >
> 
> Arrghh.. Ignore that patch.  Use this one.

Took me a moment to spot the difference.  OK!  Queuing that up for
5.1....

--b.

> 
> NeilBrown
> 
> From b7a8dced1a34869710a5d68a64e8bd37bf2ab426 Mon Sep 17 00:00:00 2001
> From: NeilBrown <neilb@suse.com>
> Date: Fri, 5 Apr 2019 09:04:41 +1100
> Subject: [PATCH] sunrpc: don't mark uninitialised items as VALID.
> 
> A recent commit added a call to cache_fresh_locked()
> when an expired item was found.
> The call sets the CACHE_VALID flag, so it is important
> that the item actually is valid.
> There are two ways it could be valid:
> 1/ If ->update has been called to fill in relevant content
> 2/ if CACHE_NEGATIVE is set, to say that content doesn't exist.
> 
> An expired item that is waiting for an update will be neither.
> Setting CACHE_VALID will mean that a subsequent call to cache_put()
> will be likely to dereference uninitialised pointers.
> 
> So we must make sure the item is valid, and we already have code to do
> that in try_to_negate_entry().  This takes the hash lock and so cannot
> be used directly, so take out the two lines that we need and use them.
> 
> Now cache_fresh_locked() is certain to be called only on
> a valid item.
> 
> Cc: stable@kernel.org # 2.6.35
> Fixes: 4ecd55ea0742 ("sunrpc: fix cache_head leak due to queued request")
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  net/sunrpc/cache.c | 3 +++
>  1 file changed, 3 insertions(+)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 12bb23b8e0c5..261131dfa1f1 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -54,6 +54,7 @@ static void cache_init(struct cache_head *h, struct cache_detail *detail)
>  	h->last_refresh = now;
>  }
>  
> +static inline int cache_is_valid(struct cache_head *h);
>  static void cache_fresh_locked(struct cache_head *head, time_t expiry,
>  				struct cache_detail *detail);
>  static void cache_fresh_unlocked(struct cache_head *head,
> @@ -105,6 +106,8 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
>  			if (cache_is_expired(detail, tmp)) {
>  				hlist_del_init_rcu(&tmp->cache_list);
>  				detail->entries --;
> +				if (cache_is_valid(tmp) == -EAGAIN)
> +					set_bit(CACHE_NEGATIVE, &tmp->flags);
>  				cache_fresh_locked(tmp, 0, detail);
>  				freeme = tmp;
>  				break;
> -- 
> 2.14.0.rc0.dirty
> 


