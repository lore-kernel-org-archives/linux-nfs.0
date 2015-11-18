Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f49.google.com ([209.85.220.49]:33805 "EHLO
	mail-pa0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750969AbbKRCje (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 17 Nov 2015 21:39:34 -0500
Received: by padhx2 with SMTP id hx2so28373056pad.1
        for <linux-nfs@vger.kernel.org>; Tue, 17 Nov 2015 18:39:33 -0800 (PST)
Subject: [PATCH v2] NFS4: Cleanup FATTR4_WORD0_FS_LOCATIONS after decoding
 success
To: Trond Myklebust <trond.myklebust@primarydata.com>
References: <564AA29F.7060404@gmail.com>
 <1447751549-1946-1-git-send-email-agruenba@redhat.com>
Cc: Andreas Gruenbacher <agruenba@redhat.com>, linux-nfs@vger.kernel.org,
        kinglongmee@gmail.com
From: Kinglong Mee <kinglongmee@gmail.com>
Message-ID: <564BE4DE.5010405@gmail.com>
Date: Wed, 18 Nov 2015 10:39:26 +0800
MIME-Version: 1.0
In-Reply-To: <1447751549-1946-1-git-send-email-agruenba@redhat.com>
Content-Type: text/plain; charset=windows-1252
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1ca843a2d2 "nfs: Fix GETATTR bitmap verification" has check
the bitmap after decoding success, but decode_attr_fs_locations forgets
cleanup the FATTR4_WORD0_FS_LOCATIONS bits.

decode_getfattr_attrs always return -EIO when meeting FS_LOCATIONS now.

ls: cannot access /mnt/referal: Input/output error
ls: cannot access /mnt/replicas: Input/output error
total 32
drwxr-xr-x. 7 root root 8192 Nov 16 20:36 pnfs
??????????? ? ?    ?       ?            ? referal
??????????? ? ?    ?       ?            ? replicas

v2: clear the bit earlier

Signed-off-by: Andreas Gruenbacher <agruenba@redhat.com>
Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4xdr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dfed4f5..4e44412 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3615,6 +3615,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
+	bitmap[0] &= ~FATTR4_WORD0_FS_LOCATIONS;
 	status = -EIO;
 	/* Ignore borken servers that return unrequested attrs */
 	if (unlikely(res == NULL))
-- 
2.5.0

