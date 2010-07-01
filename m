Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:64579 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757947Ab0GASkN (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 1 Jul 2010 14:40:13 -0400
Received: by wwb24 with SMTP id 24so185645wwb.1
        for <linux-nfs@vger.kernel.org>; Thu, 01 Jul 2010 11:40:12 -0700 (PDT)
Message-ID: <4C2CE107.3080406@panasas.com>
Date: Thu, 01 Jul 2010 21:40:07 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.35-rc3-2010-07-01
References: <4C111B9C.3080603@panasas.com> <4C1A4F0E.5070406@panasas.com>
In-Reply-To: <4C1A4F0E.5070406@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's the list of patches that went into the latest linux-pnfs tree as of 2010-07-01
since last update (pnfs-all-2.6.35-rc2-2010-06-17)

As usual, cumulative patches against the mainline kernel can be
generated via http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

nfsd-upstream:
  Boaz Harrosh     b9598af SQUASHME: nfsd41: Fix a crash when a callback is retried

nfs-upstream:
  Benny Halevy     a1c6087 nfs: fix possible leak in nfs_proc_symlink
  Trond Myklebust  1308c3f NFSv4: Ensure that /proc/self/mountinfo displays the minor version number

nfs41-all:
  Benny Halevy     20265c2 i915_dma Bug #16247

pnfs-submit:
  Benny Halevy     f88044b SQUASHME: pnfs-submit: __wait no longer used by _pnfs_update_layout
  Benny Halevy     397af9d SQUASHME: pnfs-submit: fix possible leak in nfs4_pnfs_ds_create
  Benny Halevy     970b309 SAUASHME: pnfs-submit: prevent buffer overrun in decode_and_add_ds
  Andy Adamson     4ae3ac5 SQUASHME pnfs-submit: remove struct nfs_server from stack
  Andy Adamson     fcc6499 SQUASHME: pnfs-submit: don't re-initialize i_lock
  Andy Adamson     f83fa38 SQUASHME pnfs-submit: add error handlers to layout get
  Andy Adamson     14e9066 SQUASHME pnfs-submit: handle assassinated layoutcommit
  Andy Adamson     2a1ef93 SQUASHME pnfs-submit: add error handling to layout return
  Andy Adamson     cbae7a5 SQUASHME pnfs-submit: remove encode_layoutreturn
  Andy Adamson     761f452 SQUASHME pnfs-submit: pnfs_try_to_read, write, commit using freed memory
  Andy Adamson     56a98e8 SQUASHME: pnfs-submit remove unused filelayout_mount_type
  Fred Isaman      fcbaa5e pnfs-submit: remove list_empty check from put_layout

pnfs:
  Benny Halevy     5157ed0 SQUASHME: pnfs: check for read_buf error in decode_pnfs_layoutrecall_args
  Andy Adamson     5637fa1 pnfs-post-submit: restore encode_layoutreturn

pnfs-block:
  Benny Halevy     5d459a3 SQUASHME: pnfs-block: nfs4_blk_add_block_disk ret must be signed

pnfsd-files:
  Benny Halevy     e840874 SQUASHME: pnfsd-files: nfsd4_pnfs_dlm_shutdown should use list_for_each_entry_safe
  Benny Halevy     a9fb462 SQUASHME: pnfsd-files: verify_stateid's return status is __be32
  Benny Halevy     3895976 SQUASHME: pnfsd-files: prevent NULL deref in nfsd4_pnfs_dlm_getdevinfo
  Eric Anderle     805dec2 pnfsd: Fix num_ds bug in nfsd4_set_pnfs_dlm_device()

pnfsd:
  Boaz Harrosh     259e31d SQUASHME: pnfsd: into [SQUASHME: pnfsd: Support for cb_layout returning NFS4ERR_DELAY]
  Benny Halevy     bf5656c SQUASHME: pnfsd: fix pointer dereference in dprintk of write verifiers
  Benny Halevy     263355c pnfsd: reset status on NFS4ERR_NOMATCHING_LAYOUT
  Benny Halevy     50debee SQUASHME: pnfsd: move kfree of the cb_device rpc_args to release time
  Benny Halevy     bc3b006 SQUASHME: pnfsd: move kfree of the cb_layout rpc_args to release time

spnfs-block:
  Benny Halevy     8b047ca SQUASHME: spnfs-block: kfree(res) in bl_pipe_downcall error path

pnfs-obj-all:
  Benny Halevy     8ef6e62 SQUASHME: pnfs-obj: use NFSDBG_PNFS_LD also in pnfs_osd_xdr_cli.c

pnfs-exofs-all:
  Boaz Harrosh     7cc0c0e SQUASHME: pnfsd-exofs: Fix exofs_inode_recall_layout() sending 2 recalls
