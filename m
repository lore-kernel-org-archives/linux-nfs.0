Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mail-vw0-f46.google.com ([209.85.212.46]:55443 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab1K2RZ7 convert rfc822-to-8bit (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 29 Nov 2011 12:25:59 -0500
Received: by vbbfc26 with SMTP id fc26so4965451vbb.19
        for <linux-nfs@vger.kernel.org>; Tue, 29 Nov 2011 09:25:58 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1322584823.4174.15.camel@lade.trondhjem.org>
References: <1322887965-2938-1-git-send-email-bergwolf@gmail.com>
 <1322887965-2938-5-git-send-email-bergwolf@gmail.com> <1322584823.4174.15.camel@lade.trondhjem.org>
From: Peng Tao <bergwolf@gmail.com>
Date: Wed, 30 Nov 2011 01:25:37 +0800
Message-ID: <CA+a=Yy7wbcYsBQ+tuMR86+fiRn8xNcZxFvJTFOEsWqrJKRm7sQ@mail.gmail.com>
Subject: Re: [PATCH 4/4] pnfsblock: do ask for layout in pg_init
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: linux-nfs@vger.kernel.org, bhalevy@tonian.com, Peng Tao <peng_tao@emc.com>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On Wed, Nov 30, 2011 at 12:40 AM, Trond Myklebust
<Trond.Myklebust@netapp.com> wrote:
> On Fri, 2011-12-02 at 20:52 -0800, Peng Tao wrote:
>> Asking for layout in pg_init will always make client ask for only 4KB
>> layout in every layoutget. This way, client drops the IO size information
>> that is meaningful for MDS in handing out layout.
>>
>> In stead, if layout is not find in cache, do not send layoutget
>> at once. Wait until before issuing IO in pnfs_do_multiple_reads/writes
>> because that is where we know the real size of current IO. By telling the
>> real IO size to MDS, MDS will have a better chance to give proper layout.
>
> Why can't you just split pnfs_update_layout() into 2 sub-functions
> instead of duplicating it in private block code?
Because I wanted to differentiate between no layout header and no
cached lseg, where the pnfs_update_layout() interface is not enough to
tell the difference. Of course I can put these all into generic layer.
I will update the patchset to do it.

>
> Then call layoutget in your pg_doio() callback instead of adding a
> redundant pnfs_update_layout to
> pnfs_do_multiple_reads/pnfs_do_multiple_writes...
I have considered it before but using private pg_doio() means we will
have as much duplication of pnfs_generic_pg_read/writepages.

>
>
>> Signed-off-by: Peng Tao <peng_tao@emc.com>
>> ---
>>  fs/nfs/blocklayout/blocklayout.c |   54 ++++++++++++++++++++++++++++++++++++-
>>  1 files changed, 52 insertions(+), 2 deletions(-)
>>
>> diff --git a/fs/nfs/blocklayout/blocklayout.c b/fs/nfs/blocklayout/blocklayout.c
>> index 48cfac3..fd585fe 100644
>> --- a/fs/nfs/blocklayout/blocklayout.c
>> +++ b/fs/nfs/blocklayout/blocklayout.c
>> @@ -39,6 +39,7 @@
>>  #include <linux/prefetch.h>
>>
>>  #include "blocklayout.h"
>> +#include "../internal.h"
>>
>>  #define NFSDBG_FACILITY      NFSDBG_PNFS_LD
>>
>> @@ -990,14 +991,63 @@ bl_clear_layoutdriver(struct nfs_server *server)
>>       return 0;
>>  }
>>
>> +/* While RFC doesn't limit maximum size of layout, we better limit it ourself. */
>> +#define PNFSBLK_MAXRSIZE (0x1<<22)
>> +#define PNFSBLK_MAXWSIZE (0x1<<21)
>> +static void
>> +bl_pg_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>> +{
>> +     struct inode *ino = pgio->pg_inode;
>> +     struct pnfs_layout_hdr *lo;
>> +
>> +     BUG_ON(pgio->pg_lseg != NULL);
>> +     spin_lock(&ino->i_lock);
>> +     lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_KERNEL);
>
> This has never been tested... It contains all sorts of bugs from
> recursive attempts to take the ino->i_lock, to sleep-under-spinlock...
The code is certainly tested... If you look into
pnfs_find_alloc_layout(), you'll see the spinlock is released inside
pnfs_find_alloc_layout() when it needs to sleep there.
pnfs_find_alloc_layout() actually asserts spin_locked at function
entrance... So we have to take the spin lock before calling it...

 851 static struct pnfs_layout_hdr *
 852 pnfs_find_alloc_layout(struct inode *ino,
 853                        struct nfs_open_context *ctx,
 854                        gfp_t gfp_flags)
 855 {
 856         struct nfs_inode *nfsi = NFS_I(ino);
 857         struct pnfs_layout_hdr *new = NULL;
 858
 859         dprintk("%s Begin ino=%p layout=%p\n", __func__, ino,
nfsi->layout);
 860
 861         assert_spin_locked(&ino->i_lock);
 862         if (nfsi->layout) {
 863                 if (test_bit(NFS_LAYOUT_DESTROYED,
&nfsi->layout->plh_flags))
 864                         return NULL;
 865                 else
 866                         return nfsi->layout;
 867         }
 868         spin_unlock(&ino->i_lock);
 869         new = alloc_init_layout_hdr(ino, ctx, gfp_flags);
 870         spin_lock(&ino->i_lock);
 871
 872         if (likely(nfsi->layout == NULL))       /* Won the race? */
 873                 nfsi->layout = new;
 874         else
 875                 pnfs_free_layout_hdr(new);
 876         return nfsi->layout;
 877 }

-- 
Thanks,
Tao
>
>> +     if (!lo || test_bit(lo_fail_bit(IOMODE_READ), &lo->plh_flags)) {
>> +             spin_unlock(&ino->i_lock);
>> +             nfs_pageio_reset_read_mds(pgio);
>> +             return;
>> +     }
>> +
>> +     pgio->pg_bsize = PNFSBLK_MAXRSIZE;
>> +     pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
>> +                                             req_offset(req),
>> +                                             req->wb_bytes,
>> +                                             IOMODE_READ);
>> +     spin_unlock(&ino->i_lock);
>> +}
>> +
>> +static void
>> +bl_pg_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
>> +{
>> +     struct inode *ino = pgio->pg_inode;
>> +     struct pnfs_layout_hdr *lo;
>> +
>> +     BUG_ON(pgio->pg_lseg != NULL);
>> +     spin_lock(&ino->i_lock);
>> +     lo = pnfs_find_alloc_layout(ino, req->wb_context, GFP_NOFS);
>> +     if (!lo || test_bit(lo_fail_bit(IOMODE_RW), &lo->plh_flags)) {
>> +             spin_unlock(&ino->i_lock);
>> +             nfs_pageio_reset_write_mds(pgio);
>> +             return;
>> +     }
>
> Ditto...
>
>> +
>> +     pgio->pg_bsize = PNFSBLK_MAXWSIZE;
>> +     pgio->pg_lseg = pnfs_find_get_layout_locked(ino,
>> +                                             req_offset(req),
>> +                                             req->wb_bytes,
>> +                                             IOMODE_RW);
>> +     spin_unlock(&ino->i_lock);
>> +}
>> +
>>  static const struct nfs_pageio_ops bl_pg_read_ops = {
>> -     .pg_init = pnfs_generic_pg_init_read,
>> +     .pg_init = bl_pg_init_read,
>>       .pg_test = pnfs_generic_pg_test,
>>       .pg_doio = pnfs_generic_pg_readpages,
>>  };
>>
>>  static const struct nfs_pageio_ops bl_pg_write_ops = {
>> -     .pg_init = pnfs_generic_pg_init_write,
>> +     .pg_init = bl_pg_init_write,
>>       .pg_test = pnfs_generic_pg_test,
>>       .pg_doio = pnfs_generic_pg_writepages,
>>  };
>
> --
> Trond Myklebust
> Linux NFS client maintainer
>
> NetApp
> Trond.Myklebust@netapp.com
> www.netapp.com
>
