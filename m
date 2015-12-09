Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from forward15j.cmail.yandex.net ([5.255.227.179]:54054 "EHLO
	forward15j.cmail.yandex.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750894AbbLIMlf (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Wed, 9 Dec 2015 07:41:35 -0500
Received: from web10j.yandex.ru (web10j.yandex.ru [5.45.198.51])
	by forward15j.cmail.yandex.net (Yandex) with ESMTP id C40CB21194
	for <linux-nfs@vger.kernel.org>; Wed,  9 Dec 2015 15:33:31 +0300 (MSK)
From: Nazarov Sergey <s-nazarov@yandex.ru>
To: linux-nfs@vger.kernel.org
Subject: NFSv4: Possible buffer overflow in security label decode.
MIME-Version: 1.0
Message-Id: <402981449664410@web10j.yandex.ru>
Date: Wed, 09 Dec 2015 15:33:30 +0300
Content-Type: text/plain
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Hi!
Buffer overflow possible in decode_attr_security_label, if given label buffer size is not enough to
store data received from server. This adds additional check for buffer capacity:
---
 fs/nfs/nfs4xdr.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 4e44412..6a6302b 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -4157,7 +4157,9 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 		if (unlikely(!p))
 			goto out_overflow;
 		if (len < NFS4_MAXLABELLEN) {
-			if (label) {
+			if (label && label->label) {
+				if (len > label->len)
+					return -ERANGE;
 				memcpy(label->label, p, len);
 				label->len = len;
 				label->pi = pi;
@@ -4165,9 +4167,11 @@ static int decode_attr_security_label(struct xdr_stream *xdr, uint32_t *bitmap,
 				status = NFS_ATTR_FATTR_V4_SECURITY_LABEL;
 			}
 			bitmap[2] &= ~FATTR4_WORD2_SECURITY_LABEL;
-		} else
+		} else {
 			printk(KERN_WARNING "%s: label too long (%u)!\n",
 					__func__, len);
+			return -EIO;
+		}
 	}
 	if (label && label->label)
 		dprintk("%s: label=%s, len=%d, PI=%d, LFS=%d\n", __func__,
--  
