Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:42528 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754241Ab1F1H51 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 28 Jun 2011 03:57:27 -0400
Received: by iwn6 with SMTP id 6so4757775iwn.19
        for <linux-nfs@vger.kernel.org>; Tue, 28 Jun 2011 00:57:26 -0700 (PDT)
Message-ID: <4E09895B.6050609@tonian.com>
Date: Tue, 28 Jun 2011 10:57:15 +0300
From: Benny Halevy <bhalevy@tonian.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-3.0-rc5-2011-06-28
References: <4DED231D.8070304@panasas.com>
In-Reply-To: <4DED231D.8070304@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
To: unlisted-recipients:; (no To-header on input)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I pulled Linus' v3.0-rc5 that contains Trond's bugfixes and
released pnfs-all-3.0-rc5-2011-06-28.

The tree is available on
git://linux-nfs.org/~bhalevy/linux-pnfs.git

Patches since last update (pnfs-all-3.0-rc1-2011-06-06):

nfs-bugfixes:
  Boaz Harrosh     7fdf6e0 pnfs: write: Set mds_offset in the generic layer - it is needed by all LDs

nfs-devel:
  Trond Myklebust  b0a0cc3 NFS: Cleanup of the nfs_pageio code in preparation for a pnfs bugfix
  Trond Myklebust  a2b9b3e NFSv4.1: Add an initialisation callback for pNFS
  Trond Myklebust  580d52d NFSv4.1: Fall back to ordinary i/o through the mds if we have no layout segment
  Trond Myklebust  3ed5c09 NFSv4.1: Clean ups for the device id cache
  Andy Adamson     85eb3db NFSv4.1: File layout only supports whole file layouts
  Boaz Harrosh     5506fb4 pnfs-obj: pnfs_osd_xdr: Remove dead code and cleanup
  Trond Myklebust  c16ff80 NFSv4.1: Clean up layoutreturn
  Andy Adamson     77d7303 NFSv4.1: do not use deviceids after MDS clientid invalidation

pnfs-block:
  Andy Adamson     d44424c pnfs: GETDEVICELIST
  Benny Halevy     5aadbbf pnfs: add set-clear layoutdriver interface
  Peng Tao         9658e75 pnfs: let layoutcommit code handle multiple segments
  Fred Isaman      e0a6e87 pnfsblock: define PNFS_BLOCK Kconfig option
  Fred Isaman      2398e9d pnfsblock: blocklayout stub
  Fred Isaman      14525a0 pnfsblock: layout alloc and free
  Fred Isaman      4239a88 pnfsblock: add support for simple rpc pipefs
  Jim Rees         c626870 pnfsblock: add block device discovery pipe
  Fred Isaman      038f33e pnfsblock: basic extent code
  Jim Rees         d414274 pnfsblock: add device operations
  Jim Rees         1a0a32f pnfsblock: remove device operations
  Fred Isaman      0258101 pnfsblock: lseg alloc and free
  Fred Isaman      46d3afe pnfsblock: merge extents
  Fred Isaman      7b3f776 pnfsblock: call and parse getdevicelist
  Fred Isaman      4da9dc3 pnfsblock: allow use of PG_owner_priv_1 flag
  Fred Isaman      640aa16 pnfsblock: xdr decode pnfs_block_layout4
  Fred             afed114 pnfsblock: find_get_extent
  Fred Isaman      c14a6e4 pnfsblock: SPLITME: add extent manipulation functions
  Fred Isaman      c69c46c pnfsblock: merge rw extents
  Fred Isaman      281a01a pnfsblock: encode_layoutcommit
  Fred Isaman      368dd9d pnfsblock: cleanup_layoutcommit
  Fred Isaman      3f1e3ad pnfsblock: bl_read_pagelist
  Fred Isaman      8176681 pnfsblock: write_begin
  Fred Isaman      15d8ba3 pnfsblock: write_end
  Fred Isaman      4a8f678 pnfsblock: write_end_cleanup
  Fred Isaman      ecbf836 pnfsblock: bl_write_pagelist support functions
  Fred Isaman      5211d5d pnfsblock: bl_write_pagelist
  Fred Isaman      6c4d441 pnfsblock: note written INVAL areas for layoutcommit
  Zhang Jingwang   daced34 pnfsblock: Implement release_inval_marks
  Peng Tao         8ce66ea pnfsblock DEVONLY: Add configurable prefetch size for layoutget
  Benny Halevy     86ebf6c SQUASHME: pnfs-block: use pageio_ops api
  Boaz Harrosh     030ca3a SQUASHME pnfs-blocks: mds_offset is set in the generic layer
  Benny Halevy     251bbaf SQUASHME: pnfs-block: undo list_for_each_entry_reverse in pnfs_find_lseg

panlayout:
  Benny Halevy     603e8b8 SQUASHME: panlayout: convert to new pg_test api

nfsd-upstream:
  Benny Halevy     390cca1 NFSD: allow OP_DESTROY_CLIENTID to be only op in COMPOUND

pnfsd-exofs:
  Boaz Harrosh     9b1ded1 nfs_xdr: Move nfs4_string definition out of #ifdef CONFIG_NFS_V4
  Boaz Harrosh     7066137 exofs: pnfs-tree: Remove pnfs-osd private definitions
  Boaz Harrosh     90ff4c8 pnfsd-exofs: pnfs objects server XDR functions
  Boaz Harrosh     03bc6ea pnfsd-exofs: Add pNFS export support
  Boaz Harrosh     703e6f5 pnfsd-exofs: get_device_info implementation.
  Boaz Harrosh     f33e03b pnfsd-exofs: Recall layouts on truncate
  Boaz Harrosh     333c0bb pnfsd-exofs: layoutreturn pnfs-obj information decoding

pnfsd-lexp:
  Benny Halevy     d6bef57 SQUASHME: pnfsd: add a locked version of nfsd_layout_recall_cb
  Benny Halevy     085622a SQUASHME: pnfsd-lexp: return only nfs4errs from pnfsd_lexp_layout_get
  Benny Halevy     3ed4092 DEVONLY: pnfsd: debug nfs4_lock_state
  Benny Halevy     819a1b5 FIXME: pnfsd-lexp: cannot block in pnfsd_lexp_recall_layout
  Benny Halevy     2ad2382 SQUASHME: pnfsd-lexp: find_file may fail in pnfsd_lexp_recall_layout

spnfs-block:
  Benny Halevy     26ef89d SQUASHME: pnfsd: add a locked version of nfsd_layout_recall_cb

