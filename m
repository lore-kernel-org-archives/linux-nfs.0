Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:6278 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750763Ab3GIKyC (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 9 Jul 2013 06:54:02 -0400
Date: Tue, 9 Jul 2013 06:54:00 -0400
From: Jeff Layton <jlayton@redhat.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org
Subject: Re: [PATCH 03/12] vfs: rename I_MUTEX_QUOTA now that it's not used
 for quotas
Message-ID: <20130709065400.5a55a655@tlielax.poochiereds.net>
In-Reply-To: <1372882356-14168-4-git-send-email-bfields@redhat.com>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
	<1372882356-14168-4-git-send-email-bfields@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed,  3 Jul 2013 16:12:27 -0400
"J. Bruce Fields" <bfields@redhat.com> wrote:

> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> I_MUTEX_QUOTA is now just being used whenever we want to lock two
> non-directories.  So the name isn't right.  I_MUTEX_NONDIR2 isn't
> especially elegant but it's the best I could think of.
> 
> Also fix some outdated documentation.
> 
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/inode.c         |    4 ++--
>  include/linux/fs.h |    9 ++++++---
>  2 files changed, 8 insertions(+), 5 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 942451b..304db4c 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -988,10 +988,10 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
>  {
>  	if (inode1 < inode2) {
>  		mutex_lock(&inode1->i_mutex);
> -		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_QUOTA);
> +		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_NONDIR2);
>  	} else {
>  		mutex_lock(&inode2->i_mutex);
> -		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_QUOTA);
> +		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_NONDIR2);
>  	}
>  }
>  EXPORT_SYMBOL(lock_two_nondirectories);
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 3258761..ec88235 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -620,10 +620,13 @@ static inline int inode_unhashed(struct inode *inode)
>   * 0: the object of the current VFS operation
>   * 1: parent
>   * 2: child/target
> - * 3: quota file
> + * 3: xattr
> + * 4: second non-directory
> + * The last is for certain operations (such as rename) which lock two
> + * non-directories at once.
>   *
>   * The locking order between these classes is
> - * parent -> child -> normal -> xattr -> quota
> + * parent -> child -> normal -> xattr -> second non-directory
>   */
>  enum inode_i_mutex_lock_class
>  {
> @@ -631,7 +634,7 @@ enum inode_i_mutex_lock_class
>  	I_MUTEX_PARENT,
>  	I_MUTEX_CHILD,
>  	I_MUTEX_XATTR,
> -	I_MUTEX_QUOTA
> +	I_MUTEX_NONDIR2
>  };
>  
>  void lock_two_nondirectories(struct inode *, struct inode*);

Ugly name, but I'm not sure what to call it either. Wonder if it would
make sense to do some sort of SOURCE/TARGET lock class and rearrange
the code to take that into account? But, that's just bikeshedding, so...

Acked-by: Jeff Layton <jlayton@redhat.com>
