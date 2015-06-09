Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ie0-f174.google.com ([209.85.223.174]:34194 "EHLO
	mail-ie0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932429AbbFIXoP (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 9 Jun 2015 19:44:15 -0400
Received: by iebmu5 with SMTP id mu5so23774428ieb.1
        for <linux-nfs@vger.kernel.org>; Tue, 09 Jun 2015 16:44:14 -0700 (PDT)
From: Jeff Layton <jlayton@poochiereds.net>
To: trond.myklebust@primarydata.com
Cc: linux-nfs@vger.kernel.org,
        Michael Skralivetsky <michael.skralivetsky@primarydata.com>,
        chuck.lever@oracle.com
Subject: [PATCH v3 3/5] nfs: update maxsz values for SETCLIENTID and EXCHANGE_ID
Date: Tue,  9 Jun 2015 19:43:58 -0400
Message-Id: <1433893440-3988-4-git-send-email-jeff.layton@primarydata.com>
In-Reply-To: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
References: <1433893440-3988-1-git-send-email-jeff.layton@primarydata.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The spec allows for up to NFS4_OPAQUE_LIMIT (1k). While we'll almost
certainly never use that much, these ops are generally the only ones
in the compound so we might as well allow for them to be that large.

Also, the existing code didn't add in a word for the opaque length
field for either name string. Fix that while we're in there.

Signed-off-by: Jeff Layton <jeff.layton@primarydata.com>
---
 fs/nfs/nfs4xdr.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/fs/nfs/nfs4xdr.c b/fs/nfs/nfs4xdr.c
index f58e8a979397..a07555d6968c 100644
--- a/fs/nfs/nfs4xdr.c
+++ b/fs/nfs/nfs4xdr.c
@@ -139,7 +139,8 @@ static int nfs4_stat_to_errno(int);
 #define encode_setclientid_maxsz \
 				(op_encode_hdr_maxsz + \
 				XDR_QUADLEN(NFS4_VERIFIER_SIZE) + \
-				XDR_QUADLEN(NFS4_SETCLIENTID_NAMELEN) + \
+				/* client name */ \
+				1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 				1 /* sc_prog */ + \
 				1 + XDR_QUADLEN(RPCBIND_MAXNETIDLEN) + \
 				1 + XDR_QUADLEN(RPCBIND_MAXUADDRLEN) + \
@@ -288,7 +289,8 @@ static int nfs4_stat_to_errno(int);
 #define encode_exchange_id_maxsz (op_encode_hdr_maxsz + \
 				encode_verifier_maxsz + \
 				1 /* co_ownerid.len */ + \
-				XDR_QUADLEN(NFS4_EXCHANGE_ID_LEN) + \
+				/* eia_clientowner */ \
+				1 + XDR_QUADLEN(NFS4_OPAQUE_LIMIT) + \
 				1 /* flags */ + \
 				1 /* spa_how */ + \
 				/* max is SP4_MACH_CRED (for now) */ + \
-- 
2.4.2

