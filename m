Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:8845 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753008Ab1EWQdH (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 23 May 2011 12:33:07 -0400
Message-ID: <4DDA8C3D.5080706@panasas.com>
Date: Mon, 23 May 2011 19:33:01 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: Boaz Harrosh <bharrosh@panasas.com>, NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCHSET v6 0/26] pnfs for 2.6.40
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Hi,

This is a cleaned up version of the v5 patchset I sent earlier.
It's also based over v2.6.39 and push to
git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfs-submit
at tag pnfs-for-2.6.40-v6-2011-05-23

Changes in v6: (Benny)
* squashed all SQUASHMEs
* reverted "SQUASHME: initialize data->task on the non-rpc io done
success paths"
* reverted "per mount layout driver private data"
* reverted "pnfs: set/unset layoutdriver"
* applied (in reverse) "SQUASHME: pnfs-obj: Important fallout from the
last rebase"

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
[PATCH v6 01/26] NFSv4.1: use struct nfs_client to qualify deviceid
[PATCH v6 02/26] pnfs: resolve header dependency in pnfs.h
[PATCH v6 03/26] NFSv4.1: make deviceid cache global
[PATCH v6 04/26] NFSv4.1: purge deviceid cache on nfs_free_client
[PATCH v6 05/26] pnfs: CB_NOTIFY_DEVICEID
[PATCH v6 06/26] SUNRPC: introduce xdr_init_decode_pages
[PATCH v6 07/26] pnfs: Use byte-range for layoutget
[PATCH v6 08/26] pnfs: align layoutget requests on page boundaries
[PATCH v6 09/26] pnfs: Use byte-range for cb_layoutrecall
[PATCH v6 10/26] pnfs: client stats

Basic ld driver and some std definitions:
[PATCH v6 11/26] pnfs-obj: objlayoutdriver module skeleton
[PATCH v6 12/26] pnfs-obj: pnfs_osd XDR definitions
[PATCH v6 13/26] pnfs-obj: pnfs_osd XDR client implementation

layoutget:
[PATCH v6 14/26] pnfs-obj: decode layout, alloc/free lseg

getdeviceinfo:
[PATCH v6 15/26] pnfs-obj: objio_osd device information retrieval and
caching
[PATCH v6 16/26] NFSv4.1: use layout driver in global device cache

read/write:
[PATCH v6 17/26] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH v6 18/26] pnfs-obj: define per-inode private structure
[PATCH v6 19/26] pnfs: support for non-rpc layout drivers
[PATCH v6 20/26] pnfs-obj: osd raid engine read/write implementation

layoutreturn:
[PATCH v6 21/26] pnfs: layoutreturn
[PATCH v6 22/26] pnfs: layoutret_on_setattr
[PATCH v6 23/26] pnfs: encode_layoutreturn
[PATCH v6 24/26] pnfs-obj: report errors and .encode_layoutreturn
Implementation.

layoutcommit:
[PATCH v6 25/26] pnfs: encode_layoutcommit
[PATCH v6 26/26] pnfs-obj: objlayout_encode_layoutcommit implementation
