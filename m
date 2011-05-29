Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:50722 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753122Ab1E2SO0 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sun, 29 May 2011 14:14:26 -0400
Message-ID: <4DE28CFB.4060608@panasas.com>
Date: Sun, 29 May 2011 21:14:19 +0300
From: Boaz Harrosh <bharrosh@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>,
        Benny Halevy <bhalevy@panasas.com>, open-osd <osd-dev@open-osd.org>
Subject: [PATCHSET final 00/32] pnfs-obj: pnfs-objects layout driver submission
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0


This is the complete and squashed version of the pnfs objects layout driver
plus the needed changes from the pnfs-core to support more then one LD.

[PATCH 01/32] NFSv4.1: fix typo in filelayout_check_layout
[PATCH 02/32] NFSv4.1: use struct nfs_client to qualify deviceid
[PATCH 03/32] pnfs: resolve header dependency in pnfs.h
[PATCH 04/32] NFSv4.1: make deviceid cache global
[PATCH 05/32] NFSv4.1: purge deviceid cache on nfs_free_client
[PATCH 06/32] pnfs: CB_NOTIFY_DEVICEID
[PATCH 07/32] NFSv4.1: use layout driver in global device cache
[PATCH 08/32] SUNRPC: introduce xdr_init_decode_pages
[PATCH 09/32] pnfs: Use byte-range for layoutget
[PATCH 10/32] pnfs: align layoutget requests on page boundaries
[PATCH 11/32] pnfs: Use byte-range for cb_layoutrecall
[PATCH 12/32] pnfs: client stats
[PATCH 13/32] pnfs-obj: objlayoutdriver module skeleton
[PATCH 14/32] pnfs-obj: pnfs_osd XDR definitions
[PATCH 15/32] pnfs-obj: pnfs_osd XDR client implementation
[PATCH 16/32] pnfs-obj: decode layout, alloc/free lseg
[PATCH 17/32] pnfs-obj: objio_osd device information retrieval and caching
[PATCH 18/32] pnfs: alloc and free layout_hdr layoutdriver methods
[PATCH 19/32] pnfs-obj: define per-inode private structure
[PATCH 20/32] pnfs: support for non-rpc layout drivers
[PATCH 21/32] pnfs-obj: osd raid engine read/write implementation
[PATCH 22/32] pnfs: layoutreturn
[PATCH 23/32] pnfs: layoutret_on_setattr
[PATCH 24/32] pnfs: encode_layoutreturn
[PATCH 25/32] pnfs-obj: report errors and .encode_layoutreturn Implementation.
[PATCH 26/32] pnfs: encode_layoutcommit
[PATCH 27/32] pnfs-obj: objlayout_encode_layoutcommit implementation
[PATCH 28/32] NFSv4.1: unify pnfs_pageio_init functions
[PATCH 29/32] NFSv4.1: change pg_test return type to bool
[PATCH 30/32] NFSv4.1: use pnfs_generic_pg_test directly by layout driver
[PATCH 31/32] NFSv4.1: define nfs_generic_pg_test
[PATCH 32/32] pnfs-obj: pg_test check for max_io_size

I'll send the git tree address as separate email.

Thanks
Boaz

