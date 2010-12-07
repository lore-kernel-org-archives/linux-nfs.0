Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:59924 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754050Ab0LGWaW convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 7 Dec 2010 17:30:22 -0500
Subject: Re: [PATCH v2] NFS: suppressing showing of default mount port
 value in /proc fixed
From: Trond Myklebust <Trond.Myklebust@netapp.com>
To: Stanislav Kinsbursky <skinsbursky@parallels.com>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org
In-Reply-To: <20101206085553.2172.24863.stgit@localhost6.localdomain6>
References: <20101206085553.2172.24863.stgit@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 07 Dec 2010 17:30:11 -0500
Message-ID: <1291761011.3049.46.camel@heimdal.trondhjem.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Mon, 2010-12-06 at 12:00 +0300, Stanislav Kinsbursky wrote:
> Update: added check for zero value as it was before (note: can't simply check
> mountd_port for positive value because it's typeof unsigned short)
> 
> Default value for mount server port is set to NFS_UNSPEC_PORT (-1) and will not
> be changed during parsing mount options for mound data version 6. This default
> value will be showed for mountport in /proc/mounts always since current default
> check is for zero value. This small mistake leads to big problem, because
> during umount.nfs execution from old user-space utils (at least nfs-utils
> 1.0.9) this value will be used as the server port to connect to. This request
> will be rejected (since port is 65535) and thus nfs mount point can't be
> unmounted.
> 
> Note from Chuck Lever (chuck.lever@oracle.com): this is only possible if
> /etc/mtab is a link to /proc/mounts.  Not all systems have this configuration.
> 
> ---
>  fs/nfs/super.c |    4 +++-
>  1 files changed, 3 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/super.c b/fs/nfs/super.c
> index 6d6e21d..449024f 100644
> --- a/fs/nfs/super.c
> +++ b/fs/nfs/super.c
> @@ -681,7 +681,9 @@ static void nfs_show_mountd_options(struct seq_file *m, struct nfs_server *nfss,
>  
>  	if (nfss->mountd_version || showdefaults)
>  		seq_printf(m, ",mountvers=%u", nfss->mountd_version);
> -	if (nfss->mountd_port || showdefaults)
> +	if ((nfss->mountd_port &&
> +		nfss->mountd_port != (unsigned short)NFS_UNSPEC_PORT) || 
> +		showdefaults)
>  		seq_printf(m, ",mountport=%u", nfss->mountd_port);
>  
>  	nfs_show_mountd_netid(m, nfss, showdefaults);
> 

This patch needs a 'Signed-off-by:' before I can apply it.

Cheers
  Trond

-- 
Trond Myklebust
Linux NFS client maintainer

NetApp
Trond.Myklebust@netapp.com
www.netapp.com

