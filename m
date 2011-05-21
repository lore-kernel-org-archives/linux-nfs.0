Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19611 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751193Ab1EUKWt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:22:49 -0400
Message-ID: <4DD79273.9030202@panasas.com>
Date: Sat, 21 May 2011 13:22:43 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHSET 00/13] SQUASHME pnfs-obj: Lots of changes addressing comments
 by Trond and Benny
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Submitted are SQUASHME patches on-top of *pnfs-exofs-all* that demonstrate all the
changes I did addressing comments by Trond and Benny. So it is easy to see the changes
and not need to review the complete patchset.

Thanks guys for the excellent review!

Next I will send a new *pnfs-submit* patchset so they can be reviewed and put in next.
(Benny you need to come back to me if it is OK to submit the full read/write raid-engine
 as one patch, instead of three)

Here is the list of SQUASHME patches:

[PATCH 01/13] SQUASHME: re-reorder the functions so it compares better with raids base

  Benny decided to change functions order. This completely through off all the changes
  I had pending in my trees. This patch does nothing but moves code back to its original
  place. See as reply to this email the diff of the nice changes Benny did after the last
  tree at pnfs/pnfs-all-2.6.38

[PATCH 02/13] SQUASHME: pnfs-obj: objio_segment only needs the pnfs_osd_layout->olo_comps
[PATCH 03/13] SQUASHME: pnfs-obj: Rename ios->objio_seg => ios->layout
[PATCH 04/13] SQUASHME: pnfs-obj: Fix groups code when num_devices is not divisible by group_width

  These three are bug fixes and last minute code style changes

[PATCH 05/13] SQUASHME: pnfs-obj: Convert layout and deviceinfo decoding to new XDR

  This one was requested by Trond and rightly so. It is now supported a bigger then
  4K layout, using all the new(old) exr_stream API. Thanks Trond!

[PATCH 06/13] SQUASHME: pnfs-obj: Change API of objlayout_io_set_result
[PATCH 07/13] SQUASHME: pnfs-obj: Avoid double allocation logic in objlayout_alloc_lseg

  Another nice cleanup and performance boost.

[PATCH 08/13] SQUASHME: pnfs_osd_xdr: Remove Server API declarations

  Remove the dependency on the exp_xdr header.

[PATCH 09/13] SQUASHME: pnfs_osd_xdr: Avoid using xdr_rewind_stream

  Also requested by Trond

[PATCH 10/13] [RFC] Bugs in new pnfs write path

  This is a resend of the BUGs patch to pnfs-core (So I can test the tree)

Below is some exofs changes needed to compile and test.
[PATCH 11/13] SQUASHME: pnfs_osd_xdr: Add Server API for encoding/decoding osd XDRs
[PATCH 12/13] SQUASHME: XDR API changes to pnfs_osd_xdr_decode_ioerr()
[PATCH 13/13] SQUASHME: dbg Print the full device_id returned

  Benny could you submit these to the pnfs-exofs-all branch?

So next I'll send these already squashed into a new submit patchset

Thanks
Boaz
