Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34527 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1035976AbdDUH1y (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Fri, 21 Apr 2017 03:27:54 -0400
MIME-Version: 1.0
In-Reply-To: <20170412160109.10598-4-hch@lst.de>
References: <20170412160109.10598-1-hch@lst.de> <20170412160109.10598-4-hch@lst.de>
From: Valentin Rothberg <valentinrothberg@gmail.com>
Date: Fri, 21 Apr 2017 09:27:11 +0200
Message-ID: <CAD3Xx4+79ryvNDtB4F1v-9TxQe8sTxYKeysCGqWuUYG8Ca=Yxg@mail.gmail.com>
Subject: Re: [PATCH 3/4] nfs: remove the objlayout driver
To: Christoph Hellwig <hch@lst.de>
Cc: ooo@electrozaur.com, martin.petersen@oracle.com,
        trond.myklebust@primarydata.com, axboe@kernel.dk,
        osd-dev@open-osd.org, linux-nfs@vger.kernel.org,
        linux-scsi@vger.kernel.org, linux-block@vger.kernel.org,
        LKML <linux-kernel@vger.kernel.org>
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Christoph,

I just came across this patch in linux-next commit 6d22323b2e9f.
scripts/checkkconfigsymbols.py reports that there is a leftover
reference on PNFS_OBJLAYOUT in fs/exofs/Kconfig.ore line 10 (depends
on EXOFS_FS || PNFS_OBJLAYOUT). I assume that this reference can
safely be removed now? If you want to I can send a trivial patch
removing it.

Kind regards,
 Valentin

On Wed, Apr 12, 2017 at 6:01 PM, Christoph Hellwig <hch@lst.de> wrote:
> The objlayout code has been in the tree, but it's been unmaintained and
> no server product for it actually ever shipped.
>
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/admin-guide/kernel-parameters.txt |   6 -
>  Documentation/filesystems/nfs/pnfs.txt          |  37 --
>  fs/nfs/Kconfig                                  |   5 -
>  fs/nfs/Makefile                                 |   1 -
>  fs/nfs/objlayout/Kbuild                         |   5 -
>  fs/nfs/objlayout/objio_osd.c                    | 675 ----------------------
>  fs/nfs/objlayout/objlayout.c                    | 706 ------------------------
>  fs/nfs/objlayout/objlayout.h                    | 183 ------
>  fs/nfs/objlayout/pnfs_osd_xdr_cli.c             | 415 --------------
>  9 files changed, 2033 deletions(-)
>  delete mode 100644 fs/nfs/objlayout/Kbuild
>  delete mode 100644 fs/nfs/objlayout/objio_osd.c
>  delete mode 100644 fs/nfs/objlayout/objlayout.c
>  delete mode 100644 fs/nfs/objlayout/objlayout.h
>  delete mode 100644 fs/nfs/objlayout/pnfs_osd_xdr_cli.c
>
> diff --git a/Documentation/admin-guide/kernel-parameters.txt b/Documentation/admin-guide/kernel-parameters.txt
> index facc20a3f962..17156d66b124 100644
> --- a/Documentation/admin-guide/kernel-parameters.txt
> +++ b/Documentation/admin-guide/kernel-parameters.txt
> @@ -2419,12 +2419,6 @@
>                         and gids from such clients.  This is intended to ease
>                         migration from NFSv2/v3.
>
> -       objlayoutdriver.osd_login_prog=
> -                       [NFS] [OBJLAYOUT] sets the pathname to the program which
> -                       is used to automatically discover and login into new
> -                       osd-targets. Please see:
> -                       Documentation/filesystems/pnfs.txt for more explanations
> -
>         nmi_debug=      [KNL,AVR32,SH] Specify one or more actions to take
>                         when a NMI is triggered.
>                         Format: [state][,regs][,debounce][,die]
> diff --git a/Documentation/filesystems/nfs/pnfs.txt b/Documentation/filesystems/nfs/pnfs.txt
> index 8de578a98222..80dc0bdc302a 100644
> --- a/Documentation/filesystems/nfs/pnfs.txt
> +++ b/Documentation/filesystems/nfs/pnfs.txt
> @@ -64,46 +64,9 @@ table which are called by the nfs-client pnfs-core to implement the
>  different layout types.
>
>  Files-layout-driver code is in: fs/nfs/filelayout/.. directory
> -Objects-layout-driver code is in: fs/nfs/objlayout/.. directory
>  Blocks-layout-driver code is in: fs/nfs/blocklayout/.. directory
>  Flexfiles-layout-driver code is in: fs/nfs/flexfilelayout/.. directory
>
> -objects-layout setup
> ---------------------
> -
> -As part of the full STD implementation the objlayoutdriver.ko needs, at times,
> -to automatically login to yet undiscovered iscsi/osd devices. For this the
> -driver makes up-calles to a user-mode script called *osd_login*
> -
> -The path_name of the script to use is by default:
> -       /sbin/osd_login.
> -This name can be overridden by the Kernel module parameter:
> -       objlayoutdriver.osd_login_prog
> -
> -If Kernel does not find the osd_login_prog path it will zero it out
> -and will not attempt farther logins. An admin can then write new value
> -to the objlayoutdriver.osd_login_prog Kernel parameter to re-enable it.
> -
> -The /sbin/osd_login is part of the nfs-utils package, and should usually
> -be installed on distributions that support this Kernel version.
> -
> -The API to the login script is as follows:
> -       Usage: $0 -u <URI> -o <OSDNAME> -s <SYSTEMID>
> -       Options:
> -               -u              target uri e.g. iscsi://<ip>:<port>
> -                               (always exists)
> -                               (More protocols can be defined in the future.
> -                                The client does not interpret this string it is
> -                                passed unchanged as received from the Server)
> -               -o              osdname of the requested target OSD
> -                               (Might be empty)
> -                               (A string which denotes the OSD name, there is a
> -                                limit of 64 chars on this string)
> -               -s              systemid of the requested target OSD
> -                               (Might be empty)
> -                               (This string, if not empty is always an hex
> -                                representation of the 20 bytes osd_system_id)
> -
>  blocks-layout setup
>  -------------------
>
> diff --git a/fs/nfs/Kconfig b/fs/nfs/Kconfig
> index f31fd0dd92c6..69d02cf8cf37 100644
> --- a/fs/nfs/Kconfig
> +++ b/fs/nfs/Kconfig
> @@ -123,11 +123,6 @@ config PNFS_BLOCK
>         depends on NFS_V4_1 && BLK_DEV_DM
>         default NFS_V4
>
> -config PNFS_OBJLAYOUT
> -       tristate
> -       depends on NFS_V4_1 && SCSI_OSD_ULD
> -       default NFS_V4
> -
>  config PNFS_FLEXFILE_LAYOUT
>         tristate
>         depends on NFS_V4_1 && NFS_V3
> diff --git a/fs/nfs/Makefile b/fs/nfs/Makefile
> index 6abdda209642..98f4e5728a67 100644
> --- a/fs/nfs/Makefile
> +++ b/fs/nfs/Makefile
> @@ -31,6 +31,5 @@ nfsv4-$(CONFIG_NFS_V4_1)      += pnfs.o pnfs_dev.o pnfs_nfs.o
>  nfsv4-$(CONFIG_NFS_V4_2)       += nfs42proc.o
>
>  obj-$(CONFIG_PNFS_FILE_LAYOUT) += filelayout/
> -obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayout/
>  obj-$(CONFIG_PNFS_BLOCK) += blocklayout/
>  obj-$(CONFIG_PNFS_FLEXFILE_LAYOUT) += flexfilelayout/
> diff --git a/fs/nfs/objlayout/Kbuild b/fs/nfs/objlayout/Kbuild
> deleted file mode 100644
> index ed30ea072bb8..000000000000
> --- a/fs/nfs/objlayout/Kbuild
> +++ /dev/null
> @@ -1,5 +0,0 @@
> -#
> -# Makefile for the pNFS Objects Layout Driver kernel module
> -#
> -objlayoutdriver-y := objio_osd.o pnfs_osd_xdr_cli.o objlayout.o
> -obj-$(CONFIG_PNFS_OBJLAYOUT) += objlayoutdriver.o
> diff --git a/fs/nfs/objlayout/objio_osd.c b/fs/nfs/objlayout/objio_osd.c
> deleted file mode 100644
> index 049c1b1f2932..000000000000
> --- a/fs/nfs/objlayout/objio_osd.c
> +++ /dev/null
> @@ -1,675 +0,0 @@
> -/*
> - *  pNFS Objects layout implementation over open-osd initiator library
> - *
> - *  Copyright (C) 2009 Panasas Inc. [year of first publication]
> - *  All rights reserved.
> - *
> - *  Benny Halevy <bhalevy@panasas.com>
> - *  Boaz Harrosh <ooo@electrozaur.com>
> - *
> - *  This program is free software; you can redistribute it and/or modify
> - *  it under the terms of the GNU General Public License version 2
> - *  See the file COPYING included with this distribution for more details.
> - *
> - *  Redistribution and use in source and binary forms, with or without
> - *  modification, are permitted provided that the following conditions
> - *  are met:
> - *
> - *  1. Redistributions of source code must retain the above copyright
> - *     notice, this list of conditions and the following disclaimer.
> - *  2. Redistributions in binary form must reproduce the above copyright
> - *     notice, this list of conditions and the following disclaimer in the
> - *     documentation and/or other materials provided with the distribution.
> - *  3. Neither the name of the Panasas company nor the names of its
> - *     contributors may be used to endorse or promote products derived
> - *     from this software without specific prior written permission.
> - *
> - *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> - *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> - *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> - *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> - *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> - *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> - *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> - *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> - *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> - *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> - *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> - */
> -
> -#include <linux/module.h>
> -#include <scsi/osd_ore.h>
> -
> -#include "objlayout.h"
> -#include "../internal.h"
> -
> -#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
> -
> -struct objio_dev_ent {
> -       struct nfs4_deviceid_node id_node;
> -       struct ore_dev od;
> -};
> -
> -static void
> -objio_free_deviceid_node(struct nfs4_deviceid_node *d)
> -{
> -       struct objio_dev_ent *de = container_of(d, struct objio_dev_ent, id_node);
> -
> -       dprintk("%s: free od=%p\n", __func__, de->od.od);
> -       osduld_put_device(de->od.od);
> -       kfree_rcu(d, rcu);
> -}
> -
> -struct objio_segment {
> -       struct pnfs_layout_segment lseg;
> -
> -       struct ore_layout layout;
> -       struct ore_components oc;
> -};
> -
> -static inline struct objio_segment *
> -OBJIO_LSEG(struct pnfs_layout_segment *lseg)
> -{
> -       return container_of(lseg, struct objio_segment, lseg);
> -}
> -
> -struct objio_state {
> -       /* Generic layer */
> -       struct objlayout_io_res oir;
> -
> -       bool sync;
> -       /*FIXME: Support for extra_bytes at ore_get_rw_state() */
> -       struct ore_io_state *ios;
> -};
> -
> -/* Send and wait for a get_device_info of devices in the layout,
> -   then look them up with the osd_initiator library */
> -struct nfs4_deviceid_node *
> -objio_alloc_deviceid_node(struct nfs_server *server, struct pnfs_device *pdev,
> -                       gfp_t gfp_flags)
> -{
> -       struct pnfs_osd_deviceaddr *deviceaddr;
> -       struct objio_dev_ent *ode = NULL;
> -       struct osd_dev *od;
> -       struct osd_dev_info odi;
> -       bool retry_flag = true;
> -       __be32 *p;
> -       int err;
> -
> -       deviceaddr = kzalloc(sizeof(*deviceaddr), gfp_flags);
> -       if (!deviceaddr)
> -               return NULL;
> -
> -       p = page_address(pdev->pages[0]);
> -       pnfs_osd_xdr_decode_deviceaddr(deviceaddr, p);
> -
> -       odi.systemid_len = deviceaddr->oda_systemid.len;
> -       if (odi.systemid_len > sizeof(odi.systemid)) {
> -               dprintk("%s: odi.systemid_len > sizeof(systemid=%zd)\n",
> -                       __func__, sizeof(odi.systemid));
> -               err = -EINVAL;
> -               goto out;
> -       } else if (odi.systemid_len)
> -               memcpy(odi.systemid, deviceaddr->oda_systemid.data,
> -                      odi.systemid_len);
> -       odi.osdname_len  = deviceaddr->oda_osdname.len;
> -       odi.osdname      = (u8 *)deviceaddr->oda_osdname.data;
> -
> -       if (!odi.osdname_len && !odi.systemid_len) {
> -               dprintk("%s: !odi.osdname_len && !odi.systemid_len\n",
> -                       __func__);
> -               err = -ENODEV;
> -               goto out;
> -       }
> -
> -retry_lookup:
> -       od = osduld_info_lookup(&odi);
> -       if (IS_ERR(od)) {
> -               err = PTR_ERR(od);
> -               dprintk("%s: osduld_info_lookup => %d\n", __func__, err);
> -               if (err == -ENODEV && retry_flag) {
> -                       err = objlayout_autologin(deviceaddr);
> -                       if (likely(!err)) {
> -                               retry_flag = false;
> -                               goto retry_lookup;
> -                       }
> -               }
> -               goto out;
> -       }
> -
> -       dprintk("Adding new dev_id(%llx:%llx)\n",
> -               _DEVID_LO(&pdev->dev_id), _DEVID_HI(&pdev->dev_id));
> -
> -       ode = kzalloc(sizeof(*ode), gfp_flags);
> -       if (!ode) {
> -               dprintk("%s: -ENOMEM od=%p\n", __func__, od);
> -               goto out;
> -       }
> -
> -       nfs4_init_deviceid_node(&ode->id_node, server, &pdev->dev_id);
> -       kfree(deviceaddr);
> -
> -       ode->od.od = od;
> -       return &ode->id_node;
> -
> -out:
> -       kfree(deviceaddr);
> -       return NULL;
> -}
> -
> -static void copy_single_comp(struct ore_components *oc, unsigned c,
> -                            struct pnfs_osd_object_cred *src_comp)
> -{
> -       struct ore_comp *ocomp = &oc->comps[c];
> -
> -       WARN_ON(src_comp->oc_cap_key.cred_len > 0); /* libosd is NO_SEC only */
> -       WARN_ON(src_comp->oc_cap.cred_len > sizeof(ocomp->cred));
> -
> -       ocomp->obj.partition = src_comp->oc_object_id.oid_partition_id;
> -       ocomp->obj.id = src_comp->oc_object_id.oid_object_id;
> -
> -       memcpy(ocomp->cred, src_comp->oc_cap.cred, sizeof(ocomp->cred));
> -}
> -
> -static int __alloc_objio_seg(unsigned numdevs, gfp_t gfp_flags,
> -                      struct objio_segment **pseg)
> -{
> -/*     This is the in memory structure of the objio_segment
> - *
> - *     struct __alloc_objio_segment {
> - *             struct objio_segment olseg;
> - *             struct ore_dev *ods[numdevs];
> - *             struct ore_comp comps[numdevs];
> - *     } *aolseg;
> - *     NOTE: The code as above compiles and runs perfectly. It is elegant,
> - *     type safe and compact. At some Past time Linus has decided he does not
> - *     like variable length arrays, For the sake of this principal we uglify
> - *     the code as below.
> - */
> -       struct objio_segment *lseg;
> -       size_t lseg_size = sizeof(*lseg) +
> -                       numdevs * sizeof(lseg->oc.ods[0]) +
> -                       numdevs * sizeof(*lseg->oc.comps);
> -
> -       lseg = kzalloc(lseg_size, gfp_flags);
> -       if (unlikely(!lseg)) {
> -               dprintk("%s: Failed allocation numdevs=%d size=%zd\n", __func__,
> -                       numdevs, lseg_size);
> -               return -ENOMEM;
> -       }
> -
> -       lseg->oc.numdevs = numdevs;
> -       lseg->oc.single_comp = EC_MULTPLE_COMPS;
> -       lseg->oc.ods = (void *)(lseg + 1);
> -       lseg->oc.comps = (void *)(lseg->oc.ods + numdevs);
> -
> -       *pseg = lseg;
> -       return 0;
> -}
> -
> -int objio_alloc_lseg(struct pnfs_layout_segment **outp,
> -       struct pnfs_layout_hdr *pnfslay,
> -       struct pnfs_layout_range *range,
> -       struct xdr_stream *xdr,
> -       gfp_t gfp_flags)
> -{
> -       struct nfs_server *server = NFS_SERVER(pnfslay->plh_inode);
> -       struct objio_segment *objio_seg;
> -       struct pnfs_osd_xdr_decode_layout_iter iter;
> -       struct pnfs_osd_layout layout;
> -       struct pnfs_osd_object_cred src_comp;
> -       unsigned cur_comp;
> -       int err;
> -
> -       err = pnfs_osd_xdr_decode_layout_map(&layout, &iter, xdr);
> -       if (unlikely(err))
> -               return err;
> -
> -       err = __alloc_objio_seg(layout.olo_num_comps, gfp_flags, &objio_seg);
> -       if (unlikely(err))
> -               return err;
> -
> -       objio_seg->layout.stripe_unit = layout.olo_map.odm_stripe_unit;
> -       objio_seg->layout.group_width = layout.olo_map.odm_group_width;
> -       objio_seg->layout.group_depth = layout.olo_map.odm_group_depth;
> -       objio_seg->layout.mirrors_p1 = layout.olo_map.odm_mirror_cnt + 1;
> -       objio_seg->layout.raid_algorithm = layout.olo_map.odm_raid_algorithm;
> -
> -       err = ore_verify_layout(layout.olo_map.odm_num_comps,
> -                                         &objio_seg->layout);
> -       if (unlikely(err))
> -               goto err;
> -
> -       objio_seg->oc.first_dev = layout.olo_comps_index;
> -       cur_comp = 0;
> -       while (pnfs_osd_xdr_decode_layout_comp(&src_comp, &iter, xdr, &err)) {
> -               struct nfs4_deviceid_node *d;
> -               struct objio_dev_ent *ode;
> -
> -               copy_single_comp(&objio_seg->oc, cur_comp, &src_comp);
> -
> -               d = nfs4_find_get_deviceid(server,
> -                               &src_comp.oc_object_id.oid_device_id,
> -                               pnfslay->plh_lc_cred, gfp_flags);
> -               if (!d) {
> -                       err = -ENXIO;
> -                       goto err;
> -               }
> -
> -               ode = container_of(d, struct objio_dev_ent, id_node);
> -               objio_seg->oc.ods[cur_comp++] = &ode->od;
> -       }
> -       /* pnfs_osd_xdr_decode_layout_comp returns false on error */
> -       if (unlikely(err))
> -               goto err;
> -
> -       *outp = &objio_seg->lseg;
> -       return 0;
> -
> -err:
> -       kfree(objio_seg);
> -       dprintk("%s: Error: return %d\n", __func__, err);
> -       *outp = NULL;
> -       return err;
> -}
> -
> -void objio_free_lseg(struct pnfs_layout_segment *lseg)
> -{
> -       int i;
> -       struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
> -
> -       for (i = 0; i < objio_seg->oc.numdevs; i++) {
> -               struct ore_dev *od = objio_seg->oc.ods[i];
> -               struct objio_dev_ent *ode;
> -
> -               if (!od)
> -                       break;
> -               ode = container_of(od, typeof(*ode), od);
> -               nfs4_put_deviceid_node(&ode->id_node);
> -       }
> -       kfree(objio_seg);
> -}
> -
> -static int
> -objio_alloc_io_state(struct pnfs_layout_hdr *pnfs_layout_type, bool is_reading,
> -       struct pnfs_layout_segment *lseg, struct page **pages, unsigned pgbase,
> -       loff_t offset, size_t count, void *rpcdata, gfp_t gfp_flags,
> -       struct objio_state **outp)
> -{
> -       struct objio_segment *objio_seg = OBJIO_LSEG(lseg);
> -       struct ore_io_state *ios;
> -       int ret;
> -       struct __alloc_objio_state {
> -               struct objio_state objios;
> -               struct pnfs_osd_ioerr ioerrs[objio_seg->oc.numdevs];
> -       } *aos;
> -
> -       aos = kzalloc(sizeof(*aos), gfp_flags);
> -       if (unlikely(!aos))
> -               return -ENOMEM;
> -
> -       objlayout_init_ioerrs(&aos->objios.oir, objio_seg->oc.numdevs,
> -                       aos->ioerrs, rpcdata, pnfs_layout_type);
> -
> -       ret = ore_get_rw_state(&objio_seg->layout, &objio_seg->oc, is_reading,
> -                              offset, count, &ios);
> -       if (unlikely(ret)) {
> -               kfree(aos);
> -               return ret;
> -       }
> -
> -       ios->pages = pages;
> -       ios->pgbase = pgbase;
> -       ios->private = aos;
> -       BUG_ON(ios->nr_pages > (pgbase + count + PAGE_SIZE - 1) >> PAGE_SHIFT);
> -
> -       aos->objios.sync = 0;
> -       aos->objios.ios = ios;
> -       *outp = &aos->objios;
> -       return 0;
> -}
> -
> -void objio_free_result(struct objlayout_io_res *oir)
> -{
> -       struct objio_state *objios = container_of(oir, struct objio_state, oir);
> -
> -       ore_put_io_state(objios->ios);
> -       kfree(objios);
> -}
> -
> -static enum pnfs_osd_errno osd_pri_2_pnfs_err(enum osd_err_priority oep)
> -{
> -       switch (oep) {
> -       case OSD_ERR_PRI_NO_ERROR:
> -               return (enum pnfs_osd_errno)0;
> -
> -       case OSD_ERR_PRI_CLEAR_PAGES:
> -               BUG_ON(1);
> -               return 0;
> -
> -       case OSD_ERR_PRI_RESOURCE:
> -               return PNFS_OSD_ERR_RESOURCE;
> -       case OSD_ERR_PRI_BAD_CRED:
> -               return PNFS_OSD_ERR_BAD_CRED;
> -       case OSD_ERR_PRI_NO_ACCESS:
> -               return PNFS_OSD_ERR_NO_ACCESS;
> -       case OSD_ERR_PRI_UNREACHABLE:
> -               return PNFS_OSD_ERR_UNREACHABLE;
> -       case OSD_ERR_PRI_NOT_FOUND:
> -               return PNFS_OSD_ERR_NOT_FOUND;
> -       case OSD_ERR_PRI_NO_SPACE:
> -               return PNFS_OSD_ERR_NO_SPACE;
> -       default:
> -               WARN_ON(1);
> -               /* fallthrough */
> -       case OSD_ERR_PRI_EIO:
> -               return PNFS_OSD_ERR_EIO;
> -       }
> -}
> -
> -static void __on_dev_error(struct ore_io_state *ios,
> -       struct ore_dev *od, unsigned dev_index, enum osd_err_priority oep,
> -       u64 dev_offset, u64  dev_len)
> -{
> -       struct objio_state *objios = ios->private;
> -       struct pnfs_osd_objid pooid;
> -       struct objio_dev_ent *ode = container_of(od, typeof(*ode), od);
> -       /* FIXME: what to do with more-then-one-group layouts. We need to
> -        * translate from ore_io_state index to oc->comps index
> -        */
> -       unsigned comp = dev_index;
> -
> -       pooid.oid_device_id = ode->id_node.deviceid;
> -       pooid.oid_partition_id = ios->oc->comps[comp].obj.partition;
> -       pooid.oid_object_id = ios->oc->comps[comp].obj.id;
> -
> -       objlayout_io_set_result(&objios->oir, comp,
> -                               &pooid, osd_pri_2_pnfs_err(oep),
> -                               dev_offset, dev_len, !ios->reading);
> -}
> -
> -/*
> - * read
> - */
> -static void _read_done(struct ore_io_state *ios, void *private)
> -{
> -       struct objio_state *objios = private;
> -       ssize_t status;
> -       int ret = ore_check_io(ios, &__on_dev_error);
> -
> -       /* FIXME: _io_free(ios) can we dealocate the libosd resources; */
> -
> -       if (likely(!ret))
> -               status = ios->length;
> -       else
> -               status = ret;
> -
> -       objlayout_read_done(&objios->oir, status, objios->sync);
> -}
> -
> -int objio_read_pagelist(struct nfs_pgio_header *hdr)
> -{
> -       struct objio_state *objios;
> -       int ret;
> -
> -       ret = objio_alloc_io_state(NFS_I(hdr->inode)->layout, true,
> -                       hdr->lseg, hdr->args.pages, hdr->args.pgbase,
> -                       hdr->args.offset, hdr->args.count, hdr,
> -                       GFP_KERNEL, &objios);
> -       if (unlikely(ret))
> -               return ret;
> -
> -       objios->ios->done = _read_done;
> -       dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
> -               hdr->args.offset, hdr->args.count);
> -       ret = ore_read(objios->ios);
> -       if (unlikely(ret))
> -               objio_free_result(&objios->oir);
> -       return ret;
> -}
> -
> -/*
> - * write
> - */
> -static void _write_done(struct ore_io_state *ios, void *private)
> -{
> -       struct objio_state *objios = private;
> -       ssize_t status;
> -       int ret = ore_check_io(ios, &__on_dev_error);
> -
> -       /* FIXME: _io_free(ios) can we dealocate the libosd resources; */
> -
> -       if (likely(!ret)) {
> -               /* FIXME: should be based on the OSD's persistence model
> -                * See OSD2r05 Section 4.13 Data persistence model */
> -               objios->oir.committed = NFS_FILE_SYNC;
> -               status = ios->length;
> -       } else {
> -               status = ret;
> -       }
> -
> -       objlayout_write_done(&objios->oir, status, objios->sync);
> -}
> -
> -static struct page *__r4w_get_page(void *priv, u64 offset, bool *uptodate)
> -{
> -       struct objio_state *objios = priv;
> -       struct nfs_pgio_header *hdr = objios->oir.rpcdata;
> -       struct address_space *mapping = hdr->inode->i_mapping;
> -       pgoff_t index = offset / PAGE_SIZE;
> -       struct page *page;
> -       loff_t i_size = i_size_read(hdr->inode);
> -
> -       if (offset >= i_size) {
> -               *uptodate = true;
> -               dprintk("%s: g_zero_page index=0x%lx\n", __func__, index);
> -               return ZERO_PAGE(0);
> -       }
> -
> -       page = find_get_page(mapping, index);
> -       if (!page) {
> -               page = find_or_create_page(mapping, index, GFP_NOFS);
> -               if (unlikely(!page)) {
> -                       dprintk("%s: grab_cache_page Failed index=0x%lx\n",
> -                               __func__, index);
> -                       return NULL;
> -               }
> -               unlock_page(page);
> -       }
> -       *uptodate = PageUptodate(page);
> -       dprintk("%s: index=0x%lx uptodate=%d\n", __func__, index, *uptodate);
> -       return page;
> -}
> -
> -static void __r4w_put_page(void *priv, struct page *page)
> -{
> -       dprintk("%s: index=0x%lx\n", __func__,
> -               (page == ZERO_PAGE(0)) ? -1UL : page->index);
> -       if (ZERO_PAGE(0) != page)
> -               put_page(page);
> -       return;
> -}
> -
> -static const struct _ore_r4w_op _r4w_op = {
> -       .get_page = &__r4w_get_page,
> -       .put_page = &__r4w_put_page,
> -};
> -
> -int objio_write_pagelist(struct nfs_pgio_header *hdr, int how)
> -{
> -       struct objio_state *objios;
> -       int ret;
> -
> -       ret = objio_alloc_io_state(NFS_I(hdr->inode)->layout, false,
> -                       hdr->lseg, hdr->args.pages, hdr->args.pgbase,
> -                       hdr->args.offset, hdr->args.count, hdr, GFP_NOFS,
> -                       &objios);
> -       if (unlikely(ret))
> -               return ret;
> -
> -       objios->sync = 0 != (how & FLUSH_SYNC);
> -       objios->ios->r4w = &_r4w_op;
> -
> -       if (!objios->sync)
> -               objios->ios->done = _write_done;
> -
> -       dprintk("%s: offset=0x%llx length=0x%x\n", __func__,
> -               hdr->args.offset, hdr->args.count);
> -       ret = ore_write(objios->ios);
> -       if (unlikely(ret)) {
> -               objio_free_result(&objios->oir);
> -               return ret;
> -       }
> -
> -       if (objios->sync)
> -               _write_done(objios->ios, objios);
> -
> -       return 0;
> -}
> -
> -/*
> - * Return 0 if @req cannot be coalesced into @pgio, otherwise return the number
> - * of bytes (maximum @req->wb_bytes) that can be coalesced.
> - */
> -static size_t objio_pg_test(struct nfs_pageio_descriptor *pgio,
> -                         struct nfs_page *prev, struct nfs_page *req)
> -{
> -       struct nfs_pgio_mirror *mirror = nfs_pgio_current_mirror(pgio);
> -       unsigned int size;
> -
> -       size = pnfs_generic_pg_test(pgio, prev, req);
> -
> -       if (!size || mirror->pg_count + req->wb_bytes >
> -           (unsigned long)pgio->pg_layout_private)
> -               return 0;
> -
> -       return min(size, req->wb_bytes);
> -}
> -
> -static void objio_init_read(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> -{
> -       pnfs_generic_pg_init_read(pgio, req);
> -       if (unlikely(pgio->pg_lseg == NULL))
> -               return; /* Not pNFS */
> -
> -       pgio->pg_layout_private = (void *)
> -                               OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
> -}
> -
> -static bool aligned_on_raid_stripe(u64 offset, struct ore_layout *layout,
> -                                  unsigned long *stripe_end)
> -{
> -       u32 stripe_off;
> -       unsigned stripe_size;
> -
> -       if (layout->raid_algorithm == PNFS_OSD_RAID_0)
> -               return true;
> -
> -       stripe_size = layout->stripe_unit *
> -                               (layout->group_width - layout->parity);
> -
> -       div_u64_rem(offset, stripe_size, &stripe_off);
> -       if (!stripe_off)
> -               return true;
> -
> -       *stripe_end = stripe_size - stripe_off;
> -       return false;
> -}
> -
> -static void objio_init_write(struct nfs_pageio_descriptor *pgio, struct nfs_page *req)
> -{
> -       unsigned long stripe_end = 0;
> -       u64 wb_size;
> -
> -       if (pgio->pg_dreq == NULL)
> -               wb_size = i_size_read(pgio->pg_inode) - req_offset(req);
> -       else
> -               wb_size = nfs_dreq_bytes_left(pgio->pg_dreq);
> -
> -       pnfs_generic_pg_init_write(pgio, req, wb_size);
> -       if (unlikely(pgio->pg_lseg == NULL))
> -               return; /* Not pNFS */
> -
> -       if (req->wb_offset ||
> -           !aligned_on_raid_stripe(req->wb_index * PAGE_SIZE,
> -                              &OBJIO_LSEG(pgio->pg_lseg)->layout,
> -                              &stripe_end)) {
> -               pgio->pg_layout_private = (void *)stripe_end;
> -       } else {
> -               pgio->pg_layout_private = (void *)
> -                               OBJIO_LSEG(pgio->pg_lseg)->layout.max_io_length;
> -       }
> -}
> -
> -static const struct nfs_pageio_ops objio_pg_read_ops = {
> -       .pg_init = objio_init_read,
> -       .pg_test = objio_pg_test,
> -       .pg_doio = pnfs_generic_pg_readpages,
> -       .pg_cleanup = pnfs_generic_pg_cleanup,
> -};
> -
> -static const struct nfs_pageio_ops objio_pg_write_ops = {
> -       .pg_init = objio_init_write,
> -       .pg_test = objio_pg_test,
> -       .pg_doio = pnfs_generic_pg_writepages,
> -       .pg_cleanup = pnfs_generic_pg_cleanup,
> -};
> -
> -static struct pnfs_layoutdriver_type objlayout_type = {
> -       .id = LAYOUT_OSD2_OBJECTS,
> -       .name = "LAYOUT_OSD2_OBJECTS",
> -       .flags                   = PNFS_LAYOUTRET_ON_SETATTR |
> -                                  PNFS_LAYOUTRET_ON_ERROR,
> -
> -       .max_deviceinfo_size     = PAGE_SIZE,
> -       .owner                   = THIS_MODULE,
> -       .alloc_layout_hdr        = objlayout_alloc_layout_hdr,
> -       .free_layout_hdr         = objlayout_free_layout_hdr,
> -
> -       .alloc_lseg              = objlayout_alloc_lseg,
> -       .free_lseg               = objlayout_free_lseg,
> -
> -       .read_pagelist           = objlayout_read_pagelist,
> -       .write_pagelist          = objlayout_write_pagelist,
> -       .pg_read_ops             = &objio_pg_read_ops,
> -       .pg_write_ops            = &objio_pg_write_ops,
> -
> -       .sync                    = pnfs_generic_sync,
> -
> -       .free_deviceid_node      = objio_free_deviceid_node,
> -
> -       .encode_layoutcommit     = objlayout_encode_layoutcommit,
> -       .encode_layoutreturn     = objlayout_encode_layoutreturn,
> -};
> -
> -MODULE_DESCRIPTION("pNFS Layout Driver for OSD2 objects");
> -MODULE_AUTHOR("Benny Halevy <bhalevy@panasas.com>");
> -MODULE_LICENSE("GPL");
> -
> -static int __init
> -objlayout_init(void)
> -{
> -       int ret = pnfs_register_layoutdriver(&objlayout_type);
> -
> -       if (ret)
> -               printk(KERN_INFO
> -                       "NFS: %s: Registering OSD pNFS Layout Driver failed: error=%d\n",
> -                       __func__, ret);
> -       else
> -               printk(KERN_INFO "NFS: %s: Registered OSD pNFS Layout Driver\n",
> -                       __func__);
> -       return ret;
> -}
> -
> -static void __exit
> -objlayout_exit(void)
> -{
> -       pnfs_unregister_layoutdriver(&objlayout_type);
> -       printk(KERN_INFO "NFS: %s: Unregistered OSD pNFS Layout Driver\n",
> -              __func__);
> -}
> -
> -MODULE_ALIAS("nfs-layouttype4-2");
> -
> -module_init(objlayout_init);
> -module_exit(objlayout_exit);
> diff --git a/fs/nfs/objlayout/objlayout.c b/fs/nfs/objlayout/objlayout.c
> deleted file mode 100644
> index 8f3d2acb81c3..000000000000
> --- a/fs/nfs/objlayout/objlayout.c
> +++ /dev/null
> @@ -1,706 +0,0 @@
> -/*
> - *  pNFS Objects layout driver high level definitions
> - *
> - *  Copyright (C) 2007 Panasas Inc. [year of first publication]
> - *  All rights reserved.
> - *
> - *  Benny Halevy <bhalevy@panasas.com>
> - *  Boaz Harrosh <ooo@electrozaur.com>
> - *
> - *  This program is free software; you can redistribute it and/or modify
> - *  it under the terms of the GNU General Public License version 2
> - *  See the file COPYING included with this distribution for more details.
> - *
> - *  Redistribution and use in source and binary forms, with or without
> - *  modification, are permitted provided that the following conditions
> - *  are met:
> - *
> - *  1. Redistributions of source code must retain the above copyright
> - *     notice, this list of conditions and the following disclaimer.
> - *  2. Redistributions in binary form must reproduce the above copyright
> - *     notice, this list of conditions and the following disclaimer in the
> - *     documentation and/or other materials provided with the distribution.
> - *  3. Neither the name of the Panasas company nor the names of its
> - *     contributors may be used to endorse or promote products derived
> - *     from this software without specific prior written permission.
> - *
> - *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> - *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> - *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> - *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> - *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> - *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> - *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> - *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> - *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> - *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> - *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> - */
> -
> -#include <linux/kmod.h>
> -#include <linux/moduleparam.h>
> -#include <linux/ratelimit.h>
> -#include <scsi/osd_initiator.h>
> -#include "objlayout.h"
> -
> -#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
> -/*
> - * Create a objlayout layout structure for the given inode and return it.
> - */
> -struct pnfs_layout_hdr *
> -objlayout_alloc_layout_hdr(struct inode *inode, gfp_t gfp_flags)
> -{
> -       struct objlayout *objlay;
> -
> -       objlay = kzalloc(sizeof(struct objlayout), gfp_flags);
> -       if (!objlay)
> -               return NULL;
> -       spin_lock_init(&objlay->lock);
> -       INIT_LIST_HEAD(&objlay->err_list);
> -       dprintk("%s: Return %p\n", __func__, objlay);
> -       return &objlay->pnfs_layout;
> -}
> -
> -/*
> - * Free an objlayout layout structure
> - */
> -void
> -objlayout_free_layout_hdr(struct pnfs_layout_hdr *lo)
> -{
> -       struct objlayout *objlay = OBJLAYOUT(lo);
> -
> -       dprintk("%s: objlay %p\n", __func__, objlay);
> -
> -       WARN_ON(!list_empty(&objlay->err_list));
> -       kfree(objlay);
> -}
> -
> -/*
> - * Unmarshall layout and store it in pnfslay.
> - */
> -struct pnfs_layout_segment *
> -objlayout_alloc_lseg(struct pnfs_layout_hdr *pnfslay,
> -                    struct nfs4_layoutget_res *lgr,
> -                    gfp_t gfp_flags)
> -{
> -       int status = -ENOMEM;
> -       struct xdr_stream stream;
> -       struct xdr_buf buf = {
> -               .pages =  lgr->layoutp->pages,
> -               .page_len =  lgr->layoutp->len,
> -               .buflen =  lgr->layoutp->len,
> -               .len = lgr->layoutp->len,
> -       };
> -       struct page *scratch;
> -       struct pnfs_layout_segment *lseg;
> -
> -       dprintk("%s: Begin pnfslay %p\n", __func__, pnfslay);
> -
> -       scratch = alloc_page(gfp_flags);
> -       if (!scratch)
> -               goto err_nofree;
> -
> -       xdr_init_decode(&stream, &buf, NULL);
> -       xdr_set_scratch_buffer(&stream, page_address(scratch), PAGE_SIZE);
> -
> -       status = objio_alloc_lseg(&lseg, pnfslay, &lgr->range, &stream, gfp_flags);
> -       if (unlikely(status)) {
> -               dprintk("%s: objio_alloc_lseg Return err %d\n", __func__,
> -                       status);
> -               goto err;
> -       }
> -
> -       __free_page(scratch);
> -
> -       dprintk("%s: Return %p\n", __func__, lseg);
> -       return lseg;
> -
> -err:
> -       __free_page(scratch);
> -err_nofree:
> -       dprintk("%s: Err Return=>%d\n", __func__, status);
> -       return ERR_PTR(status);
> -}
> -
> -/*
> - * Free a layout segement
> - */
> -void
> -objlayout_free_lseg(struct pnfs_layout_segment *lseg)
> -{
> -       dprintk("%s: freeing layout segment %p\n", __func__, lseg);
> -
> -       if (unlikely(!lseg))
> -               return;
> -
> -       objio_free_lseg(lseg);
> -}
> -
> -/*
> - * I/O Operations
> - */
> -static inline u64
> -end_offset(u64 start, u64 len)
> -{
> -       u64 end;
> -
> -       end = start + len;
> -       return end >= start ? end : NFS4_MAX_UINT64;
> -}
> -
> -static void _fix_verify_io_params(struct pnfs_layout_segment *lseg,
> -                          struct page ***p_pages, unsigned *p_pgbase,
> -                          u64 offset, unsigned long count)
> -{
> -       u64 lseg_end_offset;
> -
> -       BUG_ON(offset < lseg->pls_range.offset);
> -       lseg_end_offset = end_offset(lseg->pls_range.offset,
> -                                    lseg->pls_range.length);
> -       BUG_ON(offset >= lseg_end_offset);
> -       WARN_ON(offset + count > lseg_end_offset);
> -
> -       if (*p_pgbase > PAGE_SIZE) {
> -               dprintk("%s: pgbase(0x%x) > PAGE_SIZE\n", __func__, *p_pgbase);
> -               *p_pages += *p_pgbase >> PAGE_SHIFT;
> -               *p_pgbase &= ~PAGE_MASK;
> -       }
> -}
> -
> -/*
> - * I/O done common code
> - */
> -static void
> -objlayout_iodone(struct objlayout_io_res *oir)
> -{
> -       if (likely(oir->status >= 0)) {
> -               objio_free_result(oir);
> -       } else {
> -               struct objlayout *objlay = oir->objlay;
> -
> -               spin_lock(&objlay->lock);
> -               objlay->delta_space_valid = OBJ_DSU_INVALID;
> -               list_add(&objlay->err_list, &oir->err_list);
> -               spin_unlock(&objlay->lock);
> -       }
> -}
> -
> -/*
> - * objlayout_io_set_result - Set an osd_error code on a specific osd comp.
> - *
> - * The @index component IO failed (error returned from target). Register
> - * the error for later reporting at layout-return.
> - */
> -void
> -objlayout_io_set_result(struct objlayout_io_res *oir, unsigned index,
> -                       struct pnfs_osd_objid *pooid, int osd_error,
> -                       u64 offset, u64 length, bool is_write)
> -{
> -       struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[index];
> -
> -       BUG_ON(index >= oir->num_comps);
> -       if (osd_error) {
> -               ioerr->oer_component = *pooid;
> -               ioerr->oer_comp_offset = offset;
> -               ioerr->oer_comp_length = length;
> -               ioerr->oer_iswrite = is_write;
> -               ioerr->oer_errno = osd_error;
> -
> -               dprintk("%s: err[%d]: errno=%d is_write=%d dev(%llx:%llx) "
> -                       "par=0x%llx obj=0x%llx offset=0x%llx length=0x%llx\n",
> -                       __func__, index, ioerr->oer_errno,
> -                       ioerr->oer_iswrite,
> -                       _DEVID_LO(&ioerr->oer_component.oid_device_id),
> -                       _DEVID_HI(&ioerr->oer_component.oid_device_id),
> -                       ioerr->oer_component.oid_partition_id,
> -                       ioerr->oer_component.oid_object_id,
> -                       ioerr->oer_comp_offset,
> -                       ioerr->oer_comp_length);
> -       } else {
> -               /* User need not call if no error is reported */
> -               ioerr->oer_errno = 0;
> -       }
> -}
> -
> -/* Function scheduled on rpc workqueue to call ->nfs_readlist_complete().
> - * This is because the osd completion is called with ints-off from
> - * the block layer
> - */
> -static void _rpc_read_complete(struct work_struct *work)
> -{
> -       struct rpc_task *task;
> -       struct nfs_pgio_header *hdr;
> -
> -       dprintk("%s enter\n", __func__);
> -       task = container_of(work, struct rpc_task, u.tk_work);
> -       hdr = container_of(task, struct nfs_pgio_header, task);
> -
> -       pnfs_ld_read_done(hdr);
> -}
> -
> -void
> -objlayout_read_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
> -{
> -       struct nfs_pgio_header *hdr = oir->rpcdata;
> -
> -       oir->status = hdr->task.tk_status = status;
> -       if (status >= 0)
> -               hdr->res.count = status;
> -       else
> -               hdr->pnfs_error = status;
> -       objlayout_iodone(oir);
> -       /* must not use oir after this point */
> -
> -       dprintk("%s: Return status=%zd eof=%d sync=%d\n", __func__,
> -               status, hdr->res.eof, sync);
> -
> -       if (sync)
> -               pnfs_ld_read_done(hdr);
> -       else {
> -               INIT_WORK(&hdr->task.u.tk_work, _rpc_read_complete);
> -               schedule_work(&hdr->task.u.tk_work);
> -       }
> -}
> -
> -/*
> - * Perform sync or async reads.
> - */
> -enum pnfs_try_status
> -objlayout_read_pagelist(struct nfs_pgio_header *hdr)
> -{
> -       struct inode *inode = hdr->inode;
> -       loff_t offset = hdr->args.offset;
> -       size_t count = hdr->args.count;
> -       int err;
> -       loff_t eof;
> -
> -       eof = i_size_read(inode);
> -       if (unlikely(offset + count > eof)) {
> -               if (offset >= eof) {
> -                       err = 0;
> -                       hdr->res.count = 0;
> -                       hdr->res.eof = 1;
> -                       /*FIXME: do we need to call pnfs_ld_read_done() */
> -                       goto out;
> -               }
> -               count = eof - offset;
> -       }
> -
> -       hdr->res.eof = (offset + count) >= eof;
> -       _fix_verify_io_params(hdr->lseg, &hdr->args.pages,
> -                             &hdr->args.pgbase,
> -                             hdr->args.offset, hdr->args.count);
> -
> -       dprintk("%s: inode(%lx) offset 0x%llx count 0x%zx eof=%d\n",
> -               __func__, inode->i_ino, offset, count, hdr->res.eof);
> -
> -       err = objio_read_pagelist(hdr);
> - out:
> -       if (unlikely(err)) {
> -               hdr->pnfs_error = err;
> -               dprintk("%s: Returned Error %d\n", __func__, err);
> -               return PNFS_NOT_ATTEMPTED;
> -       }
> -       return PNFS_ATTEMPTED;
> -}
> -
> -/* Function scheduled on rpc workqueue to call ->nfs_writelist_complete().
> - * This is because the osd completion is called with ints-off from
> - * the block layer
> - */
> -static void _rpc_write_complete(struct work_struct *work)
> -{
> -       struct rpc_task *task;
> -       struct nfs_pgio_header *hdr;
> -
> -       dprintk("%s enter\n", __func__);
> -       task = container_of(work, struct rpc_task, u.tk_work);
> -       hdr = container_of(task, struct nfs_pgio_header, task);
> -
> -       pnfs_ld_write_done(hdr);
> -}
> -
> -void
> -objlayout_write_done(struct objlayout_io_res *oir, ssize_t status, bool sync)
> -{
> -       struct nfs_pgio_header *hdr = oir->rpcdata;
> -
> -       oir->status = hdr->task.tk_status = status;
> -       if (status >= 0) {
> -               hdr->res.count = status;
> -               hdr->verf.committed = oir->committed;
> -       } else {
> -               hdr->pnfs_error = status;
> -       }
> -       objlayout_iodone(oir);
> -       /* must not use oir after this point */
> -
> -       dprintk("%s: Return status %zd committed %d sync=%d\n", __func__,
> -               status, hdr->verf.committed, sync);
> -
> -       if (sync)
> -               pnfs_ld_write_done(hdr);
> -       else {
> -               INIT_WORK(&hdr->task.u.tk_work, _rpc_write_complete);
> -               schedule_work(&hdr->task.u.tk_work);
> -       }
> -}
> -
> -/*
> - * Perform sync or async writes.
> - */
> -enum pnfs_try_status
> -objlayout_write_pagelist(struct nfs_pgio_header *hdr, int how)
> -{
> -       int err;
> -
> -       _fix_verify_io_params(hdr->lseg, &hdr->args.pages,
> -                             &hdr->args.pgbase,
> -                             hdr->args.offset, hdr->args.count);
> -
> -       err = objio_write_pagelist(hdr, how);
> -       if (unlikely(err)) {
> -               hdr->pnfs_error = err;
> -               dprintk("%s: Returned Error %d\n", __func__, err);
> -               return PNFS_NOT_ATTEMPTED;
> -       }
> -       return PNFS_ATTEMPTED;
> -}
> -
> -void
> -objlayout_encode_layoutcommit(struct pnfs_layout_hdr *pnfslay,
> -                             struct xdr_stream *xdr,
> -                             const struct nfs4_layoutcommit_args *args)
> -{
> -       struct objlayout *objlay = OBJLAYOUT(pnfslay);
> -       struct pnfs_osd_layoutupdate lou;
> -       __be32 *start;
> -
> -       dprintk("%s: Begin\n", __func__);
> -
> -       spin_lock(&objlay->lock);
> -       lou.dsu_valid = (objlay->delta_space_valid == OBJ_DSU_VALID);
> -       lou.dsu_delta = objlay->delta_space_used;
> -       objlay->delta_space_used = 0;
> -       objlay->delta_space_valid = OBJ_DSU_INIT;
> -       lou.olu_ioerr_flag = !list_empty(&objlay->err_list);
> -       spin_unlock(&objlay->lock);
> -
> -       start = xdr_reserve_space(xdr, 4);
> -
> -       BUG_ON(pnfs_osd_xdr_encode_layoutupdate(xdr, &lou));
> -
> -       *start = cpu_to_be32((xdr->p - start - 1) * 4);
> -
> -       dprintk("%s: Return delta_space_used %lld err %d\n", __func__,
> -               lou.dsu_delta, lou.olu_ioerr_flag);
> -}
> -
> -static int
> -err_prio(u32 oer_errno)
> -{
> -       switch (oer_errno) {
> -       case 0:
> -               return 0;
> -
> -       case PNFS_OSD_ERR_RESOURCE:
> -               return OSD_ERR_PRI_RESOURCE;
> -       case PNFS_OSD_ERR_BAD_CRED:
> -               return OSD_ERR_PRI_BAD_CRED;
> -       case PNFS_OSD_ERR_NO_ACCESS:
> -               return OSD_ERR_PRI_NO_ACCESS;
> -       case PNFS_OSD_ERR_UNREACHABLE:
> -               return OSD_ERR_PRI_UNREACHABLE;
> -       case PNFS_OSD_ERR_NOT_FOUND:
> -               return OSD_ERR_PRI_NOT_FOUND;
> -       case PNFS_OSD_ERR_NO_SPACE:
> -               return OSD_ERR_PRI_NO_SPACE;
> -       default:
> -               WARN_ON(1);
> -               /* fallthrough */
> -       case PNFS_OSD_ERR_EIO:
> -               return OSD_ERR_PRI_EIO;
> -       }
> -}
> -
> -static void
> -merge_ioerr(struct pnfs_osd_ioerr *dest_err,
> -           const struct pnfs_osd_ioerr *src_err)
> -{
> -       u64 dest_end, src_end;
> -
> -       if (!dest_err->oer_errno) {
> -               *dest_err = *src_err;
> -               /* accumulated device must be blank */
> -               memset(&dest_err->oer_component.oid_device_id, 0,
> -                       sizeof(dest_err->oer_component.oid_device_id));
> -
> -               return;
> -       }
> -
> -       if (dest_err->oer_component.oid_partition_id !=
> -                               src_err->oer_component.oid_partition_id)
> -               dest_err->oer_component.oid_partition_id = 0;
> -
> -       if (dest_err->oer_component.oid_object_id !=
> -                               src_err->oer_component.oid_object_id)
> -               dest_err->oer_component.oid_object_id = 0;
> -
> -       if (dest_err->oer_comp_offset > src_err->oer_comp_offset)
> -               dest_err->oer_comp_offset = src_err->oer_comp_offset;
> -
> -       dest_end = end_offset(dest_err->oer_comp_offset,
> -                             dest_err->oer_comp_length);
> -       src_end =  end_offset(src_err->oer_comp_offset,
> -                             src_err->oer_comp_length);
> -       if (dest_end < src_end)
> -               dest_end = src_end;
> -
> -       dest_err->oer_comp_length = dest_end - dest_err->oer_comp_offset;
> -
> -       if ((src_err->oer_iswrite == dest_err->oer_iswrite) &&
> -           (err_prio(src_err->oer_errno) > err_prio(dest_err->oer_errno))) {
> -                       dest_err->oer_errno = src_err->oer_errno;
> -       } else if (src_err->oer_iswrite) {
> -               dest_err->oer_iswrite = true;
> -               dest_err->oer_errno = src_err->oer_errno;
> -       }
> -}
> -
> -static void
> -encode_accumulated_error(struct objlayout *objlay, __be32 *p)
> -{
> -       struct objlayout_io_res *oir, *tmp;
> -       struct pnfs_osd_ioerr accumulated_err = {.oer_errno = 0};
> -
> -       list_for_each_entry_safe(oir, tmp, &objlay->err_list, err_list) {
> -               unsigned i;
> -
> -               for (i = 0; i < oir->num_comps; i++) {
> -                       struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[i];
> -
> -                       if (!ioerr->oer_errno)
> -                               continue;
> -
> -                       printk(KERN_ERR "NFS: %s: err[%d]: errno=%d "
> -                               "is_write=%d dev(%llx:%llx) par=0x%llx "
> -                               "obj=0x%llx offset=0x%llx length=0x%llx\n",
> -                               __func__, i, ioerr->oer_errno,
> -                               ioerr->oer_iswrite,
> -                               _DEVID_LO(&ioerr->oer_component.oid_device_id),
> -                               _DEVID_HI(&ioerr->oer_component.oid_device_id),
> -                               ioerr->oer_component.oid_partition_id,
> -                               ioerr->oer_component.oid_object_id,
> -                               ioerr->oer_comp_offset,
> -                               ioerr->oer_comp_length);
> -
> -                       merge_ioerr(&accumulated_err, ioerr);
> -               }
> -               list_del(&oir->err_list);
> -               objio_free_result(oir);
> -       }
> -
> -       pnfs_osd_xdr_encode_ioerr(p, &accumulated_err);
> -}
> -
> -void
> -objlayout_encode_layoutreturn(struct xdr_stream *xdr,
> -                             const struct nfs4_layoutreturn_args *args)
> -{
> -       struct pnfs_layout_hdr *pnfslay = args->layout;
> -       struct objlayout *objlay = OBJLAYOUT(pnfslay);
> -       struct objlayout_io_res *oir, *tmp;
> -       __be32 *start;
> -
> -       dprintk("%s: Begin\n", __func__);
> -       start = xdr_reserve_space(xdr, 4);
> -       BUG_ON(!start);
> -
> -       spin_lock(&objlay->lock);
> -
> -       list_for_each_entry_safe(oir, tmp, &objlay->err_list, err_list) {
> -               __be32 *last_xdr = NULL, *p;
> -               unsigned i;
> -               int res = 0;
> -
> -               for (i = 0; i < oir->num_comps; i++) {
> -                       struct pnfs_osd_ioerr *ioerr = &oir->ioerrs[i];
> -
> -                       if (!ioerr->oer_errno)
> -                               continue;
> -
> -                       dprintk("%s: err[%d]: errno=%d is_write=%d "
> -                               "dev(%llx:%llx) par=0x%llx obj=0x%llx "
> -                               "offset=0x%llx length=0x%llx\n",
> -                               __func__, i, ioerr->oer_errno,
> -                               ioerr->oer_iswrite,
> -                               _DEVID_LO(&ioerr->oer_component.oid_device_id),
> -                               _DEVID_HI(&ioerr->oer_component.oid_device_id),
> -                               ioerr->oer_component.oid_partition_id,
> -                               ioerr->oer_component.oid_object_id,
> -                               ioerr->oer_comp_offset,
> -                               ioerr->oer_comp_length);
> -
> -                       p = pnfs_osd_xdr_ioerr_reserve_space(xdr);
> -                       if (unlikely(!p)) {
> -                               res = -E2BIG;
> -                               break; /* accumulated_error */
> -                       }
> -
> -                       last_xdr = p;
> -                       pnfs_osd_xdr_encode_ioerr(p, &oir->ioerrs[i]);
> -               }
> -
> -               /* TODO: use xdr_write_pages */
> -               if (unlikely(res)) {
> -                       /* no space for even one error descriptor */
> -                       BUG_ON(!last_xdr);
> -
> -                       /* we've encountered a situation with lots and lots of
> -                        * errors and no space to encode them all. Use the last
> -                        * available slot to report the union of all the
> -                        * remaining errors.
> -                        */
> -                       encode_accumulated_error(objlay, last_xdr);
> -                       goto loop_done;
> -               }
> -               list_del(&oir->err_list);
> -               objio_free_result(oir);
> -       }
> -loop_done:
> -       spin_unlock(&objlay->lock);
> -
> -       *start = cpu_to_be32((xdr->p - start - 1) * 4);
> -       dprintk("%s: Return\n", __func__);
> -}
> -
> -enum {
> -       OBJLAYOUT_MAX_URI_LEN = 256, OBJLAYOUT_MAX_OSDNAME_LEN = 64,
> -       OBJLAYOUT_MAX_SYSID_HEX_LEN = OSD_SYSTEMID_LEN * 2 + 1,
> -       OSD_LOGIN_UPCALL_PATHLEN  = 256
> -};
> -
> -static char osd_login_prog[OSD_LOGIN_UPCALL_PATHLEN] = "/sbin/osd_login";
> -
> -module_param_string(osd_login_prog, osd_login_prog, sizeof(osd_login_prog),
> -                   0600);
> -MODULE_PARM_DESC(osd_login_prog, "Path to the osd_login upcall program");
> -
> -struct __auto_login {
> -       char uri[OBJLAYOUT_MAX_URI_LEN];
> -       char osdname[OBJLAYOUT_MAX_OSDNAME_LEN];
> -       char systemid_hex[OBJLAYOUT_MAX_SYSID_HEX_LEN];
> -};
> -
> -static int __objlayout_upcall(struct __auto_login *login)
> -{
> -       static char *envp[] = { "HOME=/",
> -               "TERM=linux",
> -               "PATH=/sbin:/usr/sbin:/bin:/usr/bin",
> -               NULL
> -       };
> -       char *argv[8];
> -       int ret;
> -
> -       if (unlikely(!osd_login_prog[0])) {
> -               dprintk("%s: osd_login_prog is disabled\n", __func__);
> -               return -EACCES;
> -       }
> -
> -       dprintk("%s uri: %s\n", __func__, login->uri);
> -       dprintk("%s osdname %s\n", __func__, login->osdname);
> -       dprintk("%s systemid_hex %s\n", __func__, login->systemid_hex);
> -
> -       argv[0] = (char *)osd_login_prog;
> -       argv[1] = "-u";
> -       argv[2] = login->uri;
> -       argv[3] = "-o";
> -       argv[4] = login->osdname;
> -       argv[5] = "-s";
> -       argv[6] = login->systemid_hex;
> -       argv[7] = NULL;
> -
> -       ret = call_usermodehelper(argv[0], argv, envp, UMH_WAIT_PROC);
> -       /*
> -        * Disable the upcall mechanism if we're getting an ENOENT or
> -        * EACCES error. The admin can re-enable it on the fly by using
> -        * sysfs to set the objlayoutdriver.osd_login_prog module parameter once
> -        * the problem has been fixed.
> -        */
> -       if (ret == -ENOENT || ret == -EACCES) {
> -               printk(KERN_ERR "PNFS-OBJ: %s was not found please set "
> -                       "objlayoutdriver.osd_login_prog kernel parameter!\n",
> -                       osd_login_prog);
> -               osd_login_prog[0] = '\0';
> -       }
> -       dprintk("%s %s return value: %d\n", __func__, osd_login_prog, ret);
> -
> -       return ret;
> -}
> -
> -/* Assume dest is all zeros */
> -static void __copy_nfsS_and_zero_terminate(struct nfs4_string s,
> -                                          char *dest, int max_len,
> -                                          const char *var_name)
> -{
> -       if (!s.len)
> -               return;
> -
> -       if (s.len >= max_len) {
> -               pr_warn_ratelimited(
> -                       "objlayout_autologin: %s: s.len(%d) >= max_len(%d)",
> -                       var_name, s.len, max_len);
> -               s.len = max_len - 1; /* space for null terminator */
> -       }
> -
> -       memcpy(dest, s.data, s.len);
> -}
> -
> -/* Assume sysid is all zeros */
> -static void _sysid_2_hex(struct nfs4_string s,
> -                 char sysid[OBJLAYOUT_MAX_SYSID_HEX_LEN])
> -{
> -       int i;
> -       char *cur;
> -
> -       if (!s.len)
> -               return;
> -
> -       if (s.len != OSD_SYSTEMID_LEN) {
> -               pr_warn_ratelimited(
> -                   "objlayout_autologin: systemid_len(%d) != OSD_SYSTEMID_LEN",
> -                   s.len);
> -               if (s.len > OSD_SYSTEMID_LEN)
> -                       s.len = OSD_SYSTEMID_LEN;
> -       }
> -
> -       cur = sysid;
> -       for (i = 0; i < s.len; i++)
> -               cur = hex_byte_pack(cur, s.data[i]);
> -}
> -
> -int objlayout_autologin(struct pnfs_osd_deviceaddr *deviceaddr)
> -{
> -       int rc;
> -       struct __auto_login login;
> -
> -       if (!deviceaddr->oda_targetaddr.ota_netaddr.r_addr.len)
> -               return -ENODEV;
> -
> -       memset(&login, 0, sizeof(login));
> -       __copy_nfsS_and_zero_terminate(
> -               deviceaddr->oda_targetaddr.ota_netaddr.r_addr,
> -               login.uri, sizeof(login.uri), "URI");
> -
> -       __copy_nfsS_and_zero_terminate(
> -               deviceaddr->oda_osdname,
> -               login.osdname, sizeof(login.osdname), "OSDNAME");
> -
> -       _sysid_2_hex(deviceaddr->oda_systemid, login.systemid_hex);
> -
> -       rc = __objlayout_upcall(&login);
> -       if (rc > 0) /* script returns positive values */
> -               rc = -ENODEV;
> -
> -       return rc;
> -}
> diff --git a/fs/nfs/objlayout/objlayout.h b/fs/nfs/objlayout/objlayout.h
> deleted file mode 100644
> index fc94a5872ed4..000000000000
> --- a/fs/nfs/objlayout/objlayout.h
> +++ /dev/null
> @@ -1,183 +0,0 @@
> -/*
> - *  Data types and function declerations for interfacing with the
> - *  pNFS standard object layout driver.
> - *
> - *  Copyright (C) 2007 Panasas Inc. [year of first publication]
> - *  All rights reserved.
> - *
> - *  Benny Halevy <bhalevy@panasas.com>
> - *  Boaz Harrosh <ooo@electrozaur.com>
> - *
> - *  This program is free software; you can redistribute it and/or modify
> - *  it under the terms of the GNU General Public License version 2
> - *  See the file COPYING included with this distribution for more details.
> - *
> - *  Redistribution and use in source and binary forms, with or without
> - *  modification, are permitted provided that the following conditions
> - *  are met:
> - *
> - *  1. Redistributions of source code must retain the above copyright
> - *     notice, this list of conditions and the following disclaimer.
> - *  2. Redistributions in binary form must reproduce the above copyright
> - *     notice, this list of conditions and the following disclaimer in the
> - *     documentation and/or other materials provided with the distribution.
> - *  3. Neither the name of the Panasas company nor the names of its
> - *     contributors may be used to endorse or promote products derived
> - *     from this software without specific prior written permission.
> - *
> - *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> - *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> - *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> - *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> - *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> - *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> - *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> - *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> - *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> - *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> - *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> - */
> -
> -#ifndef _OBJLAYOUT_H
> -#define _OBJLAYOUT_H
> -
> -#include <linux/nfs_fs.h>
> -#include <linux/pnfs_osd_xdr.h>
> -#include "../pnfs.h"
> -
> -/*
> - * per-inode layout
> - */
> -struct objlayout {
> -       struct pnfs_layout_hdr pnfs_layout;
> -
> -        /* for layout_commit */
> -       enum osd_delta_space_valid_enum {
> -               OBJ_DSU_INIT = 0,
> -               OBJ_DSU_VALID,
> -               OBJ_DSU_INVALID,
> -       } delta_space_valid;
> -       s64 delta_space_used;  /* consumed by write ops */
> -
> -        /* for layout_return */
> -       spinlock_t lock;
> -       struct list_head err_list;
> -};
> -
> -static inline struct objlayout *
> -OBJLAYOUT(struct pnfs_layout_hdr *lo)
> -{
> -       return container_of(lo, struct objlayout, pnfs_layout);
> -}
> -
> -/*
> - * per-I/O operation state
> - * embedded in objects provider io_state data structure
> - */
> -struct objlayout_io_res {
> -       struct objlayout *objlay;
> -
> -       void *rpcdata;
> -       int status;             /* res */
> -       int committed;          /* res */
> -
> -       /* Error reporting (layout_return) */
> -       struct list_head err_list;
> -       unsigned num_comps;
> -       /* Pointer to array of error descriptors of size num_comps.
> -        * It should contain as many entries as devices in the osd_layout
> -        * that participate in the I/O. It is up to the io_engine to allocate
> -        * needed space and set num_comps.
> -        */
> -       struct pnfs_osd_ioerr *ioerrs;
> -};
> -
> -static inline
> -void objlayout_init_ioerrs(struct objlayout_io_res *oir, unsigned num_comps,
> -                       struct pnfs_osd_ioerr *ioerrs, void *rpcdata,
> -                       struct pnfs_layout_hdr *pnfs_layout_type)
> -{
> -       oir->objlay = OBJLAYOUT(pnfs_layout_type);
> -       oir->rpcdata = rpcdata;
> -       INIT_LIST_HEAD(&oir->err_list);
> -       oir->num_comps = num_comps;
> -       oir->ioerrs = ioerrs;
> -}
> -
> -/*
> - * Raid engine I/O API
> - */
> -extern int objio_alloc_lseg(struct pnfs_layout_segment **outp,
> -       struct pnfs_layout_hdr *pnfslay,
> -       struct pnfs_layout_range *range,
> -       struct xdr_stream *xdr,
> -       gfp_t gfp_flags);
> -extern void objio_free_lseg(struct pnfs_layout_segment *lseg);
> -
> -/* objio_free_result will free these @oir structs received from
> - * objlayout_{read,write}_done
> - */
> -extern void objio_free_result(struct objlayout_io_res *oir);
> -
> -extern int objio_read_pagelist(struct nfs_pgio_header *rdata);
> -extern int objio_write_pagelist(struct nfs_pgio_header *wdata, int how);
> -
> -/*
> - * callback API
> - */
> -extern void objlayout_io_set_result(struct objlayout_io_res *oir,
> -                       unsigned index, struct pnfs_osd_objid *pooid,
> -                       int osd_error, u64 offset, u64 length, bool is_write);
> -
> -static inline void
> -objlayout_add_delta_space_used(struct objlayout *objlay, s64 space_used)
> -{
> -       /* If one of the I/Os errored out and the delta_space_used was
> -        * invalid we render the complete report as invalid. Protocol mandate
> -        * the DSU be accurate or not reported.
> -        */
> -       spin_lock(&objlay->lock);
> -       if (objlay->delta_space_valid != OBJ_DSU_INVALID) {
> -               objlay->delta_space_valid = OBJ_DSU_VALID;
> -               objlay->delta_space_used += space_used;
> -       }
> -       spin_unlock(&objlay->lock);
> -}
> -
> -extern void objlayout_read_done(struct objlayout_io_res *oir,
> -                               ssize_t status, bool sync);
> -extern void objlayout_write_done(struct objlayout_io_res *oir,
> -                                ssize_t status, bool sync);
> -
> -/*
> - * exported generic objects function vectors
> - */
> -
> -extern struct pnfs_layout_hdr *objlayout_alloc_layout_hdr(struct inode *, gfp_t gfp_flags);
> -extern void objlayout_free_layout_hdr(struct pnfs_layout_hdr *);
> -
> -extern struct pnfs_layout_segment *objlayout_alloc_lseg(
> -       struct pnfs_layout_hdr *,
> -       struct nfs4_layoutget_res *,
> -       gfp_t gfp_flags);
> -extern void objlayout_free_lseg(struct pnfs_layout_segment *);
> -
> -extern enum pnfs_try_status objlayout_read_pagelist(
> -       struct nfs_pgio_header *);
> -
> -extern enum pnfs_try_status objlayout_write_pagelist(
> -       struct nfs_pgio_header *,
> -       int how);
> -
> -extern void objlayout_encode_layoutcommit(
> -       struct pnfs_layout_hdr *,
> -       struct xdr_stream *,
> -       const struct nfs4_layoutcommit_args *);
> -
> -extern void objlayout_encode_layoutreturn(
> -       struct xdr_stream *,
> -       const struct nfs4_layoutreturn_args *);
> -
> -extern int objlayout_autologin(struct pnfs_osd_deviceaddr *deviceaddr);
> -
> -#endif /* _OBJLAYOUT_H */
> diff --git a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c b/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> deleted file mode 100644
> index f093c7ec983b..000000000000
> --- a/fs/nfs/objlayout/pnfs_osd_xdr_cli.c
> +++ /dev/null
> @@ -1,415 +0,0 @@
> -/*
> - *  Object-Based pNFS Layout XDR layer
> - *
> - *  Copyright (C) 2007 Panasas Inc. [year of first publication]
> - *  All rights reserved.
> - *
> - *  Benny Halevy <bhalevy@panasas.com>
> - *  Boaz Harrosh <ooo@electrozaur.com>
> - *
> - *  This program is free software; you can redistribute it and/or modify
> - *  it under the terms of the GNU General Public License version 2
> - *  See the file COPYING included with this distribution for more details.
> - *
> - *  Redistribution and use in source and binary forms, with or without
> - *  modification, are permitted provided that the following conditions
> - *  are met:
> - *
> - *  1. Redistributions of source code must retain the above copyright
> - *     notice, this list of conditions and the following disclaimer.
> - *  2. Redistributions in binary form must reproduce the above copyright
> - *     notice, this list of conditions and the following disclaimer in the
> - *     documentation and/or other materials provided with the distribution.
> - *  3. Neither the name of the Panasas company nor the names of its
> - *     contributors may be used to endorse or promote products derived
> - *     from this software without specific prior written permission.
> - *
> - *  THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESS OR IMPLIED
> - *  WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF
> - *  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
> - *  DISCLAIMED. IN NO EVENT SHALL THE REGENTS OR CONTRIBUTORS BE LIABLE
> - *  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
> - *  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
> - *  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
> - *  BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
> - *  LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
> - *  NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
> - *  SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
> - */
> -
> -#include <linux/pnfs_osd_xdr.h>
> -
> -#define NFSDBG_FACILITY         NFSDBG_PNFS_LD
> -
> -/*
> - * The following implementation is based on RFC5664
> - */
> -
> -/*
> - * struct pnfs_osd_objid {
> - *     struct nfs4_deviceid    oid_device_id;
> - *     u64                     oid_partition_id;
> - *     u64                     oid_object_id;
> - * }; // xdr size 32 bytes
> - */
> -static __be32 *
> -_osd_xdr_decode_objid(__be32 *p, struct pnfs_osd_objid *objid)
> -{
> -       p = xdr_decode_opaque_fixed(p, objid->oid_device_id.data,
> -                                   sizeof(objid->oid_device_id.data));
> -
> -       p = xdr_decode_hyper(p, &objid->oid_partition_id);
> -       p = xdr_decode_hyper(p, &objid->oid_object_id);
> -       return p;
> -}
> -/*
> - * struct pnfs_osd_opaque_cred {
> - *     u32 cred_len;
> - *     void *cred;
> - * }; // xdr size [variable]
> - * The return pointers are from the xdr buffer
> - */
> -static int
> -_osd_xdr_decode_opaque_cred(struct pnfs_osd_opaque_cred *opaque_cred,
> -                           struct xdr_stream *xdr)
> -{
> -       __be32 *p = xdr_inline_decode(xdr, 1);
> -
> -       if (!p)
> -               return -EINVAL;
> -
> -       opaque_cred->cred_len = be32_to_cpu(*p++);
> -
> -       p = xdr_inline_decode(xdr, opaque_cred->cred_len);
> -       if (!p)
> -               return -EINVAL;
> -
> -       opaque_cred->cred = p;
> -       return 0;
> -}
> -
> -/*
> - * struct pnfs_osd_object_cred {
> - *     struct pnfs_osd_objid           oc_object_id;
> - *     u32                             oc_osd_version;
> - *     u32                             oc_cap_key_sec;
> - *     struct pnfs_osd_opaque_cred     oc_cap_key
> - *     struct pnfs_osd_opaque_cred     oc_cap;
> - * }; // xdr size 32 + 4 + 4 + [variable] + [variable]
> - */
> -static int
> -_osd_xdr_decode_object_cred(struct pnfs_osd_object_cred *comp,
> -                           struct xdr_stream *xdr)
> -{
> -       __be32 *p = xdr_inline_decode(xdr, 32 + 4 + 4);
> -       int ret;
> -
> -       if (!p)
> -               return -EIO;
> -
> -       p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
> -       comp->oc_osd_version = be32_to_cpup(p++);
> -       comp->oc_cap_key_sec = be32_to_cpup(p);
> -
> -       ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap_key, xdr);
> -       if (unlikely(ret))
> -               return ret;
> -
> -       ret = _osd_xdr_decode_opaque_cred(&comp->oc_cap, xdr);
> -       return ret;
> -}
> -
> -/*
> - * struct pnfs_osd_data_map {
> - *     u32     odm_num_comps;
> - *     u64     odm_stripe_unit;
> - *     u32     odm_group_width;
> - *     u32     odm_group_depth;
> - *     u32     odm_mirror_cnt;
> - *     u32     odm_raid_algorithm;
> - * }; // xdr size 4 + 8 + 4 + 4 + 4 + 4
> - */
> -static inline int
> -_osd_data_map_xdr_sz(void)
> -{
> -       return 4 + 8 + 4 + 4 + 4 + 4;
> -}
> -
> -static __be32 *
> -_osd_xdr_decode_data_map(__be32 *p, struct pnfs_osd_data_map *data_map)
> -{
> -       data_map->odm_num_comps = be32_to_cpup(p++);
> -       p = xdr_decode_hyper(p, &data_map->odm_stripe_unit);
> -       data_map->odm_group_width = be32_to_cpup(p++);
> -       data_map->odm_group_depth = be32_to_cpup(p++);
> -       data_map->odm_mirror_cnt = be32_to_cpup(p++);
> -       data_map->odm_raid_algorithm = be32_to_cpup(p++);
> -       dprintk("%s: odm_num_comps=%u odm_stripe_unit=%llu odm_group_width=%u "
> -               "odm_group_depth=%u odm_mirror_cnt=%u odm_raid_algorithm=%u\n",
> -               __func__,
> -               data_map->odm_num_comps,
> -               (unsigned long long)data_map->odm_stripe_unit,
> -               data_map->odm_group_width,
> -               data_map->odm_group_depth,
> -               data_map->odm_mirror_cnt,
> -               data_map->odm_raid_algorithm);
> -       return p;
> -}
> -
> -int pnfs_osd_xdr_decode_layout_map(struct pnfs_osd_layout *layout,
> -       struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr)
> -{
> -       __be32 *p;
> -
> -       memset(iter, 0, sizeof(*iter));
> -
> -       p = xdr_inline_decode(xdr, _osd_data_map_xdr_sz() + 4 + 4);
> -       if (unlikely(!p))
> -               return -EINVAL;
> -
> -       p = _osd_xdr_decode_data_map(p, &layout->olo_map);
> -       layout->olo_comps_index = be32_to_cpup(p++);
> -       layout->olo_num_comps = be32_to_cpup(p++);
> -       dprintk("%s: olo_comps_index=%d olo_num_comps=%d\n", __func__,
> -               layout->olo_comps_index, layout->olo_num_comps);
> -
> -       iter->total_comps = layout->olo_num_comps;
> -       return 0;
> -}
> -
> -bool pnfs_osd_xdr_decode_layout_comp(struct pnfs_osd_object_cred *comp,
> -       struct pnfs_osd_xdr_decode_layout_iter *iter, struct xdr_stream *xdr,
> -       int *err)
> -{
> -       BUG_ON(iter->decoded_comps > iter->total_comps);
> -       if (iter->decoded_comps == iter->total_comps)
> -               return false;
> -
> -       *err = _osd_xdr_decode_object_cred(comp, xdr);
> -       if (unlikely(*err)) {
> -               dprintk("%s: _osd_xdr_decode_object_cred=>%d decoded_comps=%d "
> -                       "total_comps=%d\n", __func__, *err,
> -                       iter->decoded_comps, iter->total_comps);
> -               return false; /* stop the loop */
> -       }
> -       dprintk("%s: dev(%llx:%llx) par=0x%llx obj=0x%llx "
> -               "key_len=%u cap_len=%u\n",
> -               __func__,
> -               _DEVID_LO(&comp->oc_object_id.oid_device_id),
> -               _DEVID_HI(&comp->oc_object_id.oid_device_id),
> -               comp->oc_object_id.oid_partition_id,
> -               comp->oc_object_id.oid_object_id,
> -               comp->oc_cap_key.cred_len, comp->oc_cap.cred_len);
> -
> -       iter->decoded_comps++;
> -       return true;
> -}
> -
> -/*
> - * Get Device Information Decoding
> - *
> - * Note: since Device Information is currently done synchronously, all
> - *       variable strings fields are left inside the rpc buffer and are only
> - *       pointed to by the pnfs_osd_deviceaddr members. So the read buffer
> - *       should not be freed while the returned information is in use.
> - */
> -/*
> - *struct nfs4_string {
> - *     unsigned int len;
> - *     char *data;
> - *}; // size [variable]
> - * NOTE: Returned string points to inside the XDR buffer
> - */
> -static __be32 *
> -__read_u8_opaque(__be32 *p, struct nfs4_string *str)
> -{
> -       str->len = be32_to_cpup(p++);
> -       str->data = (char *)p;
> -
> -       p += XDR_QUADLEN(str->len);
> -       return p;
> -}
> -
> -/*
> - * struct pnfs_osd_targetid {
> - *     u32                     oti_type;
> - *     struct nfs4_string      oti_scsi_device_id;
> - * };// size 4 + [variable]
> - */
> -static __be32 *
> -__read_targetid(__be32 *p, struct pnfs_osd_targetid* targetid)
> -{
> -       u32 oti_type;
> -
> -       oti_type = be32_to_cpup(p++);
> -       targetid->oti_type = oti_type;
> -
> -       switch (oti_type) {
> -       case OBJ_TARGET_SCSI_NAME:
> -       case OBJ_TARGET_SCSI_DEVICE_ID:
> -               p = __read_u8_opaque(p, &targetid->oti_scsi_device_id);
> -       }
> -
> -       return p;
> -}
> -
> -/*
> - * struct pnfs_osd_net_addr {
> - *     struct nfs4_string      r_netid;
> - *     struct nfs4_string      r_addr;
> - * };
> - */
> -static __be32 *
> -__read_net_addr(__be32 *p, struct pnfs_osd_net_addr* netaddr)
> -{
> -       p = __read_u8_opaque(p, &netaddr->r_netid);
> -       p = __read_u8_opaque(p, &netaddr->r_addr);
> -
> -       return p;
> -}
> -
> -/*
> - * struct pnfs_osd_targetaddr {
> - *     u32                             ota_available;
> - *     struct pnfs_osd_net_addr        ota_netaddr;
> - * };
> - */
> -static __be32 *
> -__read_targetaddr(__be32 *p, struct pnfs_osd_targetaddr *targetaddr)
> -{
> -       u32 ota_available;
> -
> -       ota_available = be32_to_cpup(p++);
> -       targetaddr->ota_available = ota_available;
> -
> -       if (ota_available)
> -               p = __read_net_addr(p, &targetaddr->ota_netaddr);
> -
> -
> -       return p;
> -}
> -
> -/*
> - * struct pnfs_osd_deviceaddr {
> - *     struct pnfs_osd_targetid        oda_targetid;
> - *     struct pnfs_osd_targetaddr      oda_targetaddr;
> - *     u8                              oda_lun[8];
> - *     struct nfs4_string              oda_systemid;
> - *     struct pnfs_osd_object_cred     oda_root_obj_cred;
> - *     struct nfs4_string              oda_osdname;
> - * };
> - */
> -
> -/* We need this version for the pnfs_osd_xdr_decode_deviceaddr which does
> - * not have an xdr_stream
> - */
> -static __be32 *
> -__read_opaque_cred(__be32 *p,
> -                             struct pnfs_osd_opaque_cred *opaque_cred)
> -{
> -       opaque_cred->cred_len = be32_to_cpu(*p++);
> -       opaque_cred->cred = p;
> -       return p + XDR_QUADLEN(opaque_cred->cred_len);
> -}
> -
> -static __be32 *
> -__read_object_cred(__be32 *p, struct pnfs_osd_object_cred *comp)
> -{
> -       p = _osd_xdr_decode_objid(p, &comp->oc_object_id);
> -       comp->oc_osd_version = be32_to_cpup(p++);
> -       comp->oc_cap_key_sec = be32_to_cpup(p++);
> -
> -       p = __read_opaque_cred(p, &comp->oc_cap_key);
> -       p = __read_opaque_cred(p, &comp->oc_cap);
> -       return p;
> -}
> -
> -void pnfs_osd_xdr_decode_deviceaddr(
> -       struct pnfs_osd_deviceaddr *deviceaddr, __be32 *p)
> -{
> -       p = __read_targetid(p, &deviceaddr->oda_targetid);
> -
> -       p = __read_targetaddr(p, &deviceaddr->oda_targetaddr);
> -
> -       p = xdr_decode_opaque_fixed(p, deviceaddr->oda_lun,
> -                                   sizeof(deviceaddr->oda_lun));
> -
> -       p = __read_u8_opaque(p, &deviceaddr->oda_systemid);
> -
> -       p = __read_object_cred(p, &deviceaddr->oda_root_obj_cred);
> -
> -       p = __read_u8_opaque(p, &deviceaddr->oda_osdname);
> -
> -       /* libosd likes this terminated in dbg. It's last, so no problems */
> -       deviceaddr->oda_osdname.data[deviceaddr->oda_osdname.len] = 0;
> -}
> -
> -/*
> - * struct pnfs_osd_layoutupdate {
> - *     u32     dsu_valid;
> - *     s64     dsu_delta;
> - *     u32     olu_ioerr_flag;
> - * }; xdr size 4 + 8 + 4
> - */
> -int
> -pnfs_osd_xdr_encode_layoutupdate(struct xdr_stream *xdr,
> -                                struct pnfs_osd_layoutupdate *lou)
> -{
> -       __be32 *p = xdr_reserve_space(xdr,  4 + 8 + 4);
> -
> -       if (!p)
> -               return -E2BIG;
> -
> -       *p++ = cpu_to_be32(lou->dsu_valid);
> -       if (lou->dsu_valid)
> -               p = xdr_encode_hyper(p, lou->dsu_delta);
> -       *p++ = cpu_to_be32(lou->olu_ioerr_flag);
> -       return 0;
> -}
> -
> -/*
> - * struct pnfs_osd_objid {
> - *     struct nfs4_deviceid    oid_device_id;
> - *     u64                     oid_partition_id;
> - *     u64                     oid_object_id;
> - * }; // xdr size 32 bytes
> - */
> -static inline __be32 *
> -pnfs_osd_xdr_encode_objid(__be32 *p, struct pnfs_osd_objid *object_id)
> -{
> -       p = xdr_encode_opaque_fixed(p, &object_id->oid_device_id.data,
> -                                   sizeof(object_id->oid_device_id.data));
> -       p = xdr_encode_hyper(p, object_id->oid_partition_id);
> -       p = xdr_encode_hyper(p, object_id->oid_object_id);
> -
> -       return p;
> -}
> -
> -/*
> - * struct pnfs_osd_ioerr {
> - *     struct pnfs_osd_objid   oer_component;
> - *     u64                     oer_comp_offset;
> - *     u64                     oer_comp_length;
> - *     u32                     oer_iswrite;
> - *     u32                     oer_errno;
> - * }; // xdr size 32 + 24 bytes
> - */
> -void pnfs_osd_xdr_encode_ioerr(__be32 *p, struct pnfs_osd_ioerr *ioerr)
> -{
> -       p = pnfs_osd_xdr_encode_objid(p, &ioerr->oer_component);
> -       p = xdr_encode_hyper(p, ioerr->oer_comp_offset);
> -       p = xdr_encode_hyper(p, ioerr->oer_comp_length);
> -       *p++ = cpu_to_be32(ioerr->oer_iswrite);
> -       *p   = cpu_to_be32(ioerr->oer_errno);
> -}
> -
> -__be32 *pnfs_osd_xdr_ioerr_reserve_space(struct xdr_stream *xdr)
> -{
> -       __be32 *p;
> -
> -       p = xdr_reserve_space(xdr, 32 + 24);
> -       if (unlikely(!p))
> -               dprintk("%s: out of xdr space\n", __func__);
> -
> -       return p;
> -}
> --
> 2.11.0
>
