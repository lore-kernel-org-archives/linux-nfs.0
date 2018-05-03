Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from out03.mta.xmission.com ([166.70.13.233]:46138 "EHLO
        out03.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751007AbeECPWD (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Thu, 3 May 2018 11:22:03 -0400
From: ebiederm@xmission.com (Eric W. Biederman)
To: Dan Carpenter <dan.carpenter@oracle.com>
Cc: linux-nfs@vger.kernel.org
References: <20180503124213.GA28920@mwanda>
Date: Thu, 03 May 2018 10:21:56 -0500
In-Reply-To: <20180503124213.GA28920@mwanda> (Dan Carpenter's message of "Thu,
        3 May 2018 15:42:13 +0300")
Message-ID: <87vac4sr1n.fsf@xmission.com>
MIME-Version: 1.0
Content-Type: text/plain
Subject: Re: [bug report] fs: Teach path_connected to handle nfs filesystems with multiple roots.
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Dan Carpenter <dan.carpenter@oracle.com> writes:

> Hello Eric W. Biederman,
>
> The patch 95dd77580ccd: "fs: Teach path_connected to handle nfs
> filesystems with multiple roots." from Mar 14, 2018, leads to the
> following static checker warning:
>
> 	fs/nfs/super.c:2634 nfs_fs_mount_common()
> 	error: potential NULL dereference 'server'.
>
> fs/nfs/super.c
>   2598          if (server->flags & NFS_MOUNT_UNSHARED)
>   2599                  compare_super = NULL;
>   2600  
>   2601          /* -o noac implies -o sync */
>   2602          if (server->flags & NFS_MOUNT_NOAC)
>   2603                  sb_mntdata.mntflags |= SB_SYNCHRONOUS;
>   2604  
>   2605          if (mount_info->cloned != NULL && mount_info->cloned->sb != NULL)
>   2606                  if (mount_info->cloned->sb->s_flags & SB_SYNCHRONOUS)
>   2607                          sb_mntdata.mntflags |= SB_SYNCHRONOUS;
>   2608  
>   2609          /* Get a superblock - note that we may end up sharing one that already exists */
>   2610          s = sget(nfs_mod->nfs_fs, compare_super, nfs_set_super, flags, &sb_mntdata);
>   2611          if (IS_ERR(s)) {
>   2612                  mntroot = ERR_CAST(s);
>   2613                  goto out_err_nosb;
>   2614          }
>   2615  
>   2616          if (s->s_fs_info != server) {
>   2617                  nfs_free_server(server);
>   2618                  server = NULL;
>                         ^^^^^^^^^^^^^
> We set server to NULL here.  Smatch and I don't know the value of
> s->s_root at this point, but maybe it can't be NULL here?  If so, that's
> fine then.
>
>   2619          } else {
>   2620                  error = super_setup_bdi_name(s, "%u:%u", MAJOR(server->s_dev),
>   2621                                               MINOR(server->s_dev));
>   2622                  if (error) {
>   2623                          mntroot = ERR_PTR(error);
>   2624                          goto error_splat_super;
>   2625                  }
>   2626                  s->s_bdi->ra_pages = server->rpages * NFS_MAX_READAHEAD;
>   2627                  server->super = s;
>   2628          }
>   2629  
>   2630          if (!s->s_root) {
>   2631                  /* initial superblock/root creation */
>   2632                  mount_info->fill_super(s, mount_info);
>   2633                  nfs_get_cache_cookie(s, mount_info->parsed, mount_info->cloned);
>   2634                  if (!(server->flags & NFS_MOUNT_UNSHARED))
>                               ^^^^^^^^^^^^^
> Potential NULL dereference.
>
>   2635                          s->s_iflags |= SB_I_MULTIROOT;
>   2636          }

It is not pretty but I believe in practice the code is fine.

!server implies sget returned a preexisting superblock.

!s->s_root implies !(s->s_flags & SB_BORN)

sget will not return a superblock without SB_BORN being set.
Further it is mount_fs our ``caller'' (via way of whatever calls
nfs_mount_common) that sets SB_BORN when .mount succeeds.

Eric


