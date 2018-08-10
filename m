Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:33346 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1727151AbeHJXPs (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Fri, 10 Aug 2018 19:15:48 -0400
Received: from smtp.corp.redhat.com (int-mx03.intmail.prod.int.rdu2.redhat.com [10.11.54.3])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 6F8AB401EF2B
        for <linux-nfs@vger.kernel.org>; Fri, 10 Aug 2018 20:44:21 +0000 (UTC)
From: Scott Mayhew <smayhew@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org
Subject: [nfs-utils PATCH 1/2] nfsd: allow verson 4.0 to be enabled/disabled via nfs.conf
Date: Fri, 10 Aug 2018 16:44:20 -0400
Message-Id: <20180810204421.21882-2-smayhew@redhat.com>
In-Reply-To: <20180810204421.21882-1-smayhew@redhat.com>
References: <20180810204421.21882-1-smayhew@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

The nfs.conf file has a 'vers4.0' parameter, but nfsd doesn't currently
check it.

Signed-off-by: Scott Mayhew <smayhew@redhat.com>
---
 utils/nfsd/nfsd.c | 6 +-----
 1 file changed, 1 insertion(+), 5 deletions(-)

diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index f048631..bd86d11 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -110,11 +110,7 @@ main(int argc, char **argv)
 	/* We assume the kernel will default all minor versions to 'on',
 	 * and allow the config file to disable some.
 	 */
-	if (NFSCTL_VERISSET(versbits, 4)) {
-		NFSCTL_MINORSET(minorversset, 0);
-		NFSCTL_MINORSET(minorvers, 0);
-	}
-	for (i = 1; i <= NFS4_MAXMINOR; i++) {
+	for (i = NFS4_MINMINOR; i <= NFS4_MAXMINOR; i++) {
 		char tag[20];
 		sprintf(tag, "vers4.%d", i);
 		/* The default for minor version support is to let the
-- 
2.14.4
