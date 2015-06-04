Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34924 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019AbbFDQon (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Thu, 4 Jun 2015 12:44:43 -0400
Received: by iesa3 with SMTP id a3so40213727ies.2
        for <linux-nfs@vger.kernel.org>; Thu, 04 Jun 2015 09:44:42 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>
Subject: [PATCH 2/4] nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
Date: Thu,  4 Jun 2015 12:44:27 -0400
Message-Id: <1433436269-12292-3-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com>
References: <1433436269-12292-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec allows for up to NFS4_OPAQUE_LIMIT (1k). While we'll almost
certainly never use that much, these ops are generally the only ones
in the compound so we might as well allow for them to be that large.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index 2826e117e3df..e105b9363f0a 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -139,7 +139,7 @@ static int nfs4_stat_to_errno(int);
 #define encode_setclientid_maxsz \
 				(op_encode_hdr_maxsz + \
 				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
-				XDR_QUADLEN(NFS4_SETCLIENTID_NAMELEN) + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 				1 /* sc_prog */ + \
 				1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
 				1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
@@ -288,7 +288,7 @@ static int nfs4_stat_to_errno(int);
 #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
 				encode_verifier_maxsz + \
 				1 /* co_ownerid.len */ + \
-				XDR_QUADLEN(NFS4_EXCHANGE_ID_LEN) + \
+				XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 				1 /* flags */ + \
 				1 /* spa_how */ + \
 				/* max is SP4_MACH_CRED (for now) */ + \
-- 
2.4.2

