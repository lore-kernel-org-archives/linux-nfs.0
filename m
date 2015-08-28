Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-io0-f180.google.com ([209.85.223.180]:36494 "EHLO
	mail-io0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752006AbbH1Apt (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 27 Aug 2015 20:45:49 -0400
Received: by iodv127 with SMTP id v127so76672020iod.3
        for <linux-nfs@vger.kernel.org>; Thu, 27 Aug 2015 17:45:49 -0700 (PDT)
From: Trond Myklebust <trond.myklebust@primarydata.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 1/2] NFSv4.1/flexfiles: Fix a protocol error in layoutreturn
Date: Thu, 27 Aug 2015 20:45:46 -0400
Message-Id: <1440722747-124599-1-git-send-email-trond.myklebust@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

According to the flexfiles protocol, the layoutreturn should specify an
array of errors in the following format:

struct ff_ioerr4 {
	offset4        ffie_offset;
	length4        ffie_length;
	stateid4       ffie_stateid;
	device_error4  ffie_errors<>;
};

This patch fixes up the code to ensure that our ffie_errors is indeed
encoded as an array (albeit with only a single entry).

Reported-by: Tom Haynes <thomas.haynes@primarydata.com>
Cc: stable@vger.kernel.org
Signed-off-by: Trond Myklebust <trond.myklebust@primarydata.com>
---
 fs/nfs/flexfilelayout/flexfilelayoutdev.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayoutdev.c b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
index f13e1969eedd..b28fa4cbea52 100644
--- a/fs/nfs/flexfilelayout/flexfilelayoutdev.c
+++ b/fs/nfs/flexfilelayout/flexfilelayoutdev.c
@@ -500,16 +500,19 @@ int ff_layout_encode_ds_ioerr(struct nfs4_flexfile_layout *flo,
 					   range->offset, range->length))
 			continue;
 		/* offset(8) + length(8) + stateid(NFS4_STATEID_SIZE)
-		 * + deviceid(NFS4_DEVICEID4_SIZE) + status(4) + opnum(4)
+		 * + array length + deviceid(NFS4_DEVICEID4_SIZE)
+		 * + status(4) + opnum(4)
 		 */
 		p = xdr_reserve_space(xdr,
-				24 + NFS4_STATEID_SIZE + NFS4_DEVICEID4_SIZE);
+				28 + NFS4_STATEID_SIZE + NFS4_DEVICEID4_SIZE);
 		if (unlikely(!p))
 			return -ENOBUFS;
 		p = xdr_encode_hyper(p, err->offset);
 		p = xdr_encode_hyper(p, err->length);
 		p = xdr_encode_opaque_fixed(p, &err->stateid,
 					    NFS4_STATEID_SIZE);
+		/* Encode 1 error */
+		*p++ = cpu_to_be32(1);
 		p = xdr_encode_opaque_fixed(p, &err->deviceid,
 					    NFS4_DEVICEID4_SIZE);
 		*p++ = cpu_to_be32(err->status);
-- 
2.4.3

