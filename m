Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx2.netapp.com ([216.240.18.37]:64950 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751544Ab0LJGIr (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 10 Dec 2010 01:08:47 -0500
Received: from localhost.localdomain (kozen-lxp.hq.netapp.com [10.58.53.114] (may be forged))
	by smtp1.corp.netapp.com (8.13.1/8.13.1/NTAP-1.6) with ESMTP id oBA68VLk023313
	for <linux-nfs@vger.kernel.org>; Thu, 9 Dec 2010 22:08:46 -0800 (PST)
From: Fred Isaman <iisaman@netapp.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH 09/22] SQUASHME onto "pnfs_submit: cb_layoutrecall": revert pointless reordering
Date: Thu,  9 Dec 2010 20:22:44 -0500
Message-Id: <1291944177-7819-10-git-send-email-iisaman@netapp.com>
In-Reply-To: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
References: <1291944177-7819-1-git-send-email-iisaman@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Signed-off-by: Fred Isaman <iisaman@netapp.com>
---
 fs/nfs/callback_xdr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/fs/nfs/callback_xdr.c b/fs/nfs/callback_xdr.c
index 2e1a33b..3f4889f 100644
--- a/fs/nfs/callback_xdr.c
+++ b/fs/nfs/callback_xdr.c
@@ -641,8 +641,8 @@ preprocess_nfs41_op(int nop, unsigned int op_nr, struct callback_op **op)
 		*op = &callback_ops[op_nr];
 		break;
 
-	case OP_CB_NOTIFY:
 	case OP_CB_NOTIFY_DEVICEID:
+	case OP_CB_NOTIFY:
 	case OP_CB_PUSH_DELEG:
 	case OP_CB_RECALLABLE_OBJ_AVAIL:
 	case OP_CB_WANTS_CANCELLED:
-- 
1.7.2.1

