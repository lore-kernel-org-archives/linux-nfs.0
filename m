Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:38670 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab1EVQn4 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 12:43:56 -0400
Message-ID: <4DD93D3E.9010909@panasas.com>
Date: Sun, 22 May 2011 19:43:42 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>, open-osd <osd-dev@open-osd.org>
Subject: [PATCHSET V4 00/23 boaz] pnfs for 2.6.40
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


Submitted a VER 4 with changes addressing comments from Trond and
Benny.

[Based on: 19f2043b pnfs/nfsd41-all]

changes in v4: (Boaz)
* See the long SQUASHME patchset I sent yesterday for all the changes.
  titled: [PATCHSET 00/13] SQUASHME pnfs-obj: Lots of changes addressing comments by Trond and Benny
* I have united all 3 raid-engine read/write patches to a single patch
* I've united the two error-reporting and error-encoding into one patch
* Some checkpatch love
* small cleanups here and there. 
(I'll send a diff as reply to this mail)

changes in v3: (Benny)
* removed direct i/o patch
* align layoutget requests on page boundaries
* fix lseg ordering
* cleanup pnfs_insert_lseg
* pnfs: clean up pnfs_find_lseg lseg arg
* remove unnecessary FIXME

changes in v2:
* fix CB_NOTIFY_DEVICEID
* call pnfs_return_layout right before pnfs_destroy_layout
* remove assert_spin_locked from pnfs_clear_lseg_list
* remove wait parameter from the layoutreturn path.
* remove return_type field from nfs4_layoutreturn_args
* remove range from nfs4_layoutreturn_args
* no need to send layoutcommit from _pnfs_return_layout
* don't wait on sync layoutreturn
* get rid of PNFS_USE_RPC_CODE
* get rid of __nfs4_write_done_cb
* get rid of ds_[rw]size
* rename pnfs_{read,write}_done -> pnfs_ld_{read,write}_done
* reorganize and reorder the pnfs-obj patchset to expose dependencies
  and separate api changes
* some cleaning up of the pnfs-obj patches
* add xdr space reservation for pnfs-obj opaque layoutreturn
  and layoutcommit payloads

generic patches:
[PATCH 01/23] pnfs: CB_NOTIFY_DEVICEID
[PATCH 02/23] pnfs: Use byte-range for layoutget
[PATCH 03/23] pnfs: align layoutget requests on page boundaries
[PATCH 04/23] pnfs: Use byte-range for cb_layoutrecall
[PATCH 05/23] pnfs: client stats
[PATCH 06/23] pnfs: resolve header dependency in pnfs.h

Basic ld driver and some std definitions
[PATCH 07/23] pnfs-obj: objlayoutdriver module skeleton
[PATCH 08/23] pnfs-obj: pnfs_osd XDR definitions
[PATCH 09/23] pnfs-obj: pnfs_osd XDR client implementation

layoutget:
[PATCH 10/23] pnfs-obj: decode layout, alloc/free lseg

getdeviceinfo:
[PATCH 11/23] pnfs: per mount layout driver private data
[PATCH 12/23] pnfs-obj: objio_osd device information retrieval and caching
[PATCH 13/23] pnfs: set/unset layoutdriver
[PATCH 14/23] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH 15/23] pnfs-obj: define per-mount and per-inode private structures

read/write
[PATCH 16/23] pnfs: support for non-rpc layout drivers
[PATCH 17/23] pnfs-obj: osd raid engine read/write implementation

layoutreturn:
[PATCH 18/23] pnfs: layoutreturn
[PATCH 19/23] pnfs: layoutret_on_setattr
[PATCH 20/23] pnfs: encode_layoutreturn
[PATCH 21/23] pnfs-obj: report errors and .encode_layoutreturn Implementation.

layoutcommit:
[PATCH 22/23] pnfs: encode_layoutcommit
[PATCH 23/23] pnfs-obj: objlayout_encode_layoutcommit implementation

