Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:1665 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752912Ab2FHNUX (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 8 Jun 2012 09:20:23 -0400
Message-ID: <4FD1FC02.2000608@netapp.com>
Date: Fri, 08 Jun 2012 09:20:02 -0400
From: Bryan Schumaker <bjschuma@netapp.com>
MIME-Version: 1.0
To: Joerg Roedel <joro@8bytes.org>
CC: Trond Myklebust <Trond.Myklebust@netapp.com>, linux-nfs@vger.kernel.org,
        linux-kernel@vger.kernel.org
Subject: Re: NFS regression in v3.5-rc1: mount.nfs yells about incorrect mount
 option
References: <20120607150456.GO12795@8bytes.org> <4FD0C4C2.8020605@netapp.com> <20120607155006.GR12795@8bytes.org> <4FD0CEB0.9040804@netapp.com> <20120608130352.GU12795@8bytes.org>
In-Reply-To: <20120608130352.GU12795@8bytes.org>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 06/08/2012 09:03 AM, Joerg Roedel wrote:
> On Thu, Jun 07, 2012 at 11:54:24AM -0400, Bryan Schumaker wrote:
>> On 06/07/2012 11:50 AM, Joerg Roedel wrote:
>>> mount -o nfsvers=3 ...
>>
>> What about `mount -o vers=4 ...`?  I'm compiling a kernel right now to
>> see if I can reproduce this, what NFS .config options do you have set?
>> (`cat .config | grep CONFIG_NFS_` should be good enough).
> 
> Okay, I tracked it down somewhat. The problem is that the nfs-version
> is not set in my case so that data->version in nfs_init_server is 0. The
> function returns -EPROTONOSUPPORT in this case which causes the mount
> to fail. The evil commit is db8333519 and reverting it fixes the issue
> for me. Patch attached.

Thanks!  I wasn't able to reproduce this on Ubuntu 12.04, so now I'm setting up 10.04 to see if that makes a difference.  I'd like to understand what's going on (and why my other patch didn't fix this problem) before reverting.

- Bryan
> 
> Regards,
> 
> 	Joerg
> 
> From: Joerg Roedel <joerg.roedel@amd.com>
> Date: Fri, 8 Jun 2012 14:51:01 +0200
> Subject: [PATCH] Revert "NFS: Let mount data parsing set the NFS version"
> 
> This reverts commit db8333519187d5974cf2ff33910c893bf8727d9f.
> 
> The original commit message says, that the version field is
> "unconditionally set while parsing mount data".
> Unfortunatly this is not the case and the version field may
> stay 0 so that nfs_init_server returns -EPROTONOSUPPORT
> causing the mount to fail.  Reverting this commit fixes the
> issue.
> 
> Conflicts:
> 
> 	fs/nfs/super.c
> 
> Signed-off-by: Joerg Roedel <joerg.roedel@amd.com>
> ---
>  fs/nfs/super.c |    5 +++--
>  1 file changed, 3 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index ff656c0..2fd4ce5 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -948,7 +948,7 @@ static void nfs_umount_begin(struct super_block *sb)
>  		rpc_killall_tasks(rpc);
>  }
>  
> -static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
> +static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(unsigned int version)
>  {
>  	struct nfs_parsed_mount_data *data;
>  
> @@ -963,6 +963,7 @@ static struct nfs_parsed_mount_data *nfs_alloc_parsed_mount_data(void)
>  		data->nfs_server.protocol = XPRT_TRANSPORT_TCP;
>  		data->auth_flavors[0]	= RPC_AUTH_UNIX;
>  		data->auth_flavor_len	= 1;
> +		data->version		= version;
>  		data->minorversion	= 0;
>  		data->need_mount	= true;
>  		data->net		= current->nsproxy->net_ns;
> @@ -2479,7 +2480,7 @@ static struct dentry *nfs_fs_mount(struct file_system_type *fs_type,
>  	struct dentry *mntroot = ERR_PTR(-ENOMEM);
>  	int error;
>  
> -	mount_info.parsed = nfs_alloc_parsed_mount_data();
> +	mount_info.parsed = nfs_alloc_parsed_mount_data(NFS_DEFAULT_VERSION);
>  	mount_info.mntfh = nfs_alloc_fhandle();
>  	if (mount_info.parsed == NULL || mount_info.mntfh == NULL)
>  		goto out;
> 


