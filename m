Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-ve0-f180.google.com ([209.85.128.180]:39294 "EHLO
	mail-ve0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933182AbaFRLf1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 18 Jun 2014 07:35:27 -0400
Received: by mail-ve0-f180.google.com with SMTP id jw12so642588veb.25
        for <linux-nfs@vger.kernel.org>; Wed, 18 Jun 2014 04:35:27 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1403082423-13131-1-git-send-email-hch@lst.de>
References: <1403082423-13131-1-git-send-email-hch@lst.de>
Date: Wed, 18 Jun 2014 07:35:27 -0400
Message-ID: <CAHQdGtSBN4_MPVUWZ1dhOAXyp9w++YGYLP9fmYNq5RPqzrDwPA@mail.gmail.com>
Subject: Re: [PATCH] nfs: only show Posix ACLs in listxattr if actually present
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: Christoph Hellwig <hch@lst.de>
Cc: Philippe Troin <phil@fifi.org>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

On Wed, Jun 18, 2014 at 5:07 AM, Christoph Hellwig <hch@lst.de> wrote:
> The big ACL switched nfs to use generic_listxattr, which calls all existing
> ->list handlers.  Add a custom .listxattr implementation that only lists
> the ACLs if they actually are present on the given inode.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> Reported-by: Philippe Troin <phil@fifi.org>
> Tested-by: Philippe Troin <phil@fifi.org>
> ---
>  fs/nfs/nfs3acl.c  |   43 +++++++++++++++++++++++++++++++++++++++++++
>  fs/nfs/nfs3proc.c |    4 ++--
>  2 files changed, 45 insertions(+), 2 deletions(-)
>
> diff --git a/fs/nfs/nfs3acl.c b/fs/nfs/nfs3acl.c
> index 871d6ed..8f854dd 100644
> --- a/fs/nfs/nfs3acl.c
> +++ b/fs/nfs/nfs3acl.c
> @@ -247,3 +247,46 @@ const struct xattr_handler *nfs3_xattr_handlers[] = {
>         &posix_acl_default_xattr_handler,
>         NULL,
>  };
> +
> +static int
> +nfs3_list_one_acl(struct inode *inode, int type, const char *name, void *data,
> +               size_t size, ssize_t *result)

Why do you make 'result' a pointer to ssize_t rather than a size_t here?

> +{
> +       struct posix_acl *acl;
> +       char *p = data + *result;
> +
> +       acl = get_acl(inode, type);
> +       if (!acl)
> +               return 0;
> +
> +       posix_acl_release(acl);
> +
> +       *result += strlen(name);
> +       *result += 1;
> +       if (!size)
> +               return 0;
> +       if (*result > size)
> +               return -ERANGE;
> +
> +       strcpy(p, name);
> +       return 0;
> +}
> +
> +ssize_t
> +nfs3_listxattr(struct dentry *dentry, char *data, size_t size)
> +{
> +       struct inode *inode = dentry->d_inode;
> +       ssize_t result = 0;
> +       int error;
> +
> +       error = nfs3_list_one_acl(inode, ACL_TYPE_ACCESS,
> +                       POSIX_ACL_XATTR_ACCESS, data, size, &result);
> +       if (error)
> +               return error;
> +
> +       error = nfs3_list_one_acl(inode, ACL_TYPE_DEFAULT,
> +                       POSIX_ACL_XATTR_DEFAULT, data, size, &result);
> +       if (error)
> +               return error;
> +       return result;
> +}
> diff --git a/fs/nfs/nfs3proc.c b/fs/nfs/nfs3proc.c
> index e7daa42..f0afa29 100644
> --- a/fs/nfs/nfs3proc.c
> +++ b/fs/nfs/nfs3proc.c
> @@ -885,7 +885,7 @@ static const struct inode_operations nfs3_dir_inode_operations = {
>         .getattr        = nfs_getattr,
>         .setattr        = nfs_setattr,
>  #ifdef CONFIG_NFS_V3_ACL
> -       .listxattr      = generic_listxattr,
> +       .listxattr      = nfs3_listxattr,
>         .getxattr       = generic_getxattr,
>         .setxattr       = generic_setxattr,
>         .removexattr    = generic_removexattr,
> @@ -899,7 +899,7 @@ static const struct inode_operations nfs3_file_inode_operations = {
>         .getattr        = nfs_getattr,
>         .setattr        = nfs_setattr,
>  #ifdef CONFIG_NFS_V3_ACL
> -       .listxattr      = generic_listxattr,
> +       .listxattr      = nfs3_listxattr,
>         .getxattr       = generic_getxattr,
>         .setxattr       = generic_setxattr,
>         .removexattr    = generic_removexattr,
> --
> 1.7.10.4
>



-- 
Trond Myklebust

Linux NFS client maintainer, PrimaryData

trond.myklebust@primarydata.com
