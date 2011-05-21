Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from daytona.panasas.com ([67.152.220.89]:19802 "EHLO
	daytona.panasas.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754593Ab1EUKeh (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Sat, 21 May 2011 06:34:37 -0400
From: Boaz Harrosh <bharrosh@panasas.com>
To: Benny Halevy <bhalevy@panasas.com>,
        Trond Myklebust <Trond.Myklebust@netapp.com>,
        NFS list <linux-nfs@vger.kernel.org>
Subject: [PATCH 13/13] SQUASHME: dbg Print the full device_id returned
Date: Sat, 21 May 2011 13:34:26 +0300
Message-Id: <1305974066-17583-1-git-send-email-bharrosh@panasas.com>
In-Reply-To: <4DD79273.9030202@panasas.com>
References: <4DD79273.9030202@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Boaz Harrosh <bharrosh@panasas.com>
---
 fs/exofs/export.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/fs/exofs/export.c b/fs/exofs/export.c
index 31e16b4..99768ab 100644
--- a/fs/exofs/export.c
+++ b/fs/exofs/export.c
@@ -312,8 +312,9 @@ int exofs_get_device_info(struct super_block *sb, struct exp_xdr_stream *xdr,
 
 	exp_xdr_encode_opaque_len(start, xdr->p);
 
-	EXOFS_DBGMSG("xdr_bytes=%Zu devno=%lld osdname-%s\n",
-		     exp_xdr_qbytes(xdr->p - start), devno, odi->osdname);
+	EXOFS_DBGMSG("xdr_bytes=%Zu devid=(%llx,%llx) osdname-%s\n",
+		     exp_xdr_qbytes(xdr->p - start), devid->sbid, devno,
+		     odi->osdname);
 	return 0;
 
 err:
-- 
1.7.2.3

