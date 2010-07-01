Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:39051 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754612Ab0GAS5H (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:57:07 -0400
Received: by wwb24 with SMTP id 24so193544wwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jul 2010 11:57:05 -0700 (PDT)
Message-ID: <4C2CE4FC.8030004@panasas.com>
Date: Thu, 01 Jul 2010 21:57:00 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.34-2010-07-01
References: <4BD9BF01.2000508@panasas.com> <4BE330E6.70707@panasas.com> <4BE3315C.9090908@panasas.com> <4BF1AAFC.7000308@panasas.com>
In-Reply-To: <4BF1AAFC.7000308@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the list of patches that went into the pnfs-all-2.6.34 branch as of 2010-07-01
since last update (pnfs-all-2.6.34-2010-05-17)

As usual, cumulative patches against the mainline kernel can be
generated via http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

pnfs-all-2.6.34:
  Benny Halevy     66e57bb pnfs: get open context from nfs_page in pnfs_commit
  Benny Halevy     e04e8ec SQUASHME: pnfs-block: nfs4_blk_add_block_disk ret must be signed
  Benny Halevy     a604747 SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
  Benny Halevy     e79eea9 SQUASHME: pnfs-submit: fix possible leak in nfs4_pnfs_ds_create
  Benny Halevy     c9bc804 pnfs-submit: prevent buffer overrun in decode_and_add_ds
  Andy Adamson     8a9844c pnfs-submit: remove struct nfs_server from stack
  Boaz Harrosh     4b85c27 pnfsd-exofs: Fix exofs_inode_recall_layout() sending 2 recalls
  Benny Halevy     a2ad195 pnfs-obj: use NFSDBG_PNFS_LD also in pnfs_osd_xdr_cli.c
  Boaz Harrosh     89b2bc5 move objlayout to the PNFS_LD dprint channel
  Benny Halevy     6abc85e spnfs-block: kfree(res) in bl_pipe_downcall error path
  Benny Halevy     1020447 pnfsd: fix pointer dereference in dprintk of write verifiers
  Benny Halevy     3d81dc8 pnfsd: reset status on NFS4ERR_NOMATCHING_LAYOUT
  Benny Halevy     12b5063 pnfsd: move kfree of the cb_device rpc_args to release time
  Benny Halevy     d20319d pnfsd: move kfree of the cb_layout rpc_args to release time
  Benny Halevy     12f11b7 FIXME: pnfsd: do not expire client on cb_layout error.
  Boaz Harrosh     76fcb35 pnfsd: Support for cb_layout returning NFS4ERR_DELAY
  Benny Halevy     9a3b60d pnfsd: fix error handling for s_pnfs_op->get_device_info
  Benny Halevy     81d3a84 pnfsd-files: nfsd4_pnfs_dlm_shutdown should use list_for_each_entry_safe
  Benny Halevy     7582d4e pnfsd-files: verify_stateid's return status is __be32
  Benny Halevy     17659ad pnfsd-files: prevent NULL deref in nfsd4_pnfs_dlm_getdevinfo
  Eric Anderle     a3b5760 pnfsd: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()
  Eric Anderle     6d2b022 pnfsd: Add IP address validation to nfsd4_set_pnfs_dlm_device()
  Andy Adamson     9f133db pnfsd: fix dlm device naming
  Boaz Harrosh     cfa67a7 nfsd41: Fix a crash when a callback is retried
  Benny Halevy     97d791f nfsd41: setup backchannel in create_session also in session reestablishment
  Benny Halevy     87237ef DEBUG: pnfs: turn BUG_ONs in pnfs_destroy_inode to WARN_ONs
  Andy Adamson     58f4a6e pnfs: move layoutcommit to nfs_write_inode
  Andy Adamson     de0aee1 pnfs: remove ifdef around layoutcommit_needed
  Andy Adamson     f000c40 pnfs: handle async layoutcommit errors
  Andy Adamson     6513daa pnfs: cleanup layoutcommit call
  Boaz Harrosh     b529d19 panfs_shim: Prints on Errors
  Benny Halevy     36b51a9 SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
  Boaz Harrosh     b6c10f9 SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
  Tao Guo          6f62de5 SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit
  Ricardo Labiaga  887a9a5 pnfs-submit: Dynamically load the nfslayoutdriver
  Ricardo Labiaga  56fab5a SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
  Tao Guo          29d2037 SQUASHME: pnfs-submit: call layoutcommit after flushing inode's data to disk.
  Andy Adamson     fe990bd SQUASHME: pnfs-submit: replace layoutcommit_ctx with rpc_cred
  Benny Halevy     4c7381c SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES
  J. Bruce Fields  4fb8130 SQUASHME: nfsd4: fix cb_recall encoding
  Eric Anderle     99882b9 SQUASHME: pnfsd: fix test in nfsd4_find_pnfs_dlm_device
  Eric Anderle     abab4a7 pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
  Benny Halevy     0cc2897 SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES
  Ricardo Labiaga  465a7ff SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
