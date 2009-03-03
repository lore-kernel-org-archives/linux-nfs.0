From: Suresh Jayaraman <sjayaraman@suse.de>
Subject: Re: [PATCH] NFS: Handle -ESTALE error in access()
Date: Tue, 03 Mar 2009 21:37:41 +0530
Message-ID: <49AD55CD.1030207@suse.de>
References: <49A63BB9.8020401@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-nfs@vger.kernel.org
To: Trond.Myklebust@netapp.com
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from victor.provo.novell.com ([137.65.250.26]:58246 "EHLO
	victor.provo.novell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754413AbZCCQIF (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 3 Mar 2009 11:08:05 -0500
In-Reply-To: <49A63BB9.8020401@suse.de>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Trond,

Wondering whether you get a chance to get to this one?

Thanks,

Suresh Jayaraman wrote:
> Hi Trond,
> 
> I have been looking at a bugreport where trying to open applications on KDE
> on a NFS mounted home fails temporarily. There have been multiple reports on
> different kernel versions pointing to this common issue:
> http://bugzilla.kernel.org/show_bug.cgi?id=12557
> https://bugs.launchpad.net/ubuntu/+source/linux/+bug/269954
> http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=508866.html
> 
> This issue can be reproducible consistently by doing this on a NFS mounted
> home (KDE):
> 1. Open 2 xterm sessions
> 2. From one of the xterm session, do "ssh -X <remote host>"
> 3. "stat ~/.Xauthority" on the remote SSH session 
> 4. Close the two xterm sessions
> 5. On the server do a "stat ~/.Xauthority"
> 6. Now on the client, try to open xterm
> This will fail.
> 
> Even if the filehandle had become stale, the NFS client should invalidate
> the cache/inode and should repeat LOOKUP. Looking at the packet capture when
> the failure occurs shows that there were two subsequent ACCESS() calls with
> the same filehandle and both fails with -ESTALE error.
> 
> I have tested the fix below. Now the client issue a LOOKUP after the
> ACCESS() call fails with -ESTALE. If all this makes sense to you, can you
> consider this for inclusion?
> 
> Thanks,
> 
> 
> If the server returns an -ESTALE error due to stale filehandle in response to
> an ACCESS() call, we need to invalidate the cache and inode so that LOOKUP()
> can be retried. Without this change, the nfs client retries ACCESS() with the
> same filehandle, fails again and could lead to temporary failure of
> applications running on nfs mounted home.
> 
> Signed-off-by: Suresh Jayaraman <sjayaraman@suse.de>
> ---
> 
>  fs/nfs/dir.c |    8 +++++++-
>  1 files changed, 7 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index e35c819..672368f 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1892,8 +1892,14 @@ static int nfs_do_access(struct inode *inode, struct rpc_cred *cred, int mask)
>  	cache.cred = cred;
>  	cache.jiffies = jiffies;
>  	status = NFS_PROTO(inode)->access(inode, &cache);
> -	if (status != 0)
> +	if (status != 0) {
> +		if (status == -ESTALE) {
> +			nfs_zap_caches(inode);
> +			if (!S_ISDIR(inode->i_mode))
> +				set_bit(NFS_INO_STALE, &NFS_I(inode)->flags);
> +		}
>  		return status;
> +	}
>  	nfs_access_add_cache(inode, &cache);
>  out:
>  	if ((mask & ~cache.mask & (MAY_READ | MAY_WRITE | MAY_EXEC)) == 0)
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Suresh Jayaraman
