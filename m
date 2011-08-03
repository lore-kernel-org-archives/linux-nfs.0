Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:59337 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755912Ab1HCXvo (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 3 Aug 2011 19:51:44 -0400
Message-ID: <4E39DF02.80306@panasas.com>
Date: Wed, 3 Aug 2011 16:51:30 -0700
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Linus Torvalds <torvalds@linux-foundation.org>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: Re: Please pull NFS client changes
References: <1312082377.10882.1.camel@lade.trondhjem.org>
In-Reply-To: <1312082377.10882.1.camel@lade.trondhjem.org>
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

On 07/30/2011 08:19 PM, Trond Myklebust wrote:
> Hi Linus,
> 
> Please pull from the "nfs-for-3.1" branch of the repository at
> 
>    git pull git://git.linux-nfs.org/projects/trondmy/linux-nfs.git nfs-for-3.1
> 
> This will update the following files through the appended changesets.
> 
>   Cheers,
>     Trond
> 

Trond hi.

You have not included the two patches for the objects-layout bug-fixes
I sent you. (And I don't see them in your linux-next branch). Please
include them in the next round of fixes. (They are also for stable)

Do you need that I resend them?

Thanks
Boaz

> ----
>  fs/nfs/Kconfig                      |    8 +-
>  fs/nfs/Makefile                     |    1 +
>  fs/nfs/blocklayout/Makefile         |    5 +
>  fs/nfs/blocklayout/blocklayout.c    | 1019 +++++++++++++++++++++++++++++++++++
>  fs/nfs/blocklayout/blocklayout.h    |  207 +++++++
>  fs/nfs/blocklayout/blocklayoutdev.c |  410 ++++++++++++++
>  fs/nfs/blocklayout/blocklayoutdm.c  |  111 ++++
>  fs/nfs/blocklayout/extents.c        |  935 ++++++++++++++++++++++++++++++++
>  fs/nfs/client.c                     |   11 +-
>  fs/nfs/dir.c                        |   57 ++-
>  fs/nfs/nfs4_fs.h                    |    2 +-
>  fs/nfs/nfs4filelayout.c             |    2 +-
>  fs/nfs/nfs4proc.c                   |   62 ++-
>  fs/nfs/nfs4xdr.c                    |  233 ++++++++-
>  fs/nfs/pnfs.c                       |   86 ++--
>  fs/nfs/pnfs.h                       |   28 +-
>  include/linux/nfs.h                 |    2 +
>  include/linux/nfs4.h                |    1 +
>  include/linux/nfs_fs.h              |    3 +-
>  include/linux/nfs_fs_sb.h           |    4 +-
>  include/linux/nfs_xdr.h             |   17 +-
>  21 files changed, 3113 insertions(+), 91 deletions(-)
> 
> commit 1c46c073ba7b1333d2d736056a081d4f17f5f1d3
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Sat Jul 30 20:52:56 2011 -0400
> 
>     For invalid extents, find other pages in the same fsblock and write them out.
>     
>     [pnfsblock: write_begin]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 579f69df9c99794f02878f7562a6906e8b2ac316
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:55 2011 -0400
> 
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 0593a6123b6736f06823624813a94c863af7be87
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:54 2011 -0400
> 
>     Note: When upper layer's read/write request cannot be fulfilled, the block
>     layout driver shouldn't silently mark the page as error. It should do
>     what can be done and  leave the rest to the upper layer. To do so, we
>     should set rdata/wdata->res.count properly.
>     
>     When upper layer re-send the read/write request to finish the rest
>     part of the request, pgbase is the position where we should start at.
>     
>     [pnfsblock: bl_write_pagelist support functions]
>     [pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: handle errors when read or write pagelist.]
>     Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
>     [pnfs-block: use new write_pagelist api]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     
>     [SQUASHME: pnfsblock: mds_offset is set in the generic layer]
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     
>     [pnfsblock: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     [pnfsblock: SQUASHME: adjust to API change]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: fixup blksize alignment in bl_setup_layoutcommit]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [pnfsblock: bl_write_pagelist adjust for missing PG_USE_PNFS]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: handle errors when read or write pagelist.]
>     Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
>     [pnfs-block: use new write_pagelist api]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 1371c564cf844d3f479527b623565ac262e6ebaa
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:53 2011 -0400
> 
>     Note: When upper layer's read/write request cannot be fulfilled, the block
>     layout driver shouldn't silently mark the page as error. It should do
>     what can be done and  leave the rest to the upper layer. To do so, we
>     should set rdata/wdata->res.count properly.
>     
>     When upper layer re-send the read/write request to finish the rest
>     part of the request, pgbase is the position where we should start at.
>     
>     [pnfsblock: mark IO error with NFS_LAYOUT_{RW|RO}_FAILED]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     [pnfsblock: read path error handling]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: handle errors when read or write pagelist.]
>     Signed-off-by: Zhang Jingwang <yyalone@gmail.com>
>     [pnfs-block: use new read_pagelist api]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 5dd59231aa9930bc3b217539da6d5eff1120173e
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:52 2011 -0400
> 
>     In blocklayout driver. There are two things happening
>     while layoutcommit/cleanup.
>     1. the modified extents are encoded.
>     2. On cleanup the extents are put back on the layout rw
>        extents list, for reads.
>     
>     In the new system where actual xdr encoding is done in
>     encode_layoutcommit() directly into xdr buffer, these are
>     the new commit stages:
>     
>     1. On setup_layoutcommit, the range is adjusted as before
>        and a structure is allocated for communication with
>        bl_encode_layoutcommit && bl_cleanup_layoutcommit
>        (Generic layer provides a void-star to hang it on)
>     
>     2. bl_encode_layoutcommit is called to do the actual
>        encoding directly into xdr. The commit-extent-list is not
>        freed and is stored on above structure.
>        FIXME: The code is not yet converted to the new XDR cleanup
>     
>     3. On cleanup the commit-extent-list is put back by a call
>        to set_to_rw() as before, but with no need for XDR decoding
>        of the list as before. And the commit-extent-list is freed.
>        Finally allocated structure is freed.
>     
>     [rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     [pnfsblock: introduce bl_committing list]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     [pnfsblock: SQUASHME: adjust to API change]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [blocklayout: encode_layoutcommit implementation]
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     [pnfsblock: fix bug setting up layoutcommit.]
>     Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>     [pnfsblock: cleanup_layoutcommit wants a status parameter]
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 936a675fe578d40919046bf0a26f1776960a504f
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:51 2011 -0400
> 
>     In blocklayout driver. There are two things happening
>     while layoutcommit/cleanup.
>     1. the modified extents are encoded.
>     2. On cleanup the extents are put back on the layout rw
>        extents list, for reads.
>     
>     In the new system where actual xdr encoding is done in
>     encode_layoutcommit() directly into xdr buffer, these are
>     the new commit stages:
>     
>     1. On setup_layoutcommit, the range is adjusted as before
>        and a structure is allocated for communication with
>        bl_encode_layoutcommit && bl_cleanup_layoutcommit
>        (Generic layer provides a void-star to hang it on)
>     
>     2. bl_encode_layoutcommit is called to do the actual
>        encoding directly into xdr. The commit-extent-list is not
>        freed and is stored on above structure.
>        FIXME: The code is not yet converted to the new XDR cleanup
>     
>     3. On cleanup the commit-extent-list is put back by a call
>        to set_to_rw() as before, but with no need for XDR decoding
>        of the list as before. And the commit-extent-list is freed.
>        Finally allocated structure is freed.
>     
>     [rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()]
>     [pnfsblock: get rid of deprecated xdr macros]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [blocklayout: encode_layoutcommit implementation]
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     [pnfsblock: fix bug setting up layoutcommit.]
>     Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>     [pnfsblock: prevent commit list corruption]
>     [pnfsblock: fix layoutcommit with an empty opaque]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 84e5fe06f95c8ad330a525a5b11d21d8e371fbfb
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:50 2011 -0400
> 
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 426b7d89de75cef8b308969e809f6242c72f620e
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:49 2011 -0400
> 
>     Adds working implementations of various support functions
>     to handle INVAL extents, needed by writes, such as
>     bl_mark_sectors_init and bl_is_sector_init.
>     
>     [pnfsblock: fix 64-bit compiler warnings for extent manipulation]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [Implement release_inval_marks]
>     Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit cef25cef97ff6799c82fa467f030146aea8876dc
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:48 2011 -0400
> 
>     Implement bl_find_get_extent(), one of the core extent manipulation
>     routines.
>     
>     [pnfsblock: Lookup list entry of layouts and tags in reverse order]
>     Signed-off-by: Zhang Jingwang <zhangjingwang@nrchpc.ac.cn>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     
>     pnfsblock: fix print format warnings for sector_t and size_t
>     
>     gcc spews warnings about these on x86_64, e.g.:
>     fs/nfs/blocklayout/blocklayout.c:74: warning: format ‘%Lu’ expects type ‘long long unsigned int’, but argument 2 has type ‘sector_t’
>     fs/nfs/blocklayout/blocklayout.c:388: warning: format ‘%d’ expects type ‘int’, but argument 5 has type ‘size_t’
>     
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 6cb996c2b07c4e0c48d5e67a5cc24e8211d89add
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:47 2011 -0400
> 
>     XDR decodes the block layout payload sent in LAYOUTGET result, storing
>     the result in an extent list.
>     
>     [pnfsblock: get rid of deprecated xdr macros]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
>     Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 4d9a1fcdcbf13e6e65a4b0475af7d4fb139d1842
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:46 2011 -0400
> 
>     Call GETDEVICELIST during mount, then call and parse GETDEVICEINFO
>     for each device returned.
>     
>     [pnfsblock: get rid of deprecated xdr macros]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     [pnfsblock: fix pnfs_deviceid references]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: fix print format warnings for sector_t and size_t]
>     [pnfs-block: #include <linux/vmalloc.h>]
>     [pnfsblock: no PNFS_NFS_SERVER]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     [pnfsblock: fix bug determining size of striped volume]
>     [pnfsblock: fix oops when using multiple devices]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [pnfsblock: get rid of vmap and deviceid->area structure]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit f0f45cd2693863faa19f0edfc3f16d77159f7838
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:45 2011 -0400
> 
>     Replace a stub, so that extents underlying the layouts are properly
>     added, merged, or ignored as necessary.
>     
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: delete the new node before put it]
>     Signed-off-by: Mingyang Guo <guomingyang@nrchpc.ac.cn>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 03e023d1027458d13c0007f0e4456b65ee2977f1
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:44 2011 -0400
> 
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfsblock: fix bug getting pnfs_layout_type in translate_devid().]
>     Signed-off-by: Tao Guo <guotao@nrchpc.ac.cn>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Zhang Jingwang <Jingwang.Zhang@emc.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit be4619cf2c94aad7a9853e4ab32ce31565b9335c
> Author: Jim Rees <rees@umich.edu>
> Date:   Sat Jul 30 20:52:43 2011 -0400
> 
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [upcall bugfixes]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit db1905c6f31ac745573ffb3bf860e07088dd8713
> Author: Jim Rees <rees@umich.edu>
> Date:   Sat Jul 30 20:52:42 2011 -0400
> 
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [upcall bugfixes]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 7c8b2c6c3f8bd394401da844badd28990261dd2a
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:41 2011 -0400
> 
>     Adds structures and basic create/delete code for extents.
>     
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Zhang Jingwang <Jingwang.Zhang@emc.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit be79608be504916f9534af194ca8d5b612606484
> Author: Benny Halevy <bhalevy@panasas.com>
> Date:   Sat Jul 30 20:52:40 2011 -0400
> 
>     [pnfsblock: use pnfs_generic_pg_init_read/write]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 8f7e205d20c74fbaab3e4942e5daa09f0787fdd7
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:39 2011 -0400
> 
>     Define a configuration variable to enable/disable compilation of the
>     block driver code.
>     
>     Add the minimal structure for a pnfs block layout driver, and empty
>     list-heads that will hold the extent data
>     
>     [pnfsblock: make NFS_V4_1 select PNFS_BLOCK]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     [pnfs-block: fix CONFIG_PNFS_BLOCK dependencies]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [pnfsblock: SQUASHME: adjust to API change]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfs: move pnfs_layout_type inline in nfs_inode]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     [blocklayout: encode_layoutcommit implementation]
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [pnfsblock: layout alloc and free]
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     [pnfs: move pnfs_layout_type inline in nfs_inode]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [pnfsblock: define module alias]
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     [rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit bec3f732e912295462c795d9947a7ed59f85caee
> Author: Andy Adamson <andros@netapp.com>
> Date:   Sat Jul 30 20:52:38 2011 -0400
> 
>     This gives layout driver a chance to cleanup structures they put in at
>     encode_layoutcommit.
>     
>     Signed-off-by: Andy Adamson <andros@netapp.com>
>     [fixup layout header pointer for layoutcommit]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     [rm inode and pnfs_layout_hdr args from cleanup_layoutcommit()]
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 009354f2e7d197a29ca08d5f2c0bbe6e806855ec
> Author: Fred Isaman <iisaman@citi.umich.edu>
> Date:   Sat Jul 30 20:52:37 2011 -0400
> 
>     Block layout needs it to determine IO size.
>     
>     Signed-off-by: Fred Isaman <iisaman@citi.umich.edu>
>     Signed-off-by: Tao Guo <glorioustao@gmail.com>
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 8d619fb13ecf6f56eabf88d7fa023cefb9832d2e
> Author: Benny Halevy <bhalevy@panasas.com>
> Date:   Sat Jul 30 20:52:36 2011 -0400
> 
>     To allow layout driver to issue getdevicelist at mount time, and clean up
>     at umount time.
>     
>     [fixup non NFS_V4_1 set_pnfs_layoutdriver definition]
>     [pnfs: pass mntfh down the init_pnfs path]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 3c8507c7447b671ce14c7fc250c3cd7d9f338706
> Author: Andy Adamson <andros@netapp.com>
> Date:   Sat Jul 30 20:52:35 2011 -0400
> 
>     The block driver uses GETDEVICELIST
>     
>     Signed-off-by: Andy Adamson <andros@netapp.com>
>     [pass struct nfs_server * to getdevicelist]
>     [get machince creds for getdevicelist]
>     [fix getdevicelist decode sizing]
>     Signed-off-by: Benny Halevy <bhalevy@panasas.com>
>     Signed-off-by: Benny Halevy <bhalevy@tonian.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 53e8c77ea157bb1888cf33a99de11c3d967a58df
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Sat Jul 30 20:52:34 2011 -0400
> 
>     Using NFS4_MAX_UINT64 will break current protocol.
>     
>     [Needed in v3.0]
>     CC: Stable Tree <stable@kernel.org>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit eb425aadaed93b8499bebd8802c669b1b3d592f6
> Author: Peng Tao <peng_tao@emc.com>
> Date:   Sat Jul 30 20:52:33 2011 -0400
> 
>     There can be multiple lseg per file, so layoutcommit should be
>     able to handle it.
>     
>     [Needed in v3.0]
>     CC: Stable Tree <stable@kernel.org>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit d7060761432676d0249f680ddb4d130afb0bd5c9
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Sat Jul 30 20:52:32 2011 -0400
> 
>     No need to save it for every lseg.
>     No need to save it at every pnfs_set_layoutcommit.
>     
>     [Needed in v3.0]
>     CC: Stable Tree <stable@kernel.org>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 8b7116b52046b95874f38c519b6e8923d9d1b113
> Author: Peng Tao <bergwolf@gmail.com>
> Date:   Sat Jul 30 20:52:31 2011 -0400
> 
>     No need to save it for every lseg.
>     
>     [Needed in v3.0]
>     CC: Stable Tree <stable@kernel.org>
>     Signed-off-by: Peng Tao <peng_tao@emc.com>
>     Signed-off-by: Jim Rees <rees@umich.edu>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 374e4e3ec347d4f70e1417ce3e1c454f133dab72
> Author: Bryan Schumaker <bjschuma@netapp.com>
> Date:   Fri Jul 29 11:49:06 2011 -0400
> 
>     Additional readdir cookie loop information
>     
>     Print out the name of the file that triggers the cookie loop  message to
>     make it slightly easier to track down the cause.
>     
>     Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> commit 0c0308066ca53fdf1423895f3a42838b67b3a5a8
> Author: Trond Myklebust <Trond.Myklebust@netapp.com>
> Date:   Sat Jul 30 12:45:35 2011 -0400
> 
>     NFS: Fix spurious readdir cookie loop messages
>     
>     If the directory contents change, then we have to accept that the
>     file->f_pos value may shrink if we do a 'search-by-cookie'. In that
>     case, we should turn off the loop detection and let the NFS client
>     try to recover.
>     
>     The patch also fixes a second loop detection bug by ensuring
>     that after turning on the ctx->duped flag, we read at least one new
>     cookie into ctx->dir_cookie before attempting to match with
>     ctx->dup_cookie.
>     
>     Reported-by: Petr Vandrovec <petr@vandrovec.name>
>     Cc: stable@kernel.org [2.6.39+]
>     Signed-off-by: Trond Myklebust <Trond.Myklebust@netapp.com>
> 
> 

