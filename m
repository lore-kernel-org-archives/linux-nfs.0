From: Krishna Kumar <krkumar2@in.ibm.com>
Subject: [PATCH 2/4] nfsd: Drop reference in expkey_parse error cases
Date: Mon, 20 Oct 2008 11:44:40 +0530
Message-ID: <20081020061440.17722.70281.sendpatchset@localhost.localdomain>
References: <20081020061428.17722.68145.sendpatchset@localhost.localdomain>
Cc: Krishna Kumar <krkumar2@in.ibm.com>
To: linux-nfs@vger.kernel.org
Return-path: <linux-nfs-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:51110 "EHLO
	e36.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134AbYJTGOq (ORCPT
	<rfc822;linux-nfs@vger.kernel.org>); Mon, 20 Oct 2008 02:14:46 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m9K6EhXA016622
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 02:14:43 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9K6EhbG106152
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 00:14:43 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9K6EgYt032090
	for <linux-nfs@vger.kernel.org>; Mon, 20 Oct 2008 00:14:43 -0600
In-Reply-To: <20081020061428.17722.68145.sendpatchset-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: Krishna Kumar <krkumar2@in.ibm.com>

Drop reference to export key on error. Compile tested.

Signed-off-by: Krishna Kumar <krkumar2@in.ibm.com>
---
 fs/nfsd/export.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff -ruNp linux-2.6.27.org/fs/nfsd/export.c linux-2.6.27.new/fs/nfsd/export.c
--- linux-2.6.27.org/fs/nfsd/export.c	2008-10-20 10:47:18.000000000 +0530
+++ linux-2.6.27.new/fs/nfsd/export.c	2008-10-20 10:48:36.000000000 +0530
@@ -151,8 +151,10 @@ static int expkey_parse(struct cache_det
 
 	/* now we want a pathname, or empty meaning NEGATIVE  */
 	err = -EINVAL;
-	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0)
+	if ((len=qword_get(&mesg, buf, PAGE_SIZE)) < 0) {
+		cache_put(&ek->h, &svc_expkey_cache);
 		goto out;
+	}
 	dprintk("Path seems to be <%s>\n", buf);
 	err = 0;
 	if (len == 0) {
@@ -164,8 +166,10 @@ static int expkey_parse(struct cache_det
 	} else {
 		struct nameidata nd;
 		err = path_lookup(buf, 0, &nd);
-		if (err)
+		if (err) {
+			cache_put(&ek->h, &svc_expkey_cache);
 			goto out;
+		}
 
 		dprintk("Found the path %s\n", buf);
 		key.ek_path = nd.path;
