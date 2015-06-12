Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mailrelay108.isp.belgacom.be ([195.238.20.135]:1917 "EHLO
	mailrelay108.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755222AbbFLQ66 (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Fri, 12 Jun 2015 12:58:58 -0400
From: Fabian Frederick <fabf@skynet.be>
To: linux-kernel@vger.kernel.org
Cc: Julia Lawall <Julia.Lawall@lip6.fr>, Fabian Frederick <fabf@skynet.be>,
        Trond Myklebust <trond.myklebust@primarydata.com>,
        Anna Schumaker <anna.schumaker@netapp.com>, linux-nfs@vger.kernel.org
Subject: [PATCH 1/1 linux-next] pnfs/flexfiles: use swap() in ff_layout_sort_mirrors()
Date: Fri, 12 Jun 2015 18:58:50 +0200
Message-Id: <1434128330-10253-1-git-send-email-fabf@skynet.be>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

Use kernel.h macro definition.

Thanks to Julia Lawall for Coccinelle scripting support.

Signed-off-by: Fabian Frederick <fabf@skynet.be>
---
 fs/nfs/flexfilelayout/flexfilelayout.c | 9 +++------
 1 file changed, 3 insertions(+), 6 deletions(-)

diff --git a/fs/nfs/flexfilelayout/flexfilelayout.c b/fs/nfs/flexfilelayout/flexfilelayout.c
index 7d05089..0f1410c 100644
--- a/fs/nfs/flexfilelayout/flexfilelayout.c
+++ b/fs/nfs/flexfilelayout/flexfilelayout.c
@@ -182,17 +182,14 @@ static void _ff_layout_free_lseg(struct nfs4_ff_layout_segment *fls)
 
 static void ff_layout_sort_mirrors(struct nfs4_ff_layout_segment *fls)
 {
-	struct nfs4_ff_layout_mirror *tmp;
 	int i, j;
 
 	for (i = 0; i < fls->mirror_array_cnt - 1; i++) {
 		for (j = i + 1; j < fls->mirror_array_cnt; j++)
 			if (fls->mirror_array[i]->efficiency <
-			    fls->mirror_array[j]->efficiency) {
-				tmp = fls->mirror_array[i];
-				fls->mirror_array[i] = fls->mirror_array[j];
-				fls->mirror_array[j] = tmp;
-			}
+			    fls->mirror_array[j]->efficiency)
+				swap(fls->mirror_array[i],
+				     fls->mirror_array[j]);
 	}
 }
 
-- 
2.4.2

