Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:52872 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1754366AbeAQQhy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 17 Jan 2018 11:37:54 -0500
Date: Wed, 17 Jan 2018 11:37:54 -0500
To: Max Kellermann <mk@cm4all.com>
Cc: linux-fsdevel@vger.kernel.org, hch@infradead.org,
        linux-nfs@vger.kernel.org, trond.myklebust@primarydata.com,
        gregkh@linuxfoundation.org, max.kellermann@gmail.com,
        linux-kernel@vger.kernel.org, agreunba@redhat.com,
        Al Viro <viro@zeniv.linux.org.uk>
Subject: Re: [PATCH 1/2] linux/fs.h: fix umask on NFS with
 CONFIG_FS_POSIX_ACL=n
Message-ID: <20180117163754.GA31785@fieldses.org>
References: <151603744662.29035.4910161264124875658.stgit@rabbit.intern.cm-ag>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <151603744662.29035.4910161264124875658.stgit@rabbit.intern.cm-ag>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Looks right to me.

Reviewed-by: J. Bruce Fields <bfields@redhat.com>

--b.

On Mon, Jan 15, 2018 at 06:30:46PM +0100, Max Kellermann wrote:
> Make IS_POSIXACL() return false if POSIX ACL support is disabled and
> ignore SB_POSIXACL/MS_POSIXACL.
> 
> Never skip applying the umask in namei.c and never bother to do any
> ACL specific checks if the filesystem falsely indicates it has ACLs
> enabled when the feature is completely disabled in the kernel.
> 
> This fixes a problem where the umask is always ignored in the NFS
> client when compiled without CONFIG_FS_POSIX_ACL.  This is a 4 year
> old regression caused by commit 013cdf1088d723 which itself was not
> completely wrong, but failed to consider all the side effects by
> misdesigned VFS code.
> 
> Prior to that commit, there were two places where the umask could be
> applied, for example when creating a directory:
> 
>  1. in the VFS layer in SYSCALL_DEFINE3(mkdirat), but only if
>     !IS_POSIXACL()
> 
>  2. again (unconditionally) in nfs3_proc_mkdir()
> 
> The first one does not apply, because even without
> CONFIG_FS_POSIX_ACL, the NFS client sets MS_POSIXACL in
> nfs_fill_super().
> 
> After that commit, (2.) was replaced by:
> 
>  2b. in posix_acl_create(), called by nfs3_proc_mkdir()
> 
> There's one branch in posix_acl_create() which applies the umask;
> however, without CONFIG_FS_POSIX_ACL, posix_acl_create() is an empty
> dummy function which does not apply the umask.
> 
> The approach chosen by this patch is to make IS_POSIXACL() always
> return false when POSIX ACL support is disabled, so the umask always
> gets applied by the VFS layer.  This is consistent with the (regular)
> behavior of posix_acl_create(): that function returns early if
> IS_POSIXACL() is false, before applying the umask.
> 
> Therefore, posix_acl_create() is responsible for applying the umask if
> there is ACL support enabled in the file system (SB_POSIXACL), and the
> VFS layer is responsible for all other cases (no SB_POSIXACL or no
> CONFIG_FS_POSIX_ACL).
> 
> Signed-off-by: Max Kellermann <mk@cm4all.com>
> ---
>  include/linux/fs.h |    5 +++++
>  1 file changed, 5 insertions(+)
> 
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 440281f8564d..c3240c28e61b 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -1883,7 +1883,12 @@ static inline bool sb_rdonly(const struct super_block *sb) { return sb->s_flags
>  #define IS_NOQUOTA(inode)	((inode)->i_flags & S_NOQUOTA)
>  #define IS_APPEND(inode)	((inode)->i_flags & S_APPEND)
>  #define IS_IMMUTABLE(inode)	((inode)->i_flags & S_IMMUTABLE)
> +
> +#ifdef CONFIG_FS_POSIX_ACL
>  #define IS_POSIXACL(inode)	__IS_FLG(inode, SB_POSIXACL)
> +#else
> +#define IS_POSIXACL(inode)	0
> +#endif
>  
>  #define IS_DEADDIR(inode)	((inode)->i_flags & S_DEAD)
>  #define IS_NOCMTIME(inode)	((inode)->i_flags & S_NOCMTIME)
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-nfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
