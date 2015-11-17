Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36823 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751936AbbKQDou (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 16 Nov 2015 22:44:50 -0500
Received: by pacdm15 with SMTP id dm15so196526859pac.3
        for <linux-nfs@vger.kernel.org>; Mon, 16 Nov 2015 19:44:50 -0800 (PST)
From: Kinglong Mee <kinglongmee@gmail.com>
Subject: [PATCH] NFS4: Cleanup FATTR4_WORD0_FS_LOCATIONS after decoding
 success
To: Trond Myklebust <trond.myklebust@primarydata.com>
Cc: "linux-nfs@vger.kernel.org" <linux-nfs@vger.kernel.org>,
        Andreas Gruenbacher <agruenba@redhat.com>, kinglongmee@gmail.com
Message-ID: <564AA29F.7060404@gmail.com>
Date: Tue, 17 Nov 2015 11:44:31 +0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Commit 1ca843a2d2 "nfs: Fix GETATTR bitmap verification" has
check the bitmap after decoding success, but decode_attr_fs_locations
forgets cleanup the FATTR4_WORD0_FS_LOCATIONS bits.

decode_getfattr_attrs always return -EIO when meeting FS_LOCATIONS now.

# ll /mnt/
ls: cannot access /mnt/referal: Input/output error
ls: cannot access /mnt/replicas: Input/output error
total 32
drwxr-xr-x. 7 root root 8192 Nov 16 20:36 pnfs
??????????? ? ?    ?       ?            ? referal
??????????? ? ?    ?       ?            ? replicas

Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>
---
 fs/nfs/nfs4xdr.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index dfed4f5..f9f9d94 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3671,8 +3671,10 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 		if (unlikely(status != 0))
 			goto out_eio;
 	}
-	if (res->nlocations != 0)
+	if (res->nlocations != 0) {
+		bitmap[0] &= ~FATTR4_WORD0_FS_LOCATIONS;
 		status = NFS_ATTR_FATTR_V4_LOCATIONS;
+	}
 out:
 	dprintk("%s: fs_locations done, error = %d\n", __func__, status);
 	return status;
-- 
2.5.0

