Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:54001 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752850Ab1EXQw5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 12:52:57 -0400
Message-ID: <4DDBE265.7000101@panasas.com>
Date: Tue, 24 May 2011 19:52:53 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 02/12] SQUASHME: Bug in new global-device-cache code
References: <4DDBC611.3050202@panasas.com> <1306249480-23212-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1306249480-23212-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-24 18:04, Boaz Harrosh wrote:
> NULL deref on first ever call. (When device is not found)
> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/pnfs_dev.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/pnfs_dev.c b/fs/nfs/pnfs_dev.c
> index 7997899..7e5542c 100644
> --- a/fs/nfs/pnfs_dev.c
> +++ b/fs/nfs/pnfs_dev.c
> @@ -100,7 +100,7 @@ _find_get_deviceid(const struct pnfs_layoutdriver_type *ld,
>  
>  	rcu_read_lock();
>  	d = _lookup_deviceid(ld, clp, id, hash);
> -	if (!atomic_inc_not_zero(&d->ref))
> +	if (!d || !atomic_inc_not_zero(&d->ref))

This makes more sense, no?
+	if (d && !atomic_inc_not_zero(&d->ref))

Benny

>  		d = NULL;
>  	rcu_read_unlock();
>  	return d;

