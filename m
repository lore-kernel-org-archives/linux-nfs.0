Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:57626 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751034Ab1HATCv (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 1 Aug 2011 15:02:51 -0400
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p71IfPkh024554
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 14:41:25 -0400
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p71J2lGv083626
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 15:02:48 -0400
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p71J89Uf017737
	for <linux-nfs@vger.kernel.org>; Mon, 1 Aug 2011 13:08:09 -0600
From: Matthew Treinish <treinish@linux.vnet.ibm.com>
To: linux-nfs@vger.kernel.org
Cc: Matthew Treinish <treinish@linux.vnet.ibm.com>
Subject: [PATCH 1/2] mountd: Fixed strcmp usage in in insert groups.
Date: Mon,  1 Aug 2011 15:02:26 -0400
Message-Id: <1312225347-11282-1-git-send-email-treinish@linux.vnet.ibm.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
Content-Type: text/plain
MIME-Version: 1.0

Fixed the usage of strcmp in the duplicate check in insert groups. Fixes an
issue with showmount and other commands that required the group information.

Signed-off-by: Matthew Treinish <treinish@linux.vnet.ibm.com>
---
 utils/mountd/mountd.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 035624c..bcf5080 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -633,7 +633,7 @@ static void insert_group(struct exportnode *e, char *newname)
 	struct groupnode *g;
 
 	for (g = e->ex_groups; g; g = g->gr_next)
-		if (strcmp(g->gr_name, newname))
+		if (!strcmp(g->gr_name, newname))
 			return;
 
 	g = xmalloc(sizeof(*g));
-- 
1.7.4.4

