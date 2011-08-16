Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:1026 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751792Ab1HPSDA (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 16 Aug 2011 14:03:00 -0400
Received: from int-mx02.intmail.prod.int.phx2.redhat.com (int-mx02.intmail.prod.int.phx2.redhat.com [10.5.11.12])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p7GI2wKi019523
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Tue, 16 Aug 2011 14:03:00 -0400
Message-ID: <4E4A9F01.2080305@RedHat.com>
Date: Tue, 16 Aug 2011 12:46:57 -0400
From: Steve Dickson <SteveD@redhat.com>
To: Steve Dickson <steved@redhat.com>
CC: Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Subject: Re: [PATCH] mount.nfs: submarvellous messages from mount.nfs
References: <1313496159-4281-1-git-send-email-steved@redhat.com>
In-Reply-To: <1313496159-4281-1-git-send-email-steved@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0



On 08/16/2011 08:02 AM, Steve Dickson wrote:
> From: Max Matveev <makc@redhat.com>
> 
> Consider a setup where mountd on the server is controlled via
> tcp_wrappers (usual RHEL setup) and will not process calls from a
> particular client because of something in /etc/hosts.deny.
> 
> When such client attempts to do v3 mount, the error message printed
> by mount.nfs is misleading.
> 
> This patch changes that error message from:
>     mount.nfs: Argument list too long
> to
>     mount.nfs: access denied by server while mounting server:/export
> 
> Signed-off-by: Steve Dickson <steved@redhat.com>
Committed...

steved.

> ---
>  utils/mount/stropts.c |    2 ++
>  1 files changed, 2 insertions(+), 0 deletions(-)
> 
> diff --git a/utils/mount/stropts.c b/utils/mount/stropts.c
> index f1aa503..4d023d6 100644
> --- a/utils/mount/stropts.c
> +++ b/utils/mount/stropts.c
> @@ -538,6 +538,8 @@ nfs_rewrite_pmap_mount_options(struct mount_options *options)
>  		errno = ESPIPE;
>  		if (rpc_createerr.cf_stat == RPC_PROGNOTREGISTERED)
>  			errno = EOPNOTSUPP;
> +		else if (rpc_createerr.cf_stat == RPC_AUTHERROR)
> +			errno = EACCES;
>  		else if (rpc_createerr.cf_error.re_errno != 0)
>  			errno = rpc_createerr.cf_error.re_errno;
>  		return 0;
