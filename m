Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from ipmail04.adl6.internode.on.net ([150.101.137.141]:47088 "EHLO
	ipmail04.adl6.internode.on.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752658AbbJKXjy (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 11 Oct 2015 19:39:54 -0400
Date: Mon, 12 Oct 2015 10:37:40 +1100
From: Dave Chinner <david@fromorbit.com>
To: Andreas Gruenbacher <andreas.gruenbacher@gmail.com>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org,
        Andreas Gruenbacher <agruenba@redhat.com>
Subject: Re: [PATCH v10 23/46] xfs: Make xfs_set_mode non-static
Message-ID: <20151011233740.GZ27164@dastard>
References: <1444604337-17651-1-git-send-email-andreas.gruenbacher@gmail.com>
 <1444604337-17651-24-git-send-email-andreas.gruenbacher@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <1444604337-17651-24-git-send-email-andreas.gruenbacher@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Mon, Oct 12, 2015 at 12:58:34AM +0200, Andreas Gruenbacher wrote:
> From: Andreas Gruenbacher <agruenba@redhat.com>
> 
> Make xfs_set_mode non-static and move it from xfs_acl.c into xfs_inode.c.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
.....
> +++ b/fs/xfs/xfs_inode.c
> @@ -3587,3 +3587,21 @@ xfs_iflush_int(
>  corrupt_out:
>  	return -EFSCORRUPTED;
>  }
> +
> +int
> +xfs_set_mode(struct inode *inode, umode_t mode)
> +{
> +	int error = 0;
> +
> +	if (mode != inode->i_mode) {
> +		struct iattr iattr;
> +
> +		iattr.ia_valid = ATTR_MODE | ATTR_CTIME;
> +		iattr.ia_mode = mode;
> +		iattr.ia_ctime = current_fs_time(inode->i_sb);
> +
> +		error = xfs_setattr_nonsize(XFS_I(inode), &iattr, XFS_ATTR_NOACL);
> +	}
> +
> +	return error;
> +}

Now needs a comment to explain that this function has a special
"called only from ACL modification" context associated with it.

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com
