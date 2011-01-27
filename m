Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:5006 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752485Ab1A0Ufc (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Jan 2011 15:35:32 -0500
Message-ID: <4D41D711.70807@panasas.com>
Date: Thu, 27 Jan 2011 22:35:29 +0200
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.38-rc2-2011-01-27
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I rebased the pnfs tree onto 2.6.38-rc2 (that has the wave2 patches)
and tagged the pnfs-all-latest tip as pnfs-all-2.6.38-rc2-2011-01-27

Note: spnfs-block is currently broken due to the fallocate() API change.

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.38-rc2 pnfs-all-2.6.38-rc2-2011-01-27

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches that went in since pnfs-all-2.6.37-rc3-2010-11-23:

spnfs-block:
  Benny Halevy     b4dc7fe spnfs-block: fix bl_ops.c for new blkdev_get_by_dev()
  Benny Halevy     a051448 FIXME: fix bl_ops use of fallocate

pnfs-submit:
  Fred Isaman      021fa68 DEBUG: add some BUG_ON(refcount==0) statements
  Fred Isaman      a9b6a3e POSTPONE: lseg refcounting
  Fred Isaman      5de505c debug: add assert_spin_locked
  Fred Isaman      24e076e pnfs-submit: wave4: fix bug dealing with commit split between DS and MDS

pnfs:
  Fred Isaman      7bbc4e7 pnfs-submit: revert range simplifications made by submission patches
  Fred Isaman      cbc79e3 POSTPONE: restore has_layout
  Fred Isaman      3a53a23 pnfs_submit: layoutcommit
  Fred Isaman      e214a86 pnfs-submit: Turn off layoutcommits
  Fred Isaman      3c0b776 POST_SUBMIT: restore pnfs_return_layout
  Fred Isaman      008932b REVERT ME: "Fix callback code"
  Fred Isaman      be9d7b0 DELETE ME: move rpcwaitq from nfs_server to nfs_inode
  Fred Isaman      c4df508 DELETE ME: remove list_del optimization from pnfs_free_lseg_list
  Fred Isaman      2d67203 REVERT ME: "Fix wait bug in pnfs_roc_drain"
  Fred Isaman      9ca7b1b REVERT ME: "Add prefix to struct pnfs_layout_hdr fields"
  Fred Isaman      ae88286 REVERT ME: "Add prefix to struct pnfs_layout_segment fields"
  Fred Isaman      f84b32e REVERT ME: change roc calling convention
  Fred Isaman      46555cb REVERT ME: NFS_LAYOUT_DESTROYED flag
  Fred Isaman      3fbab3a REVERT ME: join pnfs_clear_lseg_list and nfs4_asynch_forget_layouts
  Fred Isaman      67901ed REVERT ME: add recall_counts
  Fred Isaman      b5365d9 DELETE ME: outdated comment
  Fred Isaman      b050cbe DELETE ME: pointless dprintk info
  Fred Isaman      6a536e9 DELETE ME: whitespace change
  Fred Isaman      ec961df DELETE ME: incorrect comment
  Fred Isaman      bb23404 DELETE ME: making should_free_lseg public
  Fred Isaman      0581f32 SQUASHME: Remove outdated WARN
  Benny Halevy     f1ed0cc Revert "pnfs-submit: wave2: remove forgotten layoutreturn struct definitions"
  Benny Halevy     0f685c1 Revert "pnfs-submit: Turn off layoutcommits"
  Benny Halevy     8b00189 pnfs: LAYOUTRETURN code
  Benny Halevy     b16e749 Revert "pnfs-submit: wave2: Remove LAYOUTRETURN from return on close"
  Benny Halevy     b5d445a FIXME: roc should return layout on last close
  Benny Halevy     1c45467 Revert "pnfs-submit: wave2: remove cl_layoutrecalls list"
  Benny Halevy     7413bae Revert "pnfs-submit: wave2: Pull out all recall initiated LAYOUTRETURNS"
  Benny Halevy     7ca4ff5 Revert "pnfs-submit: wave2: Don't wait in layoutget"
  Benny Halevy     f9f44b6 Revert "pnfs-submit: wave2: check that partial LAYOUTGET return is ignored"
  Benny Halevy     f713392 SQUASHME: pnfs: call pnfs_choose_layoutget_stateid under the inode lock

pnfs-block:
  Benny Halevy     e834aeb SQUASHME: pnfs-block: fixup layoutcommit methods args
  Jim Rees         c0243f2 pnfs-block: fix blocklayoutdev.c for new blkdev_get_by_dev()

pnfs-obj-all:
  Benny Halevy     f5eb2e4 SQUASHME: pnfs-obj: fixup layoutcommit methods args

