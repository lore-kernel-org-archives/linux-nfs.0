Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37984 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753685Ab1DTQqb (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 20 Apr 2011 12:46:31 -0400
Received: by wwa36 with SMTP id 36so1104549wwa.1
        for <linux-nfs@vger.kernel.org>; Wed, 20 Apr 2011 09:46:30 -0700 (PDT)
Message-ID: <4DAF0DE1.6020609@panasas.com>
Date: Wed, 20 Apr 2011 19:46:25 +0300
From: Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        Boaz Harrosh <bharrosh@panasas.com>,
        "Welch, Brent" <welch@panasas.com>
CC: NFS list <linux-nfs@vger.kernel.org>
Subject: [RFC 0/27] pnfs-submit for 2.6.40
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

I prepared an initial version of the pnfs patch series candidate for 2.6.40.
It implements basic support for layout segments and error handling
(fallback to the MDS) for non-rpc based layout drivers.

Comments welcome! :)

The patches are also available in
git://linux-nfs.org/~bhalevy/linux-pnfs.git pnfs-submit

On top of it I rebased the following branches to allow easier testing:
pnfs-submit
    pnfs-obj
        pnfs
            pnfsd-all
                pnfsd-lexp-all
                    pnfs-exofs-all

These branches do not include the pnfs-block implementation yet.

generic pnfs additions:
[RFC 01/27] pnfs: CB_NOTIFY_DEVICEID
[RFC 02/27] pnfs: direct i/o
[RFC 13/27] pnfs: client stats

for pnfs-obj:
[RFC 03/27] pnfs: layoutreturn
[RFC 04/27] pnfs: layoutret_on_setattr
[RFC 05/27] pnfs: Use byte-range layout segments
[RFC 06/27] pnfs: encode_layoutreturn
[RFC 07/27] pnfs: encode_layoutcommit
[RFC 08/27] pnfs: {setup,cleanup}_layoutcommit
[RFC 09/27] pnfs: support for non-rpc layout drivers
[RFC 10/27] pnfs: {,un}set_layoutdriver methods
[RFC 11/27] pnfs: per mount layout driver private data
[RFC 12/27] pnfs: alloc and free layout_hdr layoutdriver methods
[RFC 14/27] pnfsd: introduce exp_xdr.h

pnfs-obj
[RFC 15/27] pnfs-obj: pnfs_osd XDR definitions
[RFC 16/27] pnfs-obj: pnfs_osd XDR client implementations
[RFC 17/27] exofs: pnfs-tree: Remove pnfs-osd private definitions
[RFC 18/27] pnfs-obj: Define PNFS_OBJLAYOUT Kconfig option
[RFC 19/27] pnfs-obj: objlayout driver skeleton
[RFC 20/27] pnfs-obj: objio_osd device information retrieval and caching
[RFC 21/27] pnfs-obj: objio_osd real IO implementation
[RFC 22/27] sunrpc: New xdr_rewind_stream()
[RFC 23/27] pnfs-obj: objlayout_encode_layoutreturn Implementation.
[RFC 24/27] pnfs-obj: objio_osd report osd_errors for layoutreturn
[RFC 25/27] pnfs-obj: objlayout_encode_layoutcommit implementation
[RFC 26/27] pnfs-obj: objio_osd: RAID0 support
[RFC 27/27] pnfs-obj: objio_osd: groups support

* Need to move to xdr_stream based decoding.
* Boaz has some changes queued up, including using a common
  I/O engine for exofs and the pnfs-obj layout driver.



