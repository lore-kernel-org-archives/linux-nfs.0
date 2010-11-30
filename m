Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:33501 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751225Ab0K3POo convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 30 Nov 2010 10:14:44 -0500
Subject: Re: [PATCH] mount: make sure mount correctly when kernel not support NFSv4
Content-Type: text/plain; charset=us-ascii
From: Chuck Lever <chuck.lever@oracle.com>
In-Reply-To: <4CF49FBA.2030601@cn.fujitsu.com>
Date: Tue, 30 Nov 2010 10:13:24 -0500
Cc: Steve Dickson <SteveD@redhat.com>, NFSv3 list <linux-nfs@vger.kernel.org>,
        "Trond.Myklebust" <trond.myklebust@fys.uio.no>
Message-Id: <CFD2C4B0-4B8E-4ED5-8654-796C18D4C054@oracle.com>
References: <4CEDFA23.5030103@cn.fujitsu.com> <96BE5F60-06F3-4CE9-8C1D-713992D3F246@oracle.com> <4CF49FBA.2030601@cn.fujitsu.com>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


On Nov 30, 2010, at 1:54 AM, Mi Jinlong wrote:

> 
> 
> Chuck Lever :
>> On Nov 25, 2010, at 12:54 AM, Mi Jinlong wrote:
>> 
>>> When user's nfs client(kernel) don't support NFSv4, maybe they build
>>> kernel without NFSv4, there is a problem.
>>> 
>>> When using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
>>> filesystem, mount will fail and get error:
>>> 
>>> "mount.nfs: an incorrect mount option was specified"
>>> 
>>> as above, the mount should success, but it fail.
>>> 
>>> When the mount command without specific NFS version, nfs-utils will
>>> try to mount NFSv4 at first, but the kernel don't support, the kernel
>>> will return with error EINVAL for parsing option (vers=4) fail.
>> 
>> Maybe the kernel should return EOPNOTSUPP in that case?
> 
>  Yes, what about the following patch.

Seems logical to me.  Up to Trond...

> 
> --
> thanks
> Mi Jinlong
> ---------------------------------------------------------------------------------
> From 4065f2571362ff301683218546151e19148fa775 Mon Sep 17 00:00:00 2001
> From: Mi Jinlong <mijinlong@cn.fujitsu.com>
> Date: Sat, 30 Oct 2010 10:19:33 +0800
> Subject: [PATCH] nfs: kernel should return EPROTONOSUPPORT when not support NFSv4
> 
>  When nfs client(kernel) don't support NFSv4, maybe user build
>  kernel without NFSv4, there is a problem.
> 
>  Using command "mount SERVER-IP:/nfsv3 /mnt/" to mount NFSv3
>  filesystem, mount should should success, but fail and get error:
> 
>    "mount.nfs: an incorrect mount option was specified"
> 
>  System call mount "nfs"(not "nfs4") with "vers=4", 
>  if CONFIG_NFS_V4 is not defined, the "vers=4" will be parsed
>  as invalid argument and kernel return EINVAL to nfs-utils. 
> 
>  About that, we really want get EPROTONOSUPPORT rather than 
>  EINVAL. This path make sure kernel parses argument success,
>  and return EPROTONOSUPPORT at nfs_validate_mount_data().
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> ---
> fs/nfs/super.c |    4 ----
> 1 files changed, 0 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 3c04504..4100630 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -1069,12 +1069,10 @@ static int nfs_parse_mount_options(char *raw,
> 			mnt->flags |= NFS_MOUNT_VER3;
> 			mnt->version = 3;
> 			break;
> -#ifdef CONFIG_NFS_V4
> 		case Opt_v4:
> 			mnt->flags &= ~NFS_MOUNT_VER3;
> 			mnt->version = 4;
> 			break;
> -#endif
> 		case Opt_udp:
> 			mnt->flags &= ~NFS_MOUNT_TCP;
> 			mnt->nfs_server.protocol = XPRT_TRANSPORT_UDP;
> @@ -1286,12 +1284,10 @@ static int nfs_parse_mount_options(char *raw,
> 				mnt->flags |= NFS_MOUNT_VER3;
> 				mnt->version = 3;
> 				break;
> -#ifdef CONFIG_NFS_V4
> 			case NFS4_VERSION:
> 				mnt->flags &= ~NFS_MOUNT_VER3;
> 				mnt->version = 4;
> 				break;
> -#endif
> 			default:
> 				goto out_invalid_value;
> 			}
> -- 
> 1.7.3.2
> 
> 

-- 
Chuck Lever
chuck[dot]lever[at]oracle[dot]com




