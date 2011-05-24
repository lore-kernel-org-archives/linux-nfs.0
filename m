From: Benny Halevy <bhalevy@panasas.com>
Subject: Re: [PATCH 03/12] SQUSHME: pnfs: BUG in _deviceid_purge_client
Date: Tue, 24 May 2011 19:57:41 +0300
Message-ID: <4DDBE385.7050602@panasas.com>
References: <4DDBC611.3050202@panasas.com> <1306249521-23244-1-git-send-email-bharrosh@panasas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1255
Cc: Trond Myklebust <Trond.Myklebust@netapp.com>,
	NFS list <linux-nfs@vger.kernel.org>
To: Boaz Harrosh <bharrosh@panasas.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54413 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752297Ab1EXQ5o (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 12:57:44 -0400
In-Reply-To: <1306249521-23244-1-git-send-email-bharrosh@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 2011-05-24 18:05, Boaz Harrosh wrote:
> The atomic_dec_and_test() returns *true* when zero. The !
> belongs to atomic_dec(). Fixit

Thanks!

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs_dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 7e5542c..37ca215 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -258,7 +258,7 @@ _deviceid_purge_client(const struct nfs_client *clp, long hash)
>  
>  	synchronize_rcu();
>  	hlist_for_each_entry_safe(d, n, next, &tmp, node)
> -		if (!atomic_dec_and_test(&d->ref)) {
> +		if (atomic_dec_and_test(&d->ref)) {
>  			if (d->ld->free_deviceid_node)
>  				d->ld->free_deviceid_node(d);
>  			else

