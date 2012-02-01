Return-Path: linux-nfs-owner@vger.kernel.org
Received: from acsinet15.oracle.com ([141.146.126.227]:35474 "EHLO
	acsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755674Ab2BATRq convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 1 Feb 2012 14:17:46 -0500
Subject: Re: [PATCH 2/2] NFS: add mount option 'v4.1'
Mime-Version: 1.0 (Apple Message framework v1251.1)
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <1328122817-661-2-git-send-email-dros@netapp.com>
Date: Wed, 1 Feb 2012 14:17:41 -0500
Cc: Trond.Myklebust@netapp.com, linux-nfs@vger.kernel.org
Message-Id: <16B8D5D9-4373-474E-A54A-AF853AC59153@oracle.com>
References: <1328122817-661-1-git-send-email-dros@netapp.com> <1328122817-661-2-git-send-email-dros@netapp.com>
To: Weston Andros Adamson <dros@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi-

I think we should co-ordinate with Solaris on this administrative interface.  Can we discuss in Santa Clara?

On Feb 1, 2012, at 2:00 PM, Weston Andros Adamson wrote:

> 
> Signed-off-by: Weston Andros Adamson <dros@netapp.com>
> ---
> I was already messing around with mountoptions and figured "why not".
> It's been joked (?) that 4.1 really should have been NFSv5! 
> 
> fs/nfs/super.c |    8 +++++++-
> 1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 50baca1..801b060 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -80,7 +80,7 @@ enum {
> 	Opt_cto, Opt_nocto,
> 	Opt_ac, Opt_noac,
> 	Opt_lock, Opt_nolock,
> -	Opt_v2, Opt_v3, Opt_v4,
> +	Opt_v2, Opt_v3, Opt_v4, Opt_v4_1,
> 	Opt_udp, Opt_tcp, Opt_rdma,
> 	Opt_acl, Opt_noacl,
> 	Opt_rdirplus, Opt_nordirplus,
> @@ -136,6 +136,7 @@ static const match_table_t nfs_mount_option_tokens = {
> 	{ Opt_v2, "v2" },
> 	{ Opt_v3, "v3" },
> 	{ Opt_v4, "v4" },
> +	{ Opt_v4_1, "v4.1" },
> 	{ Opt_udp, "udp" },
> 	{ Opt_tcp, "tcp" },
> 	{ Opt_rdma, "rdma" },
> @@ -1172,6 +1173,11 @@ static int nfs_parse_mount_options(char *raw,
> 			mnt->flags &= ~NFS_MOUNT_VER3;
> 			mnt->version = 4;
> 			break;
> +		case Opt_v4_1:
> +			mnt->flags &= ~NFS_MOUNT_VER3;
> +			mnt->version = 4;
> +			mnt->minorversion = 1;
> +			break;
> 		case Opt_udp:
> 			mnt->flags &= ~NFS_MOUNT_TCP;
> 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> -- 
> 1.7.4.4
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




