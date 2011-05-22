Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:43318 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753632Ab1EVXnd (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 22 May 2011 19:43:33 -0400
Message-ID: <4DD99F9B.2040406@panasas.com>
Date: Mon, 23 May 2011 02:43:23 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHSET v5 0/38] pnfs for 2.6.40
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

This version includes review comment fixes on top of Boaz v4 sent yesterday.

In addition, it includes a generic deviceid cache used for both
layout drivers, using the pointers to the layout driver and to
the nfs_client to uniquify the deviceids.

This patchset includes SQUASHME patches for ease of review
however these will be squashed to produce a smaller and cleaner
patchset.

I've tested this code to compile and pass basic/generic/special
cthon tests with the files layout driver but not with the objects
layout yet.  Boaz - I'd appreciate if you could run the pnfs-obj
tests too, thanks!

Changes in v5: (Benny)
* use struct nfs_client to qualify deviceid
* make device cache global
* use be32 res in nfs4_callback_devicenotify
* use gfp_flags
* xdr_init_decode_pages
* fix layout stateid used for layoutreturn args
* commit message for layoutret_on_setattr
* use global deviceid cache for pnfs-obj
  - revert per-mount hook and related {.un}set_layoutdriver methods
* use layout driver in global device cache

changes in v4: (Boaz)
* See the long SQUASHME patchset I sent yesterday for all the changes.
  titled: [PATCHSET 00/13] SQUASHME pnfs-obj: Lots of changes addressing
comments by Trond and Benny
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

List of patches:

generic:
[PATCH v5 01/38] NFSv4.1: use struct nfs_client to qualify deviceid
[PATCH v5 02/38] pnfs: resolve header dependency in pnfs.h
[PATCH v5 03/38] NFSv4.1: make deviceid cache global
[PATCH v5 04/38] NFSv4.1: purge deviceid cache on nfs_free_client
[PATCH v5 05/38] pnfs: CB_NOTIFY_DEVICEID
[PATCH v5 06/38] SQUASHME: use be32 res in nfs4_callback_devicenotify
[PATCH v5 07/38] SQUASHME: pnfs: use nfs_client to qualify deviceid for
cb_notify_deviceid
[PATCH v5 08/38] SQUASHME: pnfs: use global deviceid cache for
CB_NOTIFY_DEVICEID
[PATCH v5 09/38] SQUASHME: pnfs: refactor device cache _lookup_deviceid
[PATCH v5 10/38] SQUASHME: pnfs: refactor device cache _find_get_deviceid
[PATCH v5 11/38] SUNRPC: introduce xdr_init_decode_pages
[PATCH v5 12/38] pnfs: Use byte-range for layoutget
[PATCH v5 13/38] pnfs: align layoutget requests on page boundaries
[PATCH v5 14/38] pnfs: Use byte-range for cb_layoutrecall
[PATCH v5 15/38] pnfs: client stats

Basic ld driver and some std definitions:
[PATCH v5 16/38] pnfs-obj: objlayoutdriver module skeleton
[PATCH v5 17/38] pnfs-obj: pnfs_osd XDR definitions
[PATCH v5 18/38] pnfs-obj: pnfs_osd XDR client implementation

layoutget:
[PATCH v5 19/38] pnfs-obj: decode layout, alloc/free lseg

getdeviceinfo:
[PATCH v5 20/38] pnfs: per mount layout driver private data
[PATCH v5 21/38] pnfs-obj: objio_osd device information retrieval and
caching
[PATCH v5 22/38] pnfs: set/unset layoutdriver
[PATCH v5 23/38] SQUASHME: pnfs-obj: use global device cache
[PATCH v5 24/38] SQUASHME: Revert "pnfs: per mount layout driver private
data"
[PATCH v5 25/38] SQUASHME: Revert "pnfs: set/unset layoutdriver"
[PATCH v5 26/38] NFSv4.1: use layout driver in global device cache

read/write:
[PATCH v5 27/38] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH v5 28/38] pnfs-obj: define per-inode private structure
[PATCH v5 29/38] pnfs: support for non-rpc layout drivers
[PATCH v5 30/38] SQUASHME: initialize data->task on the non-rpc io done
success paths
[PATCH v5 31/38] pnfs-obj: osd raid engine read/write implementation

layoutreturn:
[PATCH v5 32/38] pnfs: layoutreturn
[PATCH v5 33/38] SQUASHME: pnfs: fix layout stateid in layoutreturn args
[PATCH v5 34/38] pnfs: layoutret_on_setattr
[PATCH v5 35/38] pnfs: encode_layoutreturn
[PATCH v5 36/38] pnfs-obj: report errors and .encode_layoutreturn
Implementation.

layoutcommit:
[PATCH v5 37/38] pnfs: encode_layoutcommit
[PATCH v5 38/38] pnfs-obj: objlayout_encode_layoutcommit implementation
