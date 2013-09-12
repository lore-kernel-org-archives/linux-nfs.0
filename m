Return-Path: linux-nfs-owner@vger.kernel.org
Received: from fieldses.org ([174.143.236.118]:56673 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751703Ab3ILDOc (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 11 Sep 2013 23:14:32 -0400
Date: Wed, 11 Sep 2013 23:14:30 -0400
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, jlayton@redhat.com,
        Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 02/13] vfs: don't use PARENT/CHILD lock classes for
 non-directories
Message-ID: <20130912031430.GC1462@fieldses.org>
References: <1378929799-1110-1-git-send-email-bfields@redhat.com>
 <1378929799-1110-3-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1378929799-1110-3-git-send-email-bfields@redhat.com>
From: "J. Bruce Fields" <bfields@fieldses.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Sep 11, 2013 at 04:03:08PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> Reserve I_MUTEX_PARENT and I_MUTEX_CHILD for locking of actual
> directories.
> 
> (Also I_MUTEX_QUOTA isn't really a meaningful name for this locking
> class any more; fixed in a later patch.)

Argh, apologies!  Revising this patch at one point I forgot to fix up
one line, and I somehow overlooked the resulting lockdep warning till
just now.

So it also needs a chunk like:

@@ -990,7 +990,7 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
 {
 	WARN_ON_ONCE(S_ISDIR(inode1->i_mode));
 	if (inode1 == inode2 || !inode2) {
-		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
+		mutex_lock(&inode1->i_mutex);
 		return;
 	}
 	WARN_ON_ONCE(S_ISDIR(inode2->i_mode));

--b.


> 
> Acked-by: Jeff Layton <jlayton@redhat.com>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/inode.c |    8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)
> 
> diff --git a/fs/inode.c b/fs/inode.c
> index 20750b0..9f50a7e 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -995,11 +995,11 @@ void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
>  	}
>  	WARN_ON_ONCE(S_ISDIR(inode2->i_mode));
>  	if (inode1 < inode2) {
> -		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
> -		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
> +		mutex_lock(&inode1->i_mutex);
> +		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_QUOTA);
>  	} else {
> -		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
> -		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
> +		mutex_lock(&inode2->i_mutex);
> +		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_QUOTA);
>  	}
>  }
>  EXPORT_SYMBOL(lock_two_nondirectories);
> -- 
> 1.7.9.5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
