Received: from smtp.kernel.org (aws-us-west-2-korg-mail-alma10-1.taild15c8.ts.net [100.103.45.18])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1DC143CE48
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 17:07:52 +0000 (UTC)
Authentication-Results: smtp.subspace.kernel.org; arc=none smtp.client-ip=100.103.45.18
ARC-Seal:i=1; a=rsa-sha256; d=subspace.kernel.org; s=arc-20240116;
	t=1784740074; cv=none; b=FqRuixHhW/89iOyLBZTj0dP2L8c99rz/LAwcE0oK4KmoEQcGEs2nIdNeV6N+HZ94jVxJ2rvCsTL16mfLPXWtfXZej1qb6F1Uw7ZhXlh3xUrBjBgy8hlolmoeqzZHtt6l4B+wQ4fMENTAqvOXkAk1uujuowjVa8cjHhfdL/9QtP4=
ARC-Message-Signature:i=1; a=rsa-sha256; d=subspace.kernel.org;
	s=arc-20240116; t=1784740074; c=relaxed/simple;
	bh=58x+rQ+VpYLNwgWWZvE9IJn/8/RLM1/gEFAdvEdIYW0=;
	h=MIME-Version:References:In-Reply-To:From:Date:Message-ID:Subject:
	 To:Cc:Content-Type; b=oZlDsi/DW4ZEvLeprAyiuxFO1e2CHwiwzkivwm9AlKmIe/KFbeKe+ajWrlIW45LklyG2NEAzRLOHxlgTnolTbElodo2AsTMDdxWjC0vxxeNtUCknidNT2wZBbxd1SujxRhAqJMDsFItkd2TqyvbfZQ8B93KoNkH7mguOXdz3Gog=
ARC-Authentication-Results:i=1; smtp.subspace.kernel.org; dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b=mOONGtnW; arc=none smtp.client-ip=100.103.45.18
Authentication-Results: smtp.subspace.kernel.org;
	dkim=pass (2048-bit key) header.d=kernel.org header.i=@kernel.org header.b="mOONGtnW"
Received: by smtp.kernel.org (Postfix) with ESMTPSA id 544B21F00AC4
	for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 17:07:52 +0000 (UTC)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=kernel.org;
	s=k20260515; t=1784740072;
	bh=rBJOHpxdVSNjjkAFIABZox4Bk7ELXy14OrIxYOp/SAc=;
	h=References:In-Reply-To:From:Date:Subject:To:Cc;
	b=mOONGtnWTNUXPpqOm6CG0pbx7HkPnO9u3zDLkYhY/etT39q8wVCj6gnkS37A7P8/o
	 8ojc/TAzDprokuqQL6InGKMx2kfP4bI5RAg86zg37CuzDlSDyf88aEDa/3cdu639rn
	 udkMjg7deOiHpu2QHRdCxKXOYEXBSQ221/8zFZAEHDQLd7B8Bslj5DC++ZZgX4iSDG
	 cdqKblXEIVqI7dc+KjV9WGSyUUxFqDcGrijQ5twKjNeBoLNtR9eu9l9LgzsxlutnG3
	 2KP8yA9f2+CN0AL5xytgMfH+GosebBunAKmigkeBfnSVWHEGfKX3v0qiAWyhm3AtuR
	 Wrt68K0mqDHaQ==
Received: by mail-yw1-f170.google.com with SMTP id 00721157ae682-81e69a2db34so79359627b3.0
        for <linux-nfs@vger.kernel.org>; Wed, 22 Jul 2026 10:07:52 -0700 (PDT)
X-Forwarded-Encrypted: i=1; AHgh+RqPCN0GjRZMlPDMciQ5VfwJSiTOQF2FkWrkABiH6I/wUXGlDERtX0snnsrjpDOlTnLq0Ip3D3o8ukI=@vger.kernel.org
X-Gm-Message-State: AOJu0YyAxg0ov0GQXXEYxAjxP5wOHrm6EV9IKbniFZYbvHAgAF8OnMAo
	sITIhBrJh9fcuxLUJ7UpeXNqdyXwvyCs5pYMqa43n3v8CP3ejyHhnSdk4QytbKP5vcnSWIFqOJo
	g7YHvVSFMTsIZ2LKLBbRsfiXNOjtfR/xxSGExfW786Q==
X-Received: by 2002:a05:690c:6d10:b0:81e:67e8:6b9f with SMTP id
 00721157ae682-81ef2858b83mr77901317b3.41.1784740071560; Wed, 22 Jul 2026
 10:07:51 -0700 (PDT)
Precedence: bulk
X-Mailing-List: linux-nfs@vger.kernel.org
List-Id: <linux-nfs.vger.kernel.org>
List-Subscribe: <mailto:linux-nfs+subscribe@vger.kernel.org>
List-Unsubscribe: <mailto:linux-nfs+unsubscribe@vger.kernel.org>
MIME-Version: 1.0
References: <20260722130615.3163560-1-hch@lst.de> <20260722130615.3163560-4-hch@lst.de>
In-Reply-To: <20260722130615.3163560-4-hch@lst.de>
From: Chris Li <chrisl@kernel.org>
Date: Wed, 22 Jul 2026 10:07:40 -0700
X-Gmail-Original-Message-ID: <CACePvbVFw6hzEHkaDPA2y4=kTweiKCiBmrD5pL3cFJ3AEUQ8rQ@mail.gmail.com>
X-Gm-Features: AUfX_mxZwu9kzWVMqPUy0dGoBvDDN8c8hl7fgvjYUxzLZEvl8AxRhoOZJvBznrs
Message-ID: <CACePvbVFw6hzEHkaDPA2y4=kTweiKCiBmrD5pL3cFJ3AEUQ8rQ@mail.gmail.com>
Subject: Re: [PATCH 3/3] mm/swap: move swap_ops into file systems for file
 system-based swap
To: Christoph Hellwig <hch@lst.de>
Cc: baoquan.he@linux.dev, akpm@linux-foundation.org, usama.arif@linux.dev, 
	kasong@tencent.com, nphamcs@gmail.com, shikemeng@huaweicloud.com, 
	youngjun.park@lge.com, ryncsn@gmail.com, trondmy@kernel.org, anna@kernel.org, 
	sfrench@samba.org, linux-mm@kvack.org, linux-cifs@vger.kernel.org, 
	linux-nfs@vger.kernel.org
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, Jul 22, 2026 at 6:07=E2=80=AFAM Christoph Hellwig <hch@lst.de> wrot=
e:
>
> Currently swap to and from file systems goes through two indirect calls
> between the swap ops and the swap_rw method.  Reduce this by directly
> providing the swap_ops from the file system.
>
> For this refactor swap_fs_submit into a swap_fs_prepare_rw helper that
> initializes the iov_iter on the callers stack so that file systems can
> call it directly, and use that to initialize file system specific ops
> in NFS and the SMB client, which then get passed to swap_fs_activate.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>

I am very happy to see the direction this patch is going. Now I see
how to get rid of the double indirection.

You convinced me with flying colors.

Acked-by: Chris Li <chrisl@kernel.org>

Chris


> ---
>  Documentation/filesystems/locking.rst |  9 +---
>  Documentation/filesystems/vfs.rst     |  8 +---
>  fs/nfs/direct.c                       | 20 ---------
>  fs/nfs/file.c                         | 42 ++++++++++++++++--
>  fs/smb/client/file.c                  | 63 +++++++++++++++++----------
>  include/linux/fs.h                    |  1 -
>  include/linux/nfs_fs.h                |  1 -
>  include/linux/swap.h                  |  6 ---
>  include/linux/swap_ops.h              |  5 +++
>  mm/page_io.c                          | 34 +++------------
>  10 files changed, 93 insertions(+), 96 deletions(-)
>
> diff --git a/Documentation/filesystems/locking.rst b/Documentation/filesy=
stems/locking.rst
> index 1a50d41a39a1..f58a8d7d5897 100644
> --- a/Documentation/filesystems/locking.rst
> +++ b/Documentation/filesystems/locking.rst
> @@ -266,7 +266,6 @@ prototypes::
>         int (*error_remove_folio)(struct address_space *, struct folio *)=
;
>         int (*swap_activate)(struct swap_info_struct *sis, struct file *f=
, sector_t *span)
>         int (*swap_deactivate)(struct file *);
> -       int (*swap_rw)(struct kiocb *iocb, struct iov_iter *iter);
>
>  locking rules:
>         All except dirty_folio and free_folio may block
> @@ -291,7 +290,6 @@ is_partially_uptodate:      yes
>  error_remove_folio:    yes
>  swap_activate:         no
>  swap_deactivate:       no
> -swap_rw:               yes, unlocks
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D =3D=
=3D=3D=3D=3D=3D=3D=3D=3D      =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>  ->write_begin(), ->write_end() and ->read_folio() may be called from
> @@ -355,15 +353,12 @@ should perform any validation and preparation neces=
sary to ensure that
>  writes can be performed with minimal memory allocation.  It should call
>  add_swap_extent(), or the helper iomap_swapfile_activate(), and return
>  the number of extents added.  If IO should be submitted through
> -->swap_rw(), it should call swap_fs_activate, otherwise IO will be submi=
tted
> -directly to the block device ``sis->bdev``.
> +the file system it should call swap_fs_activate, otherwise IO will be
> +submitted directly to the block device ``sis->bdev``.
>
>  ->swap_deactivate() will be called in the sys_swapoff()
>  path after ->swap_activate() returned success.
>
> -->swap_rw will be called for swap IO if swap_fs_activate was called by
> -->swap_activate().
> -
>  file_lock_operations
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> diff --git a/Documentation/filesystems/vfs.rst b/Documentation/filesystem=
s/vfs.rst
> index e7677423a20f..c437a342d4f3 100644
> --- a/Documentation/filesystems/vfs.rst
> +++ b/Documentation/filesystems/vfs.rst
> @@ -776,7 +776,6 @@ cache in your filesystem.  The following members are =
defined:
>                 int (*error_remove_folio)(struct mapping *mapping, struct=
 folio *);
>                 int (*swap_activate)(struct swap_info_struct *sis, struct=
 file *f, sector_t *span)
>                 int (*swap_deactivate)(struct file *);
> -               int (*swap_rw)(struct kiocb *iocb, struct iov_iter *iter)=
;
>         };
>
>  ``read_folio``
> @@ -977,16 +976,13 @@ cache in your filesystem.  The following members ar=
e defined:
>         can be performed with minimal memory allocation.  It should call
>         add_swap_extent(), or the helper iomap_swapfile_activate(), and
>         return the number of extents added.  If IO should be submitted
> -       through ->swap_rw(), it should call swap_fs_activate, otherwise I=
O will
> -       be submitted directly to the block device ``sis->bdev``.
> +       through the file system it should call swap_fs_activate, otherwis=
e IO
> +       will be submitted directly to the block device ``sis->bdev``.
>
>  ``swap_deactivate``
>         Called during swapoff on files where swap_activate was
>         successful.
>
> -``swap_rw``
> -       Called to read or write swap pages when swap_fs_activate was call=
ed.
> -
>  The File Object
>  =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
> diff --git a/fs/nfs/direct.c b/fs/nfs/direct.c
> index e626c72495e6..ccafdc1ce64d 100644
> --- a/fs/nfs/direct.c
> +++ b/fs/nfs/direct.c
> @@ -145,26 +145,6 @@ static void nfs_direct_file_adjust_size_locked(struc=
t inode *inode,
>         }
>  }
>
> -/**
> - * nfs_swap_rw - NFS address space operation for swap I/O
> - * @iocb: target I/O control block
> - * @iter: I/O buffer
> - *
> - * Perform IO to the swap-file.  This is much like direct IO.
> - */
> -int nfs_swap_rw(struct kiocb *iocb, struct iov_iter *iter)
> -{
> -       ssize_t ret;
> -
> -       if (iov_iter_rw(iter) =3D=3D READ)
> -               ret =3D nfs_file_direct_read(iocb, iter, true);
> -       else
> -               ret =3D nfs_file_direct_write(iocb, iter, true);
> -       if (ret < 0)
> -               return ret;
> -       return 0;
> -}
> -
>  static void nfs_direct_release_pages(struct page **pages, unsigned int n=
pages)
>  {
>         unsigned int i;
> diff --git a/fs/nfs/file.c b/fs/nfs/file.c
> index 851d93a09988..e1bdd10b35f1 100644
> --- a/fs/nfs/file.c
> +++ b/fs/nfs/file.c
> @@ -29,9 +29,8 @@
>  #include <linux/pagemap.h>
>  #include <linux/gfp.h>
>  #include <linux/rmap.h>
> -#include <linux/swap.h>
>  #include <linux/compaction.h>
> -
> +#include <linux/swap_ops.h>
>  #include <linux/uaccess.h>
>  #include <linux/filelock.h>
>
> @@ -575,6 +574,38 @@ static int nfs_launder_folio(struct folio *folio)
>         return ret;
>  }
>
> +#ifdef CONFIG_SWAP
> +static void nfs_swap_submit_write(struct swap_io_ctx *ctx)
> +{
> +       struct swap_iocb *sio =3D ctx->sio;
> +       struct iov_iter iter;
> +       int ret;
> +
> +       swap_fs_prepare_rw(ctx, WRITE, &iter);
> +       ret =3D nfs_file_direct_write(&sio->iocb, &iter, true);
> +       if (ret !=3D -EIOCBQUEUED)
> +               sio->iocb.ki_complete(&sio->iocb, ret);
> +}
> +
> +static void nfs_swap_submit_read(struct swap_io_ctx *ctx)
> +{
> +       struct swap_iocb *sio =3D ctx->sio;
> +       struct iov_iter iter;
> +       int ret;
> +
> +       swap_fs_prepare_rw(ctx, READ, &iter);
> +       ret =3D nfs_file_direct_read(&sio->iocb, &iter, true);
> +       if (ret !=3D -EIOCBQUEUED)
> +               sio->iocb.ki_complete(&sio->iocb, ret);
> +}
> +
> +static const struct swap_ops nfs_swap_ops =3D {
> +       .flags                  =3D SWAP_OPS_F_REQUIRE_NOFS,
> +       .submit_write           =3D nfs_swap_submit_write,
> +       .submit_read            =3D nfs_swap_submit_read,
> +       .can_merge              =3D swap_fs_can_merge,
> +};
> +
>  static int nfs_swap_activate(struct swap_info_struct *sis, struct file *=
file,
>                                                 sector_t *span)
>  {
> @@ -597,7 +628,7 @@ static int nfs_swap_activate(struct swap_info_struct =
*sis, struct file *file,
>         ret =3D rpc_clnt_swap_activate(clnt);
>         if (ret)
>                 return ret;
> -       ret =3D swap_fs_activate(sis);
> +       ret =3D swap_fs_activate(sis, &nfs_swap_ops);
>         if (ret < 0) {
>                 rpc_clnt_swap_deactivate(clnt);
>                 return ret;
> @@ -620,6 +651,10 @@ static void nfs_swap_deactivate(struct file *file)
>         if (cl->rpc_ops->disable_swap)
>                 cl->rpc_ops->disable_swap(file_inode(file));
>  }
> +#else
> +#define nfs_swap_activate      NULL
> +#define nfs_swap_deactivate    NULL
> +#endif /* CONFIG_SWAP */
>
>  const struct address_space_operations nfs_file_aops =3D {
>         .read_folio =3D nfs_read_folio,
> @@ -636,7 +671,6 @@ const struct address_space_operations nfs_file_aops =
=3D {
>         .error_remove_folio =3D generic_error_remove_folio,
>         .swap_activate =3D nfs_swap_activate,
>         .swap_deactivate =3D nfs_swap_deactivate,
> -       .swap_rw =3D nfs_swap_rw,
>  };
>
>  /*
> diff --git a/fs/smb/client/file.c b/fs/smb/client/file.c
> index 081bb16abeb4..190e24199fa1 100644
> --- a/fs/smb/client/file.c
> +++ b/fs/smb/client/file.c
> @@ -20,7 +20,7 @@
>  #include <linux/delay.h>
>  #include <linux/mount.h>
>  #include <linux/slab.h>
> -#include <linux/swap.h>
> +#include <linux/swap_ops.h>
>  #include <linux/mm.h>
>  #include <asm/div64.h>
>  #include "cifsfs.h"
> @@ -3351,6 +3351,38 @@ void cifs_oplock_break(struct work_struct *work)
>         cifs_done_oplock_break(cinode);
>  }
>
> +#ifdef CONFIG_SWAP
> +static void cifs_swap_submit_write(struct swap_io_ctx *ctx)
> +{
> +       struct swap_iocb *sio =3D ctx->sio;
> +       struct iov_iter iter;
> +       int ret;
> +
> +       swap_fs_prepare_rw(ctx, WRITE, &iter);
> +       ret =3D netfs_unbuffered_write_iter_locked(&sio->iocb, &iter, NUL=
L);
> +       if (ret !=3D -EIOCBQUEUED)
> +               sio->iocb.ki_complete(&sio->iocb, ret);
> +}
> +
> +static void cifs_swap_submit_read(struct swap_io_ctx *ctx)
> +{
> +       struct swap_iocb *sio =3D ctx->sio;
> +       struct iov_iter iter;
> +       int ret;
> +
> +       swap_fs_prepare_rw(ctx, READ, &iter);
> +       ret =3D netfs_unbuffered_read_iter_locked(&sio->iocb, &iter);
> +       if (ret !=3D -EIOCBQUEUED)
> +               sio->iocb.ki_complete(&sio->iocb, ret);
> +}
> +
> +static const struct swap_ops cifs_swap_ops =3D {
> +       .flags                  =3D SWAP_OPS_F_REQUIRE_NOFS,
> +       .submit_write           =3D cifs_swap_submit_write,
> +       .submit_read            =3D cifs_swap_submit_read,
> +       .can_merge              =3D swap_fs_can_merge,
> +};
> +
>  static int cifs_swap_activate(struct swap_info_struct *sis,
>                               struct file *swap_file, sector_t *span)
>  {
> @@ -3361,7 +3393,7 @@ static int cifs_swap_activate(struct swap_info_stru=
ct *sis,
>
>         cifs_dbg(FYI, "swap activate\n");
>
> -       if (!swap_file->f_mapping->a_ops->swap_rw)
> +       if (swap_file->f_mapping->a_ops !=3D &cifs_addr_ops)
>                 /* Cannot support swap */
>                 return -EINVAL;
>
> @@ -3392,7 +3424,7 @@ static int cifs_swap_activate(struct swap_info_stru=
ct *sis,
>          * but we could add call to grab a byte range lock to prevent oth=
ers
>          * from reading or writing the file
>          */
> -       return swap_fs_activate(sis);
> +       return swap_fs_activate(sis, &cifs_swap_ops);
>  }
>
>  static void cifs_swap_deactivate(struct file *file)
> @@ -3408,26 +3440,10 @@ static void cifs_swap_deactivate(struct file *fil=
e)
>
>         /* do we need to unpin (or unlock) the file */
>  }
> -
> -/**
> - * cifs_swap_rw - SMB3 address space operation for swap I/O
> - * @iocb: target I/O control block
> - * @iter: I/O buffer
> - *
> - * Perform IO to the swap-file.  This is much like direct IO.
> - */
> -static int cifs_swap_rw(struct kiocb *iocb, struct iov_iter *iter)
> -{
> -       ssize_t ret;
> -
> -       if (iov_iter_rw(iter) =3D=3D READ)
> -               ret =3D netfs_unbuffered_read_iter_locked(iocb, iter);
> -       else
> -               ret =3D netfs_unbuffered_write_iter_locked(iocb, iter, NU=
LL);
> -       if (ret < 0)
> -               return ret;
> -       return 0;
> -}
> +#else
> +#define cifs_swap_activate     NULL
> +#define cifs_swap_deactivate   NULL
> +#endif /* CONFIG_SWAP */
>
>  const struct address_space_operations cifs_addr_ops =3D {
>         .read_folio     =3D netfs_read_folio,
> @@ -3444,7 +3460,6 @@ const struct address_space_operations cifs_addr_ops=
 =3D {
>          */
>         .swap_activate  =3D cifs_swap_activate,
>         .swap_deactivate =3D cifs_swap_deactivate,
> -       .swap_rw =3D cifs_swap_rw,
>  };
>
>  /*
> diff --git a/include/linux/fs.h b/include/linux/fs.h
> index 50ce731a2b78..87b5e9957c00 100644
> --- a/include/linux/fs.h
> +++ b/include/linux/fs.h
> @@ -438,7 +438,6 @@ struct address_space_operations {
>         int (*swap_activate)(struct swap_info_struct *sis, struct file *f=
ile,
>                                 sector_t *span);
>         void (*swap_deactivate)(struct file *file);
> -       int (*swap_rw)(struct kiocb *iocb, struct iov_iter *iter);
>  };
>
>  extern const struct address_space_operations empty_aops;
> diff --git a/include/linux/nfs_fs.h b/include/linux/nfs_fs.h
> index ec17e602c979..764056498eba 100644
> --- a/include/linux/nfs_fs.h
> +++ b/include/linux/nfs_fs.h
> @@ -548,7 +548,6 @@ static inline const struct cred *nfs_file_cred(struct=
 file *file)
>  /*
>   * linux/fs/nfs/direct.c
>   */
> -int nfs_swap_rw(struct kiocb *iocb, struct iov_iter *iter);
>  ssize_t nfs_file_direct_read(struct kiocb *iocb,
>                              struct iov_iter *iter, bool swap);
>  ssize_t nfs_file_direct_write(struct kiocb *iocb,
> diff --git a/include/linux/swap.h b/include/linux/swap.h
> index 0544b2ec4c56..d8584f53a6e4 100644
> --- a/include/linux/swap.h
> +++ b/include/linux/swap.h
> @@ -334,8 +334,6 @@ extern void __meminit kswapd_run(int nid);
>  extern void __meminit kswapd_stop(int nid);
>
>  #ifdef CONFIG_SWAP
> -
> -int swap_fs_activate(struct swap_info_struct *sis);
>  int add_swap_extent(struct swap_info_struct *sis, unsigned long start_pa=
ge,
>                 unsigned long nr_pages, sector_t start_block);
>  int generic_swapfile_activate(struct swap_info_struct *, struct file *,
> @@ -461,10 +459,6 @@ static inline bool folio_free_swap(struct folio *fol=
io)
>         return false;
>  }
>
> -static inline int swap_fs_activate(struct swap_info_struct *sis)
> -{
> -       return -EINVAL;
> -}
>  static inline int add_swap_extent(struct swap_info_struct *sis,
>                                   unsigned long start_page,
>                                   unsigned long nr_pages, sector_t start_=
block)
> diff --git a/include/linux/swap_ops.h b/include/linux/swap_ops.h
> index e92b4f532604..57ac6c703f68 100644
> --- a/include/linux/swap_ops.h
> +++ b/include/linux/swap_ops.h
> @@ -36,4 +36,9 @@ struct swap_ops {
>         void (*submit_read)(struct swap_io_ctx *ctx);
>  };
>
> +void swap_fs_prepare_rw(struct swap_io_ctx *ctx, int rw, struct iov_iter=
 *iter);
> +bool swap_fs_can_merge(struct folio *folio, struct folio *prev_folio,
> +               size_t prev_folio_size, int rw);
> +int swap_fs_activate(struct swap_info_struct *sis, const struct swap_ops=
 *ops);
> +
>  #endif /* _MM_SWAP_OPS_H */
> diff --git a/mm/page_io.c b/mm/page_io.c
> index e741e67d6592..88962571cb93 100644
> --- a/mm/page_io.c
> +++ b/mm/page_io.c
> @@ -650,11 +650,9 @@ const struct swap_ops swap_bdev_ops =3D {
>         .can_merge              =3D swap_bdev_can_merge,
>  };
>
> -static void swap_fs_submit(struct swap_io_ctx *ctx, int rw)
> +void swap_fs_prepare_rw(struct swap_io_ctx *ctx, int rw, struct iov_iter=
 *iter)
>  {
>         struct swap_iocb *sio =3D ctx->sio;
> -       struct iov_iter iter;
> -       int ret;
>
>         init_sync_kiocb(&sio->iocb, ctx->sis->swap_file);
>         sio->iocb.ki_pos =3D swap_dev_pos(bvec_folio(&sio->bvecs[0])->swa=
p);
> @@ -663,40 +661,22 @@ static void swap_fs_submit(struct swap_io_ctx *ctx,=
 int rw)
>         else
>                 sio->iocb.ki_complete =3D swap_fs_read_complete;
>
> -       iov_iter_bvec(&iter, rw =3D=3D WRITE ? ITER_SOURCE : ITER_DEST,
> +       iov_iter_bvec(iter, rw =3D=3D WRITE ? ITER_SOURCE : ITER_DEST,
>                         sio->bvecs, sio->nr_bvecs, sio->len);
> -       ret =3D sio->iocb.ki_filp->f_mapping->a_ops->swap_rw(&sio->iocb, =
&iter);
> -       if (ret !=3D -EIOCBQUEUED)
> -               sio->iocb.ki_complete(&sio->iocb, ret);
>  }
> +EXPORT_SYMBOL_GPL(swap_fs_prepare_rw);
>
> -static void swap_fs_submit_write(struct swap_io_ctx *ctx)
> -{
> -       swap_fs_submit(ctx, WRITE);
> -}
> -
> -static void swap_fs_submit_read(struct swap_io_ctx *ctx)
> -{
> -       swap_fs_submit(ctx, READ);
> -}
> -
> -static bool swap_fs_can_merge(struct folio *folio, struct folio *prev_fo=
lio,
> +bool swap_fs_can_merge(struct folio *folio, struct folio *prev_folio,
>                 size_t prev_folio_size, int rw)
>  {
>         return swap_dev_pos(folio->swap) =3D=3D
>                 swap_dev_pos(prev_folio->swap) + prev_folio_size;
>  }
> +EXPORT_SYMBOL_GPL(swap_fs_can_merge);
>
> -static const struct swap_ops swap_fs_ops =3D {
> -       .flags                  =3D SWAP_OPS_F_REQUIRE_NOFS,
> -       .submit_write           =3D swap_fs_submit_write,
> -       .submit_read            =3D swap_fs_submit_read,
> -       .can_merge              =3D swap_fs_can_merge,
> -};
> -
> -int swap_fs_activate(struct swap_info_struct *sis)
> +int swap_fs_activate(struct swap_info_struct *sis, const struct swap_ops=
 *ops)
>  {
> -       sis->ops =3D &swap_fs_ops;
> +       sis->ops =3D ops;
>         return add_swap_extent(sis, 0, sis->max, 0);
>  }
>  EXPORT_SYMBOL_GPL(swap_fs_activate);
> --
> 2.53.0
>
