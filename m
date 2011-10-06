Return-Path: linux-nfs-owner@vger.kernel.org
Received: from natasha.panasas.com ([67.152.220.90]:54331 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964805Ab1JFMVw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 6 Oct 2011 08:21:52 -0400
Message-ID: <4E8D9D56.6020803@panasas.com>
Date: Thu, 6 Oct 2011 14:21:42 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
MIME-Version: 1.0
To: Benny Halevy <bhalevy@tonian.com>, NFS list <linux-nfs@vger.kernel.org>,
        open-osd <osd-dev@open-osd.org>
Subject: [PATCHSET 0/5] pnfsd-exofs: Adapt to Latest ore/exofs changes
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Benny Hi

I'm sending the changes needed to *pnfsd-exofs* branch which are needed
in order to work with latest, for v3.2, ore/exofs changes.

Assuming you have set up:
   git remote add loo git://git.open-osd.org/linux-open-osd.git

For your convenience the patches are also available at:

   git cherry-rebase 5d2d53b7..loo/pnfsd-exofs

You will also need to merge or put somewhere all these changes on the
linux-open-osd linux-next branch (Actually the ore-devel branch)

   git cherry-rebase loo/linus..loo/ore-devel

Here are the sets of patches in the two groups:

[pnfsd-exofs 5d2d53b7..loo/pnfsd-exofs(6127dbd)]

  This set is based on the base, none SQUASHME, pnfsd-exofs patches
	[5d2d53b7] pnfsd-exofs: layoutreturn pnfs-obj information decoding

  7638472 SQUASHME: pnfsd-exofs: convert to v3.1 ORE			  - Your original conversion
  51f3837 SQUASHME: pnfsd-exofs: Convert to ORE 3.1 PART2
  590139b SQUASHME: pnfsd-exofs: Fix export of only one group layout
  fba7909 SQUASHME: pnfsd-exofs: Type & Name of the devices array changed
  6127dbd SQUASHME pnfsd-exofs: Serve out a single group layout at a time 



[ore/exofs/pnfs-obj changes for Linux v3.2 merge window]

  My tree is based on v3.1-rc6 but you might want to base them on your pnfs/pnfs-block branch
  or have them all in a third branch and merge three branches on the top

  []$ git log --oneline --reverse loo/linus..loo/ore-devel

  a8f8c45 osd: Kconfig remove wrong FIXME
  1958c7c2 exofs/ore.c: local functions should be static
  de74b05 exofs/super.c: local functions should be static
  5bf696d exofs: Rename struct ore_components comps => oc
  8d2d83a exofs: Remove unused data_map member from exofs_sb_info
  eb507bc ore: Make ore_striping_info and ore_calc_stripe_info public
  d866d87 ore/exofs: Change the type of the devices array (API change)
  6d52274 ore: Only IO one group at a time (API change)
  a723afe ore: cleanup: Embed an ore_striping_info inside ore_io_state
  bcad9f7 ore: Remove check for ios->kern_buff in _prepare_for_striping to later
  c8dfed0 exofs: Support for short read/writes
  b2e3e8d ore: Support for short read/writes
  c0ba6d0 ore: Support for partial component table
  3c5aedd ore/exofs: Define new ore_verify_layout
  f6ee1e2 ore/exofs: Change ore_check_io API
  9bb8a8e pnfs-obj: Remove redundant EOF from objlayout_io_state
  e4ec2af pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist
  8b40d31 pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
  6b09277 pnfs-obj: Rename objlayout_io_state => objlayout_io_res
  739c109 pnfs-obj: move to ore 01: ore_layout & ore_components
  23a91ad pnfs-obj: move to ore 02: move to ORE
  b82cbb8 pnfs-obj: move to ore 03: Remove old raid engine
	Up to here is the intended patches for Linux v3.2
  c0cf571 ore: Make ore_calc_stripe_info EXPORT_SYMBOL
	This patch is intended for the pnfsd-exofs branch after it will be
	rebased on ore/exofs for v3.2 above (As is it will not patch there)

Cheers
Boaz
