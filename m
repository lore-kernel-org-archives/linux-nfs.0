Return-Path: <linux-nfs-owner@vger.kernel.org>
Received: from mx3-rdu2.redhat.com ([66.187.233.73]:50242 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1755560AbeEaPz1 (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
        Thu, 31 May 2018 11:55:27 -0400
Received: from smtp.corp.redhat.com (int-mx05.intmail.prod.int.rdu2.redhat.com [10.11.54.5])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by mx1.redhat.com (Postfix) with ESMTPS id 7F326402663A
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:27 +0000 (UTC)
Received: from steved.boston.devel.redhat.com (steved.boston.devel.redhat.com [10.19.60.47])
        by smtp.corp.redhat.com (Postfix) with ESMTP id 598F939DDB
        for <linux-nfs@vger.kernel.org>; Thu, 31 May 2018 15:55:27 +0000 (UTC)
From: Steve Dickson <steved@redhat.com>
To: Linux NFS Mailing list <linux-nfs@vger.kernel.org>
Subject: [PATCH 2/2] Fixed format overflow warnings in mountd and nfsd
Date: Thu, 31 May 2018 11:55:25 -0400
Message-Id: <20180531155525.60495-3-steved@redhat.com>
In-Reply-To: <20180531155525.60495-1-steved@redhat.com>
References: <20180531155525.60495-1-steved@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

From: gabriele balducci <balducci@units.it>

Signed-off-by: Steve Dickson <steved@redhat.com>
---
 utils/mountd/mountd.c | 2 +-
 utils/nfsd/nfsd.c     | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/utils/mountd/mountd.c b/utils/mountd/mountd.c
index 4c68702..086c39b 100644
--- a/utils/mountd/mountd.c
+++ b/utils/mountd/mountd.c
@@ -702,7 +702,7 @@ main(int argc, char **argv)
 	else
 		NFSCTL_TCPUNSET(_rpcprotobits);
 	for (vers = 2; vers <= 4; vers++) {
-		char tag[10];
+		char tag[20];
 		sprintf(tag, "vers%d", vers);
 		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(nfs_version, vers)))
 			NFSCTL_VERSET(nfs_version, vers);
diff --git a/utils/nfsd/nfsd.c b/utils/nfsd/nfsd.c
index 2303a5d..f048631 100644
--- a/utils/nfsd/nfsd.c
+++ b/utils/nfsd/nfsd.c
@@ -98,7 +98,7 @@ main(int argc, char **argv)
 	else
 		NFSCTL_TCPUNSET(protobits);
 	for (i = 2; i <= 4; i++) {
-		char tag[10];
+		char tag[20];
 		sprintf(tag, "vers%d", i);
 		if (conf_get_bool("nfsd", tag, NFSCTL_VERISSET(versbits, i)))
 			NFSCTL_VERSET(versbits, i);
-- 
2.17.0

