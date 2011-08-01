Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:34061 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752243Ab1HATCn (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 15:02:43 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e7.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p71IapVp011357
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 14:36:51 -0400
Received: from d01av01.pok.ibm.com (d01av01.pok.ibm.com [9.56.224.215])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p71J2c5L168348
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 15:02:38 -0400
Received: from d01av01.pok.ibm.com (loopback [127.0.0.1])
	by d01av01.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p71J2XBF000410
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 15:02:34 -0400
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Matthew Treinish <treinish@linux.vnet.ibm.com>
Subject: [PATCH 2/2] mountd: Removed duplicate check from insert_groups
Date: Mon,  1 Aug 2011 15:02:27 -0400
Message-Id: <1312225347-11282-2-git-send-email-treinish@linux.vnet.ibm.com>
In-Reply-To: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com>
References: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Upon further inspection of mountd the duplicate check in insert group is not
needed. It seems that export_read() already filters out duplicates so the
check for duplicates again in insert groups isn't needed.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 utils/mountd/mountd.c |    5 -----
 1 files changed, 0 insertions(+), 5 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index bcf5080..9c27d6c 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -631,11 +631,6 @@ static exportnode *lookup_or_create_elist_entry(exports *elist, nfs_export *exp)
 static void insert_group(struct exportnode *e, char *newname)
 {
 	struct groupnode *g;
-
-	for (g = e->ex_groups; g; g = g->gr_next)
-		if (!strcmp(g->gr_name, newname))
-			return;
-
 	g = xmalloc(sizeof(*g));
 	g->gr_name = xstrdup(newname);
 	g->gr_next = e->ex_groups;
-- 
1.7.4.4

