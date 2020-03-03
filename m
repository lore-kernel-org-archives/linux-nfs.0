Return-Path: <SRS0=F3kk=4U=vger.kernel.org=linux-nfs-owner@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.3 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_SANE_1 autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id E156CC3F2C6
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:37:35 +0000 (UTC)
Received: from vger.kernel.org (vger.kernel.org [209.132.180.67])
	by mail.kernel.org (Postfix) with ESMTP id C011F215A4
	for <linux-nfs@archiver.kernel.org>; Tue,  3 Mar 2020 16:37:35 +0000 (UTC)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
        id S1729504AbgCCQhf (ORCPT <rfc822;linux-nfs@archiver.kernel.org>);
        Tue, 3 Mar 2020 11:37:35 -0500
Received: from fieldses.org ([173.255.197.46]:37298 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1728497AbgCCQhe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 3 Mar 2020 11:37:34 -0500
Received: by fieldses.org (Postfix, from userid 2815)
        id 8913F378; Tue,  3 Mar 2020 11:37:34 -0500 (EST)
Date:   Tue, 3 Mar 2020 11:37:34 -0500
From:   "J . Bruce Fields" <bfields@fieldses.org>
To:     Amol Grover <frextrite@gmail.com>
Cc:     Trond Myklebust <trond.myklebust@hammerspace.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Chuck Lever <chuck.lever@oracle.com>,
        "David S . Miller" <davem@davemloft.net>,
        Jakub Kicinski <kuba@kernel.org>, linux-kernel@vger.kernel.org,
        linux-kernel-mentees@lists.linuxfoundation.org,
        Joel Fernandes <joel@joelfernandes.org>,
        Madhuparna Bhowmik <madhuparnabhowmik10@gmail.com>,
        "Paul E . McKenney" <paulmck@kernel.org>,
        linux-nfs@vger.kernel.org, netdev@vger.kernel.org
Subject: Re: [PATCH] sunrpc: Pass lockdep expression to RCU lists
Message-ID: <20200303163734.GA19140@fieldses.org>
References: <20200219093504.16290-1-frextrite@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20200219093504.16290-1-frextrite@gmail.com>
User-Agent: Mutt/1.5.21 (2010-09-15)
Sender: linux-nfs-owner@vger.kernel.org
Precedence: bulk
List-ID: <linux-nfs.vger.kernel.org>
X-Mailing-List: linux-nfs@vger.kernel.org

On Wed, Feb 19, 2020 at 03:05:05PM +0530, Amol Grover wrote:
> detail->hash_table[] is traversed using hlist_for_each_entry_rcu
> outside an RCU read-side critical section but under the protection
> of detail->hash_lock.
> 
> Hence, add corresponding lockdep expression to silence false-positive
> warnings, and harden RCU lists.

Thanks, applying for 5.7.--b.

> 
> Signed-off-by: Amol Grover <frextrite@gmail.com>
> ---
>  net/sunrpc/cache.c | 3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sunrpc/cache.c b/net/sunrpc/cache.c
> index f740cb51802a..5db5f5b94726 100644
> --- a/net/sunrpc/cache.c
> +++ b/net/sunrpc/cache.c
> @@ -97,7 +97,8 @@ static struct cache_head *sunrpc_cache_add_entry(struct cache_detail *detail,
>  	spin_lock(&detail->hash_lock);
>  
>  	/* check if entry appeared while we slept */
> -	hlist_for_each_entry_rcu(tmp, head, cache_list) {
> +	hlist_for_each_entry_rcu(tmp, head, cache_list,
> +				 lockdep_is_held(&detail->hash_lock)) {
>  		if (detail->match(tmp, key)) {
>  			if (cache_is_expired(detail, tmp)) {
>  				hlist_del_init_rcu(&tmp->cache_list);
> -- 
> 2.24.1
