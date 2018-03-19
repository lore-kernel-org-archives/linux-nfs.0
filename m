Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail.kmu-office.ch ([178.209.48.109]:45536 "EHLO
        mail.kmu-office.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936677AbeCSWhJ (ORCPT
        <rfc822;linux-nfs@vger.kernel.org>); Mon, 19 Mar 2018 18:37:09 -0400
From: Stefan Agner <stefan@agner.ch>
To: bfields@fieldses.org, jlayton@kernel.org
Cc: linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org,
        Stefan Agner <stefan@agner.ch>
Subject: [PATCH] nfsd: use correct enum type in decode_cb_op_status
Date: Mon, 19 Mar 2018 23:37:05 +0100
Message-Id: <20180319223705.28974-1-stefan@agner.ch>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use enum nfs_cb_opnum4 in decode_cb_op_status. This fixes warnings
seen with clang:
  fs/nfsd/nfs4callback.c:451:36: warning: implicit conversion from
      enumeration type 'enum nfs_cb_opnum4' to different enumeration
      type 'enum nfs_opnum4' [-Wenum-conversion]
        status = decode_cb_op_status(xdr, OP_CB_SEQUENCE, &cb->cb_seq_status);
                 ~~~~~~~~~~~~~~~~~~~      ^~~~~~~~~~~~~~

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
 fs/nfsd/nfs4callback.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4callback.c b/fs/nfsd/nfs4callback.c
index 49b0a9e7ff18..1f04d2a70d25 100644
--- a/fs/nfsd/nfs4callback.c
+++ b/fs/nfsd/nfs4callback.c
@@ -223,8 +223,8 @@ static int nfs_cb_stat_to_errno(int status)
 	return -status;
 }
 
-static int decode_cb_op_status(struct xdr_stream *xdr, enum nfs_opnum4 expected,
-			       int *status)
+static int decode_cb_op_status(struct xdr_stream *xdr,
+			       enum nfs_cb_opnum4 expected, int *status)
 {
 	__be32 *p;
 	u32 op;
-- 
2.16.2

