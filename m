Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:48572 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752041Ab0LGWei convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 17:34:38 -0500
Subject: Re: [PATCH] nfs: Discard ACL cache on mode update
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: bfields@fieldses.org, linux-nfs@vger.kernel.org
In-Reply-To: <1291200136-9982-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
References: <1291200136-9982-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 17:34:36 -0500
Message-ID: <1291761276.3049.47.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Wed, 2010-12-01 at 16:12 +0530, Aneesh Kumar K.V wrote:
> An update of mode bits can result in ACL value being changed. We need
> to mark the acl cache invalid when we update mode. Similarly we need
> to update file attribute when we change ACL value
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
> ---
>  fs/nfs/nfs4proc.c |    9 +++++++++
>  1 files changed, 9 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 821d4c7..89fb751 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3356,6 +3356,8 @@ ssize_t nfs4_proc_get_acl(struct inode *inode, void *buf, size_t buflen)
>  	ret = nfs_revalidate_inode(server, inode);
>  	if (ret < 0)
>  		return ret;
> +	if (NFS_I(inode)->cache_validity & NFS_INO_INVALID_ACL)
> +		nfs_zap_acl_cache(inode);
>  	ret = nfs4_read_cached_acl(inode, buf, buflen);
>  	if (ret != -ENOENT)
>  		return ret;
> @@ -3384,6 +3386,13 @@ static int __nfs4_proc_set_acl(struct inode *inode, const void *buf, size_t bufl
>  	nfs_inode_return_delegation(inode);
>  	buf_to_pages(buf, buflen, arg.acl_pages, &arg.acl_pgbase);
>  	ret = nfs4_call_sync(server, &msg, &arg, &res, 1);
> +	/*
> +	 * Acl update can result in inode attribute update.
> +	 * so mark the attribute cache invalid.
> +	 */
> +	spin_lock(&inode->i_lock);
> +	NFS_I(inode)->cache_validity |= NFS_INO_INVALID_ATTR;
> +	spin_unlock(&inode->i_lock);
>  	nfs_access_zap_cache(inode);
>  	nfs_zap_acl_cache(inode);
>  	return ret;

Thanks! Applied...

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

