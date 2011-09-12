Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-gw0-f47.google.com ([74.125.83.47]:57691 "EHLO
	mail-gw0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756015Ab1ILNiJ (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 12 Sep 2011 09:38:09 -0400
Received: by mail-gw0-f47.google.com with SMTP id 11so3364725gwb.6
        for <linux-nfs@vger.kernel.org>; Mon, 12 Sep 2011 06:38:09 -0700 (PDT)
Message-ID: <4E6E09CA.8090502@tonian.com>
Date: Mon, 12 Sep 2011 06:31:54 -0700
From: Benny Halevy <bhalevy@tonian.com>
To: Jim Rees <rees@umich.edu>
CC: Peng Tao <bergwolf@gmail.com>, linux-nfs@vger.kernel.org
Subject: Re: [PATCH 1/2] SQUASHME: pnfs: simplify and clean up pnfsiod workqueue
References: <4E6CD076.6050607@tonian.com> <1315755100-31204-1-git-send-email-benny@tonian.com> <20110911171749.GA5195@merit.edu>
In-Reply-To: <20110911171749.GA5195@merit.edu>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-09-11 10:17, Jim Rees wrote:
> From: Jim Rees <rees@umich.edu>
> Date: Sun, 11 Sep 2011 13:11:15 -0400
> Subject: [PATCH] SQUASHME: pnfs: whitespace

evil editor... :-/
thanks!

Benny

> 
> Signed-off-by: Jim Rees <rees@umich.edu>
> ---
>  fs/nfs/pnfs.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/pnfs.c b/fs/nfs/pnfs.c
> index 0ef4361..e5e11b4 100644
> --- a/fs/nfs/pnfs.c
> +++ b/fs/nfs/pnfs.c
> @@ -1488,13 +1488,13 @@ out:
>  int pnfsiod_start(void)
>  {
>  	struct workqueue_struct *wq;
> -	
> +
>  	dprintk("NFS:       creating workqueue pnfsiod\n");
>  	atomic_inc(&pnfsiod_users);
>  	if (pnfsiod_workqueue == NULL) {
>  		wq = alloc_workqueue("pnfsiod", WQ_MEM_RECLAIM, 0);
>  		if (wq == NULL) {
> -			pnfsiod_stop();	
> +			pnfsiod_stop();
>  			return -ENOMEM;
>  		}
>  		spin_lock(&pnfs_spinlock);
