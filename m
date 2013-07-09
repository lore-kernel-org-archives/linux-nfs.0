Return-Path: linux-nfs-owner@vger.kernel.org
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:56917 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750723Ab3GIWER (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jul 2013 18:04:17 -0400
Date: Wed, 10 Jul 2013 08:04:11 +1000
From: Dave Chinner <david@fromorbit.com>
To: "J. Bruce Fields" <bfields@redhat.com>
Cc: Al Viro <viro@zeniv.linux.org.uk>, linux-nfs@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>
Subject: Re: [PATCH 01/12] vfs: pull ext4's double-i_mutex-locking into
 common code
Message-ID: <20130709220411.GK3438@dastard>
References: <1372882356-14168-1-git-send-email-bfields@redhat.com>
 <1372882356-14168-2-git-send-email-bfields@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1372882356-14168-2-git-send-email-bfields@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Jul 03, 2013 at 04:12:25PM -0400, J. Bruce Fields wrote:
> From: "J. Bruce Fields" <bfields@redhat.com>
> 
> We want to do this elsewhere as well.
> 
> Cc: "Theodore Ts'o" <tytso@mit.edu>
> Cc: Andreas Dilger <adilger.kernel@dilger.ca>
> Signed-off-by: J. Bruce Fields <bfields@redhat.com>
> ---
>  fs/ext4/ext4.h        |    2 --
>  fs/ext4/ioctl.c       |    4 ++--
>  fs/ext4/move_extent.c |   40 ++--------------------------------------
>  fs/inode.c            |   29 +++++++++++++++++++++++++++++
>  include/linux/fs.h    |    3 +++
>  5 files changed, 36 insertions(+), 42 deletions(-)
> 
> diff --git a/fs/ext4/ext4.h b/fs/ext4/ext4.h
> index 5aae3d1..3590abe 100644

Just to throw a spanner in the works - have you considered that
other filesystems might have different inode lock ordering rules?

For example, XFS locks multiple inodes in ascending inode number
order, not ordered by pointer address. Hence we end up different
inode lock ordering at different layers of the stack and I can't see
that ending well....

> diff --git a/fs/inode.c b/fs/inode.c
> index 00d5fc3..b8afbc7 100644
> --- a/fs/inode.c
> +++ b/fs/inode.c
> @@ -980,6 +980,35 @@ void unlock_new_inode(struct inode *inode)
>  EXPORT_SYMBOL(unlock_new_inode);
>  
>  /**
> + * lock_two_nondirectories - take two i_mutexes on non-directory objects
> + * @inode1: first inode to lock
> + * @inode2: second inode to lock
> + */
> +void lock_two_nondirectories(struct inode *inode1, struct inode *inode2)
> +{
> +	if (inode1 < inode2) {
> +		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_PARENT);
> +		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_CHILD);
> +	} else {
> +		mutex_lock_nested(&inode2->i_mutex, I_MUTEX_PARENT);
> +		mutex_lock_nested(&inode1->i_mutex, I_MUTEX_CHILD);
> +	}
> +}
> +EXPORT_SYMBOL(lock_two_nondirectories);

What makes this specific to non-directories? If it's not to be used
for directory inodes, then there should be WARN_ON_ONCE() guards in
the code...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
