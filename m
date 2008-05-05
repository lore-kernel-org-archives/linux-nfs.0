From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH] NFS: Ensure that 'noac' and/or 'actimeo=0' turn off attribute caching
Date: Mon, 5 May 2008 11:02:00 -0400
Message-ID: <6A5A94A9-6F7A-469C-926D-A39B18381FFE@oracle.com>
References: <20080502202502.29449.81285.stgit@c-69-242-210-120.hsd1.mi.comcast.net>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Cc: linux-nfs@vger.kernel.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from rgminet01.oracle.com ([148.87.113.118]:35132 "EHLO
	rgminet01.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756069AbYEEPCX (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 5 May 2008 11:02:23 -0400
In-Reply-To: <20080502202502.29449.81285.stgit-KPEdlmqt5P7XOazzY/2fV4TcuzvYVacciM950cveMlzk1uMJSBkQmQ@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond-

On May 2, 2008, at 4:25 PM, Trond Myklebust wrote:
> Both the 'noac' and 'actimeo=0' mount options should ensure that  
> attributes
> are not cached, however a bug in nfs_attribute_timeout() means that
> currently, the attributes may in fact get cached for up to one  
> jiffy. This
> has been seen to cause corruption in some applications.
>
> The reason for the bug is that the time_in_range() test returns  
> 'true' as
> long as the current time lies between nfsi->read_cache_jiffies and
> nfsi->read_cache_jiffies + nfsi->attrtimeo. In other words, if jiffies
> equals nfsi->read_cache_jiffies, then we still cache the attribute  
> data.
>
> Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> ---
>
> fs/nfs/inode.c |    7 +++++++
> 1 files changed, 7 insertions(+), 0 deletions(-)
>
> diff --git a/fs/nfs/inode.c b/fs/nfs/inode.c
> index 5cb3345..38f06d3 100644
> --- a/fs/nfs/inode.c
> +++ b/fs/nfs/inode.c
> @@ -707,6 +707,13 @@ int nfs_attribute_timeout(struct inode *inode)
>
> 	if (nfs_have_delegation(inode, FMODE_READ))
> 		return 0;
> +	/*
> +	 * Special case: if the attribute timeout is set to 0, then we
> +	 * 		 treat the cache as having expired (unless we
> +	 * 		 have a delegation).
> +	 */
> +	if (nfsi->attrtimeo == 0)
> +		return 1;
> 	return !time_in_range(jiffies, nfsi->read_cache_jiffies, nfsi- 
> >read_cache_jiffies + nfsi->attrtimeo);
> }

Do nfs_access_get_cached() and nfs_update_inode() have the same issue?

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
