Return-Path: linux-nfs-owner@vger.kernel.org
Received: from mx1.redhat.com ([209.132.183.28]:47788 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758855Ab2CITem (ORCPT <rfc822;linux-nfs@vger.kernel.org>);
	Fri, 9 Mar 2012 14:34:42 -0500
Received: from int-mx11.intmail.prod.int.phx2.redhat.com (int-mx11.intmail.prod.int.phx2.redhat.com [10.5.11.24])
	by mx1.redhat.com (8.14.4/8.14.4) with ESMTP id q29JYgBV023991
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=OK)
	for <linux-nfs@vger.kernel.org>; Fri, 9 Mar 2012 14:34:42 -0500
From: Simo Sorce <simo@redhat.com>
To: steved@redhat.com
Cc: linux-nfs@vger.kernel.org, Simo Sorce <simo@redhat.com>
Subject: [PATCH 7/7] Kill SPKM3: Remove mentions of SPKM3 from README
Date: Fri,  9 Mar 2012 14:34:32 -0500
Message-Id: <1331321672-2111-8-git-send-email-simo@redhat.com>
In-Reply-To: <1331321672-2111-1-git-send-email-simo@redhat.com>
References: <1331321672-2111-1-git-send-email-simo@redhat.com>
Sender: linux-nfs-owner@vger.kernel.org
List-ID: <linux-nfs.vger.kernel.org>

---
 README |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/README b/README
index e7588cfd9337257aef27a90471c0c6935e3bc990..5c86808d3628e30c665f87501a1cd465fda5c76d 100644
--- a/README
+++ b/README
@@ -80,7 +80,7 @@ scripts can be written to work correctly.
        and starting the nfsd server is not important.
        idmapd is only needed for NFSv4 support.
        svcgssd is only needed if exportfs NFS filesystem with crypto-
-       security (Kerberos or SPKM3).
+       security (Kerberos).
 
    C/ exportfs -av ; rpc.mountd
        It is important that exportfs be run before mountd so that
@@ -130,7 +130,7 @@ scripts can be written to work correctly.
    B/ gssd ; idmapd
       idmapd should be started before mounting any NFSv4 filesystems.
       gssd should be started before mounting any NFS filesystems
-      securely (with Kerberos of SPKM3).
+      securely (with Kerberos).
 
    C/ statd should be run before any NFSv2 or NFSv3 filesystem is
       mounted with remote locking (i.e. without -o nolock).
-- 
1.7.7.6

