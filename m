Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-px0-f173.google.com ([209.85.212.173]:53270 "EHLO
	mail-px0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756537Ab1EPQPO (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 May 2011 12:15:14 -0400
Received: by pxi16 with SMTP id 16so3173815pxi.4
        for <linux-nfs@vger.kernel.org>; Mon, 16 May 2011 09:15:14 -0700 (PDT)
Message-ID: <4DD14D8E.1070701@panasas.com>
Date: Mon, 16 May 2011 09:15:10 -0700
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
CC: NFS list <linux-nfs@vger.kernel.org>, Fred Isaman <iisaman@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>
Subject: [PATCH v3 0/29] pnfs for 2.6.40
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Here's an updated version of the pnfs-obj patches addressing Fred's
review comments from May 12.

changes in v3:
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
[PATCH v3 01/29] pnfs: CB_NOTIFY_DEVICEID
[PATCH v3 02/29] pnfs: Use byte-range for layoutget
[PATCH v3 03/29] pnfs: align layoutget requests on page boundaries
[PATCH v3 04/29] pnfs: Use byte-range for cb_layoutrecall
[PATCH v3 05/29] pnfs: client stats
[PATCH v3 06/29] pnfs: resolve header dependency in pnfs.h

some preps:
[PATCH v3 07/29] pnfs-obj: objlayoutdriver module skeleton
[PATCH v3 08/29] NFSD: introduce exp_xdr.h
[PATCH v3 09/29] pnfs-obj: pnfs_osd XDR definitions
[PATCH v3 10/29] exofs: pnfs-tree: Remove pnfs-osd private definitions
[PATCH v3 11/29] pnfs-obj: pnfs_osd XDR client implementation

layoutget:
[PATCH v3 12/29] pnfs-obj: decode layout, alloc/free lseg

getdeviceinfo:
[PATCH v2 13/29] pnfs: per mount layout driver private data
[PATCH v3 13/29] pnfs: per mount layout driver private data
[PATCH v3 14/29] pnfs-obj: objio_osd device information retrieval and
caching
[PATCH v3 15/29] pnfs: set/unset layoutdriver
[PATCH v3 16/29] pnfs-obj: objlayout set/unset layout driver methods

i/o:
[PATCH v3 17/29] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH v3 18/29] pnfs: support for non-rpc layout drivers
[PATCH v3 19/29] pnfs-obj: read/write implementation

layoutreturn:
[PATCH v3 20/29] pnfs: layoutreturn
[PATCH v3 21/29] pnfs: layoutret_on_setattr
[PATCH v3 22/29] pnfs: encode_layoutreturn
[PATCH v3 23/29] sunrpc: xdr_rewind_stream()
[PATCH v3 24/29] pnfs-obj: objlayout_encode_layoutreturn Implementation.
[PATCH v3 25/29] pnfs-obj: objio_osd report osd_errors for layoutreturn

layoutcommit:
[PATCH v3 26/29] pnfs: encode_layoutcommit
[PATCH v3 27/29] pnfs-obj: objlayout_encode_layoutcommit implementation

support for more interesting osd layouts:
[PATCH v3 28/29] pnfs-obj: objio_osd: RAID0 support
[PATCH v3 29/29] pnfs-obj: objio_osd: groups support

