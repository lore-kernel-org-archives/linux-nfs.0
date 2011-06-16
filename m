Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:34952 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753258Ab1FPPjS (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 16 Jun 2011 11:39:18 -0400
Received: by vxi39 with SMTP id 39so1256271vxi.19
        for <linux-nfs@vger.kernel.org>; Thu, 16 Jun 2011 08:39:17 -0700 (PDT)
From: Benny Halevy <benny@tonian.com>
To: " J. Bruce Fields" <bfields@redhat.com>
Cc: linux-nfs@vger.kernel.org, Benny Halevy <benny@tonian.com>
Subject: [PATCH] NFSD: allow OP_DESTROY_CLIENTID to be only op in COMPOUND
Date: Thu, 16 Jun 2011 11:39:10 -0400
Message-Id: <1308238750-9822-1-git-send-email-benny@tonian.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

>From RFC5661, section 18.50:
   DESTROY_CLIENTID MAY be preceded with a SEQUENCE operation as long as
   the client ID derived from the session ID of SEQUENCE is not the same
   as the client ID to be destroyed.  If the client IDs are the same,
   then the server MUST return NFS4ERR_CLIENTID_BUSY.

(that's not implemented yet)

   If DESTROY_CLIENTID is not prefixed by SEQUENCE, it MUST be the only
   operation in the COMPOUND request (otherwise, the server MUST return
   NFS4ERR_NOT_ONLY_OP).

Signed-off-by: Benny Halevy <benny@tonian.com>
---
 fs/nfsd/nfs4proc.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index 730b6e7..02adcc3 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1773,6 +1773,11 @@ static struct nfsd4_operation nfsd4_ops[] = {
 		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
 		.op_name = "OP_SEQUENCE",
 	},
+	[OP_DESTROY_CLIENTID] = {
+		.op_func = NULL,
+		.op_flags = ALLOWED_WITHOUT_FH | ALLOWED_AS_FIRST_OP,
+		.op_name = "OP_DESTROY_CLIENTID",
+	},
 	[OP_RECLAIM_COMPLETE] = {
 		.op_func = (nfsd4op_func)nfsd4_reclaim_complete,
 		.op_flags = ALLOWED_WITHOUT_FH,
-- 
1.7.4.4

