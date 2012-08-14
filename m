Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx2.netapp.com ([216.240.18.37]:31179 "EHLO mx2.netapp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752413Ab2HNT4Z (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Tue, 14 Aug 2012 15:56:25 -0400
From: bjschuma@netapp.com
To: bfields@fieldses.org
Cc: linux-nfs@vger.kernel.org
Subject: [PATCH] NFSD: Swap the struct nfs4_operation getter and setter
Date: Tue, 14 Aug 2012 15:55:08 -0400
Message-Id: <1344974108-24531-1-git-send-email-bjschuma@netapp.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Bryan Schumaker <bjschuma@netapp.com>

stateid_setter should be matched to op_set_currentstateid, rather than
op_get_currentstateid.

Signed-off-by: Bryan Schumaker <bjschuma@netapp.com>
---
 fs/nfsd/nfs4proc.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/fs/nfsd/nfs4proc.c b/fs/nfsd/nfs4proc.c
index c9c1c0a..f2bb0ef 100644
--- a/fs/nfsd/nfs4proc.c
+++ b/fs/nfsd/nfs4proc.c
@@ -1054,8 +1054,8 @@ struct nfsd4_operation {
 	char *op_name;
 	/* Try to get response size before operation */
 	nfsd4op_rsize op_rsize_bop;
-	stateid_setter op_get_currentstateid;
-	stateid_getter op_set_currentstateid;
+	stateid_getter op_get_currentstateid;
+	stateid_setter op_set_currentstateid;
 };
 
 static struct nfsd4_operation nfsd4_ops[];
-- 
1.7.11.4

