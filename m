From: Benny Halevy <bhalevy@panasas.com>
Subject: [RFC 32/39] nfs41: verify CB_SEQUENCE position in callback compound
Date: Fri,  1 May 2009 02:24:38 +0300
Message-ID: <1241133878-1353-1-git-send-email-bhalevy@panasas.com>
References: <49FA3180.5030404@panasas.com>
Cc: Ricardo Labiaga <Ricardo.Labiaga@netapp.com>, pnfs@linux-nfs.org,
	linux-nfs@vger.kernel.org, Benny Halevy <bhalevy@panasas.com>,
	Ricardo Labiaga <ricardo.labiaga@netapp.com>
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from gw-ca.panasas.com ([209.116.51.66]:20641 "EHLO
	laguna.int.panasas.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758876AbZD3XYw (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 30 Apr 2009 19:24:52 -0400
In-Reply-To: <49FA3180.5030404@panasas.com>
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
index 066273c..17cf089 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -548,6 +548,14 @@ static __be32 process_op(uint32_t minorversion, int nop,
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
1.6.2.1

