From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 28/39] nfs41: define CB_NOTIFY_DEVICEID as not supported
Date: Fri,  1 May 2009 02:23:55 +0300
Message-ID: <1241133835-1218-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:2022 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758581AbZD3XY1 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:24:27 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>

Need to return NFS4ERR_NOTSUPP for CB_NOTIFY_DEVICEID rather
than NFS4ERR_OP_ILLEGAL.

Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback.h     |    1 +
 fs/nfs/callback_xdr.c |    1 +
 2 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback.h b/fs/nfs/callback.h
index 3d1a324..b2aea14 100644
--- a/fs/nfs/callback.h
+++ b/fs/nfs/callback.h
@@ -30,6 +30,7 @@ enum nfs4_callback_opnum {
 	OP_CB_SEQUENCE      = 11,
 	OP_CB_WANTS_CANCELLED = 12,
 	OP_CB_NOTIFY_LOCK   = 13,
+	OP_CB_NOTIFY_DEVICEID = 14,
 	OP_CB_ILLEGAL = 10044,
 };
 
diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index dd25794..9db88ce 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -394,6 +394,7 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		case OP_CB_SEQUENCE:
 		case OP_CB_WANTS_CANCELLED:
 		case OP_CB_NOTIFY_LOCK:
+		case OP_CB_NOTIFY_DEVICEID:
 			op = &callback_ops[0];
 			status = htonl(NFS4ERR_NOTSUPP);
 			break;
-- 
1.6.2.1

