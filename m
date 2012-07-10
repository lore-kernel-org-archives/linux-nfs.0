Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:53827 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752425Ab2GJO7k (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 10 Jul 2012 10:59:40 -0400
Date: Tue, 10 Jul 2012 10:59:37 -0400
From: "J. Bruce Fields" <bfields@fieldses.org>
To: Namjae Jeon <linkinjeon@gmail.com>
Cc: SteveD@redhat.com, Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org, Vivek Trivedi <vtrivedi018@gmail.com>
Subject: Re: [PATCH] nfs-util: Add cache_flush in mountd UMNT procedure.
Message-ID: <20120710145937.GA1947@fieldses.org>
References: <1341717459-7297-1-git-send-email-linkinjeon@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1341717459-7297-1-git-send-email-linkinjeon@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Sat, Jul 07, 2012 at 11:17:39PM -0400, Namjae Jeon wrote:
> For removing storage device - user needs to safely un-mount the device
> and then eject. But if 'EBUSY' occurs in umount then it will create
> confusion for the user as it will mean some I/O is in progress - and
> won't allow user to safely ejecting device.

The one drawback is that recovering from the cache flushes might be a
little expensive if you have a lot of exports in use.

I'm curious, since you said this was for a usb disk: are users expected
to just unplug it (in which case--is it read only?) or do they have some
way of unmounting before they pull the plug?

--b.

> 
> 1. Without this patch:
> 
> On NFS Client:
> $ mount.nfs <NFS_SERVER>:/mnt /mnt
> $ umount.nfs /mnt
> 
> On NFS Server:
> $ umount /mnt
> umount: can't umount /mnt: Device or resource busy
> 
> 2. With this patch:
> 
> On NFS Client:
> $ mount.nfs <NFS_SERVER>:/mnt /mnt
> $ umount.nfs /mnt
> 
> On NFS Server:
> $ umount.nfs /mnt --> umount successful
> 
> Signed-off-by: Namjae Jeon <linkinjeon@gmail.com>
> Signed-off-by: Vivek Trivedi <vtrivedi018@gmail.com>
> ---
>  utils/mountd/mountd.c |    2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
> index bcf5080..2b190fb 100644
> --- a/utils/mountd/mountd.c
> +++ b/utils/mountd/mountd.c
> @@ -275,6 +275,7 @@ mount_umnt_1_svc(struct svc_req *rqstp, dirpath *argp, void *UNUSED(resp))
>  		return 1;
>  
>  	mountlist_del(host_ntop(sap, buf, sizeof(buf)), p);
> +	cache_flush(1);
>  	return 1;
>  }
>  
> @@ -292,6 +293,7 @@ mount_umntall_1_svc(struct svc_req *rqstp, void *UNUSED(argp),
>  	auth_reload();
>  
>  	mountlist_del_all(nfs_getrpccaller(rqstp->rq_xprt));
> +	cache_flush(1);
>  	return 1;
>  }
>  
> -- 
> 1.7.9.5
> 
