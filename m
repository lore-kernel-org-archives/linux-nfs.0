Return-Path: <SRS0=31iP=RZ=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.5 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_MUTT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 070DFC43381
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 16:53:41 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id D614F218A2
	for <linux-nfs@archiver.kernel.org>; Fri, 22 Mar 2019 16:53:40 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1727524AbfCVQxj (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Fri, 22 Mar 2019 12:53:39 -0400
Received: from fieldses.org ([173.255.197.46]:52554 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1727410AbfCVQxj (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 22 Mar 2019 12:53:39 -0400
Received: by fieldses.org (Postfix, from userid 2815)
        id E01301C98; Fri, 22 Mar 2019 12:53:38 -0400 (EDT)
Date:   Fri, 22 Mar 2019 12:53:38 -0400
From:   "J. Bruce Fields" <bfields@fieldses.org>
To:     NeilBrown <neilb@suse.com>
Cc:     Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] sunrpc/cache: handle missing listeners better.
Message-ID: <20190322165338.GB7692@fieldses.org>
References: <87pnqj64br.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pnqj64br.fsf@notabene.neil.brown.name>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

I've gotten complaints about the same thing and said "well, in
retrospect we shouldn't have designed the interface this way, but we
did, so just stop opening those files".

But maybe this is a reasonable compromise.

One advantage of waiting for mountd to come back is that you could
upgrade mountd in place.  That shouldn't take 30 seconds, though.  And I
haven't heard of anyone actually doing that.

It's too bad that not opening auth.unix.gid is the only way for mountd
to communicate that gids shouldn't be mapped.

--b.

On Fri, Mar 22, 2019 at 01:16:56PM +1100, NeilBrown wrote:
> If no handler (such as rpc.mountd) has opened
> a cache 'channel', the sunrpc cache responds to
> all lookup requests with -ENOENT.  This is particularly
> important for the auth.unix.gid cache which is
> optional.
> 
> If the channel was open briefly and an upcall was written to it,
> this upcall remains pending even when the handler closes the
> channel.  When an upcall is pending, the code currently
> doesn't check if there are still listeners, it only performs
> that check before sending an upcall.
> 
> As the cache treads a recently closes channel (closed less than
> 30 seconds ago) as "potentially still open", there is a
> reasonable sized window when a request can become pending
> in a closed channel, and thereby block lookups indefinitely.
> 
> This can easily be demonstrated by running
>   cat /proc/net/rpc/auth.unix.gid/channel
> 
> and then trying to mount an NFS filesystem from this host.  It
> will block indefinitely (unless mountd is run with --manage-gids,
> or krb5 is used).
> 
> When cache_check() finds that an upcall is pending, it should
> perform the "cache_listeners_exist()" exist test.  If no
> listeners do exist, the request should be negated.
> 
> With this change in place, there can still be a 30second wait on
> mount, until the cache gives up waiting for a handler to come
> back, but this is much better than an indefinite wait.
> 
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
>  net/sunrpc/cache.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index 12bb23b8e0c5..be9e29385adc 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -40,6 +40,7 @@
>  
>  static bool cache_defer_req(struct cache_req *req, struct cache_head *item);
>  static void cache_revisit_request(struct cache_head *item);
> +static bool cache_listeners_exist(struct cache_detail *detail);
>  
>  static void cache_init(struct cache_head *h, struct cache_detail *detail)
>  {
> @@ -303,7 +304,8 @@ int cache_check(struct cache_detail *detail,
>  				cache_fresh_unlocked(h, detail);
>  				break;
>  			}
> -		}
> +		} else if (!cache_listeners_exist(detail))
> +			rv = try_to_negate_entry(detail, h);
>  	}
>  
>  	if (rv == -EAGAIN) {
> -- 
> 2.14.0.rc0.dirty
> 


