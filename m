Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qk0-f180.google.com ([209.85.220.180]:34849 "EHLO
	mail-qk0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932133AbcGFSbW (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 6 Jul 2016 14:31:22 -0400
Received: by mail-qk0-f180.google.com with SMTP id s126so38666039qkh.2
        for <linux-nfs@vger.kernel.org>; Wed, 06 Jul 2016 11:31:17 -0700 (PDT)
Message-ID: <1467829873.2908.1.camel@redhat.com>
Subject: Re: [PATCH v23 12/22] vfs: Add get_richacl and set_richacl inode
 operations
From: Jeff Layton <jlayton@redhat.com>
To: Andreas Gruenbacher <agruenba@redhat.com>,
        Alexander Viro <viro@zeniv.linux.org.uk>
Cc: Christoph Hellwig <hch@infradead.org>, "Theodore Ts'o" <tytso@mit.edu>,
        Andreas Dilger <adilger.kernel@dilger.ca>,
        "J. Bruce Fields" <bfields@fieldses.org>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>,
        Dave Chinner <david@fromorbit.com>, linux-ext4@vger.kernel.org,
        xfs@oss.sgi.com, linux-kernel@vger.kernel.org,
        linux-fsdevel@vger.kernel.org, linux-nfs@vger.kernel.org,
        linux-cifs@vger.kernel.org, linux-api@vger.kernel.org
Date: Wed, 06 Jul 2016 14:31:13 -0400
In-Reply-To: <1467294433-3222-13-git-send-email-agruenba@redhat.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
	 <1467294433-3222-13-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-06-30 at 15:47 +0200, Andreas Gruenbacher wrote:
> These operations are similar to the get_acl and set_acl operations for
> POSIX ACLs.  The distinction between access and default ACLs doesn't exist
> for richacls.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: Steve French <steve.french@primarydata.com>
> ---
>  include/linux/fs.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 06a30b0..ac96bda 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1726,6 +1726,7 @@ struct inode_operations {
>  	const char * (*get_link) (struct dentry *, struct inode *, struct delayed_call *);
>  	int (*permission) (struct inode *, int);
>  	struct posix_acl * (*get_acl)(struct inode *, int);
> +	struct richacl * (*get_richacl)(struct inode *);
>  
>  	int (*readlink) (struct dentry *, char __user *,int);
>  
> @@ -1756,6 +1757,7 @@ struct inode_operations {
>  			   umode_t create_mode, int *opened);
>  	int (*tmpfile) (struct inode *, struct dentry *, umode_t);
>  	int (*set_acl)(struct inode *, struct posix_acl *, int);
> +	int (*set_richacl)(struct inode *, struct richacl *);
>  } ____cacheline_aligned;
>  
>  ssize_t rw_copy_check_uvector(int type, const struct iovec __user * uvector,

Looks OK, though it's hard to review something like this without some
context. Maybe this patch should be folded in with the patch that
actually adds the calls for these operations?

Reviewed-by: Jeff Layton <jlayton@redhat.com>
