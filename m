Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from natasha.panasas.com ([67.152.220.90]:51948 "EHLO
	natasha.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755819Ab1JDKY5 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 4 Oct 2011 06:24:57 -0400
Message-ID: <4E8ADEDA.4050709@panasas.com>
Date: Tue, 4 Oct 2011 12:24:26 +0200
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Benny Halevy <bhalevy@panasas.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>,
        "Welch, Brent" <welch@panasas.com>
Subject: [PATCHSET 00/19] objlayout: Move to ORE
Content-Type: text/plain; charset="UTF-8"
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Submitted is the move of the objects-layout-driver to the ORE
(Objects Raid Engine). Which after this patchset will be
used by both the exofs file system and the objlayoutdriver.
(ore.ko is its own library since last Kernel)

This code is intended for the 3.2 Kernel and is already
collecting dust in linux-next. (Though the latest bits from today)

End of this week I will post the RAID5 support to ORE and both
exofs and objlayoutdriver. Also meant for 3.2

Trond Hi
  The First 12 patches are to the ore and exofs to make them
  compatible with objlayoutdriver. The pnfs-obj patches are
  dependent on the first part been present.
  We can either submit them all through your tree. Or alternatively
  You can send your ACK-by: on the last 7 and I can submit them
  to Linus through my tree. Which ever you prefer.

Benny Hi
  I please need your Review-by: to [PATCH 13/19] and [PATCH 14/19]
  which change code behaviour. The rest of the patches are just conversions
  which in theory do not add or change any functionality. (Unless there
  are bugs, but that's not intended)

  Also, With these patches panfs-layout-driver is totally broken.
  Please just remove it once you rebase on these patches. With the RAID5
  support it is no longer needed. I've started testing with PanFS export
  through the STD objlayoutdriver, hope to finish this week. (We always
  have the old versions)

  Also tomorrow I will send the needed patch for pnfsd-exofs branch
  that works with these changes.

These are the list off patches:

[PATCH 01/19] exofs: Rename struct ore_components comps => oc
[PATCH 02/19] exofs: Remove unused data_map member from exofs_sb_info
[PATCH 03/19] ore: Make ore_striping_info and ore_calc_stripe_info public
[PATCH 04/19] ore/exofs: Change the type of the devices array (API change)
[PATCH 05/19] ore: Only IO one group at a time (API change)
[PATCH 06/19] ore: cleanup: Embed an ore_striping_info inside ore_io_state
[PATCH 07/19] ore: Remove check for ios->kern_buff in _prepare_for_striping to later
[PATCH 08/19] exofs: Support for short read/writes
[PATCH 09/19] ore: Support for short read/writes
[PATCH 10/19] ore: Support for partial component table
[PATCH 11/19] ore/exofs: Define new ore_verify_layout
[PATCH 12/19] ore/exofs: Change ore_check_io API

	Up to here are the changes need to ore and exofs so the ore
	can be used by the objlayoutdriver. Any review is welcome.
	Same API will be used for RAID4/5/6 support.

[PATCH 13/19] pnfs-obj: Remove redundant EOF from objlayout_io_state
[PATCH 14/19] pnfs-obj: Return PNFS_NOT_ATTEMPTED in case of read/write_pagelist

	Benny please review these two. They are independent of the ORE
	conversion. I think the [PATCH 14/19] might not be enough and
	Error handling needs "more", but the needed changes are their
	own patch, to come later.

[PATCH 15/19] pnfs-obj: Get rid of objlayout_{alloc,free}_io_state
[PATCH 16/19] pnfs-obj: Rename objlayout_io_state => objlayout_io_res
[PATCH 17/19] pnfs-obj: move to ore 01: ore_layout & ore_components
[PATCH 18/19] pnfs-obj: move to ore 02: move to ORE
[PATCH 19/19] pnfs-obj: move to ore 03: Remove old raid engine

	These 5 stage the move to the ore. With these patches I'm
	able to pass all the tests I passed with the old code.
	Only now with more then 500 lines of code less.

Cheers
Boaz
