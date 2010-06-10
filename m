Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60334 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752802Ab0FJRGl (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 10 Jun 2010 13:06:41 -0400
Received: by wyb40 with SMTP id 40so110888wyb.19
        for <linux-nfs@vger.kernel.org>; Thu, 10 Jun 2010 10:06:40 -0700 (PDT)
Message-ID: <4C111B9C.3080603@panasas.com>
Date: Thu, 10 Jun 2010 20:06:36 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: NFS list <linux-nfs@vger.kernel.org>
Subject: pnfs git tree status pnfs-all-2.6.35-rc2-2010-06-10
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I've release the tree with Alexandros and Andy's latest pnfs-submit patches
as well as some fixes for pnfs-obj from Boaz.  The latter, and Andy's
patches went also for the pnfs-all-2.6.34 branch, tagged as
pnfs-all-2.6.34-2010-06-10

Cumulative patches can be generated from
git://linux-nfs.org/~bhalevy/linux-pnfs.git
using
git diff v2.6.35-rc2 pnfs-all-2.6.35-rc2-2010-06-10
git diff v2.6.34 pnfs-all-2.6.34-2010-06-10

Or, they can be downloaded from the wiki at:
http://wiki.linux-nfs.org/wiki/index.php/PNFS_Development_Git_tree

Latest patches (since 2010-05-17):

pnfs-submit:
Alexandros Batsakis (7):
      pnfs-submit: clean struct nfs_inode
      pnfs-submit: remove lgetcount, lretcount
      pnfs-submit: change stateid to be a union
      pnfs-submit: request whole-file layouts only
      pnfs-submit: change layout list to be similar to other state lists
      pnfs-submit: forgetful client (layouts)
      pnfs-submit: support for CB_RECALL_ANY (layouts)

Andy Adamson (5):
      SQUASHME: pnfs-submit: replace layoutcommit_ctx with rpc_cred
      SQUASHME pnfs-submit: cleanup layoutcommit call
      SQUASHME pnfs-submit: handle async layoutcommit errors
      SQUASHME pnfs remove ifdef around layoutcommit_needed
      SQUASHME pnfs-submit: move layoutcommit to nfs_write_inode

Ricardo Labiaga (2):
      SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
      pnfs-submit: Dynamically load the nfslayoutdriver

Tao Guo (2):
      SQUASHME: pnfs-submit: call layoutcommit after flushing inode's data to disk.
      SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit

pnfs-block:
Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

pnfsd-files:
Benny Halevy (1):
      SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES

Eric Anderle (2):
      pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
      SQUASHME: pnfsd: fix test in nfsd4_find_pnfs_dlm_device

Ricardo Labiaga (1):
      SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES

pnfsd:
Benny Halevy (2):
      SQUASHME: pnfsd: cb_{set,client} moved in 2.6.35
      SQUASHME: pnfsd: cl_count removed in 2.6.35

J. Bruce Fields (1):
      SQUASHME: nfsd4: fix cb_recall encoding

spnfs:
Benny Halevy (1):
      SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES

spnfs-block:
pnfsd-lexp:
Benny Halevy (1):
      SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES

pnfs-obj-all:
Boaz Harrosh (2):
      SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
      SQUASHME: panfs_shim: Prints on Errors

pnfs-block-all:
Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

spnfs-all:
Benny Halevy (1):
      SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES

pnfs-all-latest:
Benny Halevy (1):
      DEBUG: pnfs: turn BUG_ONs in pnfs_destroy_inode to WARN_ONs

pnfs-all-2.6.34:
Andy Adamson (5):
      SQUASHME: pnfs-submit: replace layoutcommit_ctx with rpc_cred
      pnfs: cleanup layoutcommit call
      pnfs: handle async layoutcommit errors
      pnfs: remove ifdef around layoutcommit_needed
      pnfs: move layoutcommit to nfs_write_inode

Benny Halevy (4):
      SQUASHME: pnfsd: dlm: fixup LAYOUT_NFSV4_1_FILES
      SQUASHME: pnfsd-lexp: fixup LAYOUT_NFSV4_1_FILES
      SQUASHME: spnfs: fixup LAYOUT_NFSV4_1_FILES
      DEBUG: pnfs: turn BUG_ONs in pnfs_destroy_inode to WARN_ONs

Boaz Harrosh (2):
      SQUASHME: pnfs-obj: panlayout: Fix very old BUG_ONs on ol_state.status
      panfs_shim: Prints on Errors

Eric Anderle (2):
      pnfsd: make /proc/fs/nfsd/pnfs_dlm_device report dlm device list.
      SQUASHME: pnfsd: fix test in nfsd4_find_pnfs_dlm_device

J. Bruce Fields (1):
      SQUASHME: nfsd4: fix cb_recall encoding

Ricardo Labiaga (3):
      SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
      SQUASHME: pnfs-submit: Use LAYOUT_NFSV4_1_FILES instead of LAYOUT_NFSV4_FILES
      pnfs-submit: Dynamically load the nfslayoutdriver

Tao Guo (2):
      SQUASHME: pnfs-submit: call layoutcommit after flushing inode's data to disk.
      SQUASHME: pnfs: unlock lo_lock before calling layoutdriver's setup_layoutcommit

Zhang Jingwang (1):
      SQAUSHME: blocklayoutdriver: NULL pointer reference when committing too many extents

