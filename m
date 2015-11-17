Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57770 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752977AbbKQJMe (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 17 Nov 2015 04:12:34 -0500
From: Andreas Gruenbacher <agruenba@redhat.com>
To: Kinglong Mee <kinglongmee@gmail.com>,
        Trond Myklebust <trond.myklebust@primarydata.com>
Cc: linux-nfs@vger.kernel.org
Subject: Re: [PATCH] NFS4: Cleanup FATTR4_WORD0_FS_LOCATIONS after decoding success
Date: Tue, 17 Nov 2015 10:12:29 +0100
Message-Id: <1447751549-1946-1-git-send-email-agruenba@redhat.com>
References: <564AA29F.7060404@gmail.com>
In-Reply-To: <564AA29F.7060404@gmail.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Kinglong Mee <kinglongmee@gmail.com>

Kinglong,

On Tue, Nov 17, 2015 at 4:44 AM, Kinglong Mee <kinglongmee@gmail.com> wrote:
> Commit 1ca843a2d2 "nfs: Fix GETATTR bitmap verification" has
> check the bitmap after decoding success, but decode_attr_fs_locations
> forgets cleanup the FATTR4_WORD0_FS_LOCATIONS bits.
> 
> decode_getfattr_attrs always return -EIO when meeting FS_LOCATIONS now.
> 
> ls: cannot access /mnt/referal: Input/output error
> ls: cannot access /mnt/replicas: Input/output error
> total 32
> drwxr-xr-x. 7 root root 8192 Nov 16 20:36 pnfs
> ??????????? ? ?    ?       ?            ? referal
> ??????????? ? ?    ?       ?            ? replicas
>
> Signed-off-by: Kinglong Mee <kinglongmee@gmail.com>

this looks like the right kind of fix, I think we can clear the bit earlier in
decode_attr_fs_locations though, as below.

Thanks,
Andreas

---
 fs/nfs/nfs4xdr.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 6779feb..55b4493 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -3637,6 +3637,7 @@ static int decode_attr_fs_locations(struct xdr_stream *xdr, uint32_t *bitmap, st
 	status = 0;
 	if (unlikely(!(bitmap[0] & FATTR4_WORD0_FS_LOCATIONS)))
 		goto out;
+	bitmap[0] &= ~FATTR4_WORD0_FS_LOCATIONS;
 	status = -EIO;
 	/* Ignore borken servers that return unrequested attrs */
 	if (unlikely(res == NULL))
-- 
2.5.0

