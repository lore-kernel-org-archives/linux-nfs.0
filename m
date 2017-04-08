Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:26184 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751995AbdDHSiS (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Sat, 8 Apr 2017 14:38:18 -0400
Date: Sat, 8 Apr 2017 21:37:09 +0300
From: Dan Carpenter <dan.carpenter@oracle.com>
To: andros@netapp.com
Cc: linux-nfs@vger.kernel.org
Subject: [bug report] NFS filelayout:call GETDEVICEINFO after
 pnfs_layout_process completes
Message-ID: <20170408182846.GA8017@mwanda>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hello Andy Adamson,

The patch 8d40b0f14846: "NFS filelayout:call GETDEVICEINFO after
pnfs_layout_process completes" from Mar 20, 2017, leads to the
following static checker warning:

	fs/nfs/filelayout/filelayout.c:951 filelayout_pg_init_read()
	warn: 'pgio->pg_lseg' is an error pointer or valid

fs/nfs/filelayout/filelayout.c
   899  static struct pnfs_layout_segment *
   900  fl_pnfs_update_layout(struct inode *ino,
   901                        struct nfs_open_context *ctx,
   902                        loff_t pos,
   903                        u64 count,
   904                        enum pnfs_iomode iomode,
   905                        bool strict_iomode,
   906                        gfp_t gfp_flags)
   907  {
   908          struct pnfs_layout_segment *lseg = NULL;
                                            ^^^^^^^^^^^
This initialization is not needed and misleading in a way because we
never return NULLs.


   909          struct pnfs_layout_hdr *lo;
   910          struct nfs4_filelayout_segment *fl;
   911          int status;
   912  
   913          lseg = pnfs_update_layout(ino, ctx, pos, count, iomode, strict_iomode,
   914                                    gfp_flags);
   915          if (!lseg)
   916                  lseg = ERR_PTR(-ENOMEM);
   917          if (IS_ERR(lseg))
   918                  goto out;
   919  
   920          lo = NFS_I(ino)->layout;
   921          fl = FILELAYOUT_LSEG(lseg);
   922  
   923          status = filelayout_check_deviceid(lo, fl, gfp_flags);
   924          if (status)
   925                  lseg = ERR_PTR(status);
   926  out:
   927          if (IS_ERR(lseg))
   928                  pnfs_put_lseg(lseg);
                        ^^^^^^^^^^^^^^^^^^^
Passing an error pointer here will Oops.  Not sure what was intended.

   929          return lseg;
   930  }
   931  
   932  static void
   933  filelayout_pg_init_read(struct nfs_pageio_descriptor *pgio,
   934                          struct nfs_page *req)
   935  {
   936          if (!pgio->pg_lseg) {
   937                  pgio->pg_lseg = fl_pnfs_update_layout(pgio->pg_inode,
   938                                                        req->wb_context,
   939                                                        0,
   940                                                        NFS4_MAX_UINT64,
   941                                                        IOMODE_READ,
   942                                                        false,
   943                                                        GFP_KERNEL);
   944                  if (IS_ERR(pgio->pg_lseg)) {
   945                          pgio->pg_error = PTR_ERR(pgio->pg_lseg);
   946                          pgio->pg_lseg = NULL;
   947                          return;
   948                  }
   949          }
   950          /* If no lseg, fall back to read through mds */
   951          if (pgio->pg_lseg == NULL)
                    ^^^^^^^^^^^^^^^^^^^^^
This is not possible.

   952                  nfs_pageio_reset_read_mds(pgio);
   953  }

regards,
dan carpenter
