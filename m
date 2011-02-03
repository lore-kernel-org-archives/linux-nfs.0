Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:31025 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751479Ab1BCUbq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 3 Feb 2011 15:31:46 -0500
Message-ID: <4D4B10B0.2040500@panasas.com>
Date: Thu, 03 Feb 2011 22:31:44 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.38-rc3-2011-02-03
References: <4D41D711.70807@panasas.com>
In-Reply-To: <4D41D711.70807@panasas.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I rebased the pnfs tree onto 2.6.38-rc3, with Fred's lock inversion fix in place
and Andy's reordering of pnfs-submit for wave3 and wave4.
pnfs-all-latest tip is tagged as pnfs-all-2.6.38-rc3-2011-02-03

Note: spnfs-block is currently broken due to the fallocate() API change.

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.38-rc3 pnfs-all-2.6.38-rc3-2011-02-03

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

A new branch, pnfs-submit-wave3 points at wave3 candidate patches
and pnfs-submit points at current wave4 patches.

pnfs-submit-wave3:
  Fred Isaman      1786469 pnfs-submit: wave3: lseg refcounting
  The pNFS Team    6d48359 pnfs_submit: add data server session to nfs4_setup_sequence
  The pNFS Team    3dec9b6 pnfs_submit: update nfs4_async_handle_error for data server
  The pNFS Team    9390f23 pnfs_submit: update state renewal for data servers
  Andy Adamson     790dbeb pnfs_submit: wave3 pageio-helpers
  Andy Adamson     54583dc pnfs_submit: wave3 associate layout segment with nfs_page
  The pNFS Team    c85562c pnfs_submit: filelayout policy operations
  The pNFS Team    a5437b7 pnfs_submit: filelayout i/o helpers
  Andy Adamson     bca89961 pnfs_submit: wave3 generic read
  The pNFS Team    a9c9c75 pnfs_submit: filelayout read
  The pNFS Team    60882f9 pnfs_submit: increase NFS_MAX_FILE_IO_SIZE
  Andy Adamson     3ad8d6c pnfs_submit: enforce requested DS only pNFS role

pnfs-submit:
  Fred Isaman      3f48c62 DEBUG: add some BUG_ON(refcount==0) statements
  Fred Isaman      502388a debug: add assert_spin_locked
  Fred Isaman      a655dac pnfs-submit: Add WARN_ONs removed by submission code
  Andy Adamson     c11704d pnfs_submit: wave4 pageio-helpers
  Andy Adamson     8fb9114 pnfs_submit: wave4 associate layout segment with nfs_page
  Andy Adamson     de2c655 pnfs_submit: wave4 generic read
  The pNFS Team    302270f pnfs_submit: generic write
  The pNFS Team    f978c0a pnfs_submit: data server write with no getattr
  The pNFS Team    15e01aa pnfs_submit: filelayout write
  The pNFS Team    f184813 pnfs_submit: signal layoutdriver commit
  The pNFS Team    b4e299a pnfs_submit: generic commit
  The pNFS Team    af37694 pnfs_submit: data server commit with no getattr
  The pNFS Team    cf279a7 pnfs_submit: filelayout commit
  Fred Isaman      13f429d pnfs-submit: wave4: fix bug dealing with commit split between DS and MDS

Latest patches that went in since pnfs-all-2.6.38-rc2-2011-01-27:

nfs-upstream:
  Fred Isaman      995a73b pnfs: avoid incorrect use of layout stateid
  Fred Isaman      8073b9d pnfs: do not need to clear NFS_LAYOUT_BULK_RECALL flag
  Fred Isaman      de5f699 pnfs: fix pnfs lock inversion of i_lock and cl_lock

pnfs-all-latest:
  Benny Halevy     5186ca3 SQUASHME: pnfs-block: use pnfs_layout_hdr field prefix
  Benny Halevy     4c5fcc5 SQUASHME: pnfs-obj: use pnfs_layout_hdr and layout_segment field prefix
