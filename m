From: Trond Myklebust <Trond.Myklebust@netapp.com>
Subject: Re: [PATCH 1/1] nfs4 use mandatory attribute file type in
 nfs4_get_root
Date: Mon, 14 Jun 2010 18:02:06 -0400
Message-ID: <1276552926.3953.8.camel@heimdal.trondhjem.org>
References: <1276203143-2118-1-git-send-email-andros@netapp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: linux-nfs@vger.kernel.org
To: andros@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:30718 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751244Ab0FNWCI convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 14 Jun 2010 18:02:08 -0400
Received: from svlrsexc2-prd.hq.netapp.com (svlrsexc2-prd.hq.netapp.com [10.57.115.31])
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id o5EM28mr024756
	for <linux-nfs@vger.kernel.org>; Mon, 14 Jun 2010 15:02:08 -0700 (PDT)
In-Reply-To: <1276203143-2118-1-git-send-email-andros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2010-06-10 at 16:52 -0400, andros@netapp.com wrote:
> From: Andy Adamson <andros@netapp.com>
> 
> decode_attr_type sets fattr->mode.

Well, yes... It sets part of fattr->mode. More specifically, though, it
sets the file type part, so your patch is correct.

I'll fix up the above changelog entry so that it is a bit more
descriptive. How about the following?

        S_ISDIR(fsinfo.fattr->mode) checks the file type rather than the
        mode bits, so we should be checking for the NFS_ATTR_FATTR_TYPE
        fattr property.

> 
> Signed-off-by: Andy Adamson <andros@netapp.com>
> ---
>  fs/nfs/getroot.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/getroot.c b/fs/nfs/getroot.c
> index 7428f7d..a70e446 100644
> --- a/fs/nfs/getroot.c
> +++ b/fs/nfs/getroot.c
> @@ -146,7 +146,7 @@ int nfs4_get_rootfh(struct nfs_server *server, struct nfs_fh *mntfh)
>  		goto out;
>  	}
>  
> -	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_MODE)
> +	if (!(fsinfo.fattr->valid & NFS_ATTR_FATTR_TYPE)
>  			|| !S_ISDIR(fsinfo.fattr->mode)) {
>  		printk(KERN_ERR "nfs4_get_rootfh:"
>  		       " getroot encountered non-directory\n");


