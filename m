Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:37134 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbaEDMBK (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Sun, 4 May 2014 08:01:10 -0400
Date: Sun, 4 May 2014 08:01:08 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Kees Cook <keescook@chromium.org>
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        linux-nfs@vger.kernel.org
Subject: Re: [PATCH] lockd: avoid warning when CONFIG_SYSCTL undefined
Message-ID: <20140504120108.GB21635@fieldses.org>
References: <20140501211502.GA31844@www.outflux.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
In-Reply-To: <20140501211502.GA31844@www.outflux.net>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, May 01, 2014 at 02:15:02PM -0700, Kees Cook wrote:
> When building without CONFIG_SYSCTL, the compiler saw an unused
> label. This moves the label into the #ifdef it is used under.

Thanks, applying.

--b.

> 
> fs/lockd/svc.c: In function ‘init_nlm’:
> fs/lockd/svc.c:626:1: warning: label ‘err_sysctl’ defined but not used [-Wunused-label]
> 
> Signed-off-by: Kees Cook <keescook@chromium.org>
> ---
>  fs/lockd/svc.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 6bf06a07f3e0..2b431f7266c3 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -622,8 +622,8 @@ static int __init init_nlm(void)
>  err_pernet:
>  #ifdef CONFIG_SYSCTL
>  	unregister_sysctl_table(nlm_sysctl_table);
> -#endif
>  err_sysctl:
> +#endif
>  	return err;
>  }
>  
> -- 
> 1.7.9.5
> 
> 
> -- 
> Kees Cook
> Chrome OS Security
