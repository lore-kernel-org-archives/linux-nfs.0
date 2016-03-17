Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from fieldses.org ([173.255.197.46]:35048 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932508AbcCQSoy (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Thu, 17 Mar 2016 14:44:54 -0400
Date: Thu, 17 Mar 2016 14:44:53 -0400
To: linux-nfs@vger.kernel.org
Subject: [PATCH] nfsd4: fix bad bounds checking
Message-ID: <20160317184453.GB25906@fieldses.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
From: bfields@fieldses.org (J. Bruce Fields)
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: "J. Bruce Fields" <bfields@redhat.com>

A number of spots in the xdr decoding follow a pattern like

	n = be32_to_cpup(p++);
	READ_BUF(n + 4);

where n is a u32.  The only bounds checking is done in READ_BUF itself,
but since it's checking (n + 4), it won't catch cases where n is very
large, (u32)(-4) or higher.  I'm not sure exactly what the consequences
are, but we've seen crashes soon after.

Instead, just break these up into two READ_BUF()s.

Cc: stable@vger.kernel.org
Signed-off-by: J. Bruce Fields <bfields@redhat.com>
---
 fs/nfsd/nfs4xdr.c | 13 ++++++++-----
 1 file changed, 8 insertions(+), 5 deletions(-)

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index d6ef0955a979..1600ec470ce7 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1072,8 +1072,9 @@ nfsd4_decode_rename(struct nfsd4_compoundargs *argp, struct nfsd4_rename *rename
 
 	READ_BUF(4);
 	rename->rn_snamelen = be32_to_cpup(p++);
-	READ_BUF(rename->rn_snamelen + 4);
+	READ_BUF(rename->rn_snamelen);
 	SAVEMEM(rename->rn_sname, rename->rn_snamelen);
+	READ_BUF(4);
 	rename->rn_tnamelen = be32_to_cpup(p++);
 	READ_BUF(rename->rn_tnamelen);
 	SAVEMEM(rename->rn_tname, rename->rn_tnamelen);
@@ -1155,13 +1156,14 @@ nfsd4_decode_setclientid(struct nfsd4_compoundargs *argp, struct nfsd4_setclient
 	READ_BUF(8);
 	setclientid->se_callback_prog = be32_to_cpup(p++);
 	setclientid->se_callback_netid_len = be32_to_cpup(p++);
-
-	READ_BUF(setclientid->se_callback_netid_len + 4);
+	READ_BUF(setclientid->se_callback_netid_len);
 	SAVEMEM(setclientid->se_callback_netid_val, setclientid->se_callback_netid_len);
+	READ_BUF(4);
 	setclientid->se_callback_addr_len = be32_to_cpup(p++);
 
-	READ_BUF(setclientid->se_callback_addr_len + 4);
+	READ_BUF(setclientid->se_callback_addr_len);
 	SAVEMEM(setclientid->se_callback_addr_val, setclientid->se_callback_addr_len);
+	READ_BUF(4);
 	setclientid->se_callback_ident = be32_to_cpup(p++);
 
 	DECODE_TAIL;
@@ -1835,8 +1837,9 @@ nfsd4_decode_compound(struct nfsd4_compoundargs *argp)
 
 	READ_BUF(4);
 	argp->taglen = be32_to_cpup(p++);
-	READ_BUF(argp->taglen + 8);
+	READ_BUF(argp->taglen);
 	SAVEMEM(argp->tag, argp->taglen);
+	READ_BUF(8);
 	argp->minorversion = be32_to_cpup(p++);
 	argp->opcnt = be32_to_cpup(p++);
 	max_reply += 4 + (XDR_QUADLEN(argp->taglen) << 2);
-- 
2.5.0

