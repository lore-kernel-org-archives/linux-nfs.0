Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:55181 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754505Ab1EXRRM (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 24 May 2011 13:17:12 -0400
Message-ID: <4DDBE815.7070106@panasas.com>
Date: Tue, 24 May 2011 20:17:09 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Boaz Harrosh <bharrosh@panasas.com>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH 10/12] SQUASHME: pnfs-obj: objlayout wants to cache devices
 until unmount
References: <4DDBC611.3050202@panasas.com> <1306249685-23453-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <1306249685-23453-1-git-send-email-bharrosh@panasas.com>
Content-Type: text/plain; charset=windows-1255
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 2011-05-24 18:08, Boaz Harrosh wrote:
> Take an extra reference on a device insert. So devices keep
> around in the cache until nfs_client release.
> (This was the behavior of the old cache)
> 
> The extra reference will be removed in nfs4_deviceid_purge_client().
> I tested this and it works perfectly.
> 
> TODO: Define an nfs4_get_deviceid()
>  Currently accesing did->ref directly

This is the right time to do it, why wait?

> 
> TODO: nfs4_insert_deviceid_node should check if there are too many
>       devices and start purging them. Say by time from last use.

yeah, an lru list would be helpful to prune the lists and get rid
of unused devices.  As we discussed before, this can be done
periodically, and all devices not used for a long enough interval can
be deleted.

Benny

> 
> Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
> ---
>  fs/nfs/objlayout/objio_osd.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> index faacde2..8b05b16 100644
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ b/fs/nfs/objlayout/objio_osd.c
> @@ -104,6 +104,7 @@ _dev_list_add(const struct nfs_server *nfss,
>  		de = n;
>  	}
>  
> +	atomic_inc(&de->id_node.ref);
>  	return de;
>  }
>  

