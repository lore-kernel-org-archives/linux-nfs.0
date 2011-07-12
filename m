Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63393 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753988Ab1GLCrD (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Mon, 11 Jul 2011 22:47:03 -0400
Received: from int-mx09.intmail.prod.int.phx2.redhat.com (int-mx09.intmail.prod.int.phx2.redhat.com [10.5.11.22])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id p6C2l26n031950
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2011 22:47:02 -0400
Received: from localhost (beach.nrt.redhat.com [10.64.200.71])
	by int-mx09.intmail.prod.int.phx2.redhat.com (8.14.4/8.14.4) with ESMTP id p6C2l1Nd021008
	for <linux-nfs@vger.kernel.org>; Mon, 11 Jul 2011 22:47:01 -0400
Date: Tue, 12 Jul 2011 11:47:00 +0900 (JST)
Message-Id: <20110712.114700.814616059257545652.yamato@redhat.com>
To: linux-nfs@vger.kernel.org
Subject: [PATCH] closing fd associated with /proc/fs/nfsd/export_features
From: Masatake YAMATO <yamato@redhat.com>
Content-Type: Text/Plain; charset=us-ascii
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>
MIME-Version: 1.0

A fd associated with /proc/fs/nfsd/export_features opened in get_export_features is 
not closed.


Signed-off-by: Masatake YAMATO <yamato@redhat.com>

diff --git a/support/nfs/exports.c b/support/nfs/exports.c
index c250383..819a18a 100644
--- a/support/nfs/exports.c
+++ b/support/nfs/exports.c
@@ -787,6 +787,7 @@ struct export_features *get_export_features(void)
 	fd = read(fd, buf, 50);
 	if (fd == -1)
 		goto err;
+	close(fd);
 	c = sscanf(buf, "%x %x", &ef.flags, &ef.secinfo_flags);
 	if (c != 2)
 		goto err;
