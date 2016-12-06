Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:44770 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752018AbcLFTT3 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Tue, 6 Dec 2016 14:19:29 -0500
Date: Tue, 6 Dec 2016 14:19:23 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Fabian Frederick <fabf@skynet.be>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
Subject: Re: [PATCH 1/1 linux-next] sunrpc: use DEFINE_SPINLOCK()
Message-ID: <20161206191923.GE31197@fieldses.org>
References: <1480855528-19620-1-git-send-email-fabf@skynet.be>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1480855528-19620-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying for 4.10.--b.

On Sun, Dec 04, 2016 at 01:45:28PM +0100, Fabian Frederick wrote:
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/sunrpc/svcauth.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/net/sunrpc/svcauth.c b/net/sunrpc/svcauth.c
> index 69841db..e112da8 100644
> --- a/net/sunrpc/svcauth.c
> +++ b/net/sunrpc/svcauth.c
> @@ -124,8 +124,7 @@ EXPORT_SYMBOL_GPL(svc_auth_unregister);
>  #define	DN_HASHMAX	(1<<DN_HASHBITS)
>  
>  static struct hlist_head	auth_domain_table[DN_HASHMAX];
> -static spinlock_t	auth_domain_lock =
> -	__SPIN_LOCK_UNLOCKED(auth_domain_lock);
> +static DEFINE_SPINLOCK(auth_domain_lock);
>  
>  void auth_domain_put(struct auth_domain *dom)
>  {
> -- 
> 2.7.4
