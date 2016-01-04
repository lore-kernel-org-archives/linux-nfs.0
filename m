Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52999 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752012AbcADWoL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 4 Jan 2016 17:44:11 -0500
Date: Mon, 4 Jan 2016 17:44:11 -0500
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Geliang Tang <geliangtang@163.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Jeff Layton <jlayton@poochiereds.net>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: [PATCH 3/3] lockd: use to_delayed_work
Message-ID: <20160104224411.GF30315@fieldses.org>
References: <87ea17d237ec636e674f8be097a7e65cbce4d252.1451656900.git.geliangtang@163.com>
 <741bd37af1f46a3713423e16138910f12a5c12b5.1451656900.git.geliangtang@163.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <741bd37af1f46a3713423e16138910f12a5c12b5.1451656900.git.geliangtang@163.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Jan 01, 2016 at 10:06:29PM +0800, Geliang Tang wrote:
> Use to_delayed_work() instead of open-coding it.

Thanks, applying 2/3 and 3/3 for 4.5.--b.

> 
> Signed-off-by: Geliang Tang <geliangtang@163.com>
> ---
>  fs/lockd/svc.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/fs/lockd/svc.c b/fs/lockd/svc.c
> index 44d18ad..b4006c72 100644
> --- a/fs/lockd/svc.c
> +++ b/fs/lockd/svc.c
> @@ -94,8 +94,7 @@ static unsigned long get_lockd_grace_period(void)
>  
>  static void grace_ender(struct work_struct *grace)
>  {
> -	struct delayed_work *dwork = container_of(grace, struct delayed_work,
> -						  work);
> +	struct delayed_work *dwork = to_delayed_work(grace);
>  	struct lockd_net *ln = container_of(dwork, struct lockd_net,
>  					    grace_period_end);
>  
> -- 
> 2.5.0
> 
