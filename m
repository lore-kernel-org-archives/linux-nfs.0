Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:35710 "EHLO
        mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752866AbcLBNM2 (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 2 Dec 2016 08:12:28 -0500
Received: by mail-vk0-f54.google.com with SMTP id w194so145457131vkw.2
        for <linux-nfs@vger.kernel.org>; Fri, 02 Dec 2016 05:12:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161201220716.GB1589@fieldses.org>
References: <1479933700-5743-1-git-send-email-bfields@redhat.com>
 <1479933700-5743-2-git-send-email-bfields@redhat.com> <20161201220716.GB1589@fieldses.org>
From: Andreas Gruenbacher <agruenba@redhat.com>
Date: Fri, 2 Dec 2016 14:12:26 +0100
Message-ID: <CAHc6FU721nR8QmcpJsDWtvg9EqzK-krYH7GTGw0Y=s7nSEy-vg@mail.gmail.com>
Subject: Re: [PATCH 1/2] nfs: add support for the umask attribute
To: "J. Bruce Fields" <bfields@fieldses.org>
Cc: "J. Bruce Fields" <bfields@redhat.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <schumakeranna@gmail.com>,
        Linux NFS Mailing List <linux-nfs@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Thu, Dec 1, 2016 at 11:07 PM, J. Bruce Fields <bfields@fieldses.org> wrote:
> On Wed, Nov 23, 2016 at 03:41:39PM -0500, J. Bruce Fields wrote:
>> From: Andreas Gruenbacher <agruenba@redhat.com>
>>
>> Clients can set the umask attribute when creating files to cause the
>> server to apply it always except when inheriting permissions from the
>> parent directory.  That way, the new files will end up with the same
>> permissions as files created locally.
>
> Trond asked out of band whether we could do away with the new
> server->caps bit and instead directly use the supported attribute
> bitmask (which is now also stored with the server).
>
> I haven't given this a real test yet, but it looks fine to me.
>
> If nobody sees an objection then I'll fold this into the client patch
> and resend.

Sure. I'm wondering why the code isn't checking for any other
attributes like that.

> --b.
>
> diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
> index 0a8326bcb481..32969907e218 100644
> --- a/fs/nfs/dir.c
> +++ b/fs/nfs/dir.c
> @@ -1537,7 +1537,7 @@ int nfs_atomic_open(struct inode *dir, struct dentry *dentry,
>         if (open_flags & O_CREAT) {
>                 struct nfs_server *server = NFS_SERVER(dir);
>
> -               if (!(server->caps & NFS_CAP_MODE_UMASK))
> +               if (!(server->attr_bitmask_nl[2] & FATTR4_WORD2_MODE_UMASK))

It seems that this patch should be checking in server->attr_bitmask,
not server->attr_bitmask_nl.

>                         mode &= ~current_umask();
>
>                 attr.ia_valid |= ATTR_MODE;
> diff --git a/fs/nfs/nfs4proc.c b/fs/nfs/nfs4proc.c
> index 1fa15fbf7b48..960ba55ddde7 100644
> --- a/fs/nfs/nfs4proc.c
> +++ b/fs/nfs/nfs4proc.c
> @@ -3323,8 +3323,7 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
>                                 NFS_CAP_MODE|NFS_CAP_NLINK|NFS_CAP_OWNER|
>                                 NFS_CAP_OWNER_GROUP|NFS_CAP_ATIME|
>                                 NFS_CAP_CTIME|NFS_CAP_MTIME|
> -                               NFS_CAP_SECURITY_LABEL|
> -                               NFS_CAP_MODE_UMASK);
> +                               NFS_CAP_SECURITY_LABEL);
>                 if (res.attr_bitmask[0] & FATTR4_WORD0_ACL &&
>                                 res.acl_bitmask & ACL4_SUPPORT_ALLOW_ACL)
>                         server->caps |= NFS_CAP_ACLS;
> @@ -3352,8 +3351,6 @@ static int _nfs4_server_capabilities(struct nfs_server *server, struct nfs_fh *f
>                 if (res.attr_bitmask[2] & FATTR4_WORD2_SECURITY_LABEL)
>                         server->caps |= NFS_CAP_SECURITY_LABEL;
>  #endif
> -               if (res.attr_bitmask[2] & FATTR4_WORD2_MODE_UMASK)
> -                       server->caps |= NFS_CAP_MODE_UMASK;
>                 memcpy(server->attr_bitmask_nl, res.attr_bitmask,
>                                 sizeof(server->attr_bitmask));
>                 server->attr_bitmask_nl[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
> @@ -3969,7 +3966,7 @@ nfs4_proc_create(struct inode *dir, struct dentry *dentry, struct iattr *sattr,
>
>         ilabel = nfs4_label_init_security(dir, dentry, sattr, &l);
>
> -       if (!(server->caps & NFS_CAP_MODE_UMASK))
> +       if (!(server->attr_bitmask_nl[2] & FATTR4_WORD2_MODE_UMASK))
>                 sattr->ia_mode &= ~current_umask();
>         state = nfs4_do_open(dir, ctx, flags, sattr, ilabel, NULL);
>         if (IS_ERR(state)) {
> @@ -4283,7 +4280,7 @@ static int nfs4_proc_mkdir(struct inode *dir, struct dentry *dentry,
>
>         label = nfs4_label_init_security(dir, dentry, sattr, &l);
>
> -       if (!(server->caps & NFS_CAP_MODE_UMASK))
> +       if (!(server->attr_bitmask_nl[2] & FATTR4_WORD2_MODE_UMASK))
>                 sattr->ia_mode &= ~current_umask();
>         do {
>                 err = _nfs4_proc_mkdir(dir, dentry, sattr, label);
> @@ -4394,7 +4391,7 @@ static int nfs4_proc_mknod(struct inode *dir, struct dentry *dentry,
>
>         label = nfs4_label_init_security(dir, dentry, sattr, &l);
>
> -       if (!(server->caps & NFS_CAP_MODE_UMASK))
> +       if (!(server->attr_bitmask_nl[2] & FATTR4_WORD2_MODE_UMASK))
>                 sattr->ia_mode &= ~current_umask();
>         do {
>                 err = _nfs4_proc_mknod(dir, dentry, sattr, label, rdev);
> diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
> index 420d27865504..54714ce5dbd1 100644
> --- a/fs/nfs/nfs4xdr.c
> +++ b/fs/nfs/nfs4xdr.c
> @@ -1023,7 +1023,7 @@ static void encode_attrs(struct xdr_stream *xdr, const struct iattr *iap,
>                 bmval[0] |= FATTR4_WORD0_SIZE;
>                 len += 8;
>         }
> -       if (!(server->caps & NFS_CAP_MODE_UMASK))
> +       if (!(server->attr_bitmask_nl[2] & FATTR4_WORD2_MODE_UMASK))
>                 umask = NULL;
>         if (iap->ia_valid & ATTR_MODE) {
>                 if (umask) {
> diff --git a/include/linux/nfs_fs_sb.h b/include/linux/nfs_fs_sb.h
> index 87ab710772b3..b34097c67848 100644
> --- a/include/linux/nfs_fs_sb.h
> +++ b/include/linux/nfs_fs_sb.h
> @@ -250,6 +250,5 @@ struct nfs_server {
>  #define NFS_CAP_LAYOUTSTATS    (1U << 22)
>  #define NFS_CAP_CLONE          (1U << 23)
>  #define NFS_CAP_COPY           (1U << 24)
> -#define NFS_CAP_MODE_UMASK     (1U << 25)
>
>  #endif

Thanks,
Andreas
