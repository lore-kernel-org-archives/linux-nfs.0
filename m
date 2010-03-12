From: Trond Myklebust <trond.myklebust@fys.uio.no>
Subject: Re: [PATCH] Fix bug nfslock request sending fail will be process
 as blocked
Date: Fri, 12 Mar 2010 08:42:09 -0500
Message-ID: <1268401329.3156.12.camel@localhost.localdomain>
References: <4B9A14A1.3000008@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "J. Bruce Fields" <bfields@fieldses.org>,
	Chuck Lever <chuck.lever@oracle.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-out2.uio.no ([129.240.10.58]:46330 "EHLO mail-out2.uio.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756646Ab0CLNmS (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 12 Mar 2010 08:42:18 -0500
In-Reply-To: <4B9A14A1.3000008@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 2010-03-12 at 18:17 +0800, Mi Jinlong wrote: 
> If local reason cause nfslock request send fail(means status < 0,
> resp->status not be reset), the request will be process as blocked 
> at first now.
> 
> This patch initialize resp->status to nlm_lck_denied_nolocks, it 
> can make the following process correctly.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
>  fs/lockd/clntproc.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/lockd/clntproc.c b/fs/lockd/clntproc.c
> index c81249f..a631582 100644
> --- a/fs/lockd/clntproc.c
> +++ b/fs/lockd/clntproc.c
> @@ -535,7 +535,7 @@ again:
>  	 * Initialise resp->status to a valid non-zero value,
>  	 * since 0 == nlm_lck_granted
>  	 */
> -	resp->status = nlm_lck_blocked;
> +	resp->status = nlm_lck_denied_nolocks;
>  	for(;;) {
>  		/* Reboot protection */
>  		fl->fl_u.nfs_fl.state = host->h_state;

We _want_ to process it as being blocked if the RPC call was
interrupted. The above patch will cause the client to just abandon the
interrupted lock request without sending the CANCEL request...

Trond

