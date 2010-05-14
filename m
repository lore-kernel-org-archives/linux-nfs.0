From: Jeff Layton <jlayton@redhat.com>
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
 file
Date: Fri, 14 May 2010 05:58:44 -0400
Message-ID: <20100514055844.109d2fdc@tlielax.poochiereds.net>
References: <4BED195F.3070504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: NFSv3 list <linux-nfs@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:14845 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751585Ab0ENJ67 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 14 May 2010 05:58:59 -0400
In-Reply-To: <4BED195F.3070504@cn.fujitsu.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, 14 May 2010 17:35:27 +0800
Mi Jinlong <mijinlong@cn.fujitsu.com> wrote:

> After client get one file's READ delegation through NFSv4,
> server delete this file but don't reclaim the delegation.
> 
> This patch add break_lease at may_delete, which can reclaim delegations.
> 
> ---
>  fs/namei.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index 16df727..17bafc1 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1338,7 +1338,7 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
>  		return -ENOENT;
>  	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
>  		return -EBUSY;
> -	return 0;
> +	return break_lease(victim->d_inode, FMODE_WRITE);
>  }
>  
>  /*	Check whether we can create an object with dentry child in directory

This doesn't look right to me.

The fcntl(2) manpage basically says that leases should be broken if the
file is opened for read or write, or is truncated. unlinks don't seem
to fall into either category...

-- 
Jeff Layton <jlayton@redhat.com>
