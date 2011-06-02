Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:34817 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752614Ab1FBTHi (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 2 Jun 2011 15:07:38 -0400
From: bjschuma@netapp.com
To: Trond.Myklebust@netapp.com
Cc: linux-nfs@vger.kernel.org, Bryan Schumaker <bjschuma@netapp.com>
Subject: [PATCH] NFS: Fix decode_secinfo_maxsz
Date: Thu,  2 Jun 2011 15:07:35 -0400
Message-Id: <1307041655-17529-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

From: Bryan Schumaker <bjschuma@netapp.com>

I initially did the calculation in bytes, and not words

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfs/nfs4xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index fcf2f33..43ac47d 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -255,7 +255,7 @@ static int nfs4_stat_to_errno(int);
 #define decode_fs_locations_maxsz \
 				(0)
 #define encode_secinfo_maxsz	(op_encode_hdr_maxsz + nfs4_name_maxsz)
-#define decode_secinfo_maxsz	(op_decode_hdr_maxsz + 4 + (NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)))
+#define decode_secinfo_maxsz	(op_decode_hdr_maxsz + 1 + ((NFS_MAX_SECFLAVORS * (16 + GSS_OID_MAX_LEN)) / 4))
 
 #if defined(CONFIG_NFS_V4_1)
 #define NFS4_MAX_MACHINE_NAME_LEN (64)
-- 
1.7.5.2

