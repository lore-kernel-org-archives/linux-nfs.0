Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:38727 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751572Ab0K2Oke (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 29 Nov 2010 09:40:34 -0500
Subject: Re: [PATCH] mount: make sure mount correctly when kernel not support NFSv4
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CEDFA23.5030103@cn.fujitsu.com>
Date: Mon, 29 Nov 2010 09:40:07 -0500
Cc: Steve Dickson <SteveD@redhat.com>, NFSv3 list <linux-nfs@vger.kernel.org>
Message-Id: <96BE5F60-06F3-4CE9-8C1D-713992D3F246@oracle.com>
References: <4CEDFA23.5030103@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 25, 2010, at 12:54 AM, Mi Jinlong wrote:

> When user's nfs client(kernel) don't support NFSv4, maybe they build
> kernel without NFSv4, there is a problem.
> 
> When using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
> filesystem, mount will fail and get error:
> 
> "mount.nfs: an incorrect mount option was specified"
> 
> as above, the mount should success, but it fail.
> 
> When the mount command without specific NFS version, nfs-utils will
> try to mount NFSv4 at first, but the kernel don't support, the kernel
> will return with error EINVAL for parsing option (vers=4) fail.

Maybe the kernel should return EOPNOTSUPP in that case?

> nfs-utils should continue to try mounting NFSv3 when meeting that.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
> utils/mount/stropts.c |    4 ++++
> 1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index 50a1a2a..e880c45 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -788,6 +788,10 @@ static int nfs_autonegotiate(struct nfsmount_info *mi)
> 		/* Linux servers prior to 2.6.25 may return
> 		 * EPERM when NFS version 4 is not supported. */
> 		goto fall_back;
> +	case EINVAL:
> +		/* If Linux kernel don't support NFSv4, the EINVAL
> +		 * will be return for parsing option (vers=4) fail. */
> +		goto fall_back;
> 	default:
> 		return result;
> 	}
> -- 
> 1.7.3.2
> 
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




