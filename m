Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:32884 "EHLO
	mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754484AbcGELMR (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 5 Jul 2016 07:12:17 -0400
Received: by mail-qt0-f173.google.com with SMTP id c34so98823402qte.0
        for <linux-nfs@vger.kernel.org>; Tue, 05 Jul 2016 04:12:17 -0700 (PDT)
Message-ID: <1467717134.3800.7.camel@redhat.com>
Subject: Re: [PATCH v23 04/22] vfs: Make the inode passed to inode_change_ok
 non-const
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
Date: Tue, 05 Jul 2016 07:12:14 -0400
In-Reply-To: <1467294433-3222-5-git-send-email-agruenba@redhat.com>
References: <1467294433-3222-1-git-send-email-agruenba@redhat.com>
	 <1467294433-3222-5-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, 2016-06-30 at 15:46 +0200, Andreas Gruenbacher wrote:
> We will need to call iop->permission and iop->get_acl from
> inode_change_ok() for additional permission checks, and both take a
> non-const inode.
> 
> Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
> Reviewed-by: J. Bruce Fields <bfields@redhat.com>
> Reviewed-by: Andreas Dilger <adilger@dilger.ca>
> Reviewed-by: Steve French <steve.french@primarydata.com>
> ---
>  fs/attr.c          | 2 +-
>  include/linux/fs.h | 2 +-
>  2 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/attr.c b/fs/attr.c
> index 25b24d0..7ca7fa0 100644
> --- a/fs/attr.c
> +++ b/fs/attr.c
> @@ -28,7 +28,7 @@
>   * Should be called as the first thing in ->setattr implementations,
>   * possibly after taking additional locks.
>   */
> -int inode_change_ok(const struct inode *inode, struct iattr *attr)
> +int inode_change_ok(struct inode *inode, struct iattr *attr)
>  {
>  	unsigned int ia_valid = attr->ia_valid;
>  
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 86bfa10..208f73b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -2993,7 +2993,7 @@ extern int buffer_migrate_page(struct address_space *,
>  #define buffer_migrate_page NULL
>  #endif
>  
> -extern int inode_change_ok(const struct inode *, struct iattr *);
> +extern int inode_change_ok(struct inode *, struct iattr *);
>  extern int inode_newsize_ok(const struct inode *, loff_t offset);
>  extern void setattr_copy(struct inode *inode, const struct iattr *attr);
>  

Yuck. Bummer to lose the "const" there, but it doesn't look like it's
possible to make those ops take a const arg.

Reviewed-by: Jeff Layton <jlayton@redhat.com>
