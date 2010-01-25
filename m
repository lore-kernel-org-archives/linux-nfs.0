Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from acsinet12.oracle.com ([141.146.126.234]:47975 "EHLO
	acsinet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751314Ab0AYWkH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 25 Jan 2010 17:40:07 -0500
Cc: linux-nfs@vger.kernel.org
Message-Id: <6A7EB11E-1344-44DB-969A-0AA1B82DA640@oracle.com>
From: Chuck Lever <chuck.lever@oracle.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
In-Reply-To: <20100125215734.14716.19614.stgit@localhost.localdomain>
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Subject: Re: [PATCH 0/8] What's in the 'bugfixes' branch of the NFS client git tree
Date: Mon, 25 Jan 2010 17:39:46 -0500
References: <20100125215734.14716.19614.stgit@localhost.localdomain>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On Jan 25, 2010, at 4:57 PM, Trond Myklebust wrote:
> I've committed the following patches to the 'bugfixes' branch for
> merging into mainline before the release of 2.6.33. Please review

Reviewed-by: Chuck Lever <chuck.lever@oracle.com>

I checked for mechanical problems.  The semantics of NFSv4 locking is  
beyond me, but fortunately the changes looked mostly obvious.

> Cheers
>  Trond
>
> ---
>
> David Howells (1):
>      NFS: Avoid warnings when CONFIG_NFS_V4=n
>
> H Hartley Sweeten (1):
>      NFS: Make nfs_commitdata_release static
>
> Trond Myklebust (6):
>      NFS: Ensure that we handle NFS4ERR_STALE_STATEID correctly
>      NFSv4.1: Don't call nfs4_schedule_state_recovery() unnecessarily
>      NFSv4: Don't allow posix locking against servers that don't  
> support it
>      NFSv4: Ensure that the NFSv4 locking can recover from stateid  
> errors
>      NFS: Try to commit unstable writes in nfs_release_page()
>      NFS: Fix a reference leak in nfs_wb_cancel_page()
>
>
> fs/nfs/file.c      |    2 +
> fs/nfs/nfs4_fs.h   |    2 +
> fs/nfs/nfs4proc.c  |   78 ++++++++++++++++++++++++++++++++++++++ 
> +-------------
> fs/nfs/nfs4state.c |    2 +
> fs/nfs/sysctl.c    |    2 +
> fs/nfs/write.c     |    3 +-
> 6 files changed, 67 insertions(+), 22 deletions(-)
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs"  
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com



