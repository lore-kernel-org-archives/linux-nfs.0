From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 85/85] nfs41: verify CB_SEQUENCE position in callback compound
Date: Mon, 10 Nov 2008 22:33:23 +0200
Message-ID: <1226349203-10074-1-git-send-email-bhalevy@panasas.com>
References: <4918920E.3030301@panasas.com>
Cc: pnfs@linux-nfs.org, linux-nfs@vger.kernel.org
To: trond.myklebust@fys.uio.no
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from DSL212-235-53-3.bb.netvision.net.il ([212.235.53.3]:53165 "EHLO
	bh-buildlin1.bhalevy.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753418AbYKJUd3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 10 Nov 2008 15:33:29 -0500
In-Reply-To: <4918920E.3030301@panasas.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

CB_SEQUENCE must appear first in the callback compound RPC.
If it is not the first operation NFS4ERR_SEQUENCE_POS must be returned.
If the first operation ni the CB_COMPOUND is not CB_SEQUENCE then
NFS4ERR_OP_NOT_IN_SESSION must be returned.

Signed-off-by: Ricardo Labiaga <ricardo.labiaga@netapp.com>
Signed-off-by: Benny Halevy <bhalevy@panasas.com>
---
 fs/nfs/callback_xdr.c |    8 ++++++++
 1 files changed, 8 insertions(+), 0 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 7b96b09..e0bd42b 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -558,6 +558,14 @@ static __be32 process_op(uint32_t minorversion, int nop,
 		__func__, minorversion, nop, op_nr);
 #if defined(CONFIG_NFS_V4_1)
 	if (minorversion == 1) {
+		if (op_nr == OP_CB_SEQUENCE) {
+			if (nop != 0) {
+				status = htonl(NFS4ERR_SEQUENCE_POS);
+				goto out;
+			}
+		} else if (nop == 0)
+			status = htonl(NFS4ERR_OP_NOT_IN_SESSION);
+
 		switch (op_nr) {
 		case OP_CB_GETATTR:
 		case OP_CB_RECALL:
-- 
1.6.0.2

