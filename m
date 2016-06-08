Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48381 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1424687AbcFHOpb (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Wed, 8 Jun 2016 10:45:31 -0400
From: "Benjamin Coddington" <bcodding@redhat.com>
To: "Weston Andros Adamson" <dros@primarydata.com>
Cc: "Linux NFS Mailing List" <linux-nfs@vger.kernel.org>
Subject: non-contiguous write across SCSI layout
Date: Wed, 08 Jun 2016 10:45:40 -0400
Message-ID: <A0E027A5-A8E1-402C-890C-89C2AE5E4FE1@redhat.com>
MIME-Version: 1.0
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi Dros,

The client takes this WARN_ON_ONCE path pretty often in
pnfs_generic_pg_test() with SCSI layout type and generic/010:

1925     if (pgio->pg_lseg) {
1926         seg_end = end_offset(pgio->pg_lseg->pls_range.offset,
1927                      pgio->pg_lseg->pls_range.length);
1928         req_start = req_offset(req);
1929         WARN_ON_ONCE(req_start >= seg_end);
1930         /* start of request is past the last byte of this segment */
1931         if (req_start >= seg_end) {
1932             /* reference the new lseg */
1933             if (pgio->pg_ops->pg_cleanup)
1934                 pgio->pg_ops->pg_cleanup(pgio);
1935             if (pgio->pg_ops->pg_init)
1936                 pgio->pg_ops->pg_init(pgio, req);
1937             return 0;
1938         }

I'm trying to figure out why that's a WARN-able path.. do you recall the
original reason for that warning?

Ben
