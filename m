From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 81/85] nfs41: define CB_NOTIFY_DEVICEID as not supported
Date: Mon, 10 Nov 2008 22:32:40 +0200
Message-ID: <1226349160-9940-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53145 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753135AbYKJUcp (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:32:45 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
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
index 9cb0451..b3ccfe8 100644
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
1.6.0.2

