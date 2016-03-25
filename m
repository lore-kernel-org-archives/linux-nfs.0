Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from michel.telenet-ops.be ([195.130.137.88]:42266 "EHLO
	michel.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751379AbcCYKrP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 25 Mar 2016 06:47:15 -0400
From: Geert Uytterhoeven <geert@linux-m68k.org>
To: Christoph Hellwig <hch@lst.de>, "J. Bruce Fields" <bfields@fieldses.org>,
        Jeff Layton <jlayton@poochiereds.net>
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
Subject: [PATCH] nfds: Fix NFSD_MDS_PR_KEY on 32-bit by adding ULL postfix
Date: Fri, 25 Mar 2016 11:47:11 +0100
Message-Id: <1458902831-24673-1-git-send-email-geert@linux-m68k.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

On 32-bit:

    fs/nfsd/blocklayout.c: In function ‘nfsd4_block_get_device_info_scsi’:
    fs/nfsd/blocklayout.c:337: warning: integer constant is too large for ‘long’ type
    fs/nfsd/blocklayout.c:344: warning: integer constant is too large for ‘long’ type
    fs/nfsd/blocklayout.c: In function ‘nfsd4_scsi_fence_client’:
    fs/nfsd/blocklayout.c:385: warning: integer constant is too large for ‘long’ type

Add the missing "ULL" postfix to 64-bit constant NFSD_MDS_PR_KEY to fix
this.

Fixes: f99d4fbdae6765d0 ("nfsd: add SCSI layout support")
Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>
---
 fs/nfsd/blocklayout.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/nfsd/blocklayout.c b/fs/nfsd/blocklayout.c
index e55b5242614da7a9..31f3df193bdbb47b 100644
--- a/fs/nfsd/blocklayout.c
+++ b/fs/nfsd/blocklayout.c
@@ -290,7 +290,7 @@ out_free_buf:
 	return error;
 }
 
-#define NFSD_MDS_PR_KEY		0x0100000000000000
+#define NFSD_MDS_PR_KEY		0x0100000000000000ULL
 
 /*
  * We use the client ID as a unique key for the reservations.
-- 
1.9.1

