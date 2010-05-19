From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [PATCH] VFS: Unlink should revoke all outstanding leases on
	file
Date: Wed, 19 May 2010 12:03:21 -0400
Message-ID: <20100519160321.GF4581@fieldses.org>
References: <4BED195F.3070504@cn.fujitsu.com> <20100514055844.109d2fdc@tlielax.poochiereds.net> <4BF3B432.3040802@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Layton <jlayton@redhat.com>,
	NFSv3 list <linux-nfs@vger.kernel.org>,
	linux-fsdevel@vger.kernel.org, ebiederm@xmission.com,
	adobriyan@gmail.com, viro@ZenIV.linux.org.uk, jamie@shareable.org,
	"Trond.Myklebust" <trond.myklebust@fys.uio.no>
To: Mi Jinlong <mijinlong@cn.fujitsu.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <4BF3B432.3040802@cn.fujitsu.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, May 19, 2010 at 05:49:38PM +0800, Mi Jinlong wrote:
> 
> 
> Jeff Layton :
> >>  /*	Check whether we can create an object with dentry child in directory
> > 
> > This doesn't look right to me.
> > 
> > The fcntl(2) manpage basically says that leases should be broken if the
> > file is opened for read or write, or is truncated. unlinks don't seem
> > to fall into either category...
> 
> Maybe the new one is better than before.

On a quick glance, break_lease() (with O_NONBLOCK unset, as here) should
only return ENOMEM or ERSTARTSYS, either of which I suspect is OK.

--b.

> 
> --------------------------------------------------------------
> 
> After client get one file's READ delegation through NFSv4,
> server delete this file but don't reclaim the delegation.
> 
> This patch add break_lease at may_delete, which can reclaim delegations.
> 
> Signed-off-by: Mi Jinlong <mijinlong@cn.fujitsu.com>
> 
> ---
>  fs/namei.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/fs/namei.c b/fs/namei.c
> index b86b96f..0423e19 100644
> --- a/fs/namei.c
> +++ b/fs/namei.c
> @@ -1338,6 +1338,10 @@ static int may_delete(struct inode *dir,struct dentry *victim,int isdir)
>  		return -ENOENT;
>  	if (victim->d_flags & DCACHE_NFSFS_RENAMED)
>  		return -EBUSY;
> +
> +	/* try to break leases, but no effect to delete. */
> +	break_lease(victim->d_inode, FMODE_WRITE);
> +
>  	return 0;
>  }
>  
> -- 
> 1.7.0
> 
> 
> 
> 
