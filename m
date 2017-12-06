Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:54798 "EHLO fieldses.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752084AbdLFTFL (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Wed, 6 Dec 2017 14:05:11 -0500
Date: Wed, 6 Dec 2017 14:05:11 -0500
To: NeilBrown <neilb@suse.com>
Cc: Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna.Schumaker@Netapp.com, Al Viro <viro@zeniv.linux.org.uk>,
        Andrew Morton <akpm@linux-foundation.org>,
        Linus Torvalds <torvalds@linux-foundation.org>,
        lkml <linux-kernel@vger.kernel.org>,
        "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        linux-fsdevel <linux-fsdevel@vger.kernel.org>,
        Lennart Poettering <lennart@poettering.net>
Subject: Re: [PATCH] NFS: allow name_to_handle_at() to work for Amazon EFS.
Message-ID: <20171206190511.GA5875@fieldses.org>
References: <87po7zv62h.fsf@notabene.neil.brown.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
In-Reply-To: <87po7zv62h.fsf@notabene.neil.brown.name>
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Fri, Dec 01, 2017 at 07:56:38AM +1100, NeilBrown wrote:
> 
> Amazon EFS provides an NFSv4.1 filesystem which appears to use
> (close to) full length (128 byte) file handles.

I wonder why?

Anyway, it seems  unfortunate that systemd should need to worry about
filehandle sizes at all, given that (as far as I can tell) all it's
really calling name_to_handle_at() for is the mount_id, so it can
recognize mountpoints.

Userland NFS servers were a major motivation for the filehandle code.
And filehandles larger than 128 bytes aren't much use to them.
Hopefully they'll be able to identify the problem and fail early on.

Oh well.  ACK to both patches from me.

--b.

> This causes the handle reported by name_to_handle_at() to exceed
> MAX_HANDLE_SZ, resulting in
>   EOVERFLOW if 128 bytes were requested, or
>   EINVAL if the size reported by the previous call was requested.
> 
> To fix this, increase MAX_HANDLE_SIZE a little, and add a BUILD_BUG
> so that this sort of inconsistent error reporting won't happen again.
> 
> Link: https://github.com/systemd/systemd/issues/7082#issuecomment-347380436
> Signed-off-by: NeilBrown <neilb@suse.com>
> ---
> 
> Sorry for the scatter-gun To: list.  This is really more of a VFS patch
> than an NFS patch and sending patches in either direction has been a bit
> hit-and-miss lately, so I'm hoping Andrew will take it unless someone
> else objects or beats him to it...
> 
> Thanks,
> NeilBrown
> 
>  fs/nfs/export.c          | 2 ++
>  include/linux/exportfs.h | 7 +++++--
>  2 files changed, 7 insertions(+), 2 deletions(-)
> 
> diff --git a/fs/nfs/export.c b/fs/nfs/export.c
> index 83fd09fc8f77..23b2fc3ab2bb 100644
> --- a/fs/nfs/export.c
> +++ b/fs/nfs/export.c
> @@ -39,6 +39,8 @@ nfs_encode_fh(struct inode *inode, __u32 *p, int *max_len, struct inode *parent)
>  	size_t fh_size = offsetof(struct nfs_fh, data) + server_fh->size;
>  	int len = EMBED_FH_OFF + XDR_QUADLEN(fh_size);
>  
> +	BUILD_BUG_ON_MSG(EMBED_FH_OFF + NFS_MAXFHSIZE > MAX_HANDLE_SZ,
> +		"MAX_HANDLE_SZ is too small");
>  	dprintk("%s: max fh len %d inode %p parent %p",
>  		__func__, *max_len, inode, parent);
>  
> diff --git a/include/linux/exportfs.h b/include/linux/exportfs.h
> index 0d3037419bc7..e7ab1b071c5e 100644
> --- a/include/linux/exportfs.h
> +++ b/include/linux/exportfs.h
> @@ -11,8 +11,11 @@ struct iomap;
>  struct super_block;
>  struct vfsmount;
>  
> -/* limit the handle size to NFSv4 handle size now */
> -#define MAX_HANDLE_SZ 128
> +/* Must be larger than NFSv4 file handle, but small
> + * enough for an on-stack allocation. overlayfs doesn't
> + * want this too close to 255.
> + */
> +#define MAX_HANDLE_SZ 200
>  
>  /*
>   * The fileid_type identifies how the file within the filesystem is encoded.
> -- 
> 2.14.0.rc0.dirty
> 


