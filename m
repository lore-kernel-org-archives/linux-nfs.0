Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:37786 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752701Ab1EIRET (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 9 May 2011 13:04:19 -0400
Message-ID: <4DC81E8C.6040901@panasas.com>
Date: Mon, 09 May 2011 20:04:12 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH v2 0/29] pnfs for 2.6.40
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's an updated version of the pnfs-obj patches addressing Trond's
review comments from April 20.

I'm on my way to the airport so I'll get to see any comments
only tomorrow.

Benny

The changes in this version are:
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

And the list of patches:

generic patches:
[PATCH v2 01/29] pnfs: CB_NOTIFY_DEVICEID
[PATCH v2 02/29] pnfs: direct i/o
[PATCH v2 03/29] pnfs: Use byte-range for layoutget
[PATCH v2 04/29] pnfs: Use byte-range for cb_layoutrecall
[PATCH v2 05/29] pnfs: client stats
[PATCH v2 06/29] pnfs: resolve header dependency in pnfs.h

some preps:
[PATCH v2 07/29] pnfs-obj: objlayoutdriver module skeleton
[PATCH v2 08/29] NFSD: introduce exp_xdr.h
[PATCH v2 09/29] pnfs-obj: pnfs_osd XDR definitions
[PATCH v2 10/29] exofs: pnfs-tree: Remove pnfs-osd private definitions
[PATCH v2 11/29] pnfs-obj: pnfs_osd XDR client implementation

layoutget:
[PATCH v2 12/29] pnfs-obj: decode layout, alloc/free lseg

getdeviceinfo:
[PATCH v2 13/29] pnfs: per mount layout driver private data
[PATCH v2 14/29] pnfs-obj: objio_osd device information retrieval and
caching
[PATCH v2 15/29] pnfs: set/unset layoutdriver
[PATCH v2 16/29] pnfs-obj: objlayout set/unset layout driver methods

i/o:
[PATCH v2 17/29] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH v2 18/29] pnfs: support for non-rpc layout drivers
[PATCH v2 19/29] pnfs-obj: read/write implementation

layoutreturn:
[PATCH v2 20/29] pnfs: layoutreturn
[PATCH v2 21/29] pnfs: layoutret_on_setattr
[PATCH v2 22/29] pnfs: encode_layoutreturn
[PATCH v2 23/29] sunrpc: xdr_rewind_stream()
[PATCH v2 24/29] pnfs-obj: objlayout_encode_layoutreturn Implementation.
[PATCH v2 25/29] pnfs-obj: objio_osd report osd_errors for layoutreturn

layoutcommit:
[PATCH v2 26/29] pnfs: encode_layoutcommit
[PATCH v2 27/29] pnfs-obj: objlayout_encode_layoutcommit implementation

support for more interesting osd layouts:
[PATCH v2 28/29] pnfs-obj: objio_osd: RAID0 support
[PATCH v2 29/29] pnfs-obj: objio_osd: groups support
