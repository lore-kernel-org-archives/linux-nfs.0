Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44848 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755476Ab1CHVc3 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Tue, 8 Mar 2011 16:32:29 -0500
Message-ID: <4D76A06A.4090405@gmail.com>
Date: Tue, 08 Mar 2011 22:32:26 +0100
From: roel <roel.kluin@gmail.com>
To: "J. Bruce Fields" <bfields@fieldses.org>, Neil Brown <neilb@suse.de>,
        linux-nfs@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>,
        LKML <linux-kernel@vger.kernel.org>
Subject: [PATCH] nfsd: wrong index used in inner loop
Content-Type: text/plain; charset=ISO-8859-1
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

Index i was already used in the outer loop

Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
---
 fs/nfsd/nfs4xdr.c |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

Not 100% sure this one is needed but it looks suspicious.

diff --git a/fs/nfsd/nfs4xdr.c b/fs/nfsd/nfs4xdr.c
index 1275b86..615f0a9 100644
--- a/fs/nfsd/nfs4xdr.c
+++ b/fs/nfsd/nfs4xdr.c
@@ -1142,7 +1142,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 
 	u32 dummy;
 	char *machine_name;
-	int i;
+	int i, j;
 	int nr_secflavs;
 
 	READ_BUF(16);
@@ -1215,7 +1215,7 @@ nfsd4_decode_create_session(struct nfsd4_compoundargs *argp,
 			READ_BUF(4);
 			READ32(dummy);
 			READ_BUF(dummy * 4);
-			for (i = 0; i < dummy; ++i)
+			for (j = 0; j < dummy; ++j)
 				READ32(dummy);
 			break;
 		case RPC_AUTH_GSS:
