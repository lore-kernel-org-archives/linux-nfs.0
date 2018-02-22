Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:41866 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751378AbeBVAuf (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 21 Feb 2018 19:50:35 -0500
Date: Wed, 21 Feb 2018 19:50:35 -0500
From: "J . Bruce Fields" <bfields@fieldses.org>
To: Colin King <colin.king@canonical.com>
Cc: Jeff Layton <jlayton@kernel.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        linux-nfs@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH] lockd: make nlm_ntf_refcnt and nlm_ntf_wq static
Message-ID: <20180222005035.GG6535@fieldses.org>
References: <20180207102947.29292-1-colin.king@canonical.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <20180207102947.29292-1-colin.king@canonical.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Thanks, applying.--b.

On Wed, Feb 07, 2018 at 10:29:47AM +0000, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The variables nlm_ntf_refcnt and nlm_ntf_wq are local to the source and
> do not need to be in global scope, so make them static.
> 
> Cleans up sparse warnings:
> fs/lockd/svc.c:60:10: warning: symbol 'nlm_ntf_refcnt' was not declared.
> Should it be static?
> fs/lockd/svc.c:61:1: warning: symbol 'nlm_ntf_wq' was not declared.
> Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  fs/lockd/svc.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 9c36d614bf89..346ed161756d 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -57,8 +57,8 @@ static struct task_struct	*nlmsvc_task;
>  static struct svc_rqst		*nlmsvc_rqst;
>  unsigned long			nlmsvc_timeout;
>  
> -atomic_t nlm_ntf_refcnt = ATOMIC_INIT(0);
> -DECLARE_WAIT_QUEUE_HEAD(nlm_ntf_wq);
> +static atomic_t nlm_ntf_refcnt = ATOMIC_INIT(0);
> +static DECLARE_WAIT_QUEUE_HEAD(nlm_ntf_wq);
>  
>  unsigned int lockd_net_id;
>  
> -- 
> 2.15.1
